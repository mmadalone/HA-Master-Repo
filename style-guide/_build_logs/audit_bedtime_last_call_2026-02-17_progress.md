# Audit Progress Log — bedtime_last_call.yaml

| Field | Value |
|-------|-------|
| **File** | `bedtime_last_call.yaml` |
| **Type** | Quick-pass audit |
| **Mode** | AUDIT |
| **Started** | 2026-02-17 |
| **Status** | completed |

## Checks Performed

- [x] AP table full scan (AP-01 through AP-43)
- [x] Security checklist (S1–S8)
- [x] Header image existence (AP-15)
- [x] Template safety (`states()` / `state_attr()` default guards — AP-16)
- [x] Legacy syntax scan (AP-10, AP-10a, AP-10b)
- [x] Alias coverage (AP-11)
- [x] Collapsed section default coverage (AP-09a)
- [x] Conversation agent selector (AP-24)
- [x] `continue_on_error` appropriateness (AP-17)
- [x] Action block size (AP-08)
- [x] Wait/timeout patterns (AP-04)
- [x] Secret hygiene (AP-21)

## Findings Summary

| Severity | Count |
|----------|-------|
| ❌ ERROR | 1 |
| ⚠️ WARNING | 2 |
| ℹ️ INFO | 0 |

See report log for details.
