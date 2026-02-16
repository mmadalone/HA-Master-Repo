# Build Log — Kill compact build log format

## Meta
- **Date started:** 2026-02-16
- **Status:** completed
- **Mode:** BUILD (crash-recovery on second session)
- **Target file(s):** `06_anti_patterns_and_workflow.md`, `ha_style_guide_project_instructions.md`
- **Style guide sections loaded:** §10 (AP-39), §11.0 (invariants), §11.2, §11.8
- **Git checkpoint:** not required (style guide edits, not HA config)

## Task
Eliminate the two-tier build log system (compact vs full). Replace with a single mandatory schema based on the PVR channel tracker gold standard. The compact format saves 3 minutes per log but costs 30 minutes on every crash recovery — a losing trade. Every build log gets Meta, Task, Decisions, Planned Work, Files Modified, Current State, and Recovery sections. No exceptions, no "minimum viable receipt."

## Decisions
- Kill compact format entirely — one schema for all logs
- Schema based on PVR channel tracker log (the gold standard from real usage)
- Add `Mode` field to Meta (distinguishes normal builds, crash recovery, audit escalation)
- Add `Git checkpoint` field to Meta (was in PVR log, missing from schema)
- Add `Task` section (2-4 sentence scope description, was in PVR log)
- Rename "Completed chunks" → "Planned Work" (works for non-chunked builds too)
- Recovery section is MANDATORY (was "optional individually" — no longer)
- Naming convention enforcement: `YYYY-MM-DD_<slug>_build_log.md`, underscores in slug
- Historical changelog entries referencing compact format left as-is (they record what happened)
- Version bump: 3.19 → 3.20

## Planned Work
- [x] Edit 1: §11.8 main section rewrite — single schema, kill compact (two-tier table + compact schema replaced; duplicate AUDIT bullet cleaned up)
- [x] Edit 2: §11.0 log-before-work invariant — removed compact/full distinction
- [x] Edit 3: AP-39 scan table entry — removed "Compact or full format per §11.8"
- [x] Edit 4: Rule #39 prose — "(compact or full per §11.8)" → "(§11.8)"
- [x] Edit 5: §11.2 step 0 — "(compact or full per §11.8)" → "(§11.8)"
- [x] Edit 6: §11.8.2 escalation chain — "(compact or full per §11.8)" → "(§11.8)"
- [x] Edit 7: Master index LOG GATES box — "Compact or full format per §11.8" → "Full schema per §11.8 — no exceptions, no 'compact' alternative"
- [x] Edit 8: Master index version bump 3.19→3.20 + changelog entry

## Files Modified
- `06_anti_patterns_and_workflow.md` — Edits 1-6: §11.8 rewritten (killed two-tier table and compact schema, added "Why one schema" rationale and "For simple edits" guidance); removed all "compact or full" references from §11.0 invariant, AP-39 table, Rule #39, §11.2 step 0, §11.8.2 escalation chain
- `ha_style_guide_project_instructions.md` — Edits 7-8: LOG GATES box updated, version bumped 3.19→3.20, changelog entry added

## Current State
All 8 edits complete. Zero "compact or full" references remain in active directives. The only "compact" mention is in §11.8's "Why one schema" historical rationale (intentional). Ready to commit.

## Recovery
- **Resume from:** N/A — all edits complete
- **Next action:** Commit via post-edit publish workflow
- **Decisions still open:** None
- **Blockers:** None
- **Context recovery:** "kill compact build log format single schema v3.20"
