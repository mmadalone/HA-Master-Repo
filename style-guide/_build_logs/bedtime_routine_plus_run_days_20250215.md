# Build Log — bedtime_routine_plus: Add weekday active logic
- **Date:** 2025-02-15
- **Blueprint:** `bedtime_routine_plus.yaml`
- **Status:** completed
- **Version:** v5.2.0 → v5.3.0

## Summary
Port `run_days` weekday gating from `proactive_llm_sensors.yaml` to bedtime blueprint.
Manual triggers bypass day gate; scheduled triggers respect it.

## Changes
1. New input `run_days` in ① Trigger section (after `presence_require_all`) — line 112
2. New variables `run_days`, `today_key` in variables block — lines 851-853
3. Replaced empty `conditions: []` with day-of-week template condition — line 983
4. Added v5.3.0 changelog entry in blueprint description

## Design Decisions
- No `effective_day_key` (cross-midnight attribution) — bedtime fires at a single time, not a window
- All 7 days default selected — existing instances unaffected
- Manual trigger bypass matches existing presence gate bypass pattern
- Used simple `today_key` via `now().weekday()` — same pattern as proactive sensors

## Verification
- All three insertion points verified via post-edit read
- File grew from 2042 to 2098 lines (56 lines added)
- YAML structure intact, no indentation errors
