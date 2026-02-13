# wake-up-guard — Changelog

## v5 — 2026-02-09
- **Style guide fix:** Added `id: wake_time` to trigger (§5.6 — future-proofs
  for multi-trigger, cleaner traces)
- **Style guide fix:** Added template justification comment on weekday condition
  (§1.4 — no native equivalent exists)
- **Style guide fix:** Stripped all numbered `# N)` comments from action section.
  Kept only comments that add context beyond what the alias conveys (§3.5)
- **Style guide fix:** Added runtime validation warning comment on
  `action: !input notify_service` (no load-time validation for string-as-action)
- ⚠️ **Pre-flight miss:** v4 backup was created AFTER v5 edits were applied.
  The `wake-up-guard_v4.yaml` file contains v5 changes. Clean rollback point
  is v3.

## v4 — 2026-02-09
- **Style guide fix:** Replaced hardcoded `script.wake_guard_tts_speak` and
  `script.wake_guard_stop_cleanup` with configurable inputs + defaults (Anti-Pattern #2)
- **Style guide fix:** Added `person_display_name` input — notification messages
  no longer hardcode "miquel" in action section (Anti-Pattern #2)
- **Style guide fix:** Added YAML comment on `notify_service` explaining why
  text selector is used (no native notify selector in blueprints) (Anti-Pattern #13)
- **Style guide fix:** Added YAML comment on `assist_satellite_entity` noting
  domain has no device_class to filter on (§3.3)
- Added variables for new inputs (`v_person_name`, `v_tts_speak_script`,
  `v_stop_cleanup_script`)

## v3 — 2026-02-08
- Extracted TTS routing into `script.wake_guard_tts_speak` (eliminates 3x duplication)
- Extracted stop-cleanup into `script.wake_guard_stop_cleanup` (eliminates 3x duplication)
- Changed `llm_agent_id` selector from `text` to `conversation_agent` (proper HA picker)
- Added description image (SVG in `/local/blueprint-images/wake-up-guard-header.svg`)
- Blueprint now depends on two companion scripts (see README)

## v2 — 2026-02-08
- **BUG FIX:** Bed presence condition now actually checks duration via `last_changed` (was only checking current state, ignoring `min_bed_minutes` entirely)
- **BUG FIX:** Workshop empty condition now actually checks duration via `last_changed` (was only checking current state, ignoring `min_workshop_empty_minutes` entirely)
- Added collapsible input sections organized by automation phase (§3.2)
- Added `author:` field, removed placeholder `source_url:`
- Added `homeassistant.min_version: 2024.6.0` (collapsible sections require it)
- Added changelog and placeholder image to blueprint description (§3.1)
- Migrated all `service:` calls to `action:` syntax (§1.4)
- Added numbered comments on all action steps alongside existing aliases (§3.5)
- Simplified weekday template from 14-line if/elif chain to one-liner
- Fixed toggle cleanup on default (no snooze/stop) timeout path — toggles were never reset
- Changed `homeassistant.turn_on` → `script.turn_on` for music script calls
- Improved LLM response extraction with safer nested access via `default()` filters
- Added `conversation_agent` selector note in description for `llm_agent_id` (kept as text for EOAI compat)

## v1 — pre-2026-02-08
- Initial version (unversioned, pre-style-guide)
