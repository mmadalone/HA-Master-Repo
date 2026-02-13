# music_assistant_follow_me_multi_room_advanced — Changelog

## v8 — 2026-02-12
- Style guide compliance: replaced external branding URL with local header image (AP-15)
- Bumped `min_version` from `2024.6.0` to `2024.10.0` to match plural syntax usage (AP-22)
- Added `alias:` to trigger block (AP-11)
- Replaced em-dash section dividers with three-line `===` box style (§3.2)
- Trimmed description changelog from 5 entries to 3 (§3.1)
- Added v8 entry to description

## v7 — 2026-02-10
- Added `continue_on_error: true` on both `transfer_queue` action calls to prevent automation crash on MA failures
- Added 1s post-transfer settling delay + `transfer_succeeded` variable (checks target player state)
- Gated cooldown stamp, silence-other-players, and post-announcement on `transfer_succeeded`
- Added failure announcement path — calls post-announcement script with `transfer_failed: true` + `failure_reason`
- Added `announce_transfer_failure` input (boolean, default: true) in ⑤ Announcements section
- Root cause: MA `transfer_queue` 500 errors (stuck ANNOUNCEMENT state, orphaned queue) killed entire automation run

## v6 — 2026-02-10
- Replaced single `tts_players` list with independent `tts_pre_players` and `tts_post_players` lists
- Each list is parallel to presence sensors — per-zone control of pre/post announcement hardware speakers
- Added `silence_other_players` toggle — stops all non-target players after successful transfer (exclusive-room mode)
- Added `other_active_players` variable to identify active non-target players
- Removed `divert_tts_player` input (superseded by per-zone post-transfer TTS list)

## v5 — 2026-02-10
- Removed divert mode (section ⑦) entirely — to route music to a fixed room, place the same MA player in every `target_players` slot
- Simplified `target_player` and `tts_output_player` resolution (no divert branching)
- Removed `divert_enabled`, `divert_target_player`, `divert_active` inputs/variables

## v4 — 2026-02-10
- Added `tts_players` input in Core setup — parallel list of physical hardware speakers for TTS output
- Added `divert_tts_player` input in Divert mode — dedicated TTS speaker when divert is active
- Added `tts_player_list` and `divert_tts_player_entity` variables
- Added `tts_output_player` resolution in action variables — uses target_index to look up physical speaker from tts_player_list, falls back to raw_target_player if list is empty/short, uses divert_tts_player in divert mode
- Updated pre-transfer announcement script call to pass `tts_output_player`
- Updated post-transfer announcement script call to pass `tts_output_player`
- Root cause fix: MA virtual players hang when receiving TTS during active playback on Voice PE hardware

## v3 — 2026-02-09
- Added excluded source players blacklist (`excluded_source_players` input + gate condition)
- Added follow-paused-music toggle (`follow_paused_music` input + `any_music_active` variable)
- Added divert mode (section ⑦) — `divert_enabled`, `divert_target_player` inputs + `divert_active` variable
- Updated `music_source_player` to include paused state when follow-paused-music is enabled
- Updated `target_player` resolution to check divert mode first
- Updated priority anchor gate to skip in divert mode

## v2 — 2026-02-09
- Migrated all `service:` calls to `action:` (deprecated syntax)
- Migrated `trigger:`/`condition:`/`action:` top-level keys to `triggers:`/`conditions:`/`actions:`
- Migrated `platform: state` to `trigger: state` in trigger block
- Added `author: madalone` and `homeassistant: min_version: "2024.6.0"` to header
- Added `### Recent changes` section to blueprint description
- Organized all inputs into collapsible sections (§3.2)
- Added `alias:` to every action step, choose branch, and sequence item (§3.5)
- Added `integration: music_assistant` filter to MA player selectors (§7.1)
- Added missing `alias:` on persons-home condition and follow-switch condition
- Removed dead variable `follow_switch_entity` (never referenced)
- Added `| default('unknown')` guards on `states()` calls in template loops

## v1 — 2026-02-09
- Pre-fix snapshot (original as received)
