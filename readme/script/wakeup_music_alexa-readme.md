# Wake-up music – Alexa

![Wake-up music Alexa header](https://raw.githubusercontent.com/mmadalone/HA-Master-Repo/main/images/header/wakeup_music_alexa-header.jpeg)

A script blueprint that plays wake-up music on an Alexa device using the `alexa_devices` integration's text command interface. Sends two sequential commands: one to set volume, one to start a song or playlist — exactly as if you spoke them to the device.

## How It Works

```
┌──────────────────────────────────┐
│  Script triggered (manual/auto)  │
└──────────────┬───────────────────┘
               │
               ▼
┌──────────────────────────────────┐
│  Send volume text command        │
│  e.g. "set volume to 10"        │
└──────────────┬───────────────────┘
               │
               ▼
┌──────────────────────────────────┐
│  Send song/playlist text command │
│  e.g. "play Mark on the bus by   │
│        the Beastie Boys"         │
└──────────────────────────────────┘
```

## Key Design Decisions

### Text commands over media_player actions

The `alexa_devices` integration provides `send_text_command` which accepts free-form text — the same as speaking to Alexa. This approach was chosen over `media_player.play_media` because it lets you leverage Alexa's natural language parsing for music resolution, and the integration does not expose entity-based targeting for this action (`device_id` is required).

### Free-text selectors

Volume and song inputs use free-text selectors rather than constrained inputs. This is intentional — Alexa text commands are natural language strings, and constraining them to dropdowns or sliders would limit the flexibility that makes this approach useful.

## Features

- **Volume-first sequencing** — sets volume before playback starts, avoiding a jarring blast at full volume.
- **Free-form commands** — any text command Alexa understands works as input, not just music.
- **Single mode** — prevents overlapping runs if triggered rapidly.

## Prerequisites

- Home Assistant 2024.8.0+
- **Alexa Devices** integration (`alexa_devices`) installed and configured with at least one device.

## Installation

Copy `wakeup_music_alexa.yaml` to your `config/blueprints/script/madalone/` directory, or import via the blueprint URL.

## Configuration

### ① Alexa Device & Commands

| Input | Default | Description |
|-------|---------|-------------|
| Alexa device | *(required)* | The Echo / Alexa device to control (device selector filtered to `alexa_devices` integration). |
| Volume command | `"set volume to 10"` | Text command sent to set volume before playback. |
| Song / playlist command | `"play Mark on the bus by the Beastie Boys"` | Text command sent to start music. |

## Technical Notes

- **Mode:** `single` — prevents overlapping runs.
- **device_id targeting:** The `alexa_devices.send_text_command` action requires `device_id` directly in the data payload. This is an integration constraint, not a style guide violation (AP-03 does not apply).
- **No error handling:** The two text commands fire sequentially with no delay or error checking between them. If the volume command fails, the song command still fires. For most wake-up scenarios this is acceptable — if you need retry logic, wrap this script in an automation with error handling.

## Changelog

- **v2 (2026-02-16):** Modernised syntax (`action:` keyword), added aliases to all steps, collapsible input section, header image, `author`/`source_url`/`min_version` metadata.
- **v1:** Initial version using `service:` keyword, flat inputs, no metadata.

## Author

**madalone**

## License

See repository for license details.
