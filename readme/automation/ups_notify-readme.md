# UPS – Notify on Power Events (NUT Status Sensor)

![UPS Notify header](https://raw.githubusercontent.com/mmadalone/HA-Master-Repo/main/images/header/ups_notify-header.jpeg)

A Home Assistant automation blueprint that sends mobile notifications when your UPS switches to battery power, when utility power returns, and when the battery level drops below a configurable threshold. Uses the NUT integration's status sensor to detect power events.

## What It Does

| Event | Trigger | Notification |
|-------|---------|--------------|
| **Power outage** | UPS status changes to contain `OB` (On Battery) | "Mains power is out. UPS switched to battery. Current charge: X%." |
| **Power restored** | UPS status transitions from `OB` to non-`OB` (back to mains) | "Utility power has returned. UPS is back on mains. Battery now at X%." |
| **Battery low** | Battery percentage drops below threshold while on battery | "UPS battery is low (X%). System will shut down soon according to NUT settings." |

## How It Works

```
NUT Status Sensor (e.g. sensor.madups_status)
    │
    ├─ OL        = On line (mains power)
    ├─ OL CHRG   = On line, charging
    ├─ OB DISCHRG = On battery, discharging
    └─ OB LB     = On battery, low battery

         ┌────────────────────┐
         │  Status changed?   │──→ Contains "OB"? ──→ Power outage notification
         │                    │──→ Was "OB", now not? ──→ Power restored notification
         └────────────────────┘

         ┌────────────────────┐
         │  Battery below     │──→ Currently on battery? ──→ Low battery warning
         │  threshold?        │
         └────────────────────┘
```

## Prerequisites

- **NUT integration** configured in Home Assistant with a connected UPS
- **Two NUT sensors:**
  - A status sensor (e.g. `sensor.madups_status`) reporting values like `OL`, `OB DISCHRG`, `OL CHRG`
  - A battery charge sensor (e.g. `sensor.madups_battery_charge`) reporting percentage
- **Mobile app** or other notification service configured in HA

## Installation

1. Copy `ups_notify.yaml` into your blueprints directory:
   ```
   config/blueprints/automation/<your_namespace>/ups_notify.yaml
   ```
   Or import via URL if hosted on GitHub.

2. Create a new automation from the blueprint: **Settings → Automations → Create Automation → Use Blueprint**

3. Configure the inputs (see below).

## Configuration

### ① UPS Sensors

| Input | Description |
|-------|-------------|
| **UPS status sensor** | NUT sensor reporting UPS status. Values typically contain `OL` (on line), `OB` (on battery), `LB` (low battery), `CHRG` (charging). |
| **UPS battery percentage** | NUT sensor reporting battery charge as a percentage (0–100). |

### ② Thresholds & Notifications

| Input | Default | Description |
|-------|---------|-------------|
| **Low battery warning threshold** | 30% | Battery level below which a low-battery warning is sent (only while on battery). NUT itself handles the actual host shutdown based on its own config. |
| **Notification service** | `notify.mobile_app_madaringer` | HA notify service to use. Free-text field since HA blueprints have no native notify-service selector. |

## Technical Notes

- Runs in `mode: restart` / `max_exceeded: silent` — a new power event always takes priority over a previous one in flight.
- The low-battery notification only fires when the UPS is actually on battery (`OB` in status). A low battery reading while on mains (e.g. during initial charging) won't trigger a warning.
- Power restoration is detected by checking that the previous status contained `OB` and the current status does not — this catches transitions like `OB DISCHRG` → `OL CHRG` regardless of the specific NUT status strings your UPS reports.
- This blueprint handles notifications only. It does not perform host shutdown — that's NUT's responsibility based on its own configuration (`upsmon`).
- Requires **Home Assistant 2024.10.0** or newer.

## Acknowledgments

UPS notification automations based on NUT status sensors are a well-documented pattern in the Home Assistant community. The [official NUT integration documentation](https://www.home-assistant.io/integrations/nut/) includes example automations for power outage and battery monitoring that cover the same core concepts. This blueprint packages the pattern into a reusable, configurable format with style-guide-compliant structure.

## Author

**madalone**

## License

See repository for license details.
