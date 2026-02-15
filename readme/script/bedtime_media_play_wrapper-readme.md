# Bedtime Media Play Wrapper — Music Assistant

![Bedtime Media Play Wrapper header](https://raw.githubusercontent.com/mmadalone/HA-Master-Repo/main/images/header/bedtime_media_play_wrapper-header.jpeg)

Wrapper script blueprint for playing bedtime media (especially audiobooks) via Music Assistant. Designed to be called by a parent bedtime automation that passes in its selected MA player, so playback always targets the correct room. Supports optional pre-playback volume setting, shuffle, and queue control.

## How It Works

```
┌─────────────────────────────────────┐
│  Bedtime automation calls script    │
│  with player, media_id, options     │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│  Set local variables from inputs    │
│  Build action_data & target_data    │
└──────────────┬──────────────────────┘
               │
               ▼
        ┌──────┴──────┐
        │ Volume set? │
        └──────┬──────┘
          yes/ \no
          ▼     ▼
  ┌────────┐  (skip)
  │ Set vol│
  └───┬────┘
      │◄────────┘
      ▼
┌─────────────────────────────────────┐
│  music_assistant.play_media         │
│  (media_id, media_type, enqueue)    │
└──────────────┬──────────────────────┘
               │
               ▼
        ┌──────┴──────┐
        │  Shuffle?   │
        └──────┬──────┘
          yes/ \no
          ▼     ▼
  ┌────────┐  (skip)
  │Shuffle │
  │  on    │
  └────────┘
```

## Key Design Decisions

### Why a wrapper script?

The bedtime automation handles orchestration — triggers, conditions, LLM conversation, duck/restore. It shouldn't also contain the details of how to call Music Assistant's `play_media`. This wrapper isolates playback mechanics so the parent automation stays clean and the play logic is reusable across different bedtime flows.

### Dynamic dict construction

Rather than hardcoding `data:` fields, the script builds `action_data` and `target_data` as Jinja2 dicts in the variables block. This keeps the action steps clean and makes it easy to extend with additional fields later without restructuring the action calls.

### Volume sentinel pattern

The `volume` input uses `default: []` (empty list) as a sentinel for "no value provided." HA's number selector has no native "unset" state, so an empty list distinguishes "user didn't touch this" from "user set it to 0.0." The conditional checks `_volume not in [[], none, '']` to catch all unset variants.

### Conditional shuffle

The shuffle step only fires when `_shuffle` is true. This avoids unnecessary `media_player.shuffle_set` calls when the user doesn't want shuffle — consistent with how the volume step already works conditionally.

## Features

- **Targeted playback** — always uses `music_assistant.play_media` on the passed-in player, never a hardcoded entity
- **Optional volume control** — set volume before playback or leave the player's current level untouched
- **Queue management** — replace the queue or append via the enqueue input
- **Media type flexibility** — supports audiobook, podcast, radio, track, album, artist, and playlist
- **Conditional shuffle** — enables shuffle only when explicitly requested
- **Queued mode** — supports up to 10 queued executions without blocking

## Prerequisites

- **Home Assistant:** 2024.10.0 or later
- **Music Assistant integration** installed and configured with at least one media player entity
- A parent automation or script that passes the target player entity

## Installation

Copy `bedtime_media_play_wrapper.yaml` to your HA config at:

```
config/blueprints/script/madalone/bedtime_media_play_wrapper.yaml
```

Or import via the blueprint import URL if hosted on GitHub.

## Configuration

### ① Playback

| Input | Default | Description |
|-------|---------|-------------|
| Target player | *(required)* | The MA media_player entity passed by the parent automation |
| Media type | `audiobook` | Content type — audiobook, podcast, radio, track, album, artist, playlist |
| Media ID | *(required)* | Name (e.g. "Bedtime Stories for Cynics") or URI (e.g. `library://audiobook/86`) |
| Enqueue | `replace` | `replace` starts fresh; `add` appends to queue |

### ② Volume & Behavior

| Input | Default | Description |
|-------|---------|-------------|
| Volume | *(unset)* | 0.0–1.0 — applied before playback. Leave empty to keep current volume |
| Shuffle | `false` | Enable shuffle on the target player after playback starts |

## Technical Notes

- **Mode:** `queued` with `max: 10` — allows multiple calls to stack without dropping requests. Useful when the parent automation triggers rapid sequential plays.
- **Template safety:** Volume and shuffle inputs use `| default()` guards to handle edge cases where inputs resolve to `none`.
- **No timeout handling needed:** This is a fire-and-forget wrapper — it issues service calls and exits. The parent automation owns any timeout/cleanup logic.
- **MA-specific:** Uses `music_assistant.play_media` (not the generic `media_player.play_media`) to access MA's queue features and media resolution.

## Changelog

- **v2:** Restructured header, collapsible inputs, conditional shuffle, aliases on all steps
- **v1:** Initial version — basic MA play_media wrapper with volume control

## Author

**madalone**

## License

See repository for license details.
