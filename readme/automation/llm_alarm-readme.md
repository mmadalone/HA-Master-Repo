# Wake-Up Alarm – LLM Context

![Wake-up alarm header](https://raw.githubusercontent.com/mmadalone/HA-Master-Repo/main/images/header/llm_alarm-header.jpeg)

A time-based wake-up alarm that fires on selected weekdays, optionally generates a personalized wake-up message via a conversation agent (with live sensor context), speaks it over TTS with ElevenLabs voice profile support, and provides mobile notification controls for one snooze cycle before launching a post-alarm music script.

## How It Works

```
Time trigger (configured wake-up time)
            │
            ▼
    ┌───────────────┐
    │ Weekday check  │──── Not an active day → stop
    └───────┬───────┘
            │
            ▼
    Turn on lights/switches
    Set TTS volume
            │
            ▼
    ┌───────────────────────┐
    │ LLM enabled?           │
    │ Yes → conversation.    │
    │   process with prompt  │
    │   + sensor context     │
    │   + time metadata      │
    │ No → static message    │
    └───────────┬───────────┘
                │
                ▼
    Send mobile notification
    (Snooze / Stop buttons)
                │
                ▼
    TTS: speak wake-up message
                │
                ▼
    ┌─────────────────────────────┐
    │ Wait for Snooze/Stop/timeout │
    ├──────────┬──────────┬───────┤
    │  STOP    │  SNOOZE  │ TIMEOUT│
    │  ↓       │  ↓       │  ↓     │
    │  Stop    │  Delay   │ Start  │
    │  TTS     │  N min   │ music  │
    │  Restore │  ↓       │ script │
    │  volume  │  TTS     │ Restore│
    │  → done  │  again   │ volume │
    │          │  ↓       │ → done │
    │          │  Wait    │        │
    │          │  Stop/   │        │
    │          │  timeout │        │
    │          │  ↓       │        │
    │          │ STOP:    │        │
    │          │ stop TTS │        │
    │          │ TIMEOUT: │        │
    │          │ music    │        │
    └──────────┴──────────┴───────┘
```

The snooze cycle is intentionally limited to one round — after snooze, you either stop or the music starts. No infinite snooze loops.

## Features

- **Weekday scheduling** — Select any combination of days (Mon–Sun). Uses a template condition since HA has no native weekday condition.
- **LLM wake-up message** — Optionally generates a personalized wake-up message via any HA conversation agent. The prompt includes structured metadata (current time in 24h and 12h formats, configured wake-up time, snooze window duration, target word count) and live sensor context from user-selected entities.
- **Static fallback** — If LLM is disabled or the LLM call fails (`continue_on_error` + defensive dict traversal), falls back to a configurable static message.
- **ElevenLabs voice profiles** — Optional `voice_profile` passed in TTS options. Computed once into a `tts_options` variable and reused across all `tts.speak` calls (DRY pattern from v3).
- **Wake-up lights/switches** — Turn on any combination of lights and switches when the alarm fires.
- **Volume management** — Sets TTS volume before the wake-up message and restores it after the flow completes (on every exit path: stop, snooze+stop, snooze+music, timeout+music).
- **Mobile snooze/stop** — Sends a push notification with configurable action IDs for Snooze and Stop buttons. Uses `mobile_app_notification_action` events.
- **Single snooze cycle** — One snooze of configurable duration. After snooze, the message replays once and then either Stop or the music script fires.
- **Post-alarm music** — Calls a configurable script entity when the wake-up flow completes without a stop.

## Prerequisites

- **Home Assistant 2024.6.0+**
- A **TTS engine** entity (ElevenLabs, Google, Piper, etc.)
- A **media_player** for TTS output
- The **HA Companion App** on your mobile device (for snooze/stop notifications)
- A **conversation agent** (OpenAI, Ollama, Google AI, etc.) if using LLM wake-up messages
- A **script entity** for post-alarm music (e.g., a script that starts a playlist)

## Installation

1. Copy `llm_alarm.yaml` into your blueprints directory:
   ```
   config/blueprints/automation/<your_namespace>/llm_alarm.yaml
   ```
   Or import via URL if hosted on GitHub.

2. Create a new automation from the blueprint: **Settings → Automations → Create Automation → Use Blueprint**

3. At minimum, configure the wake-up time, TTS engine, and output player.

## Configuration

### Stage 1 — Schedule

| Input | Default | Description |
|-------|---------|-------------|
| **Active weekdays** | Mon–Fri | Days on which the alarm fires |
| **Wake-up time** | (required) | Time trigger for the alarm |
| **Wake-up lights/switches** | (empty) | Light/switch entities to turn on at alarm time |

### Stage 2 — TTS & Audio

| Input | Default | Description |
|-------|---------|-------------|
| **TTS engine** | (required) | TTS entity for `tts.speak` |
| **TTS output media_player** | (required) | Speaker for the wake-up announcement |
| **TTS volume before** | 0.4 | Volume level set before the message plays |
| **TTS volume after** | 0.4 | Volume level restored after the flow completes |
| **ElevenLabs voice_profile** | (empty) | Optional voice profile string from ElevenLabs dashboard |
| **Static wake-up message** | "good morning, time to get up." | Fallback message when LLM is disabled or fails |

### Stage 3 — LLM Wake-Up Message (collapsed)

| Input | Default | Description |
|-------|---------|-------------|
| **Use LLM for wake-up message** | Off | Toggle LLM message generation |
| **Conversation agent** | (empty) | The HA conversation agent entity |
| **LLM wake-up prompt** | (empty) | Base prompt text — metadata and sensor context are appended automatically |
| **Entities for LLM sensor_context** | (empty) | Extra entities fed as context (temperature, presence, etc.) |

### Stage 4 — Mobile Notifications (collapsed)

| Input | Default | Description |
|-------|---------|-------------|
| **Notify service** | (empty) | `notify.mobile_app_<device>` — leave empty to skip notifications |
| **Mobile Snooze action id** | `GUARD_SNOOZE` | Action ID for the Snooze button |
| **Mobile Stop action id** | `GUARD_STOP` | Action ID for the Stop button |

### Stage 5 — Snooze & Music (collapsed)

| Input | Default | Description |
|-------|---------|-------------|
| **Snooze/Stop listening window** | 40 sec | How long to wait for a mobile action after TTS. Also used to calculate LLM target word count. |
| **Snooze minutes** | 7 min | Duration of the single snooze delay |
| **Wake-up music script** | (empty) | Script entity called when the flow completes without a stop |

## LLM Prompt Structure

The blueprint appends structured metadata to your custom prompt before sending it to the conversation agent:

```
<your custom prompt text>

meta:
- current_time_24h: 07:00
- current_time_12h_plain: 7:00
- configured_wakeup_time: 07:00:00
- snooze_stop_window_seconds: 40
- target_word_count: 80

context:
- wakeup_reason: alarm time reached
- sensor_context: sensor.outdoor_temp (Outdoor Temperature): 12.3 | person.miquel (Miquel): home
```

Behavioral instructions (personality, speech style, name, time format preferences) belong in the conversation agent's system prompt configured in the HA UI, not in this per-call prompt. This follows the v3 separation of concerns: structured per-run data here, persistent behavioral instructions in the agent config.

## Technical Notes

- Runs in `mode: single` / `max_exceeded: silent` — prevents overlapping alarm runs.
- The weekday condition uses a template with `now().weekday()` mapped to `['mon','tue','wed','thu','fri','sat','sun']` because HA has no native weekday condition type.
- `continue_on_error: true` on the `conversation.process` call catches LLM timeouts and crashes. The defensive dict traversal (`res.get('response') or {}` chain) handles unexpected response shapes without crashing.
- TTS options are computed once into a `tts_options` variable and reused at every `tts.speak` call site, avoiding duplicated choose blocks (DRY principle from v3).
- The `target_word_count` in the LLM metadata is calculated as `post_tts_timeout * 2` — roughly 2 words per second of speaking time, giving the LLM a length target that fits the snooze window.
- Volume is restored on every exit path (four distinct restoration points) to prevent the speaker from being stuck at the wake-up volume level.

## Changelog

- **v4:** Collapsible sections (stages 3–5); defaults for `llm_agent` and `music_script`; removed hardcoded name from TTS/notification text; improved `notify_service` description
- **v3:** DRY — single TTS options variable; LLM call passes only structured meta (behavioral instructions belong in agent system prompt); defensive dict traversal on LLM response
- **v2:** Style guide compliance — collapsible input sections, `action:` syntax, header fields, description image
- **v1:** Initial version

## Author

**madalone**

## License

See repository for license details.
