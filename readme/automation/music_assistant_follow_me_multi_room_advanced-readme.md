# Music Assistant – Follow Me (Multi-Room Advanced)

![Music Assistant Follow Me](https://raw.githubusercontent.com/mmadalone/HA-Master-Repo/main/images/header/music_assistant_follow_me_multi_room_advanced-header.jpeg)

A presence-driven follow-me automation for Music Assistant queues across multiple zones. When you walk into a room, your music follows — transferring the active queue to the speaker in your new location with priority ordering, anti-flicker protection, playback guards, optional TTS announcements, and transfer error recovery.

## How It Works

```
Presence sensor ON (after min hold time)
         │
         ▼
┌────────────────────────────────────┐
│  CONDITIONS                         │
│  • Follow switch ON                 │
│  • Persons home (optional)          │
│  • Cooldown elapsed (optional)      │
│  • Voice assistant not active       │
└──────────────┬─────────────────────┘
               │ pass
               ▼
┌────────────────────────────────────┐
│  RESOLVE TARGET & SOURCE            │
│  • Map sensor → player by index     │
│  • Find first playing/paused player │
│  • Filter by duration (skip TTS)    │
│  • Resolve pre/post TTS speakers    │
└──────────────┬─────────────────────┘
               │
               ▼
┌────────────────────────────────────┐
│  ACTION GATES (all must pass)       │
│  • Music is playing/paused          │
│  • Target ≠ source                  │
│  • Source in allowed list           │
│  • Source not in excluded list       │
│  • Priority anchor allows move      │
│  • Target not already playing       │
└──────────────┬─────────────────────┘
               │ pass
               ▼
┌────────────────────────────────────┐
│  PRE-TRANSFER ANNOUNCEMENT          │
│  (optional script call)             │
└──────────────┬─────────────────────┘
               │
               ▼
┌────────────────────────────────────┐
│  TRANSFER QUEUE                     │
│  music_assistant.transfer_queue     │
│  auto_play: true if playing         │
│  auto_play: false if paused         │
│  (continue_on_error)                │
└──────────────┬─────────────────────┘
               │
         ┌─────┴─────┐
         │           │
      SUCCESS     FAILURE
         │           │
         ▼           ▼
┌──────────────┐  ┌──────────────────┐
│ Stamp cooldown│  │ Announce failure  │
│ Silence others│  │ (optional script  │
│ Post-announce │  │  with context)    │
└──────────────┘  └──────────────────┘
```

## Features

- **Index-paired architecture** — Presence sensors, MA players, pre-transfer TTS speakers, and post-transfer TTS speakers are configured as parallel lists. The automation maps trigger sensor → target player → announcement speakers by index position.
- **Priority ordering** — Sensor list order defines zone priority (index 0 = highest). With priority anchor enabled, music won't move from a higher-priority zone to a lower one while the higher zone still has presence.
- **Anti-flicker** — Configurable minimum presence hold time before triggering. Prevents rapid sensor on/off cycles from bouncing music around.
- **TTS duration filter** — Ignores playback shorter than a configurable threshold (default 20s), preventing short TTS clips from being treated as music sessions. Streams with unknown duration can optionally be included.
- **Paused music following** — Optionally transfers paused sessions too, keeping them paused on the target player for manual resume.
- **Target playback protection** — Skips transfer if the target player is already playing, preventing session hijacking.
- **Source whitelists and blacklists** — Restrict which players can act as transfer sources. Useful for excluding TV players or limiting follow-me to specific speakers.
- **Exclusive room mode** — Optionally stops all non-target players after a successful transfer, ensuring only one room plays at a time.
- **Pre and post-transfer announcements** — Call external scripts before and/or after the transfer, passing target, source, and TTS speaker as variables. Scripts can use LLM agents for dynamic announcements.
- **Transfer error recovery** — `continue_on_error` prevents MA failures from crashing the automation. Failed transfers can trigger announcement scripts with failure context so the user hears a human-friendly error instead of silence.
- **Person gate** — Optionally restrict follow-me to when specific persons are home.
- **Voice assistant guard** — Block follow-me while a voice assistant is actively speaking (via helper toggle).
- **Cooldown** — Configurable minimum time between successful transfers using an `input_datetime` helper.

## Prerequisites

- **Music Assistant** integration with `music_assistant.transfer_queue` support
- One or more **presence/occupancy sensors** (`binary_sensor`) — one per zone
- One **Music Assistant media player** per zone
- A **global follow switch** (`input_boolean`)

**Optional:**
- **TTS speakers** for pre/post transfer announcements (separate from MA players)
- **Announcement scripts** for TTS (can be LLM-driven)
- An **`input_datetime`** helper for cooldown tracking
- A **voice assistant guard** helper (`input_boolean`)
- **Person entities** for the person gate

## Installation

1. Copy `music_assistant_follow_me_multi_room_advanced.yaml` into your blueprints directory:
   ```
   config/blueprints/automation/<your_namespace>/music_assistant_follow_me_multi_room_advanced.yaml
   ```
   Or import via URL if hosted on GitHub.

2. Create the required helpers:
   - `input_boolean` for the follow switch
   - `input_datetime` for cooldown tracking (optional, must have both date and time)

3. Create a new automation from the blueprint: **Settings → Automations → Create Automation → Use Blueprint**

## Configuration

### ① Core Setup

| Input | Description |
|-------|-------------|
| **Follow music toggle** | Global on/off switch for follow-me |
| **Presence sensors** | Binary sensors per zone, ordered by priority (first = highest) |
| **Music Assistant players** | MA media_player entities, same order as sensors |
| **TTS pre-transfer players** | Hardware speakers for pre-transfer announcements, same order as sensors |
| **TTS post-transfer players** | Hardware speakers for post-transfer announcements, same order as sensors |

The four lists must be in the same order. Index 0 in the presence list corresponds to index 0 in the player list, the pre-TTS list, and the post-TTS list.

### ② Persons Gate

| Input | Default | Description |
|-------|---------|-------------|
| **Require persons to be home** | Off | Only run when selected persons are home |
| **Persons** | — | Person entities to check |

### ③ Playback Filters

| Input | Default | Description |
|-------|---------|-------------|
| **Only follow when playing** | On | Require active playback before transferring |
| **Follow paused music** | Off | Include paused sessions as transfer candidates |
| **Min media duration** | 20s | Ignore playback shorter than this (filters TTS) |
| **Treat unknown duration as music** | On | Count duration-0 streams as music |
| **Protect target playback** | On | Skip transfer if target is already playing |
| **Allowed source players** | — | Whitelist of eligible source players |
| **Excluded source players** | — | Blacklist of players that must never be sources |
| **Silence other players** | Off | Stop all non-target players after transfer |

### ④ Priority & Timing

| Input | Default | Description |
|-------|---------|-------------|
| **Enforce priority anchor** | Off | Block low→high priority downgrades while source zone active |
| **Min presence on time** | 0s | Hold time before sensor triggers follow-me |
| **Delay before transfer** | 0s | Wait between pre-announcement and transfer |
| **Cooldown** | 0s | Minimum time between successful transfers |
| **Cooldown helper** | — | `input_datetime` storing last transfer timestamp |

### ⑤ Announcements

| Input | Default | Description |
|-------|---------|-------------|
| **Pre-transfer announcement** | Off | Call script before transferring |
| **Pre-transfer script** | — | Script entity receiving target/source/tts_output_player |
| **Post-transfer announcement** | On | Call script after transferring |
| **Post-transfer script** | — | Script entity receiving target/source/tts_output_player |
| **Announce transfer failures** | On | Call post script with failure context on errors |

### ⑥ Safety

| Input | Description |
|-------|-------------|
| **Voice assistant guard** | Helper that blocks follow-me while voice assistant is active |

## Source Player Resolution

The automation finds the music source by scanning all configured MA players in list order and selecting the first one in a `playing`, `paused`, or `buffering` state whose `media_duration` passes the duration filter. This means if multiple players are active, the first one in the list (highest priority) is chosen as the source.

The duration filter works as follows: if `media_duration` is greater than 0 and meets the minimum threshold, it qualifies. If `media_duration` is 0 (streams, unknown), it qualifies only when `treat_unknown_duration_as_music` is enabled.

## Transfer Logic

The `music_assistant.transfer_queue` call uses `auto_play: true` when music is actively playing, and `auto_play: false` when the source is paused or idle. This preserves the play/pause state across rooms.

After the transfer, a 1-second settling delay lets MA propagate state. The automation then checks whether the target player is now in `playing`, `paused`, or `buffering` state. If not, the transfer is considered failed, and the failure announcement path runs (if configured).

## Announcement Script Interface

Both pre and post-transfer scripts receive these variables:

| Variable | Description |
|----------|-------------|
| `target_player` | MA player entity the queue was transferred to |
| `source_player` | MA player entity the queue came from |
| `tts_output_player` | Hardware speaker to use for TTS output |

On failure, the post-transfer script additionally receives:

| Variable | Description |
|----------|-------------|
| `transfer_failed` | `true` |
| `failure_reason` | Human-readable error description |

## Technical Notes

- Runs in `mode: restart` / `max_exceeded: silent` — if a new presence trigger fires while a transfer is in progress, the automation restarts. This ensures rapid room changes don't queue up stale transfers.
- All `music_assistant.transfer_queue` calls use `continue_on_error: true` to prevent MA failures from crashing the automation.
- The cooldown helper uses `input_datetime.set_datetime` with ISO format timestamps.
- The exclusive-room silencer only stops players in `playing` or `buffering` states — paused sessions are preserved.
- Priority anchor logic: moving from lower priority (higher index) to higher priority (lower index) is always allowed. Moving from higher to lower priority is blocked while the source zone still has presence.
- Requires **Home Assistant 2024.10.0** or newer.
- Requires **Music Assistant** integration with `transfer_queue` support.

## Acknowledgments

The concept of presence-based music following has been explored by the HA community in various forms: Phil Hawthorne's [Sonos group/ungroup approach](https://philhawthorne.com/making-music-follow-you-around-the-home-with-home-assistant-and-sonos/) (2018), the [Spotifynd](https://community.home-assistant.io/t/spotifynd-spotify-music-that-automatically-follows-you-as-you-move-around-your-home/240237) Node-RED project (2020, Spotify only), fixtSE's [ESPresense blueprints](https://fixtse.com/blog/espresense-music-follow) (2023, BLE-based), and the [Music Assistant docs](https://www.home-assistant.io/integrations/music_assistant/) which include a basic 3-line `transfer_queue` example. This blueprint builds on the general concept with a comprehensive feature set not found in any existing implementation: priority ordering, source whitelists/blacklists, TTS duration filtering, announcement script hooks, transfer error recovery, exclusive-room silencing, and voice assistant guards.

## Author

**madalone**

## License

See repository for license details.
