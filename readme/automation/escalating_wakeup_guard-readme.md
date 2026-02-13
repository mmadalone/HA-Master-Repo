# Escalating Wake-Up Guard – Inverted Presence

![Escalating wake-up guard](https://raw.githubusercontent.com/mmadalone/HA-Master-Repo/main/images/header/escalating_wakeup_guard-header.jpg)

A multi-stage escalation alarm that uses inverted presence logic: instead of checking if you're in bed, it monitors non-bedroom activity sensors to determine whether you've gotten up. No activity detected = still asleep = escalate further. Volume and brightness interpolate smoothly from start to end values across a configurable number of stages (1–6), with optional per-tier LLM message generation, music at a configurable stage, and final-stage light flashing.

Designed as **Layer 2** behind [llm_alarm.yaml](./llm_alarm.yaml) — it fires 5–10 minutes after the primary alarm so it only activates if you slept through Layer 1.

## How It Works

```
Guard time trigger (e.g., 07:10)
            │
            ▼
    ┌──────────────────────┐
    │ Weekday check         │──── Not active day → stop
    └──────────┬───────────┘
               │
               ▼
    ┌──────────────────────┐
    │ Activity check        │──── Any sensor active → stop
    │ (inverted presence)   │     (user already up)
    └──────────┬───────────┘
               │
               ▼
    ┌──────────────────────────────────────────────┐
    │           ESCALATION LOOP                     │
    │  repeat: num_stages (1–6)                     │
    │                                               │
    │  For each stage:                              │
    │  ┌──────────────────────────────────────────┐ │
    │  │ 1. Inter-stage wait (skip on stage 1)    │ │
    │  │    ├─ Monitor: mobile STOP               │ │
    │  │    ├─ Monitor: stop_toggle ON            │ │
    │  │    ├─ Monitor: activity sensors           │ │
    │  │    └─ Timeout: stage_delay minutes        │ │
    │  │    → Any cancel signal = cleanup + stop   │ │
    │  │                                           │ │
    │  │ 2. Set volume (interpolated)              │ │
    │  │ 3. Set lights (interpolated, optional)    │ │
    │  │ 4. Select message tier:                   │ │
    │  │    ├─ First → gentle                      │ │
    │  │    ├─ Middle → insistent                  │ │
    │  │    └─ Final → nuclear                     │ │
    │  │    (LLM or static per tier)               │ │
    │  │ 5. TTS: speak message                     │ │
    │  │ 6. Start music (at configured stage)      │ │
    │  │ 7. Mobile notification (stage 1 only)     │ │
    │  │ 8. Flash lights (final stage only)        │ │
    │  └──────────────────────────────────────────┘ │
    └──────────────────┬───────────────────────────┘
                       │
                       ▼
              Restore volume
              Reset stop toggle
              Fire cleanup script
```

## Inverted Presence Logic

Traditional wake-up automations check "are you in bed?" — which requires a bed sensor. This blueprint inverts the question: **"have you been active outside the bedroom?"** It monitors non-bedroom binary sensors (motion, presence zones, door contacts) and considers you awake if any sensor is currently ON or was ON within the lookback window.

The lookback window (default 5 minutes) prevents false negatives: a motion sensor that turned OFF 3 minutes ago still means you were up 3 minutes ago. This check runs both before the loop starts (bail immediately if already up) and between every stage (stop escalating the moment you move).

## Features

- **Multi-stage escalation** — 1–6 configurable stages with smooth volume and brightness interpolation from start to end values. The interpolation formula uses `progress = (index - 1) / (stages - 1)` for linear ramping.
- **Inverted presence detection** — Monitors non-bedroom activity sensors with a configurable lookback window. Any recent activity = awake = escalation stops.
- **Three message tiers** — First stage (gentle), middle stages (insistent), final stage (nuclear). Each tier independently supports LLM generation or static text with `{{ stage }}` / `{{ total }}` / `{{ stage_delay }}` template variables.
- **Per-tier LLM generation** — Each tier can independently use a conversation agent. LLM prompts receive stage metadata and optional sensor context (weather, temperature, etc.). Falls back to static text if LLM fails (`continue_on_error` + defensive dict traversal).
- **Music at configurable stage** — Starts a music script at a specified stage number (e.g., stage 3). Music fires once and continues through subsequent stages.
- **Final-stage light flashing** — Rapid on/off flash cycles at full brightness for maximum annoyance. Configurable flash count (1–20).
- **Multiple cancellation paths** — Mobile STOP button, `input_boolean` toggle (for HA UI or other automations), or activity sensor detection. All paths trigger cleanup.
- **Cleanup on every exit** — Volume restored, stop toggle reset, optional cleanup script fired on every exit path (interrupted or completed).

## Prerequisites

- **Home Assistant 2024.6.0+**
- **Binary sensors** outside the bedroom (motion, presence, door contacts)
- A **TTS engine** entity
- A **media_player** for TTS output
- An **`input_boolean`** for the stop toggle (create via **Settings → Helpers → Toggle**)
- Optional: a **conversation agent** for LLM message generation
- Optional: a **script entity** for music playback
- Optional: **lights** for brightness escalation and flashing

## Installation

1. Copy `escalating_wakeup_guard.yaml` into your blueprints directory:
   ```
   config/blueprints/automation/<your_namespace>/escalating_wakeup_guard.yaml
   ```

2. Create the stop toggle helper: **Settings → Helpers → Create Helper → Toggle**

3. Create a new automation from the blueprint: **Settings → Automations → Create Automation → Use Blueprint**

## Configuration

### ① Schedule

| Input | Default | Description |
|-------|---------|-------------|
| **Active weekdays** | Mon–Fri | Days on which the guard runs |
| **Guard time** | (required) | When escalation begins — set 5–10 min after your primary alarm |

### ② Activity Sensors

| Input | Default | Description |
|-------|---------|-------------|
| **Activity sensors** | (required) | Non-bedroom binary sensors for inverted presence detection |
| **Activity lookback** | 5 min | How recently a sensor must have been ON to count as activity |

### ③ TTS & Voice

| Input | Description |
|-------|-------------|
| **TTS engine** | TTS entity for `tts.speak` |
| **TTS output player** | Media player for TTS audio and volume control |

### ④ Escalation

| Input | Default | Description |
|-------|---------|-------------|
| **Number of stages** | 4 | How many escalation stages (1–6) |
| **Delay between stages** | 10 min | Wait time between stages — activity monitored during wait |
| **Start volume** | 0.30 | TTS volume at stage 1 |
| **End volume** | 1.0 | TTS volume at final stage |
| **Lights** | (empty) | Lights to ramp up — leave empty to skip |
| **Start brightness** | 50 | Brightness at stage 1 (0–255) |
| **End brightness** | 255 | Brightness at final stage |
| **Flash final stage** | On | Rapid flash cycles at final stage |
| **Flash count** | 10 | Number of on/off cycles (1–20) |
| **Music script** | (empty) | Script to start music playback |
| **Start music at stage** | 3 | Stage number at which music begins (0 = never) |

### ⑤ Messages (collapsed)

Each tier has a static message and optional LLM override with a custom prompt:

| Tier | Static Default | LLM Prompt Default |
|------|---------------|-------------------|
| **First** | "Good morning. Time to get up." | Gentle, friendly, under two sentences |
| **Middle** | "You are still in bed. This is stage {{ stage }} of {{ total }}." | Escalating, progressively insistent |
| **Final** | "Last warning. Stage {{ stage }} of {{ total }}. I am not asking again." | Urgent, direct, no pleasantries |

All prompts support `{{ stage }}`, `{{ total }}`, and `{{ stage_delay }}` template variables.

### ⑥ LLM Agent (collapsed)

| Input | Default | Description |
|-------|---------|-------------|
| **Conversation agent** | (empty) | HA conversation agent for LLM message generation |
| **Context entities** | (empty) | Sensor entities included in LLM prompts for richer context |

### ⑦ Mobile Notifications (collapsed)

| Input | Default | Description |
|-------|---------|-------------|
| **Notification service** | (empty) | `notify.mobile_app_<device>` — leave empty to skip |
| **Mobile stop action ID** | `ESCALATION_STOP` | Action ID for the STOP button |

### ⑧ Cleanup & Restore (collapsed)

| Input | Default | Description |
|-------|---------|-------------|
| **Restore volume** | 0.4 | Volume restored on TTS player after escalation ends |
| **Cleanup script** | (empty) | Script to fire after escalation (e.g., stop music, reset lights) |
| **Stop toggle** | (required) | `input_boolean` that cancels escalation when turned ON |

## Layered Alarm Architecture

```
Layer 1: llm_alarm.yaml
├── Fires at wake-up time (e.g., 07:00)
├── LLM-generated message + TTS
├── Mobile snooze/stop
└── Post-alarm music

Layer 2: escalating_wakeup_guard.yaml (this blueprint)
├── Fires 5–10 min later (e.g., 07:10)
├── Checks if you actually got up
├── If not → multi-stage escalation
├── Volume + brightness ramp
├── Per-tier LLM messages
└── Final-stage light flashing
```

Layer 1 is the polite alarm. Layer 2 is the enforcement mechanism that activates only if Layer 1 failed to get you out of bed.

## Interpolation Formula

For a given stage `i` out of `N` total stages:

```
progress = (i - 1) / (N - 1)    [0.0 at stage 1, 1.0 at final stage]
volume   = start_volume + (end_volume - start_volume) × progress
brightness = start_brightness + (end_brightness - start_brightness) × progress
```

For single-stage configurations (`N = 1`), progress defaults to 1.0 (end values used immediately).

Example with 4 stages, volume 0.3→1.0, brightness 50→255:

| Stage | Progress | Volume | Brightness |
|-------|----------|--------|------------|
| 1 | 0.00 | 0.30 | 50 |
| 2 | 0.33 | 0.53 | 118 |
| 3 | 0.67 | 0.77 | 187 |
| 4 | 1.00 | 1.00 | 255 |

## Technical Notes

- Runs in `mode: restart` — a new trigger restarts any in-progress escalation. Useful if the guard time changes.
- `trace: stored_traces: 15` retains debugging data for the last 15 runs.
- The activity sensor check template is duplicated at the pre-loop gate and the inter-stage cancel check. HA blueprints have no extraction/function mechanism, so the NOTE comment marks both instances for manual sync.
- Uses `condition: time` with `weekday:` for day filtering (v6 replaced the earlier template-based weekday condition).
- `continue_on_error: true` on all non-critical calls (music, notify, lights, volume restore, flash cycles) prevents a single failure from derailing the escalation.
- The message tier selector uses three boolean flags (`is_first`, `is_middle`, `is_last`) computed from `repeat.index` to select the correct LLM flag, prompt, and static fallback in a single code path (DRY pattern).
- Static messages use string `.replace()` for template variables (`{{ stage }}`, `{{ total }}`) because Jinja in input defaults isn't evaluated at runtime.
- LLM sensor context injection (v7) expands `llm_context_entities` into `friendly_name: state` pairs appended to the conversation.process text.

## Changelog

- **v7:** Wired up `llm_context_entities` — sensor readings now injected into `conversation.process` text when configured (was declared but unused)
- **v6:** Replaced template weekday condition with native `condition: time`, removed decorative cleanup banner, added `continue_on_error` on flash cycle light calls, removed orphaned `v_active_days` variable
- **v5:** Added missing inner aliases, removed decorative input section banners, added default guard on weekday condition
- **v4:** `continue_on_error` on all non-critical calls, aliases on flash delays, DRY comments on duplicated activity-sensor template

## Author

**madalone**

## License

See repository for license details.
