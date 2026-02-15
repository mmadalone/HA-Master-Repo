# Coming Home – AI Welcome

![Coming home header](https://raw.githubusercontent.com/mmadalone/HA-Master-Repo/main/images/header/coming_home-header.jpeg)

An arrival automation that triggers when one or more persons come home, waits for physical entrance occupancy confirmation (GPS alone isn't reliable), optionally power-cycles speakers to clear stale connections, activates temporary helper switches, generates a personalized AI greeting via a conversation agent, then starts an interactive Assist conversation on Voice PE satellites. Supports multiple person entities and custom arrival names for multi-person households. Includes GPS-bounce cooldown, timeout handling on every wait, and guaranteed cleanup of temporary switches on all exit paths.

## How It Works

```
Person state: not_home → home (GPS)
                │
                ▼
┌───────────────────────────────┐
│ GPS bounce cooldown            │──── Ran recently → skip
│ (this.attributes.last_triggered│
│  vs cooldown_seconds)          │
└──────────────┬────────────────┘
               │
               ▼
┌───────────────────────────────┐
│ Wait for entrance occupancy    │──── Timeout → abort
│ (binary_sensor confirmation)   │     (likely GPS bounce)
└──────────────┬────────────────┘
               │
               ▼
    Power-cycle reset switches
    (OFF → delay → ON, optional)
               │
               ▼
    Turn ON temporary switches
               │
               ▼
┌───────────────────────────────┐
│ Wait for entrance to clear     │──── Timeout → cleanup + abort
│ (person moved past the door)   │
└──────────────┬────────────────┘
               │
               ▼
┌───────────────────────────────┐
│ conversation.process            │
│ Generate AI greeting            │
│ (with person_name context)      │
│ Fallback on LLM failure         │
└──────────────┬────────────────┘
               │
               ▼
┌───────────────────────────────┐
│ assist_satellite                │
│ .start_conversation             │
│ Speak greeting + listen for     │
│ follow-up commands              │
│ (extra_system_prompt provides   │
│  arrival context to agent)      │
└──────────────┬────────────────┘
               │
               ▼
    Post-conversation delay
               │
               ▼
    Turn OFF temporary switches
    (guaranteed cleanup)
```

## Key Design Decisions

### Dual Confirmation: GPS + Occupancy

GPS zone transitions are notoriously unreliable — phones can report "home" while you're still parking, or bounce between home/not_home repeatedly. This blueprint requires both the GPS state change (trigger) and a physical occupancy sensor at the entrance (confirmation) before proceeding. If the entrance sensor doesn't fire within the timeout window, the automation aborts cleanly — no speakers reset, no greeting generated, no switches left dangling.

### Multi-Person Name Resolution

The `person_name` variable resolves through a three-tier priority chain. First, if the "Arrival names" text field has content, it splits by newline, trims whitespace, drops empty lines, and joins with "and" (e.g., "Miquel and Ana"). Second, if no custom names are set but person entities are configured, it pulls `friendly_name` from each entity and joins them with "and". Third, if neither is configured, it falls back to "someone." This means you can set person entities for trigger purposes but override the greeting names for a more personal touch.

### Speaker Power-Cycle Reset (Optional)

Before generating the greeting, the blueprint can optionally power-cycle configured switches (OFF → configurable delay → ON). This clears stale Bluetooth connections, audio routing issues, and "phantom paired" states that plague Sonos, Chromecast, and other networked speakers. If no reset switches are configured, this step is skipped entirely.

### Guaranteed Temporary Switch Cleanup

Temporary switches (helper booleans, relay flags) are turned ON at the start of the arrival flow and guaranteed to turn OFF on every exit path — including entrance timeout, entrance-clear timeout, and normal completion. There's no code path that leaves switches dangling.

### Two-Phase Entrance Wait

The automation waits twice for the entrance sensor: once for the person to arrive (sensor → ON), and once for them to move past the door (sensor → OFF). This prevents the greeting from firing while you're still standing in the doorway fumbling with keys.

## Features

- **Multi-person trigger** — Select multiple person entities. The automation fires when any of them arrives home. Friendly names are joined with "and" in the greeting (e.g., "Miquel and Ana").
- **Custom arrival names** — Multiline text field for custom names (one per line). When provided, these override person entity friendly names in the greeting. Useful for partners, guests, or anyone without a HA person entity.
- **GPS bounce protection** — Cooldown timer using `this.attributes.last_triggered` prevents re-triggers from GPS bouncing. Configurable from 60s to 3600s (default 900s / 15 minutes).
- **Physical presence confirmation** — Entrance occupancy sensor must trigger before the flow proceeds. GPS-only arrivals are filtered out.
- **Speaker hardware reset (optional)** — Power-cycle switches clear stale audio connections before the greeting plays. Leave the switch list empty to skip this step entirely.
- **Temporary switch lifecycle** — Helper switches activated during the flow, guaranteed cleanup on all exit paths.
- **AI-generated greeting** — `conversation.process` generates a personalized welcome using `{{ person_name }}` which resolves to custom names (if provided), person entity friendly names joined with "and", or "someone" as a final fallback. Falls back to a static greeting if the LLM fails.
- **Interactive Assist conversation** — `assist_satellite.start_conversation` speaks the greeting and opens a follow-up conversation on Voice PE satellites. The `extra_system_prompt` provides arrival context so the agent understands responses like "both" or "just the workshop."
- **Multi-satellite support** — Target multiple Voice PE / Assist satellite entities for whole-house announcements.
- **Timeout on every wait** — Both entrance waits have configurable timeouts with clean abort paths.

## Prerequisites

- **Home Assistant 2024.10.0+**
- One or more **person entities** with GPS-based home/not_home tracking
- An **occupancy binary_sensor** at the entrance (e.g., Aqara FP2 zone, PIR sensor)
- A **conversation agent** (OpenAI, Ollama, Google AI, etc.)
- One or more **Assist satellite** entities (Voice PE or compatible)

**Optional:**
- **Switches** for speaker power-cycle reset (e.g., smart plugs powering speakers)
- **Helper switches** (`input_boolean` exposed as switches) for temporary flags

## Installation

1. Copy `coming_home.yaml` into your blueprints directory:
   ```
   config/blueprints/automation/<your_namespace>/coming_home.yaml
   ```
   Or import via URL if hosted on GitHub.

2. Create a new automation from the blueprint: **Settings → Automations → Create Automation → Use Blueprint**

3. At minimum, configure the person entities, entrance sensor, conversation agent, and Assist satellites. Reset switches are optional.

## Configuration

### Top-Level

| Input | Default | Description |
|-------|---------|-------------|
| **Persons** | — | Person entities whose arrival triggers the automation. Multiple persons supported — fires when any arrive. |
| **Arrival names** | — | Custom names for the AI greeting (one per line). Overrides person entity friendly names when provided. |

### ① Detection & Triggers

| Input | Default | Description |
|-------|---------|-------------|
| **Entrance occupancy sensor** | (required) | Binary sensor confirming physical presence at the entrance |
| **Entrance wait timeout** | 2 min | How long to wait for entrance sensor after GPS triggers |
| **Cooldown (seconds)** | 900 | Minimum seconds between runs to suppress GPS bounce |

### ② Device Preparation

| Input | Default | Description |
|-------|---------|-------------|
| **Reset switches** | — | Switches to power-cycle for speaker reset. Leave empty to skip. |
| **Reset delay** | 2 sec | Pause between OFF and ON during power-cycle |
| **Temporary switches** | (required) | Switches activated during arrival flow, guaranteed cleanup |

### ③ AI Conversation

| Input | Default | Description |
|-------|---------|-------------|
| **Conversation agent** | (required) | LLM agent for greeting generation and follow-up |
| **AI greeting prompt** | Snarky greeting asking about lights | Prompt sent to agent — use `{{ person_name }}` for the arriving person |
| **Assist satellites** | (required) | Voice PE / satellite entities for the greeting and conversation |

### ④ Cleanup & Timing

| Input | Default | Description |
|-------|---------|-------------|
| **Post-conversation delay** | 1 min | Wait after starting the Assist conversation before turning off temporary switches |

## Exit Paths and Cleanup

| Exit Path | Temporary Switches | Volume/Speakers |
|-----------|-------------------|-----------------|
| GPS bounce (cooldown) | Never turned on | Not touched |
| Entrance timeout (no physical arrival) | Never turned on | Not touched |
| Entrance-clear timeout (stuck in doorway) | Turned OFF before abort | Already reset (if configured) |
| Normal completion | Turned OFF after delay | Already reset (if configured) |

Every path that activates temporary switches also deactivates them. No dangling state.

## Technical Notes

- Runs in `mode: restart` — a new arrival restarts any in-progress flow (handles the case where someone leaves and returns quickly).
- `trigger_variables` resolves `cooldown_seconds` for use in the condition block (before action-level variables are available).
- The cooldown uses `this.attributes.last_triggered` with a default of year 2000 to handle first-ever runs where the attribute doesn't exist yet.
- `continue_on_error: true` on `conversation.process` and `assist_satellite.start_conversation` prevents LLM failures from blocking the flow.
- The greeting fallback uses defensive `is defined` checks on the nested response structure (`ai_greeting.response.speech.plain.speech`).
- The `person_name` variable resolves through a three-tier priority: custom names text field → person entity friendly names → "someone". Custom names are split by newline and joined with "and".
- When multiple person entities are configured, the trigger fires on any of them transitioning to `home`. Each arrival is independent — if two persons arrive within the cooldown window, only the first triggers the flow.
- The `extra_system_prompt` on `assist_satellite.start_conversation` feeds the greeting text back to the agent so it has full context for follow-up responses.
- The AI greeting prompt is passed directly via `!input` (not a variable) — the `{{ person_name }}` template is resolved at render time from the action-level variable.

## Changelog

- **v3:** Multi-person support — person selector accepts multiple entities, new multiline text field for custom arrival names (overrides entity friendly names, one per line). Reset switches now optional (empty list skips power-cycle step). Reset switches changed from target selector to entity selector for clean optional default.
- **v2:** Full style guide compliance — collapsible sections, modern syntax, aliases, variable scope fix
- **v1:** Initial version

## Author

**madalone**

## License

See repository for license details.
