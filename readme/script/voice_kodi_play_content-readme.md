# Voice — Kodi play content

![Voice Kodi Play Content header](https://raw.githubusercontent.com/mmadalone/HA-Master-Repo/main/images/header/voice_kodi_play_content-header.jpeg)

Universal Kodi content router exposed as a reusable script blueprint. Accepts a content type and identifier, determines the correct Kodi playback method, and fires it. Handles direct file playback for movies and episodes, plugin/favourite URIs via JSON-RPC `Player.Open`, and TV show continuation with automatic next-unwatched-episode resolution via `VideoLibrary.GetTVShows` → `VideoLibrary.GetEpisodes` chaining.

Designed primarily as a tool script for LLM conversation agents (Extended OpenAI Conversation function registration), but works from any automation, script call, or dashboard button.

> **Origin:** Extracted from the raw `voice_play_bedtime_kodi` script used by the *Bedtime Routine Plus* automation. Generalized for reuse — no bedtime-specific logic remains.

## How It Works

```
┌─────────────────────────────────────────────────────────────┐
│                  voice_kodi_play_content                     │
│                                                             │
│  Inputs: content_id, content_type, media_content_type       │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐    │
│  │              Route on content_type                   │    │
│  └──────┬──────────────┬──────────────┬────────────────┘    │
│         │              │              │                      │
│    movie/episode   favourite   tvshow_continue               │
│         │              │              │                      │
│         ▼              ▼              ▼                      │
│  ┌────────────┐ ┌────────────┐ ┌──────────────────────┐    │
│  │ play_media │ │ Player.Open│ │ Step 1: GetTVShows   │    │
│  │ (direct    │ │ (plugin,   │ │   → resolve tvshowid │    │
│  │  file path)│ │  special,  │ │                      │    │
│  └────────────┘ │  smart     │ │ Step 2: GetEpisodes  │    │
│                 │  playlist) │ │   → first unwatched  │    │
│                 └────────────┘ │   → playcount == 0   │    │
│                                │                      │    │
│                                │ Step 3: Player.Open  │    │
│                                │   → play resolved    │    │
│                                │     episode file     │    │
│                                └──────────────────────┘    │
│                                                             │
│  On failure: logbook.log or notify (configurable)           │
└─────────────────────────────────────────────────────────────┘
```

## Key Design Decisions

### Three playback methods, one entry point

Kodi's `media_player.play_media` can handle direct file paths but chokes on `plugin://` and `special://` URIs. Those need `kodi.call_method` with `Player.Open`. And continuing a TV show requires two sequential JSON-RPC lookups before you even have a file path to play. This blueprint hides all three behind a single `content_type` field — the caller doesn't need to know which Kodi API to use.

### JSON-RPC with defensive wait guards

The `tvshow_continue` path chains two `kodi.call_method` calls with `wait_for_trigger` on `kodi_call_method_result` events. Each wait has a configurable timeout (default 10 seconds) and `continue_on_error: true`. The response extraction uses full `is defined` guard chains — `wait.trigger`, `wait.trigger.event`, `wait.trigger.event.data` — to prevent silent failures if Kodi doesn't respond or returns an unexpected structure.

### Configurable error reporting

Errors (show not found, no unwatched episodes) can route to either `logbook.log` (default, zero config) or a `notify` service entity for push notifications. The choice is made via the optional `error_notify_entity` blueprint input — leave it empty for logbook, set it for notifications.

### Agent-friendly field design

The `fields:` block exposes `content_id`, `content_type`, and `media_content_type` as tool parameters for LLM function registration. The field descriptions are written to guide an LLM in selecting the correct routing type based on the user's voice request.

## Blueprint Inputs

| Section | Input | Default | Description |
|---------|-------|---------|-------------|
| ① Target | Kodi media player | *(required)* | Kodi media_player entity (filtered to Kodi integration) |
| ② Advanced | JSON-RPC timeout | 10s | Wait timeout for TV show continuation lookups |
| ② Advanced | Notification service | *(empty)* | Optional notify entity for error messages |

## Script Fields (passed at call time)

| Field | Required | Description |
|-------|----------|-------------|
| `content_id` | Yes | File path, plugin URI, or TV show title |
| `content_type` | Yes | `movie`, `episode`, `favourite`, or `tvshow_continue` |
| `media_content_type` | No | Override: `video` (default), `music`, `CHANNEL`, `DIRECTORY` |

## Example Usage

### From an automation or script

```yaml
- alias: "Play a favourite on Kodi"
  action: script.turn_on
  target:
    entity_id: script.voice_kodi_play_content
  data:
    variables:
      content_id: "plugin://plugin.video.netflix/play/81234567"
      content_type: "favourite"
```

### As an LLM agent tool (Extended OpenAI Conversation)

Register the script as a function with `content_id`, `content_type`, and optionally `media_content_type` as parameters. The agent selects the appropriate `content_type` based on the user's voice request and the Kodi library catalog injected via `extra_system_prompt`.

## Version History

| Version | Date | Changes |
|---------|------|---------|
| v1 | 2026-02-14 | Initial blueprint — extracted from voice_play_bedtime_kodi script |
