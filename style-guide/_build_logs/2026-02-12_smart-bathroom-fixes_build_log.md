# Build Log — smart-bathroom v2→v3 fixes

## Meta
- **Date started:** 2026-02-12
- **Status:** completed
- **Last updated chunk:** 1 of 1
- **Target file(s):** `/config/blueprints/automation/madalone/smart-bathroom.yaml`
- **Style guide sections loaded:** §3, §5, §10, §11.2

## Decisions
- Issue 1 (WARNING): Fix stale `shower_zone_active` variable in Branch 5 — inline `is_state()` check
- Issue 2 (INFO): Consolidate 7 sequential `choose:` blocks into single `choose:` with 7 branches
- Issue 3 (INFO): Remove pre-computed state variables (`door_is_open`, `door_is_closed`, `shower_zone_active`), inline `is_state()` calls in conditions. Keep static input refs (`has_door`, `door_entity`, etc.)
- Branch ordering for consolidated choose: Branch 4 must precede Branch 3 (motion_detected overlap — Branch 4 is more specific)
- `door_is_closed` is dead code (defined but never referenced in actions) — removed

## Completed chunks
- [x] Full file rewrite (description v3, variables, consolidated actions)

## Files modified
- `_versioning/automations/smart-bathroom_v2.yaml` — backup of current file
- `_versioning/automations/smart-bathroom_changelog.md` — v3 entry added
- `/config/blueprints/automation/madalone/smart-bathroom.yaml` — v3 rewrite

## Current state
All fixes applied and validated. YAML syntax check passed. File written to SMB mount.
v2 backup in _versioning/automations/smart-bathroom_v2.yaml. Changelog updated with v3 entry.
User should: (1) Reload automations in Developer Tools → YAML, (2) Check blueprint instance for schema errors, (3) Run manually and verify trace.
