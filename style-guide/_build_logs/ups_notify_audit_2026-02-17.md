# Build Log — ups_notify.yaml Compliance Audit

| Field | Value |
|---|---|
| **File** | `blueprints/automation/madalone/ups_notify.yaml` |
| **Date** | 2026-02-17 |
| **Status** | completed |
| **Task** | Style guide compliance remediation |

## Violations Fixed

1. ✅ Added `collapsed: false` to section ① / `collapsed: true` to section ②
2. ✅ Added `default:` to entity inputs (`ups_status`, `ups_battery_percent`)
3. ✅ Added `continue_on_error: true` to all three notify actions
4. ✅ Removed empty `conditions: []`
5. ✅ Replaced hardcoded personal notify default with bare `default:`
6. ✅ Updated description example to generic `notify.mobile_app_your_device`

## Verification

Post-edit full file read confirmed all 5 fixes applied correctly. 164 lines total.
