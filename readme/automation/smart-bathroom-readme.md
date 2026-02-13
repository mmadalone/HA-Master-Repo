# Smart Bathroom Occupancy Light Control (Door + Shower Zone Optional)

![Smart bathroom header](https://raw.githubusercontent.com/mmadalone/HA-Master-Repo/main/images/header/smart-bathroom-header.jpeg)

An occupancy-aware bathroom light automation based on the "Hornet in the Box" principle: if a person enters a closed room and motion is detected, they're inside; when the door opens and motion stops, they've left. This blueprint extends the concept with optional door and shower zone sensors — disable either toggle and the corresponding sensor is completely ignored in all logic.

When a shower zone sensor is active (e.g. Aqara FP2 zone), the light stays on even if the main motion sensor clears behind a glass shower door.

## How It Works

```
                    ┌──────────────────────────┐
                    │      DOOR OPENED          │
                    └────────────┬─────────────┘
                                 │
                    ┌────────────▼─────────────┐
                    │  Helper OFF (not occupied)?│
                    ├─── YES ──→ Turn light ON  │  Branch 2: Someone entering
                    ├─── NO  ──→ Wait for exit  │  Branch 5: Someone leaving
                    └──────────────────────────┘
                                 │
                           (Branch 5)
                                 │
                    ┌────────────▼─────────────┐
                    │  Wait for motion to stop   │
                    │  + shower zone to clear     │
                    │  (with timeout safety)      │
                    └────────────┬─────────────┘
                                 │
                    ┌────────────▼─────────────┐
                    │  Turn light OFF            │
                    │  Clear occupancy helper    │
                    └──────────────────────────┘

        ┌───────────────────────────────────────────┐
        │          MOTION DETECTED                   │
        ├─ Door open / no door → Light ON + occupied │  Branch 4
        ├─ Door closed + not occupied → Mark occupied│  Branch 3
        └───────────────────────────────────────────┘

        ┌───────────────────────────────────────────┐
        │          MOTION STOPPED                    │
        │  + (no door or door open)                  │
        │  + occupied                                │
        │  + shower zone NOT active                  │
        │  → Light OFF + clear helper                │  Branch 1
        └───────────────────────────────────────────┘

        ┌───────────────────────────────────────────┐
        │       SHOWER ZONE CLEARED                  │
        │  + occupied + motion off                   │
        │  + (no door or door open)                  │
        │  → Light OFF + clear helper                │  Branch 7
        └───────────────────────────────────────────┘

        ┌───────────────────────────────────────────┐
        │         DOOR CLOSED                        │
        │  + not occupied                            │
        │  → Light OFF                               │  Branch 6
        └───────────────────────────────────────────┘
```

## Decision Branches

| Branch | Trigger | Conditions | Action |
|--------|---------|------------|--------|
| 1 | Motion stopped | No door or door open, occupied, shower zone not active | Light OFF, clear helper |
| 2 | Door opened | Not occupied | Light ON (welcome light) |
| 3 | Motion detected | Helper off (door closed case) | Mark occupied |
| 4 | Motion detected | No door or door open | Light ON, mark occupied |
| 5 | Door opened | Occupied | Wait for motion stop + shower clear, then light OFF |
| 6 | Door closed | Not occupied | Light OFF |
| 7 | Shower zone cleared | Occupied, motion off, no door or door open | Light OFF, clear helper |

## Features

- **Optional door sensor** — Toggle `Use Door Sensor?` off and the door entity is completely ignored. Works as a simple motion→light automation without it.
- **Optional shower zone** — Toggle `Use Shower Zone Sensor?` off to skip shower logic. When enabled, the light stays on as long as the shower zone reports presence, even if the main motion sensor clears (common with glass shower doors blocking PIR/mmWave).
- **Hysteresis on motion** — Configurable delay after motion clears before treating it as "no motion," accounting for sensor cooldown.
- **Exit wait timeout** — Safety timeout on the Branch 5 exit wait (default 30 minutes) prevents the automation from hanging indefinitely if a sensor fails or gets stuck.
- **HA restart resilience** — Uses an `input_boolean` occupancy helper that persists across restarts rather than relying on automation variables.
- **Live state checks** — Branch 5 uses inline `is_state()` checks instead of pre-computed variables to avoid stale state after long waits (fixed in v3).

## Prerequisites

- A **motion/occupancy sensor** (`binary_sensor`) for the bathroom
- An **`input_boolean`** helper for occupancy tracking — create in Settings → Helpers
- A **light**, **switch**, or **input_boolean** entity to control

**Optional:**
- A **door/contact sensor** (`binary_sensor` with `device_class: door` or `opening`)
- A **shower zone sensor** (`binary_sensor` with `device_class: occupancy`, `presence`, or `motion`) — e.g. an Aqara FP2 zone configured for the shower area

## Installation

1. Copy `smart-bathroom.yaml` into your blueprints directory:
   ```
   config/blueprints/automation/<your_namespace>/smart-bathroom.yaml
   ```
   Or import via URL if hosted on GitHub.

2. Create the occupancy helper: **Settings → Helpers → Create Helper → Toggle**

3. Create a new automation from the blueprint: **Settings → Automations → Create Automation → Use Blueprint**

## Configuration

### ① Sensors & Detection

| Input | Required | Description |
|-------|----------|-------------|
| **Motion Sensor** | Yes | Primary motion/occupancy sensor for the bathroom |
| **Use Door Sensor?** | — | Toggle to enable/disable door sensor logic |
| **Door Sensor** | If enabled | Door/contact sensor entity |
| **Use Shower Zone Sensor?** | — | Toggle to enable/disable shower zone logic |
| **Shower Zone Sensor** | If enabled | Presence zone sensor covering the shower area |

### ② Lights & Helpers

| Input | Description |
|-------|-------------|
| **Bathroom Light** | Light, switch, or input_boolean to control |
| **Occupancy Helper** | Dedicated input_boolean that tracks whether the bathroom is occupied |

### ③ Timing

| Input | Default | Description |
|-------|---------|-------------|
| **Motion Sensor Delay** | 2s | Delay after motion clears before treating as "no motion" |
| **Exit Wait Timeout** | 30 min | Maximum wait time in Branch 5 before forcing cleanup |

## Technical Notes

- Runs in `mode: single` — only one execution at a time, which matches the single-occupant bathroom use case.
- Template triggers are used for door and shower zone events so they can be conditionally active based on the enable toggles. When a sensor is disabled, its template trigger never evaluates to true.
- Branch ordering in the `choose` block matters: Branch 5 (door opened + occupied) is evaluated before Branches 3/4 (motion detected) to ensure the exit-wait logic takes priority when the door opens while someone is inside.
- The v3 fix addresses a stale variable race condition where pre-computed shower zone state could become outdated during the motion wait in Branch 5. All state checks after a `wait_for_trigger` now use live `is_state()` calls.
- Requires **Home Assistant 2024.10.0** or newer.

## Acknowledgments

This blueprint is based on the [Smart Bathroom Occupancy Light Control (Hornet-in-the-Box Principle)](https://community.home-assistant.io/t/smart-bathroom-occupancy-light-control/874353) by **Murat Çeşmecioğlu**, published on the Home Assistant Community forums in April 2025. The "Hornet in the Box" principle (also known as "Wasp in the Box") — using door + motion sensor logic to determine room occupancy — originates from [wernerhp's AppDaemon script](https://github.com/wernerhp/ha.appdaemon.wasp) and has been implemented in various forms across the HA community.

This version adds optional door/shower zone sensor toggles, Aqara FP2 shower zone support, configurable timeouts with safety fallbacks, stale-state race condition fixes, and style-guide compliance.

## Author

**Murat Çeşmecioğlu** (original), modified by **Madalone**

## License

See repository for license details.
