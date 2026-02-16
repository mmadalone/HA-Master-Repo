# Build Log — README updates for style guide v3.22

## Meta
- **Date started:** 2026-02-16
- **Status:** completed
- **Mode:** BUILD
- **Target file(s):** `readme/style-guide/06_anti_patterns_and_workflow-readme.md`, `readme/style-guide/ha_style_guide_project_instructions-readme.md`
- **Style guide sections loaded:** none (README-only updates driven by git diff)
- **Git checkpoint:** not required (readme files only)

## Task
Update companion README files for style guide docs changed in v3.22. Changes: audit resilience v2 (§11.15.2 per-check granularity, §11.15.3 pre-flight estimation, §11.15.4 stage splitting, §11.8 decision reasoning, §11.8.2 interpretation notes). Token count ~19.6K→~20.4K. Two READMEs affected.

## Decisions
- Scope determined by `git diff HEAD~1` — style-guide/06, style-guide/master index, style-guide/00 changed
- 00 README unaffected (doesn't reference specific token numbers from §1.9 tables)
- master index README: version v3.21→v3.22, subsection count 128→132

## Planned Work
- [x] Update 06_anti_patterns_and_workflow-readme.md
- [x] Update ha_style_guide_project_instructions-readme.md

## Files Modified
- `readme/style-guide/06_anti_patterns_and_workflow-readme.md` — 4 edits: token count, §11.15 description, §11.8 description, audit resilience key concept
- `readme/style-guide/ha_style_guide_project_instructions-readme.md` — 1 edit: subsection count + version

## Edit Log
(Updated after each write — not batched)
- [1] 06_anti_patterns_and_workflow-readme.md — token count ~19.6K→~20.4K, §11.15 description expanded (per-check, estimation, splitting), §11.8 description expanded (decision reasoning, interpretation notes), audit resilience key concept added — DONE
- [2] ha_style_guide_project_instructions-readme.md — subsection count 128→132, version v3.21→v3.22 — DONE

## Current State
Both READMEs updated and verified. Ready for publish workflow.

## Blockers
None.

## Recovery
- **Resume point:** start edits
- **Next action:** update 06 README
- **Open decisions:** none
- **Search hint:** `readme v3.22 audit resilience per-check`
