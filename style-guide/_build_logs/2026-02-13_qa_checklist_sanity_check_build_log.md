# Build Log — QA Checklist: Sanity Check Expansion

**Date:** 2026-02-13
**Mode:** BUILD
**File in scope:** `09_qa_audit_checklist.md`
**Secondary file:** `ha_style_guide_project_instructions.md` (TOC update)

## Objective

Add 5 new QA checks and a `sanity check` user command to fill coverage gaps identified during guide audit:

| New Check | Category | Severity | Gap filled |
|-----------|----------|----------|------------|
| CQ-5 | Code Quality | ERROR | YAML example validity (syntax, real action names) |
| CQ-6 | Code Quality | WARNING | HA 2024.10+ modern syntax in examples |
| AIR-6 | AI-Readability | WARNING | Token count accuracy (claims vs reality) |
| ARCH-4 | Architecture | ERROR | Internal §X.X cross-reference integrity |
| ARCH-5 | Architecture | WARNING | Routing reachability (orphan section detection) |

Plus:
- New `sanity check` command in user-triggered commands table
- New grep patterns in appendix for CQ-5, CQ-6, ARCH-4
- Update `check vibe readiness` scope to include AIR-6
- Update master index TOC to list new checks

## Planned edits (09_qa_audit_checklist.md)

1. Insert AIR-6 after AIR-5 (after line ~183)
2. Insert CQ-5 and CQ-6 after CQ-4 (after line ~243)
3. Insert ARCH-4 and ARCH-5 after ARCH-3 (after line ~281)
4. Add `sanity check` row to user-triggered commands table
5. Add grep patterns to appendix
6. Update `check vibe readiness` description to include AIR-6

## Planned edits (ha_style_guide_project_instructions.md)

7. Add new checks to §15.1 description line in TOC

## Result

✅ **All edits complete and verified.**

### Files modified
| File | Changes |
|------|---------|
| `09_qa_audit_checklist.md` | +5 new checks (AIR-6, CQ-5, CQ-6, ARCH-4, ARCH-5), +1 user command (`sanity check`), updated automatic triggers, updated `check vibe readiness` scope, +6 grep patterns in appendix |
| `ha_style_guide_project_instructions.md` | Version 3.3 → 3.4, token estimates updated (~86K → ~90K, QA ~3K → ~6K), subsection count 123 → 128, §15.1 description updated, changelog entry added |

### Verification
- All 5 new check IDs resolve via grep
- `sanity check` command present in user-triggered table
- AIR-6 included in `check vibe readiness` scope
- Automatic triggers updated for CQ-5, CQ-6, ARCH-4, ARCH-5
- Token estimates verified via `wc -c` measurement
