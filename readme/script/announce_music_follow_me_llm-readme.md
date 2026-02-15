# Announce Music Follow Me (TTS, LLM)

![Announce Music Follow Me header](https://raw.githubusercontent.com/mmadalone/HA-Master-Repo/main/images/header/announce_music_follow_me_llm-header.jpeg)

Script blueprint that announces via TTS where the music was moved for a "music follow me" automation. Supports static messages, random message pools, and LLM-generated context-aware announcements with optional ElevenLabs voice customization.

> **Companion blueprint:** Designed for use with the **Music Assistant Follow-Me Multi-Room Advanced** automation blueprint, but works with any automation that transfers music between speakers.

## How It Works

```
Follow-Me automation detects room change
        │
        ▼
  Calls this script with:
  ├── target_player (where music moved TO)
  ├── source_player (where music was playing)
  └── tts_output_player (optional override)
        │
        ▼
  ┌─────────────────────────────────────┐
  │  Message Strategy Decision          │
  ├─────────────────────────────────────┤
  │  LLM enabled?                       │
  │  ├─ YES → conversation.process      │
  │  │        (context-aware message)    │
  │  │        Falls back to default      │
  │  │        on failure                 │
  │  ├─ NO, random enabled?             │
  │  │  ├─ YES → pick from pool         │
  │  │  └─ NO  → static default         │
  └─────────────────────────────────────┘
        │
        ▼
  ┌─────────────────────────────────────┐
  │  TTS Engine Selection               │
  ├─────────────────────────────────────┤
  │  Voice profile set?                 │
  │  ├─ YES → tts.speak + voice_profile │
  │  ├─ NO, voice name set?            │
  │  │  ├─ YES → tts.speak + voice     │
  │  │  └─ NO  → tts.speak (generic)   │
  └─────────────────────────────────────┘
```

## Key Design Decisions

### Three-tier message strategy

The blueprint supports three levels of sophistication, each falling back to the one below: LLM-generated context-aware messages (knows what's playing, the time of day, and the target room), a static random message pool with `{player_name}` templating, and a single default message. The LLM path uses `continue_on_error: true` so a failed API call never blocks the announcement — it just falls back to the default.

### ElevenLabs voice branching

TTS output branches three ways depending on whether a voice profile ID is set, a voice name is set, or neither. Voice profiles take priority over voice names. This avoids sending unsupported `options:` keys to non-ElevenLabs engines, which was a crash bug fixed in v2.

### Playback context for LLM

When enabled, the LLM prompt includes the currently playing track or radio station name. The template distinguishes between radio streams and tracks, telling the LLM explicitly when it's a live radio stream so it doesn't comment on "the song" when there isn't one.

## Features

- **Static, random, or LLM-generated announcements** — three message strategies with automatic fallback
- **Playback-aware LLM prompts** — tells the LLM what's playing (track, artist, or radio station) for context-aware commentary
- **ElevenLabs voice support** — voice name or custom voice profile ID, with clean fallback for non-ElevenLabs engines
- **Customizable message pool** — user-defined templates with `{player_name}` placeholder
- **Configurable LLM prompt** — full control over the system prompt with `{player_name}`, `{current_time}`, and `{time_of_day}` placeholders
- **TTS output override** — announce on a different speaker than the music target
- **Source player context** — reads track info from the source player (where music was) for accurate LLM context

## Prerequisites

- Home Assistant 2024.8.0 or later
- A TTS integration configured (any engine works for basic mode; ElevenLabs for voice customization)
- A conversation agent configured (Extended OpenAI Conversation, OpenAI Conversation, or similar) — only required for LLM mode
- Music Assistant with at least one media player entity

## Installation

Copy `announce_music_follow_me_llm.yaml` to your `config/blueprints/script/madalone/` directory, then reload automations in Developer Tools → YAML.

## Configuration

### ① TTS & Voice

| Input | Default | Description |
|-------|---------|-------------|
| TTS entity | *(required)* | The TTS engine entity to use for announcements |
| ElevenLabs voice | *(empty)* | Voice name (e.g., "Rachel"). Ignored when voice profile is set |
| ElevenLabs voice profile | *(empty)* | Custom cloned voice profile ID. Takes priority over voice name |

### ② Message Strategy

| Input | Default | Description |
|-------|---------|-------------|
| Use random fun messages | `true` | Pick from the message pool instead of always using the default |
| Use LLM for fun messages | `false` | Use a conversation agent for context-aware messages (requires random mode on) |
| Random messages | 3 templates | Pool of `{player_name}`-templated messages for random mode |
| Default message | "Moving the music to {player_name}." | Fallback message when random/LLM are off or LLM fails |

### ③ LLM Configuration

| Input | Default | Description |
|-------|---------|-------------|
| Include playback context | `true` | Feed current track/station info to the LLM prompt |
| LLM prompt template | Casual smart home assistant | System prompt with `{player_name}`, `{current_time}`, `{time_of_day}` placeholders |
| Conversation agent | *(empty)* | The LLM agent for generating messages |

### Script Fields (passed by calling automation)

| Field | Required | Description |
|-------|----------|-------------|
| `target_player` | Yes | Media player entity where music is being moved to |
| `source_player` | No | Media player where music was playing (for LLM context). Falls back to target_player |
| `tts_output_player` | No | Override which speaker plays the TTS announcement |

## Technical Notes

- **Mode:** `queued` with `max_exceeded: silent` — announcements queue up if Follow-Me triggers rapidly, but excess calls are silently dropped
- **LLM response extraction:** Handles both `response.speech.plain.speech` (standard HA conversation) and `response.text` (some third-party agents) response formats
- **Template safety:** All `state_attr()` calls use `| default()` guards. `source_player` existence is checked with `is defined` before access
- **Radio detection:** The LLM context template checks for "radio" in both `media_title` and `media_artist` to correctly identify live radio streams

## Changelog

- **v2:** Fixed voice_profile crash on non-ElevenLabs engines; migrated to `action:` syntax; added collapsible sections, aliases, and descriptions
- **v1:** Initial version

## Author

**madalone**

## License

See repository for license details.
