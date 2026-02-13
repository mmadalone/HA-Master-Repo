# Changelog — wake_up_guard_external_alarm.yaml

## v2 — 2026-02-11
Full style-guide compliance rewrite.

### Fixes applied (16 total)
| # | AP-ID | Severity | Fix |
|---|-------|----------|-----|
| 1 | AP-16 | ❌ ERROR | `as_timestamp(alarm)` → `as_timestamp(alarm, 0)` with `alarm_ts == 0` guard |
| 2 | AP-16 | ❌ ERROR | `| int` → `| int(0)` default on offset |
| 3 | AP-15 | ⚠️ WARNING | Added header image to description + generated image file |
| 4 | no-AP | ⚠️ WARNING | Added `author: madalone` |
| 5 | no-AP | ⚠️ WARNING | Added "Recent changes" section in description |
| 6 | AP-09 | ⚠️ WARNING | Wrapped inputs in collapsible sections (① Alarm source, ② Wake-up action) |
| 7 | AP-10 | ⚠️ WARNING | `trigger:` → `triggers:` |
| 8 | AP-10a | ⚠️ WARNING | `platform: time_pattern` → `trigger: time_pattern` |
| 9 | AP-10 | ⚠️ WARNING | `condition:` → `conditions:` |
| 10 | AP-10 | ⚠️ WARNING | `action:` → `actions:` |
| 11 | AP-10 | ⚠️ WARNING | `service: script.turn_on` → `action: script.turn_on` |
| 12 | AP-11 | ⚠️ WARNING | Added `alias:` on action step |
| 13 | no-AP | ⚠️ WARNING | Added `variables:` block resolving all inputs |
| 14 | no-AP | ⚠️ WARNING | Added `min_version: "2024.10.0"` |
| 15 | no-AP | ℹ️ INFO | Template scalar `>` → `>-` throughout |
| 16 | no-AP | ℹ️ INFO | Added `alias:` on trigger for trace visibility |

### Architecture notes
- Core logic unchanged: minute-by-minute poll checks if `now()` falls within 60 s window of (alarm_time − offset)
- Template now has two-stage guard: first checks for bad states, then validates `as_timestamp` returns non-zero
- Variables block resolves `!input` references once at automation load for cleaner templates

## v1 — pre-2026-02-11
Original file, pre-compliance.
