# Alexa Presence-Aware Radio – Music Assistant

![Header](https://raw.githubusercontent.com/mmadalone/HA-Master-Repo/main/images/header/alexa_presence_radio-header.jpeg)

A blueprint that plays radio (or any media) on the Music Assistant speaker in your current room using a single voice command to any Alexa device. Say "Radio Klara" to any Echo in the house, and Home Assistant uses presence sensors to determine which room you're in and plays the station on that room's speaker.

## How It Works

The blueprint bridges Alexa to Music Assistant through an `input_boolean` helper exposed to Alexa Cloud. An Alexa Routine maps your voice phrase to turning the boolean ON. This automation triggers on that state change, scans presence sensors in priority order, resolves the first room with active presence, and plays the configured media on that room's Music Assistant speaker via `music_assistant.play_media`.

The flow is: voice command → Alexa Routine → `input_boolean` ON → auto-reset boolean → scan presence sensors (primary rooms first, then extra zones) → resolve target player (or fallback) → optional stop/pause other players → optional volume set → play media → optional Follow-Me re-enable.

## Key Design Decisions

### Priority-Ordered Presence Detection

Presence sensors are checked in list order, and the first sensor that's ON wins. This is the priority system: if you're detected in both the living room and the hallway (because you just walked through), the room listed first takes precedence. This replaces complex "most recent" or "longest occupied" logic with a simple, predictable ordering that the user controls directly.

### Minimum Presence Duration

The `min_presence_time` input adds a duration requirement before a room counts as valid. The blueprint checks each sensor's `last_changed` attribute and computes elapsed time. A sensor that just turned ON 5 seconds ago won't qualify if the minimum is set to 30 seconds. This filters out walk-through rooms and prevents the "it picked the hallway because I triggered the sensor on my way to the living room" problem.

The duration computation handles the HA `duration` selector format, converting hours/minutes/seconds to total seconds via `h * 3600 + m * 60 + s`. A value of 0 disables the check entirely for instant detection.

### Extra Zone Slots (10 Individual Dropdowns)

The blueprint provides 10 additional zone mapping slots, each with its own sensor/player dropdown pair. This is intentionally not a list — it uses individual entity selectors so the same speaker can be reused across multiple zones (e.g., kitchen → workshop speaker, pantry → workshop speaker). A list selector would prevent selecting the same entity twice.

Extra zones are checked after primary room mappings. The `extra_pairs` variable filters out empty slots (both sensor and player must be set) and merges the valid ones with the primary lists into unified `presence_list` and `player_list` arrays.

### Reset-First Ordering

The auto-reset of the trigger boolean happens before any condition that could abort the automation. This is the same pattern used in the companion stop blueprint — if person gating, voice guard, or target resolution fails, the boolean is already OFF and ready for the next voice command. Without this, any abort condition would leave the boolean stuck ON.

### Follow-Me Interlock

The `disable_follow_me` option temporarily turns off the Follow-Me automation toggle when the radio dispatcher fires, then re-enables it after playback starts. This prevents a race condition: without the interlock, the Follow-Me automation might detect the new playback and immediately try to transfer it to a different room based on its own presence logic, fighting the dispatcher for player control.

The sequence is: disable Follow-Me → start playback → re-enable Follow-Me. Once re-enabled, Follow-Me picks up the active player and will transfer the queue if you move rooms — which is the desired behavior after the initial room selection.

### Fallback Player

When no presence sensor reports ON (or none meets the minimum duration), the blueprint falls back to a configurable default player rather than doing nothing. This handles the "sensors are asleep" or "I'm in a room without a sensor" case. If no fallback is configured either, the automation aborts cleanly after the boolean reset.

### Active Playback Protection

The `protect_active_playback` option prevents the blueprint from interrupting a speaker that's already playing something. If you're listening to an audiobook on the bedroom speaker and trigger the radio, the blueprint will skip that speaker and the next room in priority order will be checked — or the fallback will be used. This prevents the "I was listening to something and the radio stomped on it" scenario.

### Other Player Management

The `stop_other_players` option stops (or pauses, via `pause_instead_of_stop`) all other configured Music Assistant players before starting playback on the detected room's speaker. The `other_players` variable deduplicates the player list using `| unique` and excludes the target player, so a player that appears in multiple zone mappings is only stopped once.

## Setup

The setup follows the same three-step Alexa bridge pattern as the companion stop blueprint:

**1. Create an input_boolean helper** — Name it after your station (e.g., "Radio Klara") to create `input_boolean.radio_klara`.

**2. Expose to Alexa** — Settings → Home Assistant Cloud → Alexa → enable the toggle.

**3. Create one Alexa Routine** — When = Voice → "Radio Klara", From = All devices, Action = Smart Home → toggle ON the helper.

For multiple stations, create one blueprint instance per station, each with its own `input_boolean` and Alexa Routine.

## Blueprint Inputs

**Stage 1 — Trigger & Room Mapping** — The trigger boolean, presence sensors in priority order, matching Music Assistant players, and optional fallback player.

**Stage 2 — Additional Zone Mappings** (collapsed) — Up to 10 extra sensor/player pairs for zones that share speakers with other rooms.

**Stage 3 — Media & Playback** — The media ID (station name as it appears in Music Assistant library), media type (radio/playlist/album/track/artist), enqueue mode (replace/add/next), and radio mode (player settings/always/never).

**Stage 4 — Volume Settings** (collapsed) — Optional volume override before playback starts (0–100%).

**Stage 5 — Behaviour & Safety** (collapsed) — Auto-reset trigger, active playback protection, minimum presence time, stop/pause other players, and Follow-Me interlock with toggle entity.

**Stage 6 — Advanced Options** (collapsed) — Person-home gating (requires at least one configured person to be home), voice assistant guard entity (blocks automation while a voice pipeline is active).

## Condition and Action Sequence

1. **Auto-reset trigger** — Boolean OFF before any condition can abort.
2. **Person home gate** (optional) — At least one configured person must be `home`.
3. **Voice assistant guard** (optional) — Blocks if the guard boolean is ON.
4. **Target resolved** — A target player must have been found (presence or fallback).
5. **Active playback check** (optional) — Target must not already be playing/buffering.
6. **Disable Follow-Me** (optional) — Turn off Follow-Me toggle.
7. **Stop/pause other players** (optional) — Clear other rooms.
8. **Set volume** (optional) — Override target speaker volume.
9. **Play media** — Three-branch choose for radio mode (Always/Never/player default).
10. **Re-enable Follow-Me** (optional) — Turn Follow-Me back on so radio follows the user.

## Template Logic

The `detected_index` variable iterates through the merged `presence_list` using a `namespace` pattern. For each sensor that's ON, it checks the minimum presence duration by comparing `last_changed` against `now().timestamp()`. The `| default('unknown')` on `states()` and `| default(0)` on timestamp conversion prevent template errors for unavailable entities.

The `extra_pairs` variable builds merged sensor/player lists from the 10 individual slots, filtering out any slot where either sensor or player is empty. This uses a `namespace` with list concatenation rather than dictionary mutation.

The `other_players` template uses `| unique` to deduplicate (since the same player can appear in multiple zone mappings) and `| reject('eq', target_player)` to exclude the target.

## Companion Blueprints

This blueprint is the play half of a voice-controlled radio system. The **Alexa Presence-Aware Radio Stop** blueprint provides the stop half, using the same sensor/player index mapping for presence-aware stopping. The **Music Assistant Follow-Me** blueprint handles queue transfer when you move between rooms after playback starts. The **Alexa ↔ Music Assistant Volume Sync** blueprint keeps Echo and MA speaker volumes in sync.

## Version History

**v5** — Added optional Follow-Me interlock: disables Follow-Me during room detection, re-enables after playback starts so radio follows the user.

**v4** — Folded trigger_entity into Stage 1, de-duplicated zone slot descriptions.

**v3** — Renamed input sections to Stage N pattern, added pause-instead-of-stop option for other players.

**v2** — Added aliases to all actions, replaced templated data dict with choose block, added template safety guards, added author field.

**v1** — Initial version.

## Technical Notes

- Mode: `single` with `max_exceeded: silent` — duplicate triggers during processing are silently dropped.
- The `music_assistant.play_media` action uses a three-branch `choose` for radio mode rather than a templated `data:` dict. This avoids the HA limitation where template-rendered data dictionaries can produce unexpected types for boolean fields.
- The volume level is divided by 100 (`volume_level_value | float / 100.0`) because the UI input is 0–100% but `media_player.volume_set` expects 0.0–1.0.
- The person gate checks `persons_list | select('is_state', 'home') | list | length > 0` rather than iterating, and returns `false` if the list is empty when the requirement is enabled (fail-closed).
- The voice assistant guard uses `| default('off')` on `states()` to treat missing entities as "not active" rather than erroring.
- Extra zone inputs use individual `default:` (empty) selectors rather than a list, because HA's multi-entity selector doesn't allow selecting the same entity twice — which is required when multiple zones share a speaker.

## Requirements

- Home Assistant 2024.10.0+
- Music Assistant integration with configured media players and radio stations in the library
- Home Assistant Cloud (Nabu Casa) for Alexa integration, or manual Alexa Smart Home skill
- An `input_boolean` helper per station, exposed to Alexa
- One Alexa Routine per station
- Presence sensors (Aqara FP2, mmWave, PIR, or any `binary_sensor` where ON = occupied)
- For Follow-Me interlock: the Follow-Me blueprint and its control `input_boolean`

## Author

**madalone**

## License

See repository for license details.
