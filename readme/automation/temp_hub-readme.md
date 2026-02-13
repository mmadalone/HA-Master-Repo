# Temperature Hub – Cooling Fan Per Device

![Temperature hub header](https://raw.githubusercontent.com/mmadalone/HA-Master-Repo/main/images/header/temp_hub-header.jpeg)

A Home Assistant automation blueprint that monitors a temperature sensor and controls a smart plug (powering a cooling fan) using dual-threshold hysteresis. Turns the fan ON when temperature exceeds a high threshold and OFF when it drops below a lower threshold, preventing rapid on/off flapping. Includes a safety fallback that turns the fan OFF if the sensor becomes unavailable.

Designed to be instanced once per device — create one automation for your media center, another for your Raspberry Pi, another for your server rack, etc.

## How It Works

```
Temperature rises above HIGH threshold (e.g. 60°C)
    │
    ▼
  Fan ON ─────────────────────────────────────────┐
    │                                              │
    │  Temperature stays between LOW and HIGH      │
    │  (hysteresis zone) ── fan stays ON           │
    │                                              │
    ▼                                              │
Temperature drops below LOW threshold (e.g. 50°C)  │
    │                                              │
    ▼                                              │
  Fan OFF ◄────────────────────────────────────────┘

Sensor unavailable/unknown at any point → Fan OFF (safety)
HA restart → Re-evaluates current temperature immediately
```

The gap between the ON and OFF thresholds is the hysteresis zone. While the temperature is in this zone, the fan maintains its current state — no switching. This prevents rapid toggling when the temperature hovers around a single threshold.

## Prerequisites

- A **temperature sensor** entity (e.g. Glances CPU temp, ESPHome sensor, any `sensor` with `device_class: temperature`)
- A **smart switch** entity controlling the fan's power (e.g. a Zigbee/Wi-Fi smart plug)

## Installation

1. Copy `temp_hub.yaml` into your blueprints directory:
   ```
   config/blueprints/automation/<your_namespace>/temp_hub.yaml
   ```
   Or import via URL if hosted on GitHub.

2. Create one automation per device: **Settings → Automations → Create Automation → Use Blueprint**

3. Configure the sensor, switch, and thresholds for each device.

## Configuration

### ① Sensor & Fan

| Input | Description |
|-------|-------------|
| **Temperature sensor** | Temperature sensor to monitor. Must have `device_class: temperature`. |
| **Fan smart switch** | Smart plug or switch entity that powers the external cooling fan. |

### ② Thresholds

| Input | Default | Description |
|-------|---------|-------------|
| **Turn fan ON above** | 60°C | Fan turns ON when temperature exceeds this value. |
| **Turn fan OFF below** | 50°C | Fan turns OFF when temperature drops below this value. Set lower than the ON threshold to create hysteresis. |

### Example Configurations

| Device | Sensor | ON above | OFF below |
|--------|--------|----------|-----------|
| Media center (TV box) | Glances CPU temp | 60°C | 50°C |
| Raspberry Pi (RetroPie) | CPU thermal sensor | 65°C | 55°C |
| Network switch | ESPHome temp probe | 45°C | 38°C |

## Technical Notes

- Runs in `mode: single` / `max_exceeded: silent` — prevents overlapping evaluations.
- Triggers on every state change of the temperature sensor, plus on HA restart to sync fan state immediately after a reboot.
- The safety fallback turns the fan OFF when the sensor reports `unavailable` or `unknown`. This prevents a stuck fan if the monitored device goes offline or the sensor integration fails.
- The choose block evaluates conditions in order: hot → cool → unavailable. If the temperature is in the hysteresis zone (between LOW and HIGH) and the sensor is available, no branch matches and the fan stays in its current state — this is the intended behavior.
- Requires **Home Assistant 2024.10.0** or newer.

## Acknowledgments

Temperature-based fan/switch control with hysteresis is a well-documented pattern in the Home Assistant community, with several existing blueprints implementing similar concepts (notably [Sam04's temperature-based fan control](https://community.home-assistant.io/t/automatic-fan-control-based-on-presence-and-temperature/310398) and [HubEight's radiator fan controller](https://community.home-assistant.io/t/radiator-fan-controller/942940)). Home Assistant also provides a built-in [Threshold helper](https://www.home-assistant.io/integrations/threshold/) with hysteresis support. This blueprint packages the pattern into a minimal, device-focused format with safety fallbacks.

## Author

**madalone**

## License

See repository for license details.
