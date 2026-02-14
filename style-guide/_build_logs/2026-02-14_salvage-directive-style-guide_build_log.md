# Build Log — Salvage Directive Style Guide Integration

## Meta
- **Date started:** 2026-02-14
- **Status:** completed
- **Target file(s):** `06_anti_patterns_and_workflow.md`, `ha_style_guide_project_instructions.md`
- **Style guide sections loaded:** §10 (anti-patterns scan table), §11.0 (universal pre-flight), §11.8 (build log schema)

## Decisions
- Deliverable 1 (project instructions Salvage Directive section): ALREADY DONE — confirmed in project instruction field
- AP-41: new anti-pattern for ignoring crash recovery signals, severity ⚠️ WARNING
- §11.0 addition: reactive crash detection paragraph bridging user-triggered phrases to existing proactive protocol
- §11.8 Recovery section: ADDED — structured cold-start checklist inside build log schema
- Version bump: 3.12 → 3.13

## Completed Edits
- [x] Add AP-41 to Development Environment scan table in §10
- [x] Update AP numbering note ("AP-01 through AP-41")
- [x] Update Development Environment narrative header ("36–41")
- [x] Add narrative entry #41 to Development Environment section
- [x] Add reactive crash detection paragraph to §11.0 (after Step 3, before Log-before-edit invariant)
- [x] Bump style guide version 3.12 → 3.13 in master index header
- [x] Add `## Recovery (for cold-start sessions)` section to §11.8 build log schema
- [x] Add Recovery bullet to "Why every field matters" list in §11.8

## Files modified
- `06_anti_patterns_and_workflow.md` — AP-41 scan table row, numbering note, section header, narrative entry #41, §11.0 reactive detection paragraph, §11.8 Recovery section + field explanation
- `ha_style_guide_project_instructions.md` — version bump 3.12 → 3.13

## Current state
All edits complete and verified. No outstanding items.
