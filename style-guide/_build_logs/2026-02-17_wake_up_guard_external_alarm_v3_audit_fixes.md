# Build Log — wake_up_guard_external_alarm.yaml audit remediation

## Metadata

| Field             | Value |
|-------------------|-------|
| **File**          | `blueprints/automation/madalone/wake_up_guard_external_alarm.yaml` |
| **Task**          | Audit remediation — collapsible section defaults + metadata + resilience |
| **Mode**          | BUILD (escalated from AUDIT) |
| **Version**       | v2 → v3 |
| **Status**        | completed |
| **Created**       | 2026-02-17 |
| **Checkpoint**    | `6e32d5a1` (`checkpoint_20260217_223858`) |

## Scope

| # | Severity | AP-ID | Finding | Status |
|---|----------|-------|---------|--------|
| 1 | 🟡 MED | AP-44 | `alarm_sensor` (§①) missing `default:` — blocks collapse | ✅ `fixed` |
| 2 | 🟡 MED | AP-44 | `wakeup_script` (§②) missing `default:` — blocks collapse | ✅ `fixed` |
| 3 | 🟢 LOW | — | Missing `source_url:` in blueprint metadata | ✅ `fixed` |
| 4 | 🟢 LOW | AP-42 | Missing `version:` + `min_version` misplaced (bare, not under `homeassistant:`) | ✅ `fixed` |
| 5 | 🟢 LOW | AP-17 | `script.turn_on` missing `continue_on_error: true` | ✅ `fixed` |

## Planned Work

- [x] Stage 1: Add `default: {}` to `alarm_sensor` and `default: {}` to `wakeup_script` (F1, F2)
- [x] Stage 2: Add `source_url:`, nest `min_version` under `homeassistant:` (F3, F4)
- [x] Stage 3: Add `continue_on_error: true` to `script.turn_on` action (F5)
- [x] Stage 4: Update changelog in description, version bump v2 → v3, fix header image URL
- [x] Stage 5: Verify file — read back in full

## Verification

- ✅ All 2 sections have `collapsed:` key (§① false, §② true)
- ✅ All 3 inputs have explicit non-null `default:` values
- ✅ No bare `default:` (YAML null) remaining
- ✅ `source_url:` present
- ✅ `homeassistant: min_version:` properly nested (was bare)
- ✅ `continue_on_error: true` on external `script.turn_on` call
- ✅ Header image URL fixed (removed `homeassistant.local:8123` prefix)
- ✅ Changelog v3 + v2
- ✅ File reads clean at 130 lines (was 120, delta +10)

## Decisions

- Entity selectors get `default: {}` per §3.2 AP-44 (not bare `default:` which is prohibited)
- `source_url` points to `GIT_REPO_URL` + path
- `continue_on_error: true` on the script.turn_on — it's an external call, blueprint shouldn't crash if the target script is missing/broken

## Edit Log

1. F1: `alarm_sensor` — added `default: {}`, updated description to note functional requirement
2. F2: `wakeup_script` — added `default: {}`, updated description to note functional requirement
3. F3: Added `source_url:` after `author:`
4. F4: Moved `min_version:` from bare under `blueprint:` to nested under `homeassistant:` (AP-42 fix)
5. F5: Added `continue_on_error: true` to `script.turn_on` action
6. Updated changelog: added v3 entry, kept v2
7. Fixed header image URL — removed erroneous `https://homeassistant.local:8123` prefix from raw GitHub URL
