### Voice Media Controls

| Blueprint | File | Purpose |
|-----------|------|---------|
| **Active Media Controls** | `voice_active_media_controls.yaml` | Centralized voice media control dispatcher — priority-based pause, radio stop, and "shut up all" commands invoked by LLM agent wrapper scripts |

---

# Voice Active Media Controls

![Voice Active Media Controls](https://raw.githubusercontent.com/mmadalone/HA-Master-Repo/main/images/header/voice_active_media_controls.jpeg)

A centralized command dispatcher for voice-driven media control. This automation does not listen to voice directly — thin wrapper scripts (created from companion script blueprints) call it with a `command` variable. This pattern keeps all logic in one place while giving the LLM agent clean, single-purpose tools to call.

### Commands

| Command | Behavior |
|---------|----------|
| `pause_active` | Pauses the highest-priority player that is currently `playing` or `paused`. Priority determined by candidates list order. |
| `stop_radio` | Pauses all configured Music Assistant radio players. |
| `shut_up` | Pauses ALL currently playing candidates at once. |

### Architecture

```
LLM Agent (Rick / Quark / etc.)
    │
    ├─→ script.pause_media     ──→ automation.voice_active_media_controls
    │                                 command: "pause_active"
    ├─→ script.stop_radio      ──→ automation.voice_active_media_controls
    │                                 command: "stop_radio"
    └─→ script.shut_up         ──→ automation.voice_active_media_controls
                                      command: "shut_up"
```

### Validation & Notifications

The blueprint runs a validation phase before dispatching commands. If required players aren't configured, it creates persistent notifications to help diagnose setup issues. Notifications can be disabled once stable.

**Configuration sections:**

| Section | What it controls |
|---------|-----------------|
| ① Media players | Priority-ordered candidate list, Music Assistant radio players |
| ② Notifications | Toggle persistent notifications for misconfiguration warnings |

---

## Installation

### 1. Import Blueprints

Copy the YAML files into your blueprints directory:

```
config/blueprints/automation/<your_namespace>/
└── voice_active_media_controls.yaml
```

Or import via URL if hosted on GitHub.

### 2. Create Automations

**Settings → Automations → Create Automation → Use Blueprint**

Make sure paired blueprints share the same helper entities:
- **Duck + Restore** — Same ducking flag, same volume helpers, same player/announcement player configuration
- **Wake-Up Guard + Mobile Handler** — Same snooze/stop toggles, same TTS and music player entities

## Technical Notes

- All blueprints require **Home Assistant 2024.10.0** or newer.
- Active Media Controls runs `mode: restart` — new commands override in-flight ones.

## Author

**madalone**