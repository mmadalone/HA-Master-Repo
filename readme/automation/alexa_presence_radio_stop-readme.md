# Alexa Presence-Aware Radio Stop – Music Assistant

![Header](https://raw.githubusercontent.com/mmadalone/HA-Master-Repo/main/images/header/alexa_presence_radio_stop-header.jpeg)

A blueprint that stops Music Assistant radio playback from any Alexa device in your home using a single voice command. Say "stop the music" to any Echo and Home Assistant stops all configured players, or — with presence-aware mode enabled — only the player in the room where you currently are.

## How It Works

The blueprint bridges Alexa voice commands to Home Assistant via an `input_boolean` helper exposed to Alexa Cloud. An Alexa Routine maps your stop phrase ("stop the music", "shut up", "silence", etc.) to turning the boolean ON. This automation triggers on that state change and stops the configured Music Assistant players.

The flow is: voice command → Alexa Routine → `input_boolean` ON → this automation fires → stop/pause players → auto-reset boolean to OFF → ready for next command.

### Two Stop Modes

**Stop All** (default) — Every configured Music Assistant player is stopped regardless of where you are. Simple, reliable, nuclear option.

**Presence-Aware** — The automation checks your presence sensors (mapped 1:1 with the player list) and stops only the player in the room where presence is detected. If no presence is found anywhere, it falls back to stopping all players as a safety net.

## Key Design Decisions

### Reset-First Ordering

The auto-reset of the trigger boolean happens *before* the stop/pause action, not after. This is deliberate — if the `media_player.media_stop` call fails or times out, the boolean is already OFF and ready for the next voice command. Without this ordering, a failed stop could leave the boolean stuck ON, requiring manual intervention before the next command would work.

### 1:1 Sensor-Player Index Mapping

Presence sensors and players are matched by list position: first sensor maps to first player, second to second, and so on. This is the same mapping pattern used by the companion play blueprint (`alexa_presence_radio.yaml`), so both blueprints share identical sensor/player ordering. If the play blueprint uses duplicate players for multi-zone mapping, the same duplicated order must be replicated here.

### Namespace Index Detection

The `detected_index` variable uses a Jinja2 `namespace` to find the first presence sensor that's ON, iterating through the list and locking on the first match (`ns.idx == -1` guard prevents overwriting). The result feeds into `stop_targets`, which either returns the single matched player or falls back to the full player list if no match is found or presence mode is disabled.

### Fallback to All Players

When presence-aware mode is enabled but no sensor reports `on`, the blueprint stops all players rather than doing nothing. This prevents the "I said stop and nothing happened" scenario — if the presence sensors are misbehaving or you're in a room without a sensor, the music still stops.

### Pause vs. Stop

The `also_pause_instead_of_stop` option switches the action from `media_player.media_stop` to `media_player.media_pause`. This preserves the Music Assistant queue so playback can be resumed later — useful if you just need silence for a phone call rather than ending the listening session entirely.

### Companion Boolean Reset

The `turn_off_radio_booleans` option resets the input_boolean helpers used by the companion radio dispatch blueprints. When you stop the music, the dispatch triggers that started playback are also reset, keeping the entire radio system's state clean. Without this, the play booleans would remain ON after a stop, potentially causing confusion on the next trigger.

## Setup

The setup has three parts, all documented in the blueprint description:

**1. Create an input_boolean helper** — Settings → Devices & Services → Helpers → Toggle. Name it something like "Stop Radio" to create `input_boolean.stop_radio`.

**2. Expose to Alexa** — Settings → Home Assistant Cloud → Alexa → find the toggle → enable it.

**3. Create one Alexa Routine** — In the Alexa app: When = Voice → your stop phrase, From = All devices, Action = Smart Home → toggle ON the helper.

For presence-aware mode, configure presence sensors in the same order as your player list, and enable the "Presence-aware stop" toggle.

## Blueprint Inputs

**① Trigger** — The `input_boolean` entity that fires the automation when Alexa turns it ON.

**② Player Selection** — The Music Assistant `media_player` entities that can be stopped. In stop-all mode, every player in this list is stopped. In presence-aware mode, only the matched player is stopped.

**③ Stop Mode** — Toggle between stop-all and presence-aware behavior. When presence-aware is enabled, map your `binary_sensor` presence sensors 1:1 with the player list.

**④ Behaviour** (collapsed) — Auto-reset trigger (recommended ON), pause-instead-of-stop mode, and companion radio boolean reset with configurable boolean list.

## Template Logic

The blueprint computes stop targets entirely in the `variables:` block before actions execute:

`detected_index` iterates through presence sensors using a `namespace` pattern, finding the first sensor with state `on`. The `| default('off')` guard on `states()` prevents errors if a sensor entity is unavailable.

`stop_targets` is a conditional template: if presence mode is enabled and both lists are non-empty, it uses the detected index to pick a single player (with bounds checking via `idx >= 0 and idx < player_list | length`). If the index is out of range or presence mode is disabled, it returns the full player list.

The `| int(-1)` guard on `detected_index` ensures the value is always a valid integer, even if the template evaluates to an unexpected type.

## Error Resilience

All `media_player` and `input_boolean` service calls use `continue_on_error: true`. This prevents a single unavailable player from blocking the entire action sequence — if one player fails to stop, the rest still get stopped, and the boolean reset still happens.

The `default: []` on the auto-reset `choose` block provides an explicit no-op path when auto-reset is disabled, avoiding implicit fallthrough behavior.

The empty `player_list` guard in `stop_targets` (added in v5) prevents template errors when the player list selector returns an empty list.

## Companion Blueprints

This blueprint is designed as the stop companion to the **Alexa Presence-Aware Radio** play blueprint. Together they form a complete voice-controlled radio system: one blueprint starts playback (with presence-aware room targeting), this one stops it (with the same presence logic). Both use the same sensor/player index mapping, so configuration stays consistent.

## Version History

**v5** — Empty `player_list` guard in `stop_targets` template (AP-16), `>` → `>-` on variable templates (§3.7 style compliance), explicit `default: []` on auto-reset choose.

**v4** — Template hardening and error resilience: `| int(-1)` guard on `detected_index`, trigger `id:` added, all inputs resolved in `variables:` block, `continue_on_error` on service calls, `===` section dividers.

**v3** — Template safety with `| default()` on `states()`, §3.2 section naming/dividers, explicit `conditions: []`.

## Technical Notes

- Mode: `single` with `max_exceeded: silent` — if two stop commands arrive simultaneously, the second is silently dropped rather than queued.
- The trigger uses `id: trigger_boolean_on` for trace readability.
- All inputs are resolved into variables at the top of the action sequence, keeping templates readable and avoiding repeated `!input` references in action blocks.
- The `conditions: []` block is explicitly empty rather than omitted, making it clear that the automation always runs when triggered (no conditional gating).
- The `states(sensor) | default('off')` pattern in `detected_index` returns `'off'` for unavailable or unknown entities, treating sensor failures as "no presence" rather than errors.

## Requirements

- Home Assistant 2024.10.0+
- Music Assistant integration with configured media players
- Home Assistant Cloud (Nabu Casa) for Alexa integration, or manual Alexa Smart Home skill
- An `input_boolean` helper exposed to Alexa
- One Alexa Routine mapping your stop phrase to the boolean
- For presence-aware mode: binary_sensor presence sensors (Aqara FP2, mmWave, PIR, etc.)

## Author

**madalone**

## License

See repository for license details.
