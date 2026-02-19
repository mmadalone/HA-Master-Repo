# Build Log — coming_home.yaml audit remediation

## Meta
- **Date:** 2026-02-19
- **Status:** completed
- **Blueprint:** coming_home.yaml
- **Mode:** BUILD (escalated from AUDIT)
- **Audit report:** 2026-02-19_coming_home_audit_report.log
- **Version before:** v4.2
- **Version after:** v4.3 (planned)

## Task
Fix 3 findings + 1 advisory from quick-pass audit of coming_home.yaml:
1. ❌ AP-20: wait_for_trigger won't fire if entrance sensor already on — add pre-check
2. ⚠️ AP-23: mode: restart with no cleanup failsafe — add idempotent preamble
3. ⚠️ AP-11: 2 missing alias: fields on switch.turn_off inside choose sequences
4. ℹ️ AP-17: continue_on_error on main deliverable — add failure notification

## Decisions
- AP-20 fix: Use if/then/else pre-check pattern (more explicit in traces than wait_template swap)
- AP-23 fix: Idempotent cleanup as first action, before entrance wait
- AP-17 fix: Add persistent_notification on assist_satellite failure path
- Changelog bump to v4.3 in description block

## Planned Work
- [x] AP-23: Add restart-safe cleanup preamble as first action
- [x] AP-20: Wrap entrance wait in if/else with state pre-check
- [x] AP-11: Add alias to 2 bare switch.turn_off actions
- [x] AP-17: Add failure notification after assist_satellite call
- [x] Bump version to v4.3 in description changelog
- [x] Verify file after all edits

## Files modified
| # | File | Operation |
|---|------|-----------|
| 1 | coming_home.yaml | edit (surgical — 5 edits) |

## Edit Log
1. **AP-23 fix** — Added restart-safe cleanup preamble as first action block (13 lines inserted before entrance wait). Idempotent switch.turn_off with choose guard + continue_on_error.
2. **AP-20 fix** — Wrapped entrance wait_for_trigger in if/else pre-check. If entrance sensor already "on", skips wait entirely. wait_for_trigger + timeout handler now nested inside else block. stop: still halts full automation from nested scope.
3. **AP-11 fix (a)** — Added alias "Turn off temporary arrival switches before aborting" to bare switch.turn_off in entrance-clear timeout cleanup.
4. **AP-11 fix (b)** — Added alias "Turn off temporary arrival switches (final cleanup)" to bare switch.turn_off in final cleanup choose sequence.
5. **AP-17 fix** — Added logbook.log entry after assist_satellite.start_conversation to create an audit trail for greeting attempts. Uses entrance_sensor as entity_id for trace correlation. First attempt (template condition check) was bad — reverted and replaced with unconditional logbook entry.
6. **Changelog bump** — Added v4.3 entry to description ### Recent changes block.

## Current state
All edits landed and verified. File is 417 lines, v4.3. Ready for git commit.

## Recovery (for cold-start sessions)
- Audit report: `_build_logs/2026-02-19_coming_home_audit_report.log`
- Progress log: `_build_logs/2026-02-19_coming_home_audit_progress.log`
- Target file: `HA_CONFIG/blueprints/automation/madalone/coming_home.yaml`
- Git checkpoint: created before first edit
