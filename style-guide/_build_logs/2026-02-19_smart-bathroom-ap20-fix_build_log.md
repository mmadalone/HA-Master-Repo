# Build Log — smart-bathroom AP-20 motion pre-check fix

## Meta
- **Date started:** 2026-02-19
- **Status:** completed
- **Mode:** audit-escalation
- **Target file(s):** /Users/madalone/Library/Containers/nz.co.pixeleyes.AutoMounter/Data/Mounts/Home Assistant/SMB/config/blueprints/automation/madalone/smart-bathroom.yaml
- **Style guide sections loaded:** §5.1 (wait semantics), §10 (AP-20)
- **Git checkpoint:** checkpoint_20260219_210425 (1459806c)

## Task
Fix AP-20 in Branch 5: wait_for_trigger on motion "off" won't fire if motion already cleared before the wait starts. Wrap the motion wait + timeout handler in a pre-check — if motion is already off, skip to shower zone check. Audit escalation from 2026-02-19_smart-bathroom_audit_report.log.

## Decisions
- Approach: wrap wait_for_trigger + timeout handler in if(motion==on) guard (rejected wait_template — can't express the for: duration for sensor cooldown)
- Accepts +1 nesting depth (AP-08 already flagged and deferred by user)

## Planned Work
- [x] Wrap Branch 5 motion wait in pre-check condition

## Files modified
- smart-bathroom.yaml — Branch 5 motion wait wrapped in if(motion still on) pre-check

## Edit Log
- [1] smart-bathroom.yaml — wrapped motion wait + timeout in if(motion=="on") guard — DONE

## Current state
AP-20 fix applied and verified. File grew from 445 to 451 lines (6 lines added for the if/then wrapper). Ready for HA git commit.

## Recovery
- **Resume from:** complete
- **Next action:** git commit
- **Decisions still open:** None
- **Blockers:** None
- **Context recovery:** "smart-bathroom AP-20 motion pre-check"
