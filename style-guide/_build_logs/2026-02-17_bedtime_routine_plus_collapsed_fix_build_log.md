# Build Log — bedtime_routine_plus.yaml collapsed sections fix

## Metadata
- **Date:** 2026-02-17
- **File:** `bedtime_routine_plus.yaml`
- **Version:** v5.3.2 → v5.3.3
- **Mode:** BUILD (crash recovery from chat 28b8af7c)
- **Status:** complete

## Root Cause
HA refuses to collapse a section if ANY input has a null `default:` (bare YAML key with no value). Entity/time selectors need `default: ""` — not null. §⑥–⑪ collapse because every input has an actual value.

## Planned Work
- [x] Fix §① `collapsed: false` → `collapsed: true`
- [x] Fix all bare `default:` → `default: ""` in §①②③④⑨⑪
- [x] Update changelog v5.3.2 → v5.3.3
- [x] Verify file after edits — zero remaining bare `default:` on input selectors

## Edit Log
1. §① `collapsed: false` → `collapsed: true`
2. §① `scheduled_time`: `default:` → `default: ""`
3. §① `manual_trigger`: `default:` → `default: ""`
4. §② `tv_entity`: `default:` → `default: ""`
5. §② `tv_off_script`: `default:` → `default: ""`
6. §② `living_room_lamp`: `default:` → `default: ""`
7. §③ `tts_engine`: `default:` → `default: ""`
8. §④ `kodi_entity`: `default:` → `default: ""`
9. §④ `kodi_tts_player`: `default:` → `default: ""`
10. §⑨ `bathroom_sensor`: `default:` → `default: ""`
11. §⑨ `countdown_helper`: `default:` → `default: ""`
12. §⑪ `weekend_scheduled_time`: `default:` → `default: ""` (preventive)
13. Changelog updated: v5.3.2 → v5.3.3
14. §① `scheduled_time`: `default: ""` → `default: "23:00:00"` — empty string crashes `at:` trigger parsing
15. §⑪ `weekend_scheduled_time`: `default: ""` → `default: "00:30:00"` — same issue
