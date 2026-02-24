# Notification Replay

![Notification Replay header](https://raw.githubusercontent.com/mmadalone/HA-Master-Repo/main/images/header/notification_replay-header.jpeg)

On-demand replay of the last phone notification through the Follow-Me TTS pipeline.
Reads the current notification sensor state, resolves your room via FP2 presence
sensors, applies sender aliases, generates an LLM summary, and delivers TTS to
the nearest voice satellite. No trigger, no cooldown, no filtering gates — just
the replay pipeline, callable from a dashboard button, voice intent, or any
automation.

> **Companion blueprint:** [Notification Follow-Me](https://github.com/mmadalone/HA-Master-Repo/blob/main/automation/notification_follow_me.yaml) — the full autonomous notification pipeline with triggers, cooldowns, quiet hours, DND, blocked contacts, and junk pattern filtering.

## How It Works

```
┌──────────────────────────────────┐
│  Script invoked (button/voice/   │
│  automation)                     │
└──────────────┬───────────────────┘
               ▼
┌──────────────────────────────────┐
│  1. Read notification sensor     │
│     attributes (sender, text,    │
│     package, group status)       │
└──────────────┬───────────────────┘
               ▼
┌──────────────────────────────────┐
│  1a. Gate: usable data?          │──── No ──▶ EXIT (silent)
└──────────────┬───────────────────┘
               │ Yes
               ▼
┌──────────────────────────────────┐
│  2. Resolve sender alias         │
│     (Key=Value map lookup)       │
└──────────────┬───────────────────┘
               ▼
┌──────────────────────────────────┐
│  3. Detect media messages,       │
│     truncate text to char cap    │
└──────────────┬───────────────────┘
               ▼
┌──────────────────────────────────┐
│  4. Build sensor context for LLM │
│     (optional extra entities)    │
└──────────────┬───────────────────┘
               ▼
┌──────────────────────────────────┐
│  5. Resolve presence → satellite │
│     (first occupied zone wins,   │
│      fallback if none active)    │
└──────────────┬───────────────────┘
               ▼
┌──────────────────────────────────┐
│  5a. Gate: satellite available?  │──── No ──▶ LOG WARNING + EXIT
└──────────────┬───────────────────┘
               │ Yes
               ▼
┌──────────────────────────────────┐
│  6. Generate summary             │
│  ┌─ Media + short_tts? ──▶ skip │
│  │  LLM, use hardcoded line     │
│  └─ Otherwise ──▶ conversation  │
│     .process with full prompt    │
│     + defensive fallback         │
└──────────────┬───────────────────┘
               ▼
┌──────────────────────────────────┐
│  7. Build TTS payload            │
│  7a. Snapshot + duck other       │
│      playing media players       │
└──────────────┬───────────────────┘
               ▼
┌──────────────────────────────────┐
│  8. Deliver TTS to satellite     │
│  ┌─ ElevenLabs custom ──▶ voice │
│  │  profile option               │
│  └─ Standard ──▶ tts.speak      │
│  8-wait. Poll satellite state    │
└──────────────┬───────────────────┘
               ▼
┌──────────────────────────────────┐
│  8a. Restore ducked volumes      │
│      Clear snapshot helper       │
└──────────────┬───────────────────┘
               ▼
┌──────────────────────────────────┐
│  9. Log successful replay        │
└──────────────────────────────────┘
```

## Key Design Decisions

### Full pipeline, no gates
The entire Follow-Me delivery pipeline (presence routing, sender aliases, media
detection, LLM summary, TTS with ducking) is preserved — but trigger, cooldown,
blocked contacts, junk patterns, quiet hours, DND, and ringer mode gates are
deliberately stripped. This is an on-demand tool, not an autonomous listener.

### Parallel-array presence mapping
Presence sensors and target satellites are paired by array index — same pattern
as Notification Follow-Me. First occupied zone wins. This avoids the complexity
of a mapping entity while keeping configuration straightforward.

### Defensive LLM fallback
If the conversation agent call fails or returns an incomplete response, a
hardcoded fallback announcement fires instead of silent failure. The failure
is logged as a warning for troubleshooting.

### Duck volume snapshot persistence
Ducked player volumes are written to an optional `input_text` helper as JSON.
This prevents race conditions when multiple replays queue — the second run
reads the original volumes from the helper rather than capturing
already-ducked levels.

## Features

- **Presence-aware routing** — automatically resolves your current room via FP2 binary sensors and routes TTS to the nearest voice satellite.
- **Sender alias support** — maps raw notification sender names to friendly display names via comma-separated Key=Value pairs.
- **LLM-powered summaries** — conversation agent generates natural-language paraphrases instead of reading messages verbatim.
- **Media message detection** — recognizes photos, voice messages, videos, stickers, GIFs, documents, contacts, and locations with configurable behavior (short TTS or full LLM summary).
- **Dual TTS engine support** — standard `tts.speak` or HACS ElevenLabs custom service with voice profile selection.
- **Announce mode** — optional `announce: true` flag for TTS calls that duck current audio at the satellite level.
- **Volume ducking** — temporarily lowers other playing media players during TTS, with configurable duck level and automatic volume restoration.
- **Persistent volume snapshots** — optional `input_text` helper prevents race conditions across queued replays.
- **Extra context entities** — pass additional sensor states to the LLM for contextually-aware summaries.
- **Character cap** — configurable limit on message text sent to the LLM (50–2000 characters).
- **Group chat context** — optionally includes group/direct message status in the LLM prompt.
- **Comprehensive logging** — system log entries for successful replays, no-satellite warnings, LLM failures, and unknown TTS mode fallbacks.

## Prerequisites

- **Home Assistant** 2024.10.0 or later
- **Android Companion App** with `last_notification` sensor enabled
- **Conversation agent** (Extended OpenAI Conversation, Google Generative AI, or any agent supporting `conversation.process`)
- **Presence sensors** — binary sensors for room occupancy (e.g., Aqara FP2 zones)
- **Voice satellites** — media players capable of TTS playback (e.g., ESPHome Voice PE)
- **Optional:** HACS ElevenLabs integration (for custom voice profiles)
- **Optional:** `input_text` helper for persistent duck volume snapshots

## Installation

1. Copy `notification_replay.yaml` to your HA config: `blueprints/script/madalone/`
2. Reload blueprints: **Developer Tools → YAML → Reload all YAML configuration**
3. Create a new script from the blueprint: **Settings → Automations & Scenes → Scripts → Add Script → Use Blueprint**
4. Configure inputs (at minimum: notification sensor, conversation agent, presence sensors, and target satellites)

Or import directly:
```
https://github.com/mmadalone/HA-Master-Repo/blob/main/script/notification_replay.yaml
```

## Configuration

### ① Core Setup

| Input | Default | Description |
|-------|---------|-------------|
| Notification sensor | *(empty)* | Android Companion App `last_notification` sensor |
| Conversation agent | *(empty)* | LLM agent for natural-language summaries |
| LLM summarization prompt | *(built-in)* | Instructions for how the AI summarizes notifications |
| Sender alias map | *(empty)* | Comma-separated `Key=Value` pairs (e.g., `Mare=Mum,Jessica=Love of my life`) |
| Include group chat context | `false` | Pass group/direct message status to the LLM |
| Extra context entities | *(none)* | Additional sensors passed to the LLM as environmental context |
| Message character cap | `500` | Maximum characters of message text sent to the LLM (50–2000) |
| Media message behavior | `short_tts` | `short_tts` = hardcoded line, no LLM call; `llm_summary` = full pipeline |

### ② Presence Routing

| Input | Default | Description |
|-------|---------|-------------|
| Presence sensors | *(none)* | Binary sensors for room occupancy, in priority order |
| Target satellites | *(none)* | Media players paired 1:1 with presence sensors above |
| Fallback satellite | *(empty)* | Satellite used when no presence sensor is active |

### ③ TTS Configuration

| Input | Default | Description |
|-------|---------|-------------|
| TTS mode | `standard_tts_entity` | `standard_tts_entity` or `elevenlabs_custom_service` |
| TTS entity | *(empty)* | TTS entity for `tts.speak` calls |
| ElevenLabs voice profile | *(empty)* | Voice profile name/ID for ElevenLabs custom integration |
| Use announce mode | `false` | Sends `announce: true` with TTS calls |

### ④ Duck Other Players

| Input | Default | Description |
|-------|---------|-------------|
| Players eligible for ducking | *(none)* | Media players to volume-duck during TTS |
| Duck volume level | `0.10` | Volume level (0.0–1.0) for ducked players |
| Duck volume snapshot helper | *(empty)* | Optional `input_text` helper for persistent snapshots |
| Max restore wait | `8` | Seconds to poll satellite state before restoring volumes (1–30) |

## Technical Notes

- **Mode:** `single` — concurrent invocations are queued, not overlapping.
- **LLM prompt injection defense:** Notification data passed to the conversation agent is sanitized (`<` → `‹`, `>` → `›`) and wrapped in explicit `BEGIN/END NOTIFICATION DATA` delimiters with an "untrusted user content" label.
- **Template safety:** All `states()` and `state_attr()` calls use `| default()` guards with explicit fallback values.
- **Error handling:** Critical-path actions (`conversation.process`, `tts.speak`) use `continue_on_error: true` with explicit fallback logic. Non-critical actions (logging, helper writes) use `continue_on_error: true` to prevent blocking the main pipeline.
- **AP-08 acknowledged:** Sequence block exceeds the 200-line guideline (~544 lines including variables and comments). Flow is linear with numbered aliases and mirrors the Notification Follow-Me structure. Accepted as-is — refactoring into sub-scripts would add indirection without readability benefit.

## Changelog

### v1.0
- Initial release — full Follow-Me delivery pipeline (presence routing, sender aliases, media detection, LLM summary, TTS, duck/restore) without trigger, cooldown, blocked contacts, junk patterns, quiet hours, DND, or ringer mode gates.

## Author

**madalone**

## License

See repository for license details.
