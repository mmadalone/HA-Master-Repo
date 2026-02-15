# Build Log — bedtime_routine.yaml weekday active logic port

| Field | Value |
|---|---|
| **Date** | 2026-02-15 |
| **File** | `blueprints/automation/madalone/bedtime_routine.yaml` |
| **Version** | v4.1.1 → v4.2.0 |
| **Task** | Port run_days + weekend overrides from bedtime_routine_plus.yaml |
| **Checkpoint** | `checkpoint_20260215_215531` (b8a56c54) |
| **Status** | completed |

## Changes

1. **Input: `run_days`** — added to ① TRIGGER after `presence_require_all`
2. **Input section: ⑧ Weekend overrides** — new collapsed section after ⑦ Final goodnight TTS
3. **Variables** — `run_days`, `weekend_mode`, `weekend_days`, `weekend_scheduled_time_val`, `today_key`, `trigger_scheduled_time`, `effective_day_key`, `is_weekend`, `weekend_profile_active`, `weekend_blocked`
4. **Trigger** — `scheduled_weekend` time trigger added
5. **Conditions** — replaced `conditions: []` with day-gate template condition
6. **Description** — bumped to v4.2.0 with changelog entry
