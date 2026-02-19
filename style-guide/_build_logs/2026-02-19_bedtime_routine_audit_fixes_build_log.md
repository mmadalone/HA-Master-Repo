# Build Log — Bedtime Routine Audit Fixes

## Session
- **Date started:** 2026-02-19
- **Status:** completed
- **Mode:** BUILD
- **Target file(s):** `/config/blueprints/automation/madalone/bedtime_routine.yaml`
- **Style guide version:** 3.24
- **Predecessor:** audit conversation same session

## Task
Fix 5 issues found during §10 audit of bedtime_routine.yaml (v4.2.0):
1. AP-16: `state_attr(sensor, 'last_changed')` → `states[sensor].last_changed` (presence gate broken)
2. AP-16: `states(tv) | default('off')` on IR guard (×2 locations)
3. AP-44: bare `default:` → explicit values on 4 inputs (scheduled_time → "23:00:00", weekend_scheduled_time → "01:00:00", manual_trigger → "", tv_entity → "", tv_off_script → "", tv_ir_remote → "")
4. AP-44: missing `default:` on 7 required inputs (lights_off_target, living_room_lamp, assist_satellites, tts_engine, audiobook_player, bathroom_sensor, countdown_helper)
5. AP-44: sections ②–⑦ add `collapsed: true`

## Decisions
- Dropped finding #6 (null weekend trigger) — log noise, not actionable without HA conditional trigger support
- Dropped finding #7 (code duplication) — architectural trade-off; extraction requires external dependencies, breaking self-containment
- Default times: 23:00:00 weekday, 01:00:00 weekend
- Version bump: 4.2.0 → 4.2.1

## Edit Log
<!-- Updated after each edit lands -->
1. ✅ L732: `state_attr(sensor, 'last_changed')` → `states[sensor].last_changed` — presence duration gate now functional
2. ✅ L1062: `states(tv)` → `states(tv) | default('off')` — IR guard preset mode
3. ✅ L1378: `states(tv)` → `states(tv) | default('off')` — IR guard conversational mode
4. ✅ Inputs: bare `default:` → explicit values: scheduled_time="23:00:00", manual_trigger="", tv_entity="", tv_off_script="", tv_ir_remote="", weekend_scheduled_time="01:00:00"
5. ✅ Inputs: added `default:` to 7 required inputs: lights_off_target={}, living_room_lamp="", assist_satellites={}, tts_engine="", audiobook_player="", bathroom_sensor="", countdown_helper=""
6. ✅ Sections ②–⑦: added `collapsed: true` (6 sections)
7. ✅ Description: added v4.2.1 changelog entry

## Verification
- `state_attr.*last_changed` — zero code matches (only changelog) ✅
- `states[sensor].last_changed` — L732 confirmed ✅
- `states(tv) | default('off')` — L1062 + L1378 confirmed ✅
- `collapsed:` — 7 instances (②–⑧) confirmed ✅
- bare input `default:` — all resolved (remaining matches are `choose:` keywords or list-valued defaults) ✅
