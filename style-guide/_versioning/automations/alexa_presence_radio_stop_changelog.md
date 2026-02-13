# alexa_presence_radio_stop — Changelog

## v5 — 2026-02-11
- **ERROR** Fixed AP-16: added `player_list | length > 0` guard in `stop_targets` template to prevent index-out-of-range when player list is empty in presence mode
- **WARNING** Changed `>` to `>-` on `detected_index` and `stop_targets` variable templates (§3.7 — strip trailing newline)
- **WARNING** Added `default: []` to auto-reset `choose` block for explicit no-op in traces

## v4 — 2026-02-11
- **ERROR** Fixed AP-16: added `| int(-1)` guard on `detected_index` final output `{{ ns.idx }}`
- **WARNING** Fixed AP-11: added `id: trigger_boolean_on` to trigger block (§5.6)
- **WARNING** Fixed AP-02: resolved `trigger_entity` via `!input` in variables block; action now uses `{{ trigger_entity }}` instead of hardcoded `!input trigger_entity`
- **WARNING** Added `continue_on_error: true` on radio boolean cleanup action
- **INFO** Added `continue_on_error: true` on `media_player.media_pause` and `media_player.media_stop` actions (AP-17)
- **INFO** Replaced `# ---` em-dash dividers with `# ===` box-style dividers in variables and actions sections (§3.2)
- Updated blueprint description changelog to v4
- Skipped AP-35 (pause default) — intentional design choice; stop is correct default for radio use case
- Skipped AP-13 (boolean vs select) — booleans appropriate for independent toggles

## v3 — 2026-02-11
- Fixed AP-16: added `| default('off')` guard on `states(sensor)` in `detected_index` template
- Renamed input section YAML keys from `stage_N_xxx` to descriptive names (§3.2)
- Updated section display names to circled Unicode numbers: `"① Trigger"` etc. (§3.2)
- Added three-line `===` box-style comment dividers before each input section (§3.2)
- Added explicit `conditions: []` for structural completeness
- Updated blueprint description changelog to v3

## v2 — 2026-02-09
- Added `author:` field to blueprint header
- Restructured inputs into proper "Stage N — Phase" collapsible sections (§3.2)
- Added `alias:` to every action, choose branch, and service call (§3.5)
- Added `### Recent changes` section to blueprint description (§3.1)
- Updated description image URL to local blueprint-specific image
- Replaced heavy comment dividers with lighter section markers

## v1 — pre-2026-02-09
- Initial version (pre-style-guide review)
