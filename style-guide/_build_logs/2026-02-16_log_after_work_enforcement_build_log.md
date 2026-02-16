# Build Log — Log-after-work enforcement (Edit Log section + AP-43)

## Meta
- **Date started:** 2026-02-16
- **Status:** completed
- **Mode:** BUILD
- **Target file(s):** `06_anti_patterns_and_workflow.md`, `ha_style_guide_project_instructions.md`
- **Style guide sections loaded:** §10 (AP table), §11.0 (invariants), §11.8 (build log schema)
- **Git checkpoint:** not required (style guide edits, not HA config)

## Task
Add two structural fixes to prevent batching of build log updates: (1) Add an `## Edit Log` section to the §11.8 build log schema template with per-edit timestamped lines, making the update-after-each-edit step visible in the template itself. (2) Add AP-43 to the scan table flagging build logs that exist but weren't updated between edits ("stale log" anti-pattern). Both fixes address the failure mode observed during the v3.20 session where 7 edits landed without a single log update.

## Decisions
- New AP: AP-43, severity ⚠️ WARNING, Development Environment group
- Edit Log section goes inside the schema template between "Files modified" and "Current state"
- Corresponding Rule #43 in the Development Environment numbered rules
- Version bump: 3.20 → 3.21

## Planned Work
- [x] Edit 1: §11.8 schema template — added `## Edit Log` section with format, instructions, and example entries between Files Modified and Current State
- [x] Edit 2: §11.0 log-after-work invariant — BUILD instruction now references `## Edit Log` section
- [x] Edit 3: AP-43 scan table entry — added after AP-41 in Development Environment group
- [x] Edit 4: Rule #43 prose — added after rule 41 in Development Environment numbered rules
- [x] Edit 5: Master index version bump 3.20→3.21 + changelog entry

## Edit Log
- [1] 06_anti_patterns_and_workflow.md — §11.8 schema: added `## Edit Log` section with format/instructions/examples — DONE
- [2] 06_anti_patterns_and_workflow.md — §11.0 log-after-work invariant: BUILD instruction now references Edit Log — DONE
- [3] 06_anti_patterns_and_workflow.md — AP-43 added to Dev Environment scan table — DONE
- [4] 06_anti_patterns_and_workflow.md — Rule #43 added after rule 41 — DONE
- [5] ha_style_guide_project_instructions.md — version 3.20→3.21 + changelog — DONE

## Files Modified
- `06_anti_patterns_and_workflow.md` — §11.8 schema (Edit Log section added), §11.0 invariant updated, AP-43 in scan table, Rule #43 in numbered rules
- `ha_style_guide_project_instructions.md` — version bumped 3.20→3.21, changelog entry added

## Current State
All 5 edits complete. Ready to commit.

## Recovery
- **Resume from:** N/A — all edits complete
- **Next action:** Commit via post-edit publish workflow
- **Decisions still open:** None
- **Blockers:** None
- **Context recovery:** "log after work enforcement edit log AP-43 v3.21"
