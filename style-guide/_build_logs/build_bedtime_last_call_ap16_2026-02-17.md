# Build Log — bedtime_last_call.yaml AP-16 Fix

| Field | Value |
|-------|-------|
| **File** | `blueprints/automation/madalone/bedtime_last_call.yaml` |
| **Task** | AP-16 remediation: add `| default()` guard to `states()` call |
| **Mode** | BUILD (escalated from AUDIT) |
| **Audit ref** | `audit_bedtime_last_call_2026-02-17_report.md` |
| **Git checkpoint** | `f0052e38` (`checkpoint_20260217_120316`) |
| **Started** | 2026-02-17 |
| **Status** | completed |

## Plan

Single-line fix at line 343. Change:
```jinja
{{ states(player_entity) not in ['playing', 'buffering'] }}
```
To:
```jinja
{{ states(player_entity) | default('unknown') not in ['playing', 'buffering'] }}
```

No other files affected. No version bump needed (this is a bugfix within v2.1).

## Edit Log

| # | Line | Change | Verified |
|---|------|--------|----------|
| 1 | 343 | Added `\| default('unknown')` to `states(player_entity)` call | ✅ |

