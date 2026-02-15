# Voice — Play bedtime audiobook (Music Assistant)

![Voice — Play bedtime audiobook](https://raw.githubusercontent.com/mmadalone/HA-Master-Repo/main/images/header/voice_play_bedtime_audiobook.jpeg)

LLM tool wrapper that plays an audiobook (or other media type) via Music Assistant on a designated player at a configurable volume. The LLM passes the title, player, and optional volume at runtime via script fields, while blueprint inputs lock in sensible defaults at instantiation time.

Designed primarily as a tool script for LLM conversation agents (Extended OpenAI Conversation function registration). Instantiate once per use-case — one for audiobooks, one for podcasts, one for playlists — each with different defaults, while the LLM tool interface stays identical across all instances.

> **Companion script:** The standalone `voice_play_bedtime_audiobook` script in `scripts.yaml` provides identical functionality without the blueprint wrapper. The standalone script is appropriate when only one instance is needed and shareability isn't a concern.

## How It Works

```
┌──────────────────────────────────────────────────────┐
│         voice_play_bedtime_audiobook                 │
│                                                      │
│  Blueprint inputs (config-time):                     │
│    default_volume, media_type, enqueue               │
│                                                      │
│  Script fields (runtime, from LLM):                  │
│    title, player, volume (optional)                  │
│                                                      │
│  ┌────────────────────────────────────────────────┐  │
│  │ 1. Resolve volume                              │  │
│  │    field value → or → blueprint default        │  │
│  └──────────────────┬─────────────────────────────┘  │
│                     ▼                                │
│  ┌────────────────────────────────────────────────┐  │
│  │ 2. media_player.volume_set                     │  │
│  │    → target: {{ player }}                      │  │
│  │    → volume_level: {{ resolved volume }}       │  │
│  └──────────────────┬─────────────────────────────┘  │
│                     ▼                                │
│  ┌────────────────────────────────────────────────┐  │
│  │ 3. music_assistant.play_media                  │  │
│  │    → target: {{ player }}                      │  │
│  │    → media_id: {{ title }}                     │  │
│  │    → media_type: {{ blueprint default }}       │  │
│  │    → enqueue: {{ blueprint default }}          │  │
│  └────────────────────────────────────────────────┘  │
│                                                      │
│  mode: single                                        │
└──────────────────────────────────────────────────────┘
```

## Key Design Decisions

### Blueprint inputs vs script fields — two layers of configuration

Blueprint inputs (`default_volume`, `media_type`, `enqueue`) are set once when creating the script instance. Script fields (`title`, `player`, `volume`) are passed dynamically at each call. This separation means you can stamp out an "audiobook player" instance and a "podcast player" instance from the same blueprint, each with different media type defaults, while the LLM tool interface remains identical.

### Volume cascading with safe fallback

The volume resolution chain is `field value → blueprint default → float(0.35)`. If the LLM passes a volume, it wins. If not, the blueprint default applies. If somehow both are empty (shouldn't happen, but template safety demands it), the `float()` filter catches it with a hardcoded 0.35. No silent failures, no blasting audio at full volume.

### Always set volume before playback

Volume is set as a separate `media_player.volume_set` call before `music_assistant.play_media`, not as a parameter on the play call. This ensures the volume is applied regardless of whether Music Assistant's play action supports an inline volume parameter, and it works across all MA player types (Sonos, Chromecast, DLNA, etc.).

## Blueprint Inputs

| Section | Input | Default | Description |
|---------|-------|---------|-------------|
| ① Playback defaults | Default volume | 0.35 | Fallback volume when caller doesn't specify (0.0–1.0) |
| ① Playback defaults | Media type | audiobook | Media type sent to Music Assistant (audiobook, podcast, track, album, artist, playlist, radio) |
| ① Playback defaults | Enqueue mode | replace | `replace` clears queue; `add` appends to it |

## Script Fields (passed at call time)

| Field | Required | Description |
|-------|----------|-------------|
| `title` | Yes | Media title or URI to search for and play |
| `player` | Yes | Media player entity to play on |
| `volume` | No | Playback volume (0.0–1.0). Overrides blueprint default when provided. |

## Prerequisites

- **Home Assistant** 2024.10.0 or later (uses `action:` syntax)
- **Music Assistant** integration installed and configured
- At least one MA-managed media player entity

## Installation

Copy `voice_play_bedtime_audiobook.yaml` to your `blueprints/script/madalone/` directory, then reload blueprints (Developer Tools → YAML → Reload all).

## Example Usage

### Creating an instance for audiobooks

```yaml
voice_play_bedtime_audiobook:
  use_blueprint:
    path: madalone/voice_play_bedtime_audiobook.yaml
    input:
      default_volume: 0.30
      media_type: audiobook
      enqueue: replace
  alias: "Voice - Play bedtime audiobook"
  description: "LLM tool: plays an audiobook on a specified player."
```

### Creating a second instance for podcasts

```yaml
voice_play_bedtime_podcast:
  use_blueprint:
    path: madalone/voice_play_bedtime_audiobook.yaml
    input:
      default_volume: 0.40
      media_type: podcast
      enqueue: add
  alias: "Voice - Play podcast"
  description: "LLM tool: plays a podcast on a specified player."
```

### As an LLM agent tool (Extended OpenAI Conversation)

Register the script instance as a function with `title`, `player`, and optionally `volume` as parameters. The agent selects the appropriate title and player based on the user's voice request.

## Technical Notes

- **Mode:** `single` — prevents overlapping calls from stacking volume changes.
- **Template safety:** Volume resolution uses `| default()` + `| float()` chain to prevent template errors from missing or non-numeric field values.
- **No seek support:** Unlike the standalone `bedtime_now` script, this blueprint doesn't seek to a specific position after playback starts. If you need seek-after-play, extend the blueprint or handle it in the calling automation.

## Version History

| Version | Date | Changes |
|---------|------|---------|
| v1 | 2026-02-15 | Initial blueprint — converted from standalone voice_play_bedtime_audiobook script |

## Author

**Miquel Angel Madalone**

## License

See repository for license details.
