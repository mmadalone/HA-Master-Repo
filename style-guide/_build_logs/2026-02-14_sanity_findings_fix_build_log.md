# Build Log — Sanity Check Findings Fix (AIR-6, VER-3, ARCH-5)
**Date:** 2026-02-14
**Mode:** BUILD (escalated from AUDIT — sanity check report `2026-02-14_style_guide_sanity_report.log`)
**Scope:** Fix 3 findings from sanity check: AIR-6 token mismatch, VER-3 data_template date inconsistency, ARCH-5 routing gap
**Style guide sections loaded:** §1 (Core Philosophy), §2.3 (pre-flight)

## Decisions
1. AIR-6: Internal §1 token claims in 00_core_philosophy.md are ~1K stale (~7.9K → ~8.8K measured). Full file also stale (~11.0K → ~12.0K). Master index ~8.9K is close enough — update to ~8.8K for consistency.
2. VER-3: QA checklist mentions data_template removal "2025.12" but §11.3 says "no removal date announced." QA checklist is wrong — correct it.
3. ARCH-5: 09_qa_audit_checklist.md has no explicit routing entry. Add to AUDIT mode task-specific table.

## Files
- [x] 00_core_philosophy.md — Fix §1.9 token estimates (lines 149, 159)
- [x] ha_style_guide_project_instructions.md — Fix master index §1 token claim, add AUDIT routing for QA checklist
- [x] 09_qa_audit_checklist.md — Fix data_template removal date claim

## Status: COMPLETE

## Edits Applied
| # | File | Change | Finding |
|---|------|--------|---------|
| 1 | 00_core_philosophy.md | Line 149: §1 token ~7.9K → ~8.8K | AIR-6 |
| 2 | 00_core_philosophy.md | Line 159: full ~11.0K → ~12.0K, §1 ~7.9K → ~8.8K | AIR-6 |
| 3 | ha_style_guide_project_instructions.md | Doc table: §1 alone ~8.9K → ~8.8K | AIR-6 |
| 4 | ha_style_guide_project_instructions.md | AUDIT routing table: added QA check commands → 09_qa_audit_checklist.md | ARCH-5 |
| 5 | 09_qa_audit_checklist.md | VER-1 table: data_template "deprecation target: 2025.12" → "deprecated ~HA 0.115/2020, no removal date announced" | VER-3 |
| 6 | 09_qa_audit_checklist.md | VER-3 example format: "deprecated in HA 2024.x / Target removal: HA 2025.12" → "deprecated in ~HA 0.115 (2020) / No removal date announced" | VER-3 |
