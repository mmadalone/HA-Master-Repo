# Build Log — ha_aqara_devices FP2 Refactor (Fork)

## Meta
- **Date started:** 2026-02-19
- **Status:** completed
- **Mode:** BUILD
- **Target file(s):**
  - `HA_CONFIG/custom_components/ha_aqara_devices/__init__.py`
  - `HA_CONFIG/custom_components/ha_aqara_devices/sensor.py`
  - `HA_CONFIG/custom_components/ha_aqara_devices/binary_sensor.py`
  - `HA_CONFIG/custom_components/ha_aqara_devices/manifest.json`
  - `HA_CONFIG/custom_components/ha_aqara_devices/const.py`
  - `HA_CONFIG/custom_components/ha_aqara_devices/api.py`
  - `HA_CONFIG/custom_components/ha_aqara_devices/fp2.py`
- **Style guide sections loaded:** N/A (custom integration Python, not blueprint YAML)
- **Git checkpoint:** N/A (custom_components not tracked by HA MCP git — manual backup at `ha_aqara_devices_backup_20260219/`)

## Task
Refactor the `ha_aqara_devices` HACS integration (forked from Darkdragon14/ha-aqara-devices)
to fix critical FP2 presence sensor reliability issues. The integration currently creates
**duplicate DataUpdateCoordinators** per FP2 device (one in `sensor.py`, one in
`binary_sensor.py`), each polling Aqara cloud every 2 seconds with 3 concurrent API calls —
resulting in ~12 cloud round-trips every 2 seconds per device. Presence detection uses a
history-log endpoint instead of real-time state, adding propagation delay. The manifest
falsely claims `cloud_push` when the integration is pure polling. The user plans to move
FP2 presence/zone binary sensors back to HomeKit (local push, fast) and keep this integration
only for: (a) FP2 people-count analytics sensors at a relaxed polling interval, and (b) full
Camera Hub G3 control features. All modified files must clearly reflect this is a fork.

