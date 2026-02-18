# Goodnight Routine – Bedtime Negotiator (Music Assistant)

![Header](https://raw.githubusercontent.com/mmadalone/HA-Master-Repo/main/images/header/goodnight_routine_music_assistant-header.jpeg)

Interactive voice-driven goodnight routine with multi-stage negotiation.
Uses `assist_satellite.ask_question` for conversational YES/NO flow on a
Voice PE satellite — perfect for bedtime automation with personality.

## Episode Premise

**"The Bedtime Negotiator"** — *Rick & Quark Series, S02E09*

When the USS Profit's crew refuses to go to sleep on schedule, Quark
reprograms the ship's computer to run a multi-stage "goodnight protocol"
that asks each crew member if they want their devices turned off, their
entertainment systems powered down, and whether they'd like some bedtime
music. Rick hacks the system to add a "free text" mode so he can request
"interdimensional whale songs" — which accidentally summons an actual
interdimensional whale through a subspace rift. Now Quark has to negotiate
the whale's departure fee while the crew tries to sleep through the
hull-shaking cetacean vibrations. Rule of Acquisition #190: "Hear all,
trust nothing — especially a whale that claims it knows a shortcut
through the wormhole."

## Requirements

- **Home Assistant 2024.10.0** or later
- An **assist satellite** entity (ESPHome Voice PE)
- **Music Assistant** integration with at least one configured player
- Optional: `input_text` helpers for AI-refreshed messages
- Optional: IR off scripts for infrared device control

## Installation

Copy `goodnight_routine_music_assistant.yaml` to:

```
config/blueprints/script/madalone/goodnight_routine_music_assistant.yaml
```

Or import via blueprint URL:

```
https://github.com/mmadalone/HA-Master-Repo/blob/main/script/goodnight_routine_music_assistant.yaml
```

## Configuration

### ① Core Settings

| Input | Default | Description |
|-------|---------|-------------|
| Assist Satellite | *(empty)* | Voice PE for questions and announcements |
| TTS entity | *(empty)* | TTS engine for pre/post announcements |
| Speaker for TTS | *(empty)* | Media player for TTS output |
| Voice profile | *(empty)* | ElevenLabs voice profile (optional) |
| Use satellite for pre/post | `true` | Route announcements through satellite |
| Devices to turn off | `{}` | Target entities/areas for Stage 1 |
| IR off scripts | `[]` | Script entities for Stage 2 IR commands |

### ② Pre-Announcement

Optional TTS message before the routine begins. Supports manual text or
AI-driven `input_text` helper with automatic priority fallback.

### ③ Stage 1 – Devices

Asks whether to switch off targeted devices. Question text, YES confirm,
and NO confirm messages are all editable and optionally helper-sourced.

### ④ Stage 2 – IR Devices

Asks whether to run IR off scripts. Same helper/manual pattern as Stage 1.

### ⑤ Stage 3 – Music / Bedtime Story

Asks if you want music or a bedtime story. On YES, branches by music mode:

| Mode | Behaviour |
|------|-----------|
| `preset_single` | Play one fixed media_id immediately |
| `preset_multi` | Ask which of up to 3 labeled presets |
| `from_input_text` | Read media_id from an input_text helper |
| `free_text_name` | Voice search — spoken answer becomes media_id |

### ⑥ Post-Announcement

Optional TTS message after the routine completes. Same helper/manual
pattern as the pre-announcement.

## Technical Notes

- **Mode:** `single` with `max_exceeded: silent`
- **Template safety:** All `states()` calls use `| default('')` guards
- **Action syntax:** Modern `action:` syntax throughout (2024.10+)
- **All action steps** have descriptive `alias:` fields for trace readability
- **Error handling:** `continue_on_error: true` on every external service call
- **Music playback:** Unified single block (deduplicated from original 3× copy)

## Changelog

- **v2.0.0:** Full compliance rebuild — collapsible sections (①–⑥), aliases,
  continue_on_error, states() guards, deduplicated playback, removed dead
  variable, fixed Stage 2→3 coupling bug, metadata + header image
- **v1.0.0:** Original implementation (unversioned)

## Author

**madalone**
