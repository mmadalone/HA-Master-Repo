# Build Log — README workflow + path corrections

## Session
- **Date started:** 2026-02-14
- **Status:** completed
- **Scope:** Add §11.14 README generation workflow, fix AP-15 image path, anchor _build_logs to PROJECT_DIR, add QA check
- **Style guide sections loaded:** §1 (Core Philosophy), §2.3 (pre-flight), §10/§11 (anti-patterns/workflow), §15 (QA checklist)
- **Style guide version:** 3.7 → 3.8
- **Files in scope:** 4 (expanded from 3 — added 00_core_philosophy.md for token estimate sync)

## File Queue
- [x] SCANNED — 06_anti_patterns_and_workflow.md | edits: 6
- [x] SCANNED — 09_qa_audit_checklist.md | edits: 2
- [x] SCANNED — ha_style_guide_project_instructions.md | edits: 5
- [x] SCANNED — 00_core_philosophy.md | edits: 2 (token estimate sync only)

## Issues Found
| # | File | AP-ID | Severity | Line | Description | Suggested fix | Status |
|---|------|-------|----------|------|-------------|---------------|--------|
| 1 | 06_anti_patterns | AP-15 | ⚠️ WARNING | AP-15 row | Stale path `/config/www/blueprint-images/` in scan table trigger text | Update to reference HEADER_IMG | FIXED |
| 2 | 06_anti_patterns | AP-15 | ⚠️ WARNING | Rule #15 | Same stale path in narrative rule text | Same fix + deprecation note | FIXED |
| 3 | 06_anti_patterns | AP-39 | ⚠️ WARNING | §11.0 | _build_logs/ path not anchored to PROJECT_DIR | Add explicit PROJECT_DIR anchoring paragraph | FIXED |
| 4 | 06_anti_patterns | no-AP | ℹ️ INFO | n/a | Missing §11.14 README workflow | Add new section after §11.13 | FIXED |
| 5 | 06_anti_patterns | no-AP | ℹ️ INFO | §11.2 | §11.2 step 1b path used GIT_REPO directly, no HEADER_IMG ref | Updated to HEADER_IMG + added README cross-reference | FIXED |
| 6 | 06_anti_patterns | no-AP | ℹ️ INFO | §11.9 | Convergence criterion #4 missing README requirement | Added README to criterion | FIXED |
| 7 | 09_qa_audit | no-AP | ℹ️ INFO | n/a | No README verification check | Added ARCH-6 check | FIXED |
| 8 | 09_qa_audit | no-AP | ℹ️ INFO | §15.2 | README trigger missing from automatic checks table | Added trigger row | FIXED |
| 9 | master index | no-AP | ℹ️ INFO | header | Version not bumped for structural change | Bumped 3.7 → 3.8 | FIXED |
| 10 | master index | no-AP | ℹ️ INFO | doc table | §11.14 not mentioned in doc index | Added to Covers column | FIXED |
| 11 | master index | no-AP | ℹ️ INFO | routing | README generation not in BUILD routing table | Added routing row | FIXED |
| 12 | master index | AIR-6 | ℹ️ INFO | doc table | Token estimate stale (13.2K → 14.8K) | Updated | FIXED |
| 13 | master index | AIR-6 | ℹ️ INFO | header | Total token estimate stale (92K → 93K) | Updated | FIXED |
| 14 | 00_core_philosophy | AIR-6 | ℹ️ INFO | §1.9 | Token table estimate for 06 file stale | Updated 13.2K → 14.8K | FIXED |
| 15 | 00_core_philosophy | AIR-6 | ℹ️ INFO | §1.9 | Total token estimate stale (83K → 93K) | Updated | FIXED |

## Fixes Applied
| # | File | Description | Issue ref |
|---|------|-------------|-----------|
| 1 | 06_anti_patterns_and_workflow.md | AP-15 scan table: path → HEADER_IMG + deprecation note | #1 |
| 2 | 06_anti_patterns_and_workflow.md | Rule #15: path → HEADER_IMG + deprecation note | #2 |
| 3 | 06_anti_patterns_and_workflow.md | §11.0: Added _build_logs PROJECT_DIR anchoring paragraph | #3 |
| 4 | 06_anti_patterns_and_workflow.md | Added §11.14 README generation workflow (~93 lines) | #4 |
| 5 | 06_anti_patterns_and_workflow.md | §11.2 step 1b: path → HEADER_IMG + README cross-ref | #5 |
| 6 | 06_anti_patterns_and_workflow.md | §11.9 criterion #4: added README requirement | #6 |
| 7 | 09_qa_audit_checklist.md | Added ARCH-6 README verification check | #7 |
| 8 | 09_qa_audit_checklist.md | §15.2: added README trigger to automatic checks | #8 |
| 9 | ha_style_guide_project_instructions.md | Version bump 3.7 → 3.8 | #9 |
| 10 | ha_style_guide_project_instructions.md | Doc index: added §11.14 to Covers | #10 |
| 11 | ha_style_guide_project_instructions.md | BUILD routing: added README generation row | #11 |
| 12 | ha_style_guide_project_instructions.md | Token estimate: 13.2K → 14.8K | #12 |
| 13 | ha_style_guide_project_instructions.md | Total tokens: 92K → 93K | #13 |
| 14 | 00_core_philosophy.md | §1.9 token table: 13.2K → 14.8K | #14 |
| 15 | 00_core_philosophy.md | §1.9 total: 83K → 93K | #15 |

## Current State
All 15 issues fixed across 4 files. Build complete.

Commit message for sync:
```
[docs] style guide v3.8: add §11.14 README workflow, fix AP-15 paths, anchor _build_logs
- New §11.14: README generation workflow (mandatory for blueprints/scripts)
- AP-15: migrated stale /config/www/blueprint-images/ → HEADER_IMG path
- §11.0: _build_logs/ explicitly anchored to PROJECT_DIR (never HA_CONFIG)
- §11.2: review step 1b now checks README existence
- §11.9: convergence criterion #4 includes README
- ARCH-6: new QA check for README existence and currency
- Token estimates updated (06 file: 13.2K → 14.8K, total: ~93K)
```
