# Goodnight Negotiator (Hybrid) — Bedtime Script Blueprint

![Goodnight Negotiator Hybrid header](https://raw.githubusercontent.com/mmadalone/HA-Master-Repo/main/images/header/goodnight_negotiator_hybrid-header.jpeg)

Hybrid bedtime script with optional staged confirmations covering TV/devices, lights/devices, and bedtime audio via Music Assistant. Each stage can independently ask permission, execute silently, or skip. Voice interactions flow through your chosen conversation agent persona, keeping the whole experience in-character.

## How It Works

```
┌─────────────────────────────────────┐
│  Preflight: lock + debounce check   │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│  Opening line (fixed / LLM / skip)  │
└──────────────┬──────────────────────┘
               │
     ┌─────────┼─────────┐
     ▼         ▼         ▼
┌─────────┐┌─────────┐┌─────────────────┐
│ Stage 1 ││ Stage 2 ││    Stage 3      │
│ TV / IR ││ Lights  ││ Bedtime Audio   │
│         ││ Devices ││ (Music Asst.)   │
│ ask /   ││ ask /   ││ ask / search /  │
│ do_it / ││ do_it / ││ resolve / play  │
│ skip    ││ skip    ││                 │
└────┬────┘└────┬────┘└───────┬─────────┘
     └─────────┼─────────────┘
               ▼
┌─────────────────────────────────────┐
│  Closing line (fixed / LLM / skip)  │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│  Cleanup: release lock helper       │
└─────────────────────────────────────┘
```

## Key Design Decisions

### Three-stage architecture

Bedtime routines involve fundamentally different action types: IR/TV power-off (irreversible, critical), light/device control (reversible, bulk), and audio playback (non-critical, preference-based). Splitting these into independent stages lets each have its own ask/skip/do-it behavior and fallback logic.

### Voice-first interaction via conversation agent

All spoken lines route through `conversation.process` using the configured persona agent. This means Rick Sanchez can ask if you want the TV off, and Quark can negotiate your audiobook choice — the blueprint doesn't care which persona is driving. Custom phrase overrides let you bypass the LLM for specific messages.

### Helper-backed memory and locking

Optional `input_boolean` / `input_number` / `input_text` helpers persist state between runs: last opening line (prevents repetition), last run epoch (debounce), and an in-progress lock (prevents double-runs). All helper operations use `continue_on_error: true` so missing helpers never crash the script.

### Music Assistant LLM pattern (Stage 3)

Instead of calling `music_assistant.search` directly and parsing results, Stage 3 asks the conversation agent to return a strict JSON payload (`media_id`, `media_type`, etc.) which is then fed to `music_assistant.play_media`. This makes playback less brittle and leverages the LLM's ability to interpret fuzzy queries.

### Multilingual yes/no/abort detection

Voice responses are matched against regex patterns covering English, Dutch, Spanish, and French variants for yes, no, and abort intents. Unclear responses trigger configurable retries before falling back to the stage's default behavior.

## Features

- **Three independent stages** with per-stage ask/do-it/skip modes
- **Express mode** skips all confirmations for one-command bedtime
- **Persona-aware voice** via any conversation agent entity
- **LLM-generated opening/closing lines** with anti-repetition logic
- **Music Assistant integration** with category filtering (music/audiobook/podcast/radio/auto)
- **Late-night bias** shifts auto-category toward audiobooks after a configurable hour
- **Media context awareness** can mention what's currently playing
- **Helper-backed debounce and locking** prevents double-triggered runs
- **Configurable retry logic** for unclear voice responses
- **Custom phrase overrides** for every spoken message type
- **Delegate playback script** option for advanced MA routing

## Prerequisites

- **Home Assistant:** 2024.10.0 or later
- A **conversation agent** entity (Extended OpenAI Conversation, built-in, etc.)
- An **assist satellite** entity (ESPHome Voice PE, etc.)
- **Music Assistant** integration with at least one configured player (for Stage 3)
- Optional: input helpers for memory/locking features

## Installation

Copy `goodnight_negotiator_hybrid.yaml` to:

```
config/blueprints/script/madalone/goodnight_negotiator_hybrid.yaml
```

Or import via blueprint URL:

```
https://github.com/mmadalone/HA-Master-Repo/blob/main/script/goodnight_negotiator_hybrid.yaml
```

## Configuration

### ① Core Routing

| Input | Default | Description |
|-------|---------|-------------|
| User's name | `friend` | How the assistant addresses you |
| Area name | `workshop` | Room context for LLM prompts |
| Conversation agent | *(required)* | Persona to use for all spoken lines |
| Voice satellite | *(required)* | Satellite entity for announcements and questions |

### ② Express Mode & Timing

| Input | Default | Description |
|-------|---------|-------------|
| Express mode | `false` | Skip all ask prompts, execute stages directly |
| Inter-stage delay | `1` sec | Breathing room between stages |
| Unclear retries | `1` | Re-ask count for ambiguous voice responses |
| Debounce seconds | `20` | Ignore re-triggers within this window |

### ③–⑩ Additional Sections

Custom phrases, context inputs, opening/closing line modes, per-stage configuration, helper assignments, and feedback options are organized into collapsible sections in the blueprint UI.

## Technical Notes

- **Mode:** `single` with `max_exceeded: silent` — prevents overlapping runs
- **Template safety:** All `states()` calls use `| default()` guards; `| list | first` filters use `| default(none)`
- **Action syntax:** Uses modern `action:` syntax throughout (no legacy `service:` calls)
- **All 88 action steps** have descriptive `alias:` fields for trace readability
- **Stage 3 nesting:** Deep choose/sequence nesting handles the complex search → resolve → play flow; this is a known complexity tradeoff documented in the audit

## Changelog

- **v8.7.0:** Compliance overhaul — `action:` migration (AP-10), 88 aliases (AP-11), collapsible inputs (AP-09), `conversation_agent:` selector (AP-24), template safety fixes (AP-16), added `author` and `source_url`
- **v8.6.9:** Template safety fix for `states()` and `| list | first` calls
- **v8.6.3:** Stage 3 JSON parsing with mapping type-check fallback; TV-no skips stage 3
- **v8.5.0:** Switched to Music Assistant LLM pattern (JSON → play_media)
- **v8.4:** Helper-backed memory/locking, debounce improvements
- **v8.0:** Run debounce, single mode, anti-cliché prompt rules
- **v7.0:** Persona-aware voice routing, custom phrase inputs, search clarification
- **v6.0:** Music Assistant config_entry_id, unintelligible voice feedback

## Author

**madalone**

## License

See repository for license details.
