# Bedtime Routine – LLM-Driven Goodnight (Audiobook)

![Bedtime Routine header](https://raw.githubusercontent.com/mmadalone/HA-Master-Repo/main/images/header/bedtime_routine-header.jpeg)

Fully LLM-orchestrated bedtime wind-down with audiobook playback via Music Assistant. Conversational modes (curated/freeform/both) use multi-turn LLM dialogue on Assist satellites for audiobook selection. Preset mode plays a configured URI directly — no conversation, maximum efficiency.

All modes: stops the TV (three-method shutdown stack), kills lights (except living room lamp), countdown timer, bathroom occupancy guard, then final lamp-off.

> **Companion blueprint:** For Kodi/TV playback instead of audiobooks, see `bedtime_routine_plus.yaml`.

## How It Works

```
Trigger: scheduled time / manual input_boolean
                │
                ▼
┌─────────────────────────────────┐
│ Auto-reset manual trigger        │
│ Presence gate (ANY/ALL sensors)  │──── Nobody home → abort + cleanup
│ Initialize countdown helper      │
│ Activate temporary switches      │
│ Power-cycle speaker reset        │
└──────────────┬──────────────────┘
               │
      ┌────────┴────────┐
      │                  │
   PRESET              CONVERSATIONAL
   MODE                (curated/freeform/both)
      │                  │
      ▼                  ▼
  LLM bedtime        TV shutdown
  announcement       (CEC→script→IR)
  (one-shot TTS)          │
      │              Stop media players
      ▼              Lights OFF (lamp stays)
  TV shutdown             │
  (CEC→script→IR)    LLM bedtime announcement
      │              ┌─── negotiation? ───┐
  Lights OFF         │                    │
  (lamp stays)   satellite            one-shot
      │          conversation         TTS only
  Pause media    (countdown adjust)       │
  (pause→stop        │                   │
   fallback)         └────────┬───────────┘
      │                       │
  Set volume              Re-read countdown
  Play preset URI         Audiobook offer?
  (music_assistant)       ┌─── enabled? ───┐
      │                   │                │
  Settling-in TTS    satellite          skip
  (optional)         conversation
      │              (audiobook
  Fixed countdown     selection)
      │                   │
      │              Goodnight TTS
      │              (conversation.process)
      │                   │
      │              Negotiated countdown
      │                   │
      ▼                   ▼
  Bathroom guard     Bathroom guard
      │                   │
  Final goodnight         │
  TTS (optional)          │
      │                   │
      └────────┬──────────┘
               │
               ▼
     Lamp OFF → Cleanup
     Reset countdown helper
```

## Key Design Decisions

### Three-Method TV Shutdown Stack

The blueprint fires up to three TV shutdown methods in sequence, each gated by configuration checks:

1. **CEC / software** — `media_player.turn_off` on the TV entity. Skipped if no TV entity configured.
2. **Custom script** — `script.turn_on` on a user-provided script entity. Handles complex IR sequences, multi-step power-off, or hardware-specific logic. Skipped if no script configured.
3. **IR remote** — `remote.send_command` with device name and command string (e.g., Broadlink, SmartIR). Has a state guard: skips IR if CEC already reports the TV as off/standby/unavailable. Fail-open: if no CEC entity exists, IR always fires. Skipped if no IR remote configured.

A 2-second delay between CEC and IR lets the state propagate before the guard evaluates. All three methods are independent — configure any combination.

### Preset vs. Conversational Flow Order

The two branches have deliberately different action ordering:

**Preset mode** runs: announcement → TV off → lights off → pause media → play audiobook → settling TTS → countdown → bathroom → goodnight TTS. The audiobook plays early so the user hears content during the countdown.

**Conversational mode** runs: TV off → stop media → lights off → announcement (with negotiation) → audiobook conversation → goodnight TTS → countdown → bathroom. TV and media stop early to eliminate noise before the satellite conversation starts.

### Pause-with-Fallback vs. Direct Stop

Preset mode uses a two-step approach for additional media players: `media_player.media_pause` first (gentler, preserves queue position), then `media_player.media_stop` as fallback for players where pause failed or isn't supported. Both have `continue_on_error: true`.

Conversational mode uses direct `media_player.media_stop` (legacy behavior) — since the satellite conversation is about to start, a clean stop is preferred over preserving queue state.

### Music Assistant Integration

Audiobook playback uses `music_assistant.play_media` with `enqueue: replace`, which restarts the audiobook from the current resume position. The `media_type` input supports auto, audiobook, album, playlist, and track — MA can usually infer type from the URI in preset mode, but explicit typing helps in conversational modes where the LLM passes a title string.

### Shared Infrastructure with Kodi Variant

This blueprint shares the same bedtime infrastructure as `bedtime_routine_plus.yaml` (Kodi variant): presence gate, speaker reset, countdown negotiation, bathroom guard, temporary switch lifecycle, settling-in TTS, final goodnight TTS. The only differences are the media playback layer (Music Assistant vs. Kodi) and the absence of TV sleep timer / sleepy TV detection (since this variant turns the TV off).

## Features

- **Four audiobook modes** — Curated list, freeform (LLM picks via MA), both combined, or preset direct URI play
- **Music Assistant playback** — `music_assistant.play_media` with configurable media type, volume, and enqueue mode
- **Three-method TV shutdown** — CEC, custom script, and IR remote with state guard (configure any combination)
- **LLM-driven audiobook selection** — Multi-turn satellite conversation with curated list and/or freeform requests
- **Countdown negotiation** — LLM adjusts `input_number` helper via exposed script (conversational modes)
- **Presence sensor gate** — ANY/ALL mode with minimum duration, manual trigger bypass
- **Bathroom occupancy guard** — Wait for clear with grace period and max timeout
- **Settling-in contextual TTS** — Optional post-audiobook announcement with sensor context (preset mode)
- **Final goodnight contextual TTS** — Optional pre-lamp-off announcement with sensor context (preset mode)
- **Speaker power-cycle reset** — Smart plug reset clears stale audio connections
- **ElevenLabs voice profile** — Optional `voice_profile` in TTS options (DRY pattern)
- **Dual trigger** — Scheduled time and/or manual `input_boolean` (auto-resets on use)
- **Response type guard** — Prevents LLM error messages from being spoken as TTS
- **Logbook entries** — Key decisions logged (presence gate failure, bathroom timeout)

## Prerequisites

- **Home Assistant 2024.10.0+**
- A **Music Assistant media_player** entity for audiobook playback
- A **conversation agent** (OpenAI, Ollama, Google AI, etc.) — ideally a dedicated bedtime agent
- One or more **Assist satellite** entities (Voice PE or compatible)
- A **TTS engine** entity (ElevenLabs, Piper, etc.)
- A **bathroom occupancy sensor** (`binary_sensor` with `device_class: occupancy`)
- An **`input_number` helper** for countdown minutes (min 1, max 30, step 1)
- Optional: TV entity (CEC), TV off script, IR remote entity, presence sensors, speaker reset switches, temporary switches

## Installation

1. Copy `bedtime_routine.yaml` into your blueprints directory:
   ```
   config/blueprints/automation/<your_namespace>/bedtime_routine.yaml
   ```
   Or import via URL if hosted on GitHub.

2. Create a new automation from the blueprint: **Settings → Automations → Create Automation → Use Blueprint**

3. At minimum, configure: audiobook player, conversation agent, Assist satellites, TTS engine, bathroom sensor, countdown helper, lights-off target, and living room lamp.

## Configuration

### ① Trigger

| Input | Default | Description |
|-------|---------|-------------|
| **Scheduled bedtime** | (empty) | Time trigger — leave empty to disable |
| **Manual trigger boolean** | (empty) | `input_boolean` for voice/UI triggering — auto-resets on use |
| **Presence sensors** | (empty) | Occupancy/presence/motion sensors for gate — empty disables gate |
| **Minimum presence duration** | 0 min | Consecutive minutes sensor must report occupied |
| **Require ALL sensors** | false | ALL vs ANY mode for presence gate |

### ② Devices

| Input | Default | Description |
|-------|---------|-------------|
| **TV media player** | (empty) | CEC-capable TV entity — leave empty to skip CEC shutdown |
| **TV off script** | (empty) | Custom power-off script for complex IR or multi-step shutdown |
| **IR remote entity** | (empty) | Broadlink/SmartIR remote for direct IR power-off |
| **IR power-off command** | "Power" | Command string sent via `remote.send_command` |
| **IR device name** | (empty) | Learned device name in remote (must match exactly) |
| **Lights to turn off** | (required) | Lights/switches killed immediately — supports area/label targeting |
| **Living room lamp** | (required) | Last light — stays on during countdown, off after bathroom guard |
| **Speaker reset switches** | (empty) | Smart plugs to power-cycle before TTS |
| **Speaker reset delay** | 2 sec | Pause between OFF and ON during power-cycle |
| **Media players to stop** | (empty) | Additional players to pause/stop (TV handled separately) |

### ③ AI Conversation

| Input | Default | Description |
|-------|---------|-------------|
| **Conversation agent** | conversation.quark_extended_bedtime | Dedicated bedtime agent |
| **Assist satellites** | (required) | Voice PE / satellite entities |
| **TTS engine** | (required) | Text-to-speech entity |
| **Voice profile** | (empty) | ElevenLabs voice name — empty for default |
| **Default countdown** | 4 min | Minutes before lamp-off (negotiable in conversational modes) |
| **Enable countdown negotiation** | true | Allow LLM to adjust countdown via helper |
| **Enable audiobook offer** | true | Let LLM offer audiobooks (conversational modes) |
| **Bedtime prompt** | (default) | Prompt with `{{ countdown_minutes }}` variable |
| **Goodnight prompt** | (default) | Final goodnight prompt (conversational modes only) |

### ④ Audiobook

| Input | Default | Description |
|-------|---------|-------------|
| **Music Assistant player** | (required) | MA media_player entity for audiobook playback |
| **Audiobook selection mode** | both | curated / freeform / both / preset |
| **Curated audiobook list** | "Hitchhiker's Guide, Dune, The Hobbit" | Comma-separated titles for curated/both modes |
| **Preset audiobook URI** | (empty) | MA content ID for preset mode (library URI, playlist, album) |
| **Audiobook media type** | auto | auto / audiobook / album / playlist / track |
| **Audiobook volume** | 0.25 | Playback volume (0.0–1.0) |

### ⑤ Bathroom Guard & Timing

| Input | Default | Description |
|-------|---------|-------------|
| **Bathroom sensor** | (required) | Occupancy sensor — lamp stays on while occupied |
| **Grace period** | 2 min | Post-clear delay before lamp-off |
| **Max timeout** | 10 min | Maximum wait — lamp off regardless after this |
| **Countdown helper** | (required) | `input_number` entity for negotiated countdown |
| **Temporary switches** | (empty) | Activated during flow, cleaned up on exit |
| **Post-TTS delay** | 5 sec | Buffer after TTS for streaming audio finish |

### ⑥ Settling-In TTS (Preset Mode)

| Input | Default | Description |
|-------|---------|-------------|
| **Enable settling-in TTS** | false | Contextual announcement after audiobook starts |
| **Settling-in prompt** | (default) | Prompt — sensor states auto-injected |
| **Context sensors** | (empty) | Entities injected as `entity_id: state` pairs |

### ⑦ Final Goodnight TTS (Preset Mode)

| Input | Default | Description |
|-------|---------|-------------|
| **Enable final goodnight TTS** | false | Contextual goodnight after bathroom clears |
| **Final goodnight prompt** | (default) | Prompt — sensor states auto-injected |
| **Goodnight sensors** | (empty) | Can differ from settling-in sensors |

## Comparison with Kodi Variant

| Feature | Audiobook (this) | Kodi Plus |
|---------|-----------------|-----------|
| Media backend | Music Assistant | Kodi JSON-RPC |
| TV behavior | Turned OFF | Stays ON (Kodi needs screen) |
| Library pre-fetch | No (MA resolves by name) | Yes (4 JSON-RPC calls) |
| Genre filtering | No (MA handles search) | Yes (excluded/preferred genres) |
| Sleepy TV detection | No | Yes (3 methods) |
| TV sleep timer | No (TV already off) | Yes (CEC or script) |
| TV shutdown methods | CEC + script + IR | Not applicable |
| Content type auto-detect | No | Yes (CHANNEL crash fix) |
| Settling-in TTS | Preset mode only | Both modes |
| Final goodnight TTS | Preset mode only | Both modes |
| Shared infrastructure | Presence gate, speaker reset, countdown negotiation, bathroom guard, temporary switches |

## Technical Notes

- Runs in `mode: single` — no overlapping bedtime runs.
- `trace: stored_traces: 15` for debugging.
- The manual trigger boolean is auto-reset as the very first action — before any condition can abort — ensuring it's always cleaned up regardless of gate failures.
- The presence gate uses `state_attr(sensor, 'last_changed')` for minimum duration checks. Unavailable/unknown sensors are treated as passing (fail-open).
- `continue_on_error: true` on all LLM calls, media playback, and non-critical actions.
- Response type guard (`response_type | default('') != 'error'`) on all LLM response extraction prevents error messages from being spoken as TTS.
- The IR state guard uses fail-open logic: if no CEC entity exists to check state against, IR always fires (can't know if TV is already off without CEC feedback).
- The voice profile is passed via `options.voice_profile` in `tts.speak` — DRY `choose` pattern selecting profile vs. default TTS across all speak calls.
- The audiobook conversation prompt is dynamically built based on mode: curated-only restricts choices to the list, freeform allows anything, both offers the list first with freeform fallback.
- The `extra_system_prompt` on satellite conversations provides the agent with player entity, media type, and volume — enabling the agent to use exposed tool scripts correctly.
- Bathroom guard has three paths: occupied → wait + grace, recently cleared → wait remaining grace, long-cleared → proceed immediately.
- The countdown helper is reset to default on cleanup, ready for the next run.

## Changelog

- **v4.1.1:** Fixed LLM error messages spoken as TTS — added `response_type` guard
- **v4.1.0:** Optional presence sensor gate — skip routine if nobody home (configurable ANY/ALL, min duration, manual trigger bypass)
- **v4.0.1:** Clarified name/description — this is the Audiobook/MA variant
- **v4:** Preset audiobook mode — direct URI play, media pause-with-fallback, settling-in and final-goodnight contextual TTS slots

## Author

**madalone**

## License

See repository for license details.
