# smart-bathroom — Changelog

## v3 — 2026-02-12
- Fixed stale shower_zone_active race condition in Branch 5 (could skip shower wait after long motion wait)
- Consolidated 7 sequential choose blocks into single choose with 7 branches (cleaner traces)
- Inlined state checks, removed pre-computed state variables (door_is_open/closed, shower_zone_active)
- Removed dead code: door_is_closed variable was defined but never referenced

## v2 — 2026-02-11
- Full style guide compliance rewrite: modern syntax (action:/trigger:/plural keys), collapsible input sections, aliases on all steps
- Added timeout handling + cleanup on both wait_for_trigger blocks (was hanging indefinitely)
- Consolidated 7 single-branch choose blocks into one choose with 7 branches
- Added header image, min_version, Recent changes block, entity validation guards

## v1 — 2025-11-25
- Initial version (original by Murat Çeşmecioğlu, modified by Madalone & Miquel)
