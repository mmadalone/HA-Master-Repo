# Alexa Presence-Aware Radio – Music Assistant

![Alexa Presence Radio header](https://raw.githubusercontent.com/mmadalone/HA-Master-Repo/main/images/header/alexa_presence_radio-header.jpeg)

Say a single phrase to any Alexa device in your home. Home Assistant determines which room you're in using presence sensors and plays a configured radio station (or other media) on that room's Music Assistant speaker. One voice command, one Alexa routine, any Echo — HA handles the room detection automatically.

## How It Works

```
 ┌─────────────────────────────────────────────────┐
 │  "Alexa, turn on Radio Klara" (from ANY Echo)   │
 └──────────────────────┬──────────────────────────┘
                        ▼
 ┌──────────────────────────────────────────────────┐
 │  input_boolean.radio_klara → ON                  │
 │  (Alexa sees it as a smart switch)               │
 └──────────────────────┬───────────────────────────┘
                        ▼
 ┌──────────────────────────────────────────────────┐
 │  Auto-reset boolean → OFF (ready for re-trigger) │
 │  Runs BEFORE any condition can abort              │
 └──────────────────────┬───────────────────────────┘
                        ▼
          ┌─────────────────────────┐
          │  Person home gate?      │──── No ──→ STOP
          │  Voice guard active?    │──── Yes ─→ STOP
          └────────────┬────────────┘
                       ▼
 ┌──────────────────────────────────────────────────┐
 │  Scan presence sensors in priority order:        │
 │  1. Primary rooms (sensors ↔ players 1:1)        │
 │  2. Extra zones (sensor → reused speaker)        │
 │  3. Fallback player (if no presence detected)    │
 └──────────────────────┬───────────────────────────┘
                        ▼
          ┌─────────────────────────┐
          │  Target resolved?       │──── No ──→ STOP
          │  Already playing?       │──── Yes ─→ STOP (optional)
          └────────────┬────────────┘
                       ▼
 ┌──────────────────────────────────────────────────┐
 │  Optional: Disable Follow-Me interlock           │
 │  Optional: Stop/pause other configured players   │
 │  Optional: Set volume                            │
 └──────────────────────┬───────────────────────────┘
                        ▼
 ┌──────────────────────────────────────────────────┐
 │  music_assistant.play_media on target speaker    │
 │  (radio mode: player default / always / never)   │
 └──────────────────────┬───────────────────────────┘
                        ▼
 ┌──────────────────────────────────────────────────┐
 │  Post-play verification (3s settle + state check)│
 │  Logbook warning if playback did not start       │
 └──────────────────────┬───────────────────────────┘
                        ▼
 ┌──────────────────────────────────────────────────┐
 │  Optional: Re-enable Follow-Me                   │
 │  (radio now follows user between rooms)          │
 └──────────────────────────────────────────────────┘
```

## Key Design Decisions

### Auto-reset before conditions

The input_boolean is turned OFF as the very first action, before any condition can abort the run. This ensures the boolean is always ready for the next voice command, even if a later condition (person gate, voice guard, no presence) stops execution. Without this, a failed run would leave the boolean ON and block the next trigger (AP-34 compliance).

### Priority-ordered presence detection

Sensors are evaluated in the order configured by the user. The first room with active presence wins. This gives the user deterministic control over room priority — if the living room and bathroom both detect presence, whichever is listed first takes precedence. The minimum presence time filter prevents picking a room you just walked through.

### Extra zones as overflow slots

Rather than forcing all zones into a single multi-select (which would require a second parallel list for speakers), extra zones use individual sensor + player dropdown pairs. This lets the same speaker be selected multiple times across different zones — a common pattern where rooms share audio hardware (e.g., kitchen and pantry both route to the workshop speaker).

### Post-play verification

Instead of masking failures with `continue_on_error: true`, the automation waits 3 seconds for the player to settle, then checks whether playback actually started. A logbook entry is written on failure, giving the user a visible trail for troubleshooting Music Assistant issues.

### Follow-Me interlock

When enabled, the automation temporarily disables Follow-Me before room detection to prevent the two automations from fighting over player control. After playback starts, Follow-Me is re-enabled so the radio stream follows the user as they move between rooms.

## Features

- **Any-Echo voice trigger** — single Alexa routine works from every Echo device in the home
- **Priority-based room detection** — scans presence sensors in user-defined order; first match wins
- **Up to 10 extra zone mappings** — overflow zones with reusable speaker assignments
- **Fallback player** — optional default speaker when no presence is detected
- **Minimum presence time** — configurable dwell filter to avoid transit rooms
- **Music Assistant native playback** — uses `music_assistant.play_media` with queue control (replace, add, play next)
- **Radio mode control** — player default, always-on, or never — all user-configurable
- **Volume override** — optionally set target speaker volume before playback starts
- **Active playback protection** — skip if the target speaker is already playing something
- **Stop/pause other players** — clear or pause other configured speakers before starting
- **Follow-Me interlock** — disable/re-enable Follow-Me automation to prevent player contention
- **Person home gate** — optional check that at least one person is home before playing
- **Voice assistant guard** — block execution while a voice pipeline is active
- **Post-play verification** — 3-second settle check with logbook warning on failure
- **Auto-reset trigger** — input_boolean resets before conditions, always ready for next command

## Prerequisites

- **Home Assistant** 2024.10.0 or later
- **Music Assistant** integration with at least one configured speaker
- **Presence sensors** — Aqara FP2, PIR sensors, or any `binary_sensor` where ON = presence
- **Alexa integration** — Home Assistant Cloud (Nabu Casa) or manual Alexa Smart Home setup
- **input_boolean helper** — one per radio station / media trigger
- **Alexa routine** — one per voice phrase, turning the input_boolean ON

## Installation

1. Copy `alexa_presence_radio.yaml` to your `config/blueprints/automation/madalone/` directory.
2. Reload automations: **Developer Tools → YAML → Reload Automations**.
3. Create a new automation from the blueprint: **Settings → Automations → + Create Automation → Use Blueprint**.
4. Configure the inputs per the sections below.

Alternatively, import via the blueprint URL:
```
https://github.com/mmadalone/HA-Master-Repo/blob/main/automation/alexa_presence_radio.yaml
```


## Inputs Reference

### ① Trigger & Room Mapping

| Input | Type | Default | Description |
|-------|------|---------|-------------|
| **Trigger entity** | `entity` (input_boolean) | — | The input_boolean that fires the automation when turned ON. Create one per station, expose to Alexa via HA Cloud. |
| **Presence sensors** | `entity` (binary_sensor, multi) | `[]` | Presence sensors in priority order — first match wins. Supports Aqara FP2, PIR, mmWave, or any binary_sensor where ON = presence. |
| **Music Assistant players** | `entity` (media_player, multi) | `[]` | MA speakers mapped 1:1 with presence sensors. Order must exactly match the sensor list. |
| **Fallback player** | `entity` (media_player) | none | Speaker used when no presence is detected anywhere. Leave empty to skip playback. |

### ② Additional Zone Mappings

Ten extra zone slots, each with an independent presence sensor and speaker dropdown. Use for zones that share a speaker with another room (e.g., kitchen → workshop speaker). Checked after primary room mappings. Leave unused slots empty.

| Input | Type | Default | Description |
|-------|------|---------|-------------|
| **Extra zone N — Presence sensor** | `entity` (binary_sensor) | none | Binary sensor for the extra zone. |
| **Extra zone N — Music Assistant player** | `entity` (media_player) | none | Target speaker — can reuse a primary room speaker. |

### ③ Media & Playback

| Input | Type | Default | Description |
|-------|------|---------|-------------|
| **Radio station or media** | `text` | `""` | Name or content ID as it appears in Music Assistant library. |
| **Media type** | `select` | `radio` | Options: radio, playlist, album, track, artist. |
| **Enqueue mode** | `select` | `replace` | Replace (clear queue), Add (append), Play next (insert after current). |
| **Radio mode** | `select` | `Use player settings` | Player default, Always (force continuous), or Never (stop when content ends). |

### ④ Volume Settings

| Input | Type | Default | Description |
|-------|------|---------|-------------|
| **Set volume before playback** | `boolean` | `false` | Enable to override speaker volume before playback starts. |
| **Volume level** | `number` (0–100, step 5) | `25` | Target volume percentage. Only applied when volume override is enabled. |

### ⑤ Behaviour & Safety

| Input | Type | Default | Description |
|-------|------|---------|-------------|
| **Auto turn off trigger** | `boolean` | `true` | Resets the input_boolean after playback, ready for the next voice command. |
| **Skip if already playing** | `boolean` | `false` | Prevents interrupting an active session on the target speaker. |
| **Minimum presence time** | `duration` | `0s` | How long a sensor must be continuously ON before the room counts. Filters transit rooms. |
| **Stop other players** | `boolean` | `false` | Stops all other configured MA players before starting playback. |
| **Pause instead of stop** | `boolean` | `false` | Pauses other players (preserving queues) instead of stopping them. |
| **Disable Follow-Me** | `boolean` | `false` | Turns off the Follow-Me toggle when radio starts, re-enables after playback. |
| **Follow-Me toggle entity** | `entity` (input_boolean) | none | The input_boolean controlling your Follow-Me automation. |

### ⑥ Advanced Options

| Input | Type | Default | Description |
|-------|------|---------|-------------|
| **Require person home** | `boolean` | `false` | Only fires when at least one selected person has state "home". |
| **Persons** | `entity` (person, multi) | `[]` | Person entities to check. Empty list with gate enabled = never fires. |
| **Voice assistant guard** | `entity` (input_boolean) | none | Blocks execution while a voice pipeline is active. |

## Companion Blueprints

This blueprint is the **play** half of a voice-controlled radio system. Pair it with:

- **[Alexa Presence Radio Stop](alexa_presence_radio_stop-readme.md)** — The stop companion. Same presence-aware room detection in reverse: says "stop" to the right speaker, or stops all. Uses the same sensor/player index mapping for consistent configuration.
- **[Music Assistant Follow-Me](music_assistant_follow_me_multi_room_advanced-readme.md)** — Once playback starts, Follow-Me transfers the queue when you move between rooms. The Follow-Me interlock feature (§⑤) coordinates the handoff so the two automations don't fight over player control.
- **[Alexa ↔ MA Volume Sync](alexa_ma_volume_sync-readme.md)** — Bidirectional volume sync between paired Echo and MA speakers, so Alexa volume commands affect the MA player and vice versa.

## Version History

**v6** — Post-play verification: removed `continue_on_error: true` from all `music_assistant.play_media` calls, added 3-second settle delay + state check with `logbook.log` warning on playback failure. Explicit `default: ""` on all optional entity inputs (AP-17, AP-44 compliance).

**v5** — Follow-Me interlock: optionally disables Follow-Me toggle during room detection, re-enables after playback starts so radio follows the user between rooms.

**v4** — Folded `trigger_entity` into Stage ① section, de-duplicated zone slot descriptions across 10 extra zone pairs.

**v3** — Renamed input sections to Stage N pattern (① ② ③…), added pause-instead-of-stop option for other players.

**v2** — Added aliases to all action steps, replaced templated data dict with choose block for radio mode, added template safety guards (`| default()` on all `states()` calls), added `author` field.

**v1** — Initial version.

## Technical Notes

- **Mode:** `single` with `max_exceeded: silent` — if the automation is already running (e.g., from a double-tap), the second invocation is silently dropped.
- All `!input` values are resolved into `variables:` at the top of the action sequence, keeping templates readable and avoiding repeated `!input` references deep in action blocks.
- The `extra_pairs` variable uses a Jinja namespace loop to filter out empty zone slots and merge them into the primary sensor/player lists. This avoids 10 separate conditional branches.
- The `detected_index` template uses `loop.index0` with a namespace guard (`ns.idx == -1`) to implement first-match-wins priority logic in a single pass.
- The `states(sensor) | default('unknown')` pattern treats unavailable or unknown sensors as "no presence" rather than raising template errors.
- Volume is divided by 100 in the service call (`volume_level_value | float / 100.0`) because HA's `media_player.volume_set` expects 0.0–1.0, not 0–100.

## Requirements

- Home Assistant 2024.10.0+
- Music Assistant integration with configured media players
- Home Assistant Cloud (Nabu Casa) for Alexa integration, or manual Alexa Smart Home skill
- An `input_boolean` helper per radio station / media trigger
- One Alexa Routine per voice phrase, turning the corresponding boolean ON
- Binary sensor presence detectors (Aqara FP2, mmWave, PIR, etc.)

## Author

**madalone**

## License

See repository for license details.
