# Proactive – Presence-Based Last Call

![Last Call header](https://raw.githubusercontent.com/mmadalone/HA-Master-Repo/main/images/header/bedtime_last_call-header.jpeg)

Speaks a single, AI-generated "last call" message when presence is detected in an area during an allowed time window. Optionally runs an external script after the announcement (e.g., turn off lights, start bedtime routine, queue up audio). No questions, no repeats, no cooldowns — fire once and done.

Designed as a lightweight proactive layer that notices you're still in a room late at night and gives you a gentle nudge. Pairs well with the bedtime routine blueprints as a pre-bedtime trigger.

## How It Works

```
Presence sensor turns ON
         │
         ▼
┌─────────────────────────────┐
│ Condition checks (all must   │
│ pass before actions fire):   │
│                              │
│  ✓ Today is an allowed day   │
│  ✓ Current time within       │
│    active window             │
│    (midnight crossing OK)    │
│  ✓ Media not playing         │
│    (if guard enabled)        │
│  ✓ Minimum presence          │
│    duration met              │
│  ✓ Presence still active     │
│    (not a walk-by)           │
└──────────────┬──────────────┘
               │
               ▼
┌─────────────────────────────┐
│ conversation.process         │
│ Generate one-sentence        │
│ last-call message            │
│ (area + time + sensor        │
│  context injected)           │
│ Fallback on LLM failure      │
└──────────────┬──────────────┘
               │
               ▼
┌─────────────────────────────┐
│ TTS speak                    │
│ (standard or ElevenLabs      │
│  with voice profile)         │
└──────────────┬──────────────┘
               │
               ▼
┌─────────────────────────────┐
│ Follow-up script (optional)  │
│ Post-TTS delay → script.     │
│ turn_on on external script   │
└─────────────────────────────┘
```

## Key Design Decisions

### Single-Fire, No Cooldown

This blueprint runs in `mode: single` with `max_exceeded: silent`. Once triggered, it fires once and won't re-trigger while still running. There's no cooldown timer, no repeat logic, no multi-stage escalation. It's a one-shot nudge — if you want escalation, pair it with the escalating wake-up guard or bedtime routine blueprints.

### Midnight-Crossing Time Window

The schedule condition handles time windows that cross midnight (e.g., 22:00 → 02:00). If the end time is earlier than the start time, the logic uses OR instead of AND: `now >= start OR now <= end`. This is essential for "last call" scenarios where the active window spans late evening into early morning.

### Five-Layer Condition Stack

All five conditions must pass before the automation fires:

1. **Day check** — Today's weekday key (mon-sun) must be in the allowed days list
2. **Time window** — Current time must be within the active window (midnight crossing supported)
3. **Media guard** — If enabled, blocks the announcement when the target media player is playing or buffering
4. **Minimum presence** — If configured, presence must have been continuously detected for at least N seconds (uses `last_changed` on the most recent sensor transition)
5. **Presence still active** — Re-checks that at least one sensor is still ON at condition evaluation time (filters out walk-by triggers where the sensor turned OFF between the trigger and the condition check)

### Context-Rich LLM Prompt

The LLM receives structured context: area name, current timestamp, and optional sensor states (temperature, light levels, media status, etc.) formatted as entity-id/name/state/unit tuples. The prompt enforces a single natural sentence, max 220 characters, no quotation marks. The fallback message uses the area name: "Last call, {area}. Time to wrap it up."

### Follow-Up Script Pattern

Instead of embedding bedtime actions directly, the blueprint fires an external script after the announcement. This keeps the blueprint focused (announce) and delegates behavior (lights, TV, audio) to a separate script that can be shared across automations. A configurable delay between TTS and script execution ensures the speech finishes before actions start.

## Features

- **Presence-triggered** — Any configured binary sensor turning ON fires the automation
- **Time-windowed** — Configurable active window with midnight-crossing support
- **Day filtering** — Per-day control over when the automation runs
- **AI-generated message** — `conversation.process` with area/time/sensor context
- **Media playing guard** — Optional: skip announcement if media player is actively playing
- **Minimum presence duration** — Optional: require N seconds of continuous presence before firing
- **Walk-by filter** — Re-checks presence is still active at condition evaluation time
- **ElevenLabs voice profile** — Optional custom voice via `options.voice_profile`
- **Follow-up script** — Optional external script execution after announcement with configurable delay
- **Static fallback** — Graceful fallback message if LLM fails

## Prerequisites

- **Home Assistant 2024.10.0+**
- One or more **binary sensors** for presence detection (motion, occupancy, presence)
- A **media player** entity for TTS output
- A **TTS engine** entity (ElevenLabs, Piper, Google, etc.)
- A **conversation agent** (OpenAI, Ollama, Google AI, etc.)
- Optional: an external **script** entity for follow-up actions

## Installation

1. Copy `bedtime_last_call.yaml` into your blueprints directory:
   ```
   config/blueprints/automation/<your_namespace>/bedtime_last_call.yaml
   ```
   Or import via URL if hosted on GitHub.

2. Create a new automation from the blueprint: **Settings → Automations → Create Automation → Use Blueprint**

3. At minimum, configure: presence sensors, media player, TTS entity, and conversation agent.

## Configuration

### ① Presence & Area

| Input | Default | Description |
|-------|---------|-------------|
| **Presence sensors** | (required) | Binary sensors — automation triggers when ANY turns ON |
| **Area name** | Living room | Friendly name used in spoken message and LLM context. Dropdown with common rooms + custom value support. |

### ② Schedule

| Input | Default | Description |
|-------|---------|-------------|
| **Active from** | 20:00 | Start of the active time window |
| **Active until** | 01:00 | End of window — can cross midnight |
| **Allowed days** | All days | Per-day enable/disable |

### ③ Speech Output

| Input | Default | Description |
|-------|---------|-------------|
| **Media player** | (required) | Speaker for TTS output |
| **TTS mode** | standard_tts_entity | Standard TTS or ElevenLabs custom service |
| **TTS entity** | (required) | TTS engine entity |
| **ElevenLabs voice profile** | (empty) | Voice name — only used with ElevenLabs mode |

### ④ Safety & Interruption Guards

| Input | Default | Description |
|-------|---------|-------------|
| **Minimum presence duration** | 0 sec | Seconds of continuous presence required before firing (0 = disabled) |
| **Block if media playing** | false | Skip announcement if media player is playing/buffering |

### ⑤ AI Message Generation

| Input | Default | Description |
|-------|---------|-------------|
| **Conversation agent** | (required) | LLM agent for message generation |
| **LLM prompt style** | "ONE short, natural last call sentence..." | Prompt instructions — enforces single sentence, 220 char max |
| **Extra context entities** | (empty) | Sensor states injected into LLM prompt as structured context |

### ⑥ Follow-Up Script

| Input | Default | Description |
|-------|---------|-------------|
| **Enable follow-up script** | false | Run an external script after the announcement |
| **Delay before script** | 5 sec | Post-TTS buffer before script fires |
| **Script to run** | (required if enabled) | External script entity — blueprint doesn't define what it does |

## Usage Patterns

**Standalone nudge** — Configure with living room presence sensors, active 22:00–01:00. No follow-up script. Just a gentle "hey, it's late" message.

**Bedtime pre-trigger** — Enable follow-up script pointing to a script that triggers the bedtime routine. Last call announces, then the bedtime routine starts after the delay.

**Multi-room deployment** — Create multiple automations from the same blueprint, each targeting a different room with appropriate sensors and area name. Each instance runs independently.

## Technical Notes

- `mode: single` with `max_exceeded: silent` — no overlapping runs, no queue, no error on re-trigger.
- The time window condition uses `as_timestamp()` comparisons with conditional logic for midnight crossing.
- The day check converts `now().weekday()` (0–6) to a three-letter string (mon–sun) and checks membership in the allowed days list.
- The minimum presence check uses `expand()` on sensors, filters to state `on`, finds the most recent `last_changed`, and compares elapsed time against the threshold.
- The presence-still-active check is a separate condition that runs after the minimum duration check — covers the edge case where presence was detected long enough but the sensor turned OFF before conditions finished evaluating.
- `continue_on_error: true` on `conversation.process` — LLM failure doesn't block the announcement.
- The sensor context builder uses `expand()` to get entity names and unit_of_measurement attributes, formatted as structured lines for the LLM.
- The LLM prompt appends a hard task instruction after the user-configurable prompt style, ensuring the output stays as a single sentence regardless of prompt customization.

## Changelog

- **v2:** Style guide compliance — collapsible sections, aliases, error handling
- **v1:** Initial version

## Author

**madalone**

## License

See repository for license details.
