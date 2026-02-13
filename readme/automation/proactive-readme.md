# Proactive – Presence-Based Suggestions (Helper-Based)

![Proactive](https://raw.githubusercontent.com/mmadalone/HA-Master-Repo/main/images/header/proactive-header.jpeg)

A Home Assistant automation blueprint that proactively speaks a message via TTS when presence is detected in a room during a configurable time window. Unlike the direct LLM variants, this version reads messages from `input_text` helpers (morning, afternoon, evening) that are pre-filled by a separate AI refresh automation. Includes configurable cooldown, nag-while-present mode, post-run refresh, and an optional bedtime yes/no question via Assist Satellite.

This is the **helper-based** variant — the foundation of the proactive speaker lineage. It decouples message generation from message delivery: a separate automation writes messages into `input_text` helpers (typically using an LLM), and this blueprint reads and speaks them on presence.

## How It Works

```
┌─────────────────────────────────────────┐
│  SEPARATE AUTOMATION (not this blueprint)│
│  Generates messages via LLM / template   │
│  and writes them into input_text helpers │
│  ┌─────────────┐  ┌──────────────┐      │
│  │ morning msg │  │ afternoon msg│  ... │
│  └─────────────┘  └──────────────┘      │
└─────────────────────────────────────────┘
                    │
        ════════════╪═══════════════
                    │  (reads from helpers)
                    ▼
Presence sensor ON (or nag tick / bedtime time)
         │
         ▼
┌──────────────────────────────┐
│  CONDITIONS (all must pass)   │
│  • Within active time window  │
│  • Presence still detected    │
│  • Repeat mode allows tick    │
│  • Cooldown elapsed           │
│  • Max nags not exceeded      │
└──────────────┬───────────────┘
               │ pass
               ▼
┌──────────────────────────────┐
│  SELECT MESSAGE               │
│  • Determine time of day      │
│  • Read matching input_text   │
│  • Use fallback if empty      │
└──────────────┬───────────────┘
               │
               ▼
┌──────────────────────────────┐
│  SPEAK VIA TTS                │
│  Standard tts.speak or        │
│  ElevenLabs custom with       │
│  voice_profile                │
└──────────────┬───────────────┘
               │
               ├──▶ (if refresh enabled + not bedtime)
               │    Press refresh button → triggers
               │    external AI to regenerate messages
               │
               ▼ (if bedtime enabled)
┌──────────────────────────────┐
│  BEDTIME QUESTION             │
│  • Static question text       │
│  • ask_question on satellite  │
│  • YES → run bedtime script   │
│  • NO / timeout → do nothing  │
└──────────────────────────────┘
```

## Features

- **Helper-based messages** — Reads from three `input_text` entities (morning, afternoon, evening) that can be populated by any external automation, LLM-based or otherwise.
- **Post-run refresh** — Optionally presses an `input_button` after speaking to trigger a separate automation that regenerates messages for the next trigger.
- **Configurable cooldown** — Minimum time between messages. Acts as a nag interval when repeat mode is enabled.
- **Repeat / nag while present** — Optionally keeps speaking at the cooldown interval as long as presence stays on, with a configurable max nags per session limit.
- **ElevenLabs Custom TTS support** — Two TTS modes: standard `tts.speak` or ElevenLabs custom with `options.voice_profile`.
- **Bedtime question flow** — After the TTS message, optionally asks a static yes/no bedtime question on an Assist Satellite using `assist_satellite.ask_question`. If you answer yes, a configurable bedtime script runs.
- **Bedtime time trigger** — A dedicated `time` trigger fires at the start of the active window each day, useful for bedtime-only instances.
- **Time-of-day fallbacks** — If an `input_text` helper is empty, unavailable, or unknown, a built-in fallback message is spoken instead.
- **Cross-midnight time windows** — Active window can span midnight (e.g. 23:00 → 02:00).

## Comparison with LLM Variants

| Feature | This blueprint | `proactive_llm` | `proactive_llm_sensors` |
|---------|---------------|-----------------|------------------------|
| Message source | input_text helpers | Direct LLM | Direct LLM |
| Post-run refresh button | ✅ | — | — |
| Bedtime time trigger | ✅ | — | — |
| Nag / cooldown / max sessions | ✅ | ✅ | ✅ |
| ElevenLabs custom TTS | ✅ | ✅ | ✅ |
| Bedtime question flow | ✅ (static text) | ✅ (LLM-generated) | ✅ (LLM-generated) |
| LLM bedtime question | — | ✅ | ✅ |
| Extra sensor context for LLM | — | — | ✅ |
| Weekend overrides | — | — | ✅ |
| User name pools | — | — | ✅ |

Use this blueprint when you want to decouple message generation from delivery — for example, when a separate automation pre-generates messages on a schedule or when you want manual control over what gets spoken.

## Prerequisites

- Three **`input_text`** helpers for morning, afternoon, and evening messages
- One or more **presence/occupancy sensors** (`binary_sensor`)
- A **media player** entity for TTS output
- A **TTS entity** (any HA-supported engine, or ElevenLabs custom via HACS)

**Optional:**
- An **`input_button`** to trigger message refresh after speaking
- A separate automation that listens for the button press and regenerates messages
- An **Assist Satellite** entity for the bedtime question flow
- A **bedtime script** to run when the user answers yes

## Installation

1. Copy `proactive.yaml` into your blueprints directory:
   ```
   config/blueprints/automation/<your_namespace>/proactive.yaml
   ```
   Or import via URL if hosted on GitHub.

2. Create the required `input_text` helpers: **Settings → Helpers → Create Helper → Text**
   - One for morning messages
   - One for afternoon messages
   - One for evening messages

3. Optionally create an `input_button` for the refresh trigger.

4. Create one automation per area: **Settings → Automations → Create Automation → Use Blueprint**

## Configuration

### ① Detection

| Input | Default | Description |
|-------|---------|-------------|
| **Presence sensors** | — | One or more binary sensors indicating presence in this area |
| **Area name** | Workshop | Friendly name used in fallback messages |

### ② TTS Configuration

| Input | Default | Description |
|-------|---------|-------------|
| **Speaker / media player** | — | Media player to speak from in this area |
| **TTS mode** | standard_tts_entity | `standard_tts_entity` or `elevenlabs_custom_service` |
| **TTS entity** | — | TTS entity for `tts.speak` |
| **ElevenLabs voice profile** | — | Voice profile for ElevenLabs custom mode |

### ③ Schedule & Timing

| Input | Default | Description |
|-------|---------|-------------|
| **Active from** | 08:00 | Start of the daily active window |
| **Active until** | 23:00 | End of the daily active window (supports crossing midnight) |
| **Cooldown / nag interval** | 30 min | Minimum time between messages |

### ④ Nagging Behavior

| Input | Default | Description |
|-------|---------|-------------|
| **Keep nagging while present** | Off | Repeat at cooldown interval while presence stays on |
| **Max nags per session** | 0 | Limit per continuous presence session (0 = unlimited) |

### ⑤ Message Sources

| Input | Description |
|-------|-------------|
| **Morning message input_text** | `input_text` entity storing the morning message |
| **Afternoon message input_text** | `input_text` entity storing the afternoon message |
| **Evening message input_text** | `input_text` entity storing the evening/night message |
| **Refresh messages after each run** | Press refresh button after speaking (default: off) |
| **Refresh button** | `input_button` that triggers the AI refresh automation |

### ⑥ Bedtime Question

| Input | Default | Description |
|-------|---------|-------------|
| **Enable bedtime question** | Off | Ask a yes/no question after the TTS message |
| **Delay before question** | 5s | Wait after TTS before asking |
| **Assist Satellite** | — | Satellite entity for `assist_satellite.ask_question` |
| **Bedtime question text** | "Miquel, do you want me to help you go to bed now?" | Static question text |
| **Bedtime script** | — | Script to run when user answers yes |

## Triggers

This blueprint has three trigger types:

- **`presence_on`** — State trigger when any presence sensor transitions OFF → ON.
- **`periodic_tick`** — `time_pattern` firing every minute for repeat nag checks.
- **`bedtime_time`** — `time` trigger at the configured start time each day, useful for bedtime-only instances that should fire at an exact time regardless of presence transitions.

## Technical Notes

- Runs in `mode: single` / `max_exceeded: silent` — prevents overlapping executions.
- When `enable_bedtime_question` is on, the time-of-day label is forced to "evening" so the evening `input_text` is always read.
- The refresh button is only pressed when refresh is enabled AND bedtime mode is off, preventing message regeneration during bedtime routines.
- Unlike the LLM variants, the bedtime question uses static text rather than LLM-generated questions.
- The `assist_satellite.ask_question` call uses `continue_on_error: true` to handle satellite failures gracefully.
- Fallback messages check for empty, `unavailable`, and `unknown` states on the `input_text` helpers.
- Requires **Home Assistant 2024.10.0** or newer.

## Relationship to Other Blueprints

This is the **v4 helper-based** variant — the original proactive speaker design. It evolved into `proactive_llm.yaml` (v5, direct LLM generation) and then `proactive_llm_sensors.yaml` (v7, full-featured with weekend overrides and sensor context). All three share the same core trigger/condition/nag architecture.

## Author

**madalone**

## License

See repository for license details.
