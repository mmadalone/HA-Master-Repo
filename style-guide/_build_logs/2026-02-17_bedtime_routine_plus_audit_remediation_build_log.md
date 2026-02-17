# Build Log — bedtime_routine_plus.yaml audit remediation

## Metadata
- **Date:** 2026-02-17
- **File:** `bedtime_routine_plus.yaml`
- **Version:** v5.3.1 → v5.3.2
- **Mode:** BUILD (escalated from AUDIT)
- **Audit reference:** `2026-02-17_bedtime_routine_plus_audit_report.log`
- **Status:** complete

## Decisions
- Escalated from quick-pass audit per user request
- All four findings to be remediated
- AP-08 (nesting depth) deferred to dedicated refactoring session — requires extracting TTS delivery pattern to helper script, which is architectural work beyond a fix pass
- User requested: all input sections must have `collapsed: true`, defaults set to best practices

## Planned Work
- [x] Remove duplicate `source_url` at L4 (no-AP finding)
- [x] Add `collapsed: true` to §① Trigger and §② Devices
- [x] AP-17: Add logbook.log fallback after preset Kodi play_media failure
- [x] AP-04: Replace `continue_on_error: true` with `continue_on_timeout: true` on pre-fetch wait_for_trigger blocks
- [x] AP-08: Acknowledged — deferred (needs TTS helper script extraction)
- [x] Update changelog in description
- [x] Verify file after edits

## Edit Log
1. Removed duplicate `source_url:` at L4 (kept L39 which is the canonical position after description block). YAML parsers were silently dropping L4 anyway.
2. Added `collapsed: true` to §① Trigger section. All inputs already have defaults — no changes needed.
3. Added `collapsed: true` to §② Devices section. All inputs already have defaults — no changes needed.
4. AP-17: Added Kodi playback verification after preset play_media + post-play delay. Uses if/then to check Kodi state — logs to logbook if not in playing/paused/buffering. continue_on_error stays (don't abort routine on Kodi failure) but now failures are visible.
5. AP-04: Replaced `continue_on_error: true` with `continue_on_timeout: true` on all 4 pre-fetch wait_for_trigger blocks (in-progress shows, movies, recently added episodes, favourites). Semantic intent is now explicit.
6. Updated changelog in description: v5.3.1 → v5.3.2 with all remediation items listed.
