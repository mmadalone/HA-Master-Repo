# Music Assistant – Follow Me (Idle OFF + Optional Auto-ON)

![Music Assistant Follow Me Idle Off](https://raw.githubusercontent.com/mmadalone/HA-Master-Repo/main/images/header/music_assistant_follow_me_idle_off-header.jpeg)

A companion automation that manages your follow-me toggle (`input_boolean`). It automatically disables follow-me when all monitored Music Assistant players have been idle for a configurable duration, and optionally re-enables it when any player starts playing again.

Designed to be used alongside the **Music Assistant – Follow Me (multi-room advanced)** blueprint, which handles the actual queue transfers based on presence. This blueprint just manages the on/off switch that gates that behavior.

## How It Works

```
Any monitored MA player changes state
                │
                ▼
┌──────────────────────────────────┐
│  COMPUTE STATE                    │
│                                   │
│  all_idle = every player has been │
│  non-playing for ≥ idle_minutes   │
│                                   │
│  any_playing = at least one       │
│  player is in "playing" state     │
└──────────────┬───────────────────┘
               │
         ┌─────┴─────┐
         │           │
   AUTO-OFF      AUTO-ON
   (Branch 1)    (Branch 2)
         │           │
         ▼           ▼
┌──────────────┐ ┌──────────────────┐
│ Switch is ON  │ │ Auto-enable ON   │
│ + all_idle    │ │ + switch is OFF  │
│ → turn OFF    │ │ + any_playing    │
│               │ │ → turn ON        │
└──────────────┘ └──────────────────┘
```

The two branches are mutually exclusive: Branch 1 only fires when the switch is currently ON, Branch 2 only fires when the switch is currently OFF.

## Features

- **Auto-disable on idle** — When all monitored MA players have been non-playing for at least the configured idle duration, the follow-me toggle turns OFF. Prevents follow-me from staying armed when nobody's listening to anything.
- **Auto-enable on playback** — Optionally turns the follow-me toggle back ON when any monitored player starts playing. This means you just start music anywhere and follow-me activates automatically.
- **Per-player idle tracking** — Uses each player's `last_changed` timestamp to determine how long it's been idle, not just current state. A player that just stopped doesn't count as "idle for 15 minutes" until 15 minutes have actually passed.
- **Reactive triggering** — Fires on every state change of any monitored player, so it responds immediately to playback starting and checks idle duration on every transition.

## Prerequisites

- **Music Assistant** integration
- An **`input_boolean`** for the follow-me toggle (e.g. `input_boolean.music_follow_me`)
- One or more **Music Assistant media_player** entities to monitor
- The **Music Assistant – Follow Me (multi-room advanced)** blueprint (or similar) configured to use the same `input_boolean`

## Installation

1. Copy `music_assistant_follow_me_idle_off.yaml` into your blueprints directory:
   ```
   config/blueprints/automation/<your_namespace>/music_assistant_follow_me_idle_off.yaml
   ```
   Or import via URL if hosted on GitHub.

2. Ensure the follow-me toggle helper exists: **Settings → Helpers → Create Helper → Toggle**

3. Create a new automation from the blueprint: **Settings → Automations → Create Automation → Use Blueprint**

## Configuration

### ① Core Settings

| Input | Description |
|-------|-------------|
| **Follow music toggle** | The `input_boolean` that enables/disables your follow-me behavior |
| **Music players to monitor** | One or more Music Assistant media_player entities that may hold your queues |

### ② Behavior

| Input | Default | Description |
|-------|---------|-------------|
| **Idle minutes before disabling** | 15 min | How long ALL players must be non-playing before the toggle turns OFF |
| **Auto-enable on playback** | On | Automatically turn the toggle ON when any monitored player starts playing |

## Idle Calculation

The `all_idle` check is strict: it requires that every monitored player satisfies both conditions simultaneously. If any player is currently in `playing` state, `all_idle` is false. If any player's `last_changed` timestamp is more recent than `idle_minutes` ago, `all_idle` is also false — even if that player is now in `idle` or `paused` state. This prevents the toggle from turning off too soon after the last player stops.

## Typical Setup

```
┌─────────────────────────────┐     ┌──────────────────────────────────┐
│  This blueprint              │     │  Follow Me (multi-room advanced)  │
│  Manages the toggle          │────▶│  Reads the toggle as a gate       │
│  ON when playing starts      │     │  Transfers queues on presence     │
│  OFF when all players idle   │     │  Only acts when toggle is ON      │
└─────────────────────────────┘     └──────────────────────────────────┘
              │
              ▼
    input_boolean.music_follow_me
```

Both blueprints reference the same `input_boolean`. This one controls when follow-me is armed; the multi-room advanced blueprint controls where the music goes.

## Technical Notes

- Runs in `mode: single` / `max_exceeded: silent` — prevents overlapping evaluations.
- Triggers on every state change of any monitored player via a state trigger with no `to:` filter. This ensures both idle timeout and playback start are detected promptly.
- The idle check uses `expand()` to iterate players and `as_timestamp(p.last_changed)` for time comparison, making it resilient to HA restarts (which reset `last_changed`).
- No minimum HA version dependency beyond the parent blueprint's requirement of **Home Assistant 2024.10.0**.

## Author

**madalone**

## License

See repository for license details.
