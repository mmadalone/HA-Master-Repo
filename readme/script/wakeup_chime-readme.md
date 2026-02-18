# Wake-up chime

![Wake-up chime header](https://raw.githubusercontent.com/mmadalone/HA-Master-Repo/main/images/header/wakeup_chime-header.jpeg)

Plays a simple chime sound on a media player before the system starts yelling. Designed as the gentle first step in a wake-up escalation chain — the polite knock before the door gets kicked in.

## How It Works

```
┌─────────────────────────────┐
│  Script triggered            │
└──────────┬──────────────────┘
           │
           ▼
┌─────────────────────────────┐
│  media_player.play_media     │
│  on target player            │
│  (continue_on_error: true)   │
└─────────────────────────────┘
```

That's it. One action. Ring the bell, move on. The 22nd Rule of Acquisition: *"A wise man can hear profit in the wind."* This script makes sure they hear *something*.

## Key Design Decisions

### Single-action simplicity

This script does exactly one thing: play a chime. No volume control, no queue management, no post-playback logic. The calling automation (typically the escalating wake-up guard) owns all of that context. This keeps the chime script reusable across any scenario that needs an audio nudge — wake-ups, doorbell alerts, timer completions, whatever.

### continue_on_error protection

The media player call runs with `continue_on_error: true`. If the speaker is offline, unpowered, or unreachable, the script exits gracefully instead of crashing the calling automation's entire escalation sequence. A failed chime shouldn't mean you never wake up.

### Generic media_player action

This script uses `media_player.play_media` rather than any platform-specific action (Music Assistant, Alexa, etc.). A chime is a simple audio file — it doesn't need queue management, radio mode, or media resolution. The generic action works on every media player entity in HA, making this script platform-agnostic.

## Features

- **One-shot chime playback** — plays a single audio file on any media player
- **Platform-agnostic** — works with Sonos, Alexa, MA players, Chromecast, or any `media_player` entity
- **Graceful failure** — `continue_on_error` ensures a dead speaker doesn't break the escalation chain
- **Configurable media** — chime file path and media type are inputs, not hardcoded

## Prerequisites

- **Home Assistant** 2024.10.0 or later
- At least one media player entity
- A chime audio file accessible to HA (e.g., `/local/sounds/chime.mp3` in your `www/` folder)

## Installation

Copy `wakeup_chime.yaml` to your HA config directory:

```
config/blueprints/script/madalone/wakeup_chime.yaml
```

Or import via the blueprint import URL if hosted on GitHub.

### Chime file setup

Place your chime audio file in `/config/www/sounds/` so it's accessible at `/local/sounds/chime.mp3`. Any short audio file works — WAV, MP3, OGG. Keep it under 5 seconds for best results in an escalation chain.

## Configuration

### ① Chime settings

| Input | Default | Description |
|-------|---------|-------------|
| Chime media_player | *(required)* | Media player entity that should play the chime. |
| Chime media URL or path | `/local/sounds/chime.mp3` | Path to the chime audio file. Must be accessible to HA. |
| Chime media type | `music` | Media content type — typically `music` or `audio/mp3`. |

## Technical Notes

- **Mode:** `single` — concurrent calls are blocked while the script runs.
- **No volume control** — the script plays at whatever volume the speaker is currently set to. If you need a specific volume, set it in the calling automation before invoking this script.
- **No delay/wait** — the script fires the play command and exits immediately. It does not wait for the chime to finish. The calling automation should add its own delay if it needs to wait before the next escalation step.

## Changelog

- **v1.1.0:** Style guide compliance — `action:` syntax (AP-06), full metadata (`author`, `source_url`, `min_version`), `alias` on action, `continue_on_error`, collapsible input section
- **v1.0.0:** Initial version

## Author

**madalone**

## License

See repository for license details.
