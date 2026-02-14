# PVR Channel Tracker — Kodi Live TV Channel Detection

![PVR Channel Tracker header](https://raw.githubusercontent.com/mmadalone/HA-Master-Repo/main/images/header/pvr_channel_tracker-header.jpeg)

A Home Assistant automation blueprint that detects when Kodi is playing PVR/live TV content and queries the active channel name via the Kodi JSON-RPC API. The resolved channel name is stored in a user-provided `input_text` helper, making it available to template sensors, dashboards, and other automations.

## How It Works

```
Kodi media_player state changes to "playing"
    │
    ▼
┌─────────────────────────────────────┐
│  PVR fingerprint check              │
│  media_season == -1                 │
│  AND media_episode == -1?           │
└──────────┬──────────────┬───────────┘
           │ YES          │ NO
           ▼              ▼
┌──────────────────┐   (ignore — not PVR)
│  kodi.call_method│
│  Player.GetItem  │
│  playerid: 1     │
│  props: [channel]│
└────────┬─────────┘
         ▼
┌──────────────────────────────┐
│  wait_for_trigger            │
│  event: kodi_call_method_    │
│  result (timeout: 5s)        │
└────────┬──────────┬──────────┘
         │ SUCCESS  │ TIMEOUT
         ▼          ▼
┌───────────────┐  (continue — helper
│ Extract       │   unchanged, no crash)
│ channel name  │
│ from result   │
└───────┬───────┘
        ▼
┌──────────────────────────┐
│ Store in input_text      │
│ helper for template      │
│ sensors & dashboards     │
└──────────────────────────┘
```

## Key Design Decisions

### Single automation via `wait_for_trigger`

The `kodi.call_method` action fires a JSON-RPC request to Kodi, but the result arrives asynchronously as a `kodi_call_method_result` event. Rather than using two automations (one to send, one to listen), this blueprint uses `wait_for_trigger` on the result event inline — keeping the entire flow self-contained in a single automation run with a clean trace.

### PVR fingerprint: `media_season == -1` and `media_episode == -1`

Kodi marks PVR/live TV content by setting both season and episode metadata to `-1`. This is a reliable fingerprint that distinguishes live TV from regular video library playback, where these fields are either positive integers or absent.

### Mode: restart

Channel switches should kill any in-progress query from a previous channel. `mode: restart` ensures that rapid channel surfing doesn't stack up stale `wait_for_trigger` blocks — only the most recent channel switch survives.

### PseudoTV compatibility

PseudoTV virtual channels may or may not return a `channel` field via `Player.GetItem` — this depends on how PseudoTV registers its content with Kodi's PVR subsystem. The blueprint handles this gracefully via `continue_on_timeout` and `| default()` guards on the result extraction. Live testing is required to confirm PseudoTV behavior.

## Features

- **Automatic PVR detection** — triggers only when Kodi plays live TV content, ignoring regular video library playback.
- **Channel name resolution** — queries Kodi's JSON-RPC API for the active channel name via `Player.GetItem`.
- **Helper-based storage** — stores the channel name in a configurable `input_text` helper, making it available to template sensors, Lovelace cards, and other automations.
- **Configurable timeout** — the query timeout is exposed as a blueprint input (default 5 seconds) with `continue_on_timeout: true` for resilience.
- **Restart-safe** — `mode: restart` ensures rapid channel switches don't create stale queries.

## Prerequisites

- **Kodi integration** configured in Home Assistant with a working `media_player` entity.
- **PVR backend** configured in Kodi (e.g., TVHeadend, PseudoTV Live, or any PVR addon).
- An `input_text` helper to store the resolved channel name (created as part of this build — see Configuration).
- **Home Assistant 2024.10.0** or newer.

## Installation

1. Copy `pvr_channel_tracker.yaml` into your blueprints directory:
   ```
   config/blueprints/automation/madalone/pvr_channel_tracker.yaml
   ```

2. Ensure the `input_text.madteevee_pvr_channel` helper exists (or create your own — the helper is a blueprint input).

3. Create a new automation from the blueprint: **Settings → Automations → Create Automation → Use Blueprint**.

4. Configure the inputs (see below).

## Configuration

### ① Core Settings

| Input | Default | Description |
|-------|---------|-------------|
| **Kodi media player** | *(required)* | The Kodi `media_player` entity to monitor for PVR content. |
| **PVR channel helper** | *(required)* | An `input_text` entity where the resolved channel name will be stored. |

### ② Timing

| Input | Default | Description |
|-------|---------|-------------|
| **Query timeout** | 5 seconds | How long to wait for the `kodi_call_method_result` event before giving up. Increase if your Kodi instance is slow to respond. |

## Companion: Template Sensor Enrichment

This blueprint is designed to feed the `sensor.madteevee_now_playing` template sensor. When the PVR channel helper is populated, the sensor's state string changes from `"Live TV: <title>"` to `"Live TV: <title> (<channel>)"` and exposes a `pvr_channel` attribute for dashboards and automations.

## Technical Notes

- Runs in `mode: restart` — a new channel switch always cancels any in-progress query from a previous switch.
- The `Player.GetItem` call uses `playerid: 1` (Kodi's video player) and requests the `channel` and `channeltype` properties.
- The `wait_for_trigger` block listens for `kodi_call_method_result` with `result_ok: true` from the target entity. Timeout is configurable with `continue_on_timeout: true` — a timeout does not crash the automation.
- Channel name extraction uses `| default('')` guards throughout to handle missing or malformed results gracefully.
- The `input_text` helper is not cleared when Kodi stops playing — it retains the last known channel until overwritten by a new PVR detection. Downstream template sensors should check the media player's state before using the helper value.

## Changelog

- **v1:** Initial version — PVR fingerprint detection, `Player.GetItem` channel resolution, `input_text` storage.

## Author

**madalone**

## License

See repository for license details.
