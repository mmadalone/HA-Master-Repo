# Build Log — bedtime_routine_plus: Full weekend override system
- **Date:** 2025-02-15
- **Blueprint:** `bedtime_routine_plus.yaml`
- **Status:** completed
- **Version:** v5.2.0 → v5.3.0

## Summary
Full port of weekday/weekend scheduling from `proactive_llm_sensors.yaml`.
Adds run_days gate, weekend overrides (mode/days/separate schedule), cross-midnight
day attribution via `effective_day_key`, and dual time triggers.

## Changes
1. Input `run_days` in ① Trigger section (previously applied)
2. New input section ⑪ Weekend overrides (collapsed): weekend_mode, weekend_days, weekend_scheduled_time
3. New trigger `scheduled_weekend` using weekend_scheduled_time
4. Variables block expanded: run_days, weekend_mode, weekend_days, weekend_scheduled_time_val,
   today_key, trigger_scheduled_time, effective_day_key, is_weekend, weekend_profile_active, weekend_blocked
5. Condition expanded: manual bypass, weekend_blocked check, trigger/profile cross-validation,
   effective_day_key against run_days
6. Description changelog updated to reflect full weekend system

## Design Decisions
- `effective_day_key` uses `trigger_scheduled_time` (trigger-specific) for cross-midnight
  attribution. If scheduled time is before noon → shift back one day.
- `is_weekend` checks `effective_day_key` (not raw `today_key`) to prevent double-firing.
  Saturday 01:00 weekend trigger → effective_day_key=fri → is_weekend=false → blocked.
- Condition cross-validates trigger ID against weekend_profile_active: weekday trigger blocked
  when profile active, weekend trigger blocked when profile inactive.
- `collapsed: true` on ⑪ — most users won't need weekend overrides.
- All defaults safe for existing instances: weekend_mode=same_as_weekdays, all 7 run_days selected.

## Cross-Midnight Scenarios Verified
- Thu 23:00 weekday trigger, Fri not in run_days → effective_day_key=thu → runs ✓
- Fri 01:00 weekend trigger → effective_day_key=thu → is_weekend=false → blocked ✓
- Sat 01:00 weekend trigger → effective_day_key=fri → is_weekend=false → blocked ✓
- Sat 23:00 weekday trigger → effective_day_key=sat → weekend_profile_active → blocked ✓
- Sun 01:00 weekend trigger → effective_day_key=sat → is_weekend=true → runs ✓
- Mon 01:00 weekend trigger → effective_day_key=sun → is_weekend=true → runs ✓
- Mon 23:00 weekday trigger → effective_day_key=mon → is_weekend=false → runs ✓
- Tue 01:00 weekend trigger → effective_day_key=mon → is_weekend=false → blocked ✓

## Verification
- File grew from 2094 to 2202 lines (108 lines added)
- All five edit zones verified via post-edit read
- YAML structure intact