## Decisions
- FP2 binary sensors: REMOVE entirely from cloud integration (user will use HomeKit for presence/zone occupancy — local push is 10-100x faster than cloud polling)
- FP2 sensor polling interval: increase from 2s to 30s (people-count analytics don't need sub-second freshness; reduces API load by 15x)
- Coordinator architecture: centralize in `__init__.py` — one shared coordinator per FP2 device, one per G3 camera. Platform modules consume the shared coordinator via `hass.data[DOMAIN]` (rejected per-platform coordinators — current design causes duplicate API calls)
- FP2 `get_fp2_presence()` history call: REMOVE from coordinator update cycle (presence is moving to HomeKit; the history endpoint was the primary source of latency and staleness)
- FP2 coordinator update method: use `get_fp2_status()` + `get_fp2_settings()` only (2 API calls instead of 3, at 30s interval instead of 2s = ~97% reduction in cloud API load)
- manifest.json `iot_class`: change from `cloud_push` to `cloud_polling` (honest)
- Fork attribution: add fork notice to manifest `documentation` URL, add `FORK_NOTICE` constant to `const.py`, update `__init__.py` module docstring
- Camera Hub G3: NO CHANGES to G3 coordinator architecture or features — G3 stays as-is, already works correctly
- G3 coordinator: also centralize in `__init__.py` for consistency (same pattern, same shared approach)

## Planned Work
- [x] **Pre-flight:** back up current `custom_components/ha_aqara_devices/` directory → `ha_aqara_devices_backup_20260219/`
- [x] **1. manifest.json** — fix `iot_class` to `cloud_polling`, update `documentation` URL to fork repo, bump version to 0.4.0-beta
- [x] **2. const.py** — add `FORK_NOTICE`, `FORK_AUTHOR`, `FORK_REPO`, `FORK_UPSTREAM` constants; add `FP2_POLL_INTERVAL_SECONDS` (30) and `G3_POLL_INTERVAL_SECONDS` (1); fork docstring
- [x] **3. api.py** — add `get_fp2_analytics_state()` method (status + settings only, no history/presence call); add fork docstring header
- [x] **4. fp2.py** — remove `FP2_BINARY_SENSORS_DEF` (entire block + zone binary helper + BinarySensorDeviceClass import); keep all sensor specs unchanged; add fork docstring header
- [x] **5. __init__.py** — centralize coordinators: `AqaraFP2Coordinator` (30s, calls `get_fp2_analytics_state`), `AqaraG3Coordinator` (1s, calls `get_device_states`), stored in `hass.data[DOMAIN][entry.entry_id]`; first refresh validates connectivity; fork docstring header
- [x] **6. sensor.py** — FP2 sensors consume shared `fp2_coordinators` from `hass.data` instead of creating local coordinator; M3 hub path unchanged; fork docstring header
- [x] **7. binary_sensor.py** — remove ALL FP2 binary sensor setup (entire loop + `AqaraFP2BinarySensor` class); G3 cameras consume shared `g3_coordinators` from `hass.data`; M3 hub path unchanged; fork docstring header
- [x] **8. Verify** — cross-referenced all imports: zero dangling references to removed symbols, all new imports resolve correctly

## Files modified
- `manifest.json` — iot_class, documentation URL, codeowners, version
- `const.py` — fork attribution constants, coordinator interval constants, module docstring
- `api.py` — `get_fp2_analytics_state()` method, fork docstring
- `fp2.py` — removed binary sensor definitions + import, fork docstring
- `__init__.py` — full rewrite: centralized coordinator classes + shared instances
- `sensor.py` — FP2 section consumes shared coordinator, fork docstring
- `binary_sensor.py` — FP2 section + class removed, G3 uses shared coordinator, fork docstring

## Edit Log
- 2026-02-19 — Pre-flight: backed up directory to `ha_aqara_devices_backup_20260219/`
- 2026-02-19 — manifest.json: `iot_class` → `cloud_polling`, docs/issues URLs → fork, `@mmadalone` added to codeowners, version → `0.4.0-beta`
- 2026-02-19 — const.py: added fork docstring, `FORK_NOTICE`, `FORK_AUTHOR`, `FORK_REPO`, `FORK_UPSTREAM`, `FP2_POLL_INTERVAL_SECONDS=30`, `G3_POLL_INTERVAL_SECONDS=1`
- 2026-02-19 — api.py: added fork docstring, added `get_fp2_analytics_state()` (status+settings, no presence)
- 2026-02-19 — fp2.py: added fork docstring, removed `BinarySensorDeviceClass` import, removed `_zone_presence_binary_sensor()`, `FP2_ZONE_BINARY_SENSORS_DEF`, `FP2_BINARY_SENSORS_DEF` — sensor specs untouched
- 2026-02-19 — __init__.py: full rewrite — added `AqaraFP2Coordinator` class (30s poll), `AqaraG3Coordinator` class (1s poll), `async_config_entry_first_refresh()` for both, stored in `hass.data[DOMAIN][entry.entry_id]`
- 2026-02-19 — sensor.py: FP2 loop now fetches shared `fp2_coordinators` from `hass.data`, removed local coordinator creation + `get_fp2_full_state` call; M3 unchanged
- 2026-02-19 — binary_sensor.py: removed entire FP2 loop + `AqaraFP2BinarySensor` class + `from .fp2 import FP2_BINARY_SENSORS_DEF`; G3 cameras now use shared `g3_coordinators`; M3 unchanged
- 2026-02-19 — __init__.py: added `_derive_zone_people_count()` function (counts active detection_area zones); FP2 coordinator now calls it post-fetch; imported `FP2_ZONE_COUNT` from const
- 2026-02-19 — fp2.py: added "Zone-Based People Count" derived sensor spec (`derived_zone_people_count` key) to `FP2_COUNT_SENSORS_DEF` — ported from dev copy at `ha_aqara_devices.madalone/`

## Current state
All 8 planned work items completed. Build verified — zero dangling references, all imports clean.

### Known follow-ups (out of scope for this build):
- `switch.py`, `number.py`, `select.py`, `button.py` still create local G3 coordinators (pre-existing duplication, not a regression). Should migrate to shared `g3_coordinators` in a follow-up build.
- `get_fp2_full_state()` and `get_fp2_presence()` are dead code in api.py — kept for backward compatibility, can be pruned later.
- M3 hub entities still use local coordinators — M3 centralization was not in scope.

## Recovery (for cold-start sessions)
- **Resume from:** COMPLETED — no further action needed
- **Decisions still open:** None
- **Blockers:** None — restart Home Assistant to test
