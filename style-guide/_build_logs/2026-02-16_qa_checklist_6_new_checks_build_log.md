# Build Log — QA Checklist: 6 New Checks + Wiring

**Date:** 2026-02-16
**Status:** in-progress
**Mode:** BUILD
**Scope:** Style guide maintenance — `09_qa_audit_checklist.md` + cross-references in 6 other files

## Task Summary

Add 6 new QA checks (CQ-7, CQ-8, CQ-9, SEC-3, AIR-7, MAINT-5) to the audit checklist, update trigger tables and grep patterns, then wire cross-references into existing guide files.

## Files to Edit

| File | Changes |
|------|---------|
| `09_qa_audit_checklist.md` | Add 6 checks, update trigger tables, update commands, add grep patterns |
| `01_blueprint_patterns.md` | Add SEC-3, CQ-8 cross-refs |
| `02_automation_patterns.md` | Add CQ-7, CQ-8, CQ-9 cross-refs |
| `05_music_assistant_patterns.md` | Add CQ-9 cross-ref |
| `06_anti_patterns_and_workflow.md` | Add AIR-7 cross-ref |
| `08_voice_assistant_pattern.md` | Add CQ-7 cross-ref |

## New Check IDs

- **CQ-7:** Template Safety / Jinja Robustness [WARNING]
- **CQ-8:** Idempotency / Re-trigger Safety [WARNING]
- **CQ-9:** Entity Availability Guards [WARNING]
- **SEC-3:** Template Injection via Blueprint Inputs [ERROR]
- **AIR-7:** Contradictory Guidance Detection [WARNING]
- **MAINT-5:** Community Alignment Check [INFO]

## Decisions

- Check insertion order follows the prompt spec (after last check in each category)
- Cross-references use existing one-line `> 📋 **QA Check` format
- Each target file read before editing to find correct placement

## Progress

- [x] Read full 09_qa_audit_checklist.md
- [ ] Insert 6 new checks (Task 1)
- [ ] Update trigger tables and commands (Task 2)
- [ ] Add grep patterns (Task 3)
- [ ] Wire cross-references (Task 4)
- [ ] Summary (Task 5)
