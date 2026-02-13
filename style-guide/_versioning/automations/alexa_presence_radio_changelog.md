# alexa_presence_radio — Changelog

## v5 — 2026-02-10
- Added optional Follow-Me interlock in Stage 5 (Behaviour & safety)
  - `disable_follow_me` boolean input — toggles the feature on/off
  - `follow_me_entity` entity selector — configurable input_boolean target
  - Disable action after conditions pass: turns off Follow-Me before room detection + playback
  - Restore action after playback starts: turns Follow-Me back on so radio follows the user
  - Net effect: Follow-Me is OFF only during the ~2s room-pick window, then resumes normally
- Updated description changelog

## v4 — 2026-02-09
- Folded `trigger_entity` from top-level into Stage 1 section (§3.2 — no orphaned inputs)
- Stage 1 renamed from "Room & presence mapping" to "Trigger & room mapping"
- De-duplicated all 20 extra zone slot descriptions (§3.3 — no per-slot zone number parroting)
  - Sensors: "Binary sensor for this zone. Leave empty if unused."
  - Players: "Target speaker — can reuse a primary room speaker."

## v3 — 2026-02-09
- Renamed all input sections to `"Stage N — Phase name"` pattern (§3.2 compliance)
  - `room_configuration` → `stage_1_room_mapping`
  - `extra_zone_configuration` → `stage_2_extra_zones`
  - `media_settings` → `stage_3_media`
  - `volume_settings` → `stage_4_volume`
  - `behaviour_settings` → `stage_5_behaviour`
  - `advanced_settings` → `stage_6_advanced`
- Added `pause_instead_of_stop` boolean input in Stage 5 (§7.3 compliance)
  - New variable `pause_instead_of_stop_flag`
  - Stop-others action now branches: pause (preserves queues) vs stop (clears queues)
- Description formatting downgraded from violation — `|` block scalar is correct for code blocks (§3.7)

## v2 — 2026-02-09
- Added `author:` field to blueprint header
- Added `### Recent changes` section to description
- Updated description image to local `/local/blueprint-images/` path
- Added `alias:` to all actions, choose branches, and conditions (§3.5 compliance)
- Replaced templated `data:` dict on play_media with `choose` block per §7.2
- Added `| default()` guards to template conditions for unavailable entity safety (§3.6)

## v1 — 2026-02-09
- Initial versioned backup (pre-review state)
