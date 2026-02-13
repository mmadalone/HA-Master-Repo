## Wake-Up Guard System

![Wake-up guard header](https://raw.githubusercontent.com/mmadalone/HA-Master-Repo/main/images/header/wake-up-guard-header.jpg)

### How It Works

```
┌─────────────────────────────────────────────────────────────┐
│                     TRIGGER                                  │
│  Schedule (wake-up-guard) OR External alarm sensor           │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
              ┌────────────────┐
              │ Presence check │
              │ • Bed sensors  │
              │ • Workshop     │
              │   empty?       │
              └───────┬────────┘
                      │ pass
                      ▼
         ┌────────────────────────┐
         │ Turn on lights/switches│
         │ Set TTS volume         │
         │ Generate message       │
         │  (static or LLM)       │
         └───────────┬────────────┘
                     │
                     ▼
         ┌────────────────────────┐
         │ Mobile push + TTS      │──── Mobile handler stops
         │ announcement           │     players instantly
         └───────────┬────────────┘
                     │
           ┌─────────┼──────────┐
           ▼         ▼          ▼
        SNOOZE     STOP     TIMEOUT
           │         │          │
           │         │          ▼
           │         │     Music script
           │         ▼
           │    Clean up &
           │    restore volume
           ▼
     Lights off,
     wait N min,
     repeat TTS
     (2nd snooze = stop)
```

### Features

- **Presence-gated triggering** — Verifies bed presence duration and workshop emptiness before firing. Prevents false triggers if you just sat on the bed or are already up.
- **LLM-generated wake-up messages** — Optionally generates wake-up rants via `conversation.process` with any compatible agent (OpenAI, Google, local LLM). Falls back to static message on failure.
- **ElevenLabs Custom TTS support** — Passes voice profile strings via `options.voice_profile` when using the HACS ElevenLabs custom integration.
- **One snooze, then done** — First snooze darkens the room and pauses. Second snooze press is treated as Stop. No infinite snooze loops.
- **Mobile push with Snooze/Stop** — Companion App actionable notifications with `GUARD_SNOOZE` and `GUARD_STOP` actions.
- **Assist Satellite announcements** — Optional spoken confirmations on satellite devices ("ok, snoozing the wake-up alarm").
- **Music handoff** — If no button is pressed, hands off to a configurable music script.

### Prerequisites

**Helpers:**
- `input_boolean` — Snooze toggle
- `input_boolean` — Stop toggle

**Scripts:**
- `script.wake_guard_tts_speak` — Routes TTS between ElevenLabs Custom and standard engines
- `script.wake_guard_stop_cleanup` — Handles stop playback, satellite announce, volume restore, toggle reset
- A music handoff script of your choice

**Configuration sections:**

| Section | What it controls |
|---------|-----------------|
| ① Schedule & presence | Wake-up time, active weekdays, bed/workshop sensors with duration thresholds |
| ② Lights & switches | Optional devices to turn on at wake-up / off during snooze |
| ③ TTS & voice output | TTS engine, output speaker, volume levels, ElevenLabs voice profile |
| ④ Wake-up message | Static fallback, LLM toggle, conversation agent, LLM prompt |
| ⑤ Snooze/Stop controls | Toggles, music script, timeout window, snooze duration |
| ⑥ Optional integrations | Person name, mobile notify service, Assist Satellite, helper script overrides |

### External Alarm Trigger

Instead of a fixed schedule, this blueprint watches an external alarm sensor (e.g. `sensor.pixel_7_next_alarm` or `sensor.bedroom_echo_next_alarm`) and fires your wake-up script at alarm time minus a configurable offset. Polls every minute and uses template math to match the target window.

### Mobile Snooze/Stop Handler

A companion automation that listens for both Companion App notification actions and `input_boolean` state changes. When triggered, it immediately stops TTS and music players (instant feedback) and sets the appropriate toggle so the main blueprint takes the correct branch. Runs in `mode: restart` so rapid presses always register.

---

#

## License

See repository for license details.

## Installation

### 1. Import Blueprints

Copy the YAML files into your blueprints directory:

```
config/blueprints/automation/<your_namespace>/
├── wake-up-guard.yaml
├── wake_up_guard_external_alarm.yaml
└── wakeup_guard_mobile_notify.yaml
```

Or import via URL if hosted on GitHub.

### 2. Create Helpers

| Helper type | Purpose | Used by |
|-------------|---------|---------|
| `input_boolean` | Wake guard snooze toggle | Wake-Up Guard, Mobile Handler |
| `input_boolean` | Wake guard stop toggle | Wake-Up Guard, Mobile Handler |

### 3. Create Automations

**Settings → Automations → Create Automation → Use Blueprint**

Make sure paired blueprints share the same helper entities:
- **Wake-Up Guard + Mobile Handler** — Same snooze/stop toggles, same TTS and music player entities

## Technical Notes

- All blueprints require **Home Assistant 2024.10.0** or newer.
- Wake-Up Guard runs `mode: single` / `max_exceeded: silent` — no overlapping executions.
- Mobile Handler runs `mode: restart` — rapid presses always register.
- The `notify_service` input in Wake-Up Guard uses a text selector because HA blueprints have no native notify-service selector. Typos will only fail at runtime.

## Author

**madalone**
