# Wake-up music – Music Assistant (simple)

![Wake-up music MA header](https://raw.githubusercontent.com/mmadalone/HA-Master-Repo/main/images/header/wakeup_music_ma-header.jpeg)

Simple helper script: set volume, clear queue, play one item on a Music Assistant player. Supports configurable enqueue mode and radio mode for continuous playback. No AFTER logic — handle post-playback with a separate automation if needed.

## How It Works

```
┌─────────────────────────────┐
│  Script triggered            │
└──────────┬──────────────────┘
           │
           ▼
┌─────────────────────────────┐
│  Set volume to configured    │
│  level (volume_before)       │
└──────────┬──────────────────┘
           │
           ▼
┌─────────────────────────────┐
│  Clear MA queue              │
│  (continue_on_error: true)   │
└──────────┬──────────────────┘
           │
           ▼
┌─────────────────────────────┐
│  Radio mode preference?      │
├──────┬──────────┬───────────┤
│Always│  Never   │  Default  │
└──┬───┘──────┬───┘───────┬───┘
   │          │           │
   ▼          ▼           ▼
┌──────┐ ┌──────┐  ┌───────────┐
│radio │ │radio │  │ omit flag │
│=true │ │=false│  │ (use plyr │
│      │ │      │  │ settings) │
└──┬───┘ └──┬───┘  └─────┬─────┘
   │        │            │
   └────────┴────────────┘
           │
           ▼
┌─────────────────────────────┐
│  music_assistant.play_media  │
│  with media_id, media_type,  │
│  enqueue mode                │
└─────────────────────────────┘
```

## Key Design Decisions

### MA-native playback

This script uses `music_assistant.play_media` exclusively — never the generic
`media_player.play_media`. The MA-specific action supports queue management
(`enqueue` modes), radio mode for continuous playback, and proper media
resolution from MA's library. The generic action lacks all of these and may
fail to resolve MA media URIs entirely.

### Radio mode via choose block

Rather than injecting `radio_mode` into a templated `data:` dict (which can
break across HA versions due to YAML/Jinja dict coercion), the script uses a
`choose` block with three branches: Always (force on), Never (force off), and
Default (omit the parameter, letting the player's own setting govern). This
follows the §7.2 pattern for robust MA parameter handling.

### Non-critical queue clear

The `clear_playlist` step runs with `continue_on_error: true` because a
failed queue clear shouldn't prevent the music from playing. If the player is
already idle or the queue is empty, the clear may error — that's fine, the
next step plays regardless.

## Features

- **MA-native playback** — uses `music_assistant.play_media` with full queue
  and radio mode support
- **Volume pre-set** — sets speaker volume before playback starts, ensuring
  consistent wake-up volume
- **Queue management** — configurable enqueue mode (replace, play, next, add)
  for flexible queue behavior
- **Radio mode** — three-way control (always/never/player default) for
  continuous playback after the queue ends
- **MA entity filter** — player selector only shows Music Assistant entities,
  preventing accidental selection of platform players
- **Graceful queue clear** — non-critical step with `continue_on_error` so
  playback proceeds even if the clear fails

## Prerequisites

- **Home Assistant** 2024.10.0 or later
- **Music Assistant** 2.x integration installed and configured
- At least one MA player entity available

## Installation

Copy `wakeup_music_ma.yaml` to your HA config directory:

```
config/blueprints/script/madalone/wakeup_music_ma.yaml
```

Or import via the blueprint import URL if hosted on GitHub.

## Configuration

### ① Player & media

| Input | Default | Description |
|-------|---------|-------------|
| Music Assistant player | *(required)* | MA speaker entity to play on. Filtered to MA integration only. |
| Media ID (URI or name) | `""` | MA media identifier — URI, library name, or any string MA can resolve. |
| Media type | `music` | Type of media: music, track, album, artist, playlist, or radio. |

### ② Playback settings

| Input | Default | Description |
|-------|---------|-------------|
| Volume BEFORE playback | `0.6` | Volume level (0.0–1.0) set before playing. |
| Enqueue mode | `replace` | Queue behavior: replace (clear + play), play (play + keep queue), next (after current), add (append). |
| Radio mode | `Use player settings` | Continuous playback: Always (force on), Never (force off), or use the player's own setting. |

## Technical Notes

- **Mode:** `single` — concurrent calls are blocked while the script runs.
- **No post-playback logic** — this script is intentionally minimal. It sets
  volume, clears queue, and plays. Any "after" behavior (fade-in, follow-up
  announcements, light sequences) should be handled by the calling automation.
- **Provider dependency** — radio mode relies on the music provider's ability
  to generate similar-track recommendations. Streaming providers (Spotify,
  Qobuz, Tidal) generally support this well. Local-only libraries may produce
  poor or no recommendations.

## Changelog

- **v2:** Full rebuild — `music_assistant.play_media`, modern `action:` syntax,
  collapsible sections, `radio_mode`/`enqueue` inputs, MA entity filter
- **v1:** Initial version (used generic `media_player.play_media`)

## Author

**madalone**

## License

See repository for license details.
