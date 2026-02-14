# Build Log — URL constants, image cleanup, README step placement

## Session
- **Date started:** 2026-02-14
- **Status:** completed
- **Scope:** Add GIT_REPO_URL/HEADER_IMG_RAW constants, image cleanup steps, README workflow triggers in §11.1/§11.3
- **Style guide sections loaded:** §1 (Core Philosophy), §10/§11 (anti-patterns/workflow), §3.1 (blueprint header), §15 (QA checklist)
- **Style guide version:** 3.8 → 3.9
- **Files in scope:** 4

## File Queue
- [x] SCANNED — ha_style_guide_project_instructions.md | edits: 1 (version bump)
- [x] SCANNED — 06_anti_patterns_and_workflow.md | edits: 6
- [x] SCANNED — 01_blueprint_patterns.md | edits: 1
- [x] SCANNED — 09_qa_audit_checklist.md | edits: 0 (no hardcoded URLs present)

## Planned Changes

### ha_style_guide_project_instructions.md
1. ~~Add GIT_REPO_URL and HEADER_IMG_RAW to Project Paths block~~ → Added to Claude Project Instructions instead (these are env paths, not style guide content)
2. Version bump 3.8 → 3.9

### 06_anti_patterns_and_workflow.md
3. §11.1 step 4: replaced hardcoded raw.githubusercontent URL with HEADER_IMG_RAW constant
4. §11.1 step 4: added image cleanup sub-steps (delete originals, rejected attempts, orphans)
5. §11.1: added step 8 — README generation after verification
6. §11.2 step 1b: replaced hardcoded URL with HEADER_IMG_RAW + filename reference
7. §11.3: added step 4 — README sync check on material edits
8. §11.14: replaced hardcoded URL references with HEADER_IMG_RAW constants

### 01_blueprint_patterns.md
9. §3.1: replaced hardcoded URL with HEADER_IMG_RAW constant

### 09_qa_audit_checklist.md
10. ~~ARCH-6: replace hardcoded URL references with constants~~ → No hardcoded URLs present; no edit needed

## Issues Found
| # | File | AP-ID | Severity | Line | Description | Status |
|---|------|-------|----------|------|-------------|--------|
| 1 | multiple | no-AP | ⚠️ WARNING | various | Hardcoded raw.githubusercontent URLs across active files | FIXED |
| 2 | 06_anti_patterns | no-AP | ℹ️ INFO | §11.1 | No image cleanup after approval/rejection | FIXED |
| 3 | 06_anti_patterns | no-AP | ℹ️ INFO | §11.1 | No README generation step in build workflow | FIXED |
| 4 | 06_anti_patterns | no-AP | ℹ️ INFO | §11.3 | No README sync check in edit workflow | FIXED |

## Fixes Applied
| # | File | Description | Issue ref |
|---|------|-------------|-----------|
| 1 | ha_style_guide_project_instructions.md | Version bump 3.8 → 3.9 | — |
| 2 | Claude Project Instructions | Added GIT_REPO_URL and HEADER_IMG_RAW constants | #1 |
| 3 | 06_anti_patterns_and_workflow.md | §11.1 step 4: URL → HEADER_IMG_RAW + image cleanup sub-steps | #1, #2 |
| 4 | 06_anti_patterns_and_workflow.md | §11.1 step 8: README generation step | #3 |
| 5 | 06_anti_patterns_and_workflow.md | §11.2 step 1b: URL → HEADER_IMG_RAW | #1 |
| 6 | 06_anti_patterns_and_workflow.md | §11.3 step 4: README sync check | #4 |
| 7 | 06_anti_patterns_and_workflow.md | §11.14: URLs → constants | #1 |
| 8 | 01_blueprint_patterns.md | §3.1: URL → HEADER_IMG_RAW | #1 |

## Current State
All edits confirmed on disk. Zero remaining hardcoded mmadalone/HA-Master-Repo URLs in active style guide files.
Note: Session initially crashed mid-run; resumed session verified all edits had landed despite build log not being updated.

Commit message for sync:
```
[docs] style guide v3.9: URL constants, image cleanup, README workflow steps
- GIT_REPO_URL and HEADER_IMG_RAW constants replace all hardcoded GitHub URLs
- §11.1 step 4: mandatory image cleanup after approval/rejection (delete orphans)
- §11.1 step 8: README generation as explicit build step
- §11.3 step 4: README sync check on material edits
- §11.2 step 1b: review asset check uses HEADER_IMG_RAW constant
```
