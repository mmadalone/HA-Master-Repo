# LLM Script for Music Assistant voice requests

![LLM Voice Script header](https://raw.githubusercontent.com/mmadalone/HA-Master-Repo/main/images/header/llm_voice_script-header.jpeg)

Script blueprint that translates natural-language voice commands into Music Assistant playback actions. An LLM conversation agent parses the request, extracts structured parameters (media type, artist, album, track, target area/player), and this script routes them to `music_assistant.play_media` with proper targeting and shuffle control.

> **⚠️ Modified version** of the official [Music Assistant LLM Voice Script](https://github.com/music-assistant/voice-support/blob/main/llm-script-blueprint/llm_voice_script.yaml) by [TheFes](https://github.com/TheFes). Local modifications include alias coverage, error handling, section naming conventions, min_version correction, and project-specific header image. The upstream blueprint is the canonical source — check there for updates.

Designed to be exposed as a tool in Assist or Extended OpenAI Conversation agents. The LLM decides *what* to play and *where* — this script handles the *how*.

## How It Works

```
┌──────────────────────────────────────────────────────────┐
│              llm_voice_script                              │
│                                                          │
│  Fields (from LLM):                                      │
│    media_type, media_id, artist, album,                  │
│    media_description, area, media_player, shuffle        │
│                                                          │
│  ┌────────────────────────────────────────────────────┐  │
│  │ Step 1: Resolve target                             │  │
│  │   media_player field → MA entity lookup            │  │
│  │   area field → area_id                             │  │
│  │   fallback → default_player input                  │  │
│  │   none found → stop with error response            │  │
│  └────────────────────────┬───────────────────────────┘  │
│                           │                              │
│  ┌────────────────────────▼───────────────────────────┐  │
│  │ Step 2: Build action data                          │  │
│  │   media_id → split on ";" for multi-track          │  │
│  │   radio_mode → from play_continuously input        │  │
│  │   strip "NA" sentinel values                       │  │
│  └────────────────────────┬───────────────────────────┘  │
│                           │                              │
│  ┌────────────────────────▼───────────────────────────┐  │
│  │ Step 3: music_assistant.play_media                 │  │
│  └────────────────────────┬───────────────────────────┘  │
│                           │                              │
│  ┌────────────────────────▼───────────────────────────┐  │
│  │ Step 4: media_player.shuffle_set                   │  │
│  │   (continue_on_error — non-critical)               │  │
│  └────────────────────────┬───────────────────────────┘  │
│                           │                              │
│  ┌────────────────────────▼───────────────────────────┐  │
│  │ Step 5: User-defined additional actions             │  │
│  └────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────┘
```

## Key Design Decisions

### LLM prompt customization via inputs

All prompts sent to the LLM are exposed as text inputs in Section ② (collapsed by default). This means you can tune how the LLM interprets voice commands without editing the blueprint YAML — adjust the `media_type_prompt` to handle edge cases, refine `area_prompt` for your room naming conventions, etc. The defaults are solid for most setups.

### Target resolution: area → player → default

The script resolves playback targets in priority order: if the LLM extracted a specific `media_player` entity, use that. If it extracted an `area`, use that. If neither, fall back to the `default_player` input. If *nothing* resolves, the script stops with an error response rather than playing to a random player.

### Multi-track support via semicolon separator

When the LLM returns multiple tracks (e.g., "play the best Queen songs"), it separates them with semicolons in `media_id`. The script splits on `;` and passes a list to Music Assistant, which queues them as a playlist.

### Radio mode from input, not hardcoded

The `play_continuously` input maps to MA's `radio_mode` parameter: "Always" enables continuous playback, "Never" stops after the queue ends, and "Use player settings" defers to the MA player's "Don't stop the music" toggle. This avoids AP-31 (hardcoded radio_mode).

### Shuffle as a first-class parameter

The LLM determines shuffle intent from the voice command (e.g., "shuffle music by Muse" → `shuffle: true`). The script applies it as a separate `media_player.shuffle_set` call after playback starts, with `continue_on_error: true` since shuffle failure shouldn't kill the whole script.

## Input Sections

| Section | Contents | Default state |
|---------|----------|---------------|
| ① Settings for Music Assistant playback | Default player, radio mode | Expanded |
| ② Prompt settings for the LLM | All 8 LLM prompt templates | Collapsed |
| ③ Additional actions | User-defined post-playback actions | Collapsed |

## Script Fields (populated by LLM)

| Field | Required | Description |
|-------|----------|-------------|
| `media_type` | ✅ | One of: track, album, artist, playlist, radio |
| `media_id` | ✅ | Track/album/artist/playlist name(s), semicolon-separated for multiple |
| `artist` | ✅ | Artist name, or empty string if unknown/multiple |
| `album` | ✅ | Album name, or empty string if unknown/multiple |
| `media_description` | ✅ | Natural language description of the media request |
| `area` | ❌ | Target area(s) for playback |
| `media_player` | ❌ | Specific MA media player entity(s) |
| `shuffle` | ✅ | Whether to enable shuffle (true/false) |

## Example Script Description (for agent tool registration)

When exposing this script to a conversation agent, use a description like:

> This script is used to play music based on a voice request. The tool takes the following arguments: media_type, artist, album, media_id, radio_mode, area, shuffle. media_id, media_type, and shuffle are always required and must always be supplied as arguments to this tool. An area or Music Assistant media player can optionally be provided in the voice request as well.

## Dependencies

- **Music Assistant** integration (required)
- **LLM conversation agent** (required — provides the structured field values)
- Home Assistant 2024.8.0+

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 20250526 | 2025-05-26 | Upstream version from TheFes |
| local-1 | 2026-02-18 | Adopted: bumped min_version to 2024.8.0, fixed bare default on default_player, added continue_on_error to shuffle, added aliases to all action steps, added section numbering, header image, README |
