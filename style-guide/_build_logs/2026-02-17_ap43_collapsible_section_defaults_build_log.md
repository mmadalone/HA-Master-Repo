# Build Log — AP-44: Collapsible Section Defaults

| Field              | Value |
|--------------------|-------|
| **Date**           | 2026-02-17 |
| **Status**         | completed |
| **Target files**   | `01_blueprint_patterns.md` (§3.2 additions), `06_anti_patterns_and_workflow.md` (AP-44 entry) |
| **Blueprint scope** | All blueprints using `collapsed:` in input sections |
| **Build log**      | `_build_logs/2026-02-17_ap43_collapsible_section_defaults_build_log.md` |

---

## Objective

Add a two-piece addition to the Rules of Acquisition:

1. **Subsection rule** — Expand "Collapsible Section Defaults" in §3.2 with type-appropriate defaults table
2. **AP-44** — "Null or Missing Defaults in Collapsible Sections" in the anti-pattern catalog

---

## AP Number Resolution

Original abstract used AP-43. Discovery during build revealed AP-43 is already assigned:
> AP-43 ⚠️ — Build log exists but `## Edit Log` section was not updated between consecutive edits

**Resolution:** Renumbered to **AP-44**. All references in this log use the corrected ID.

---

## What Already Exists (from prior session, confirmed in §3.2 lines 146–149)

The following were added in a previous build (v3.17, 2026-02-16) and are **already live**:

- ✅ "No exceptions" — every blueprint uses collapsible sections regardless of input count
- ✅ Default collapse state — Sections ①② expanded (omit `collapsed:`), ③+ `collapsed: true`
- ✅ Every input in a collapsible section MUST have `default:`
- ✅ Entity selectors → `default:` (empty/null), target selectors → `default: {}`
- ✅ `min_version: 2024.6.0` cross-reference
- ✅ `collapsed: true` shown in §3.2 YAML example on sections ③ and ④

## What Remains

### Piece 1 — §3.2 additions (`01_blueprint_patterns.md`)

Add after the existing collapsible section rules (after line 149):

- Type-appropriate defaults table:
  - `input_boolean` → `default: false` (or `true` if opt-in-active). **Always requires explicit default regardless of section.**
  - `input_number` / `number` → reasonable midpoint or common value
  - `selector: time` → contextually appropriate time (e.g., `"07:00:00"`, `"22:00:00"`)
  - `selector: select` → most common/safe option from the options list
  - `input_text` / `text` → `default: ""` acceptable where no sensible preset exists
- Bare `default:` (YAML null) prohibition — except entity selectors which already use `default:` per existing rule
- `input_boolean` edge case callout — requires default in ALL sections, not just collapsed ones
- Cross-reference to AP-44

### Piece 2 — AP-44 entry (`06_anti_patterns_and_workflow.md`)

Add to the anti-pattern catalog table (after AP-43, line 74):

| AP-44 | ⚠️ | Null or missing defaults in collapsible sections |

Full entry with detection flags:
1. `default:` absent entirely in a `collapsed: true` section input
2. `default:` bare/null in any section (except entity selectors per §3.2)
3. `input_boolean` missing `default:` in ANY section
4. Section 1 declared `collapsed: true`
5. Section 2+ declared `collapsed: false` without documented justification

Severity: Medium (silent UX degradation, no error output)
Cross-reference: §3.2 Collapsible Section Defaults

### Piece 3 — Housekeeping

- Version bump in `ha_style_guide_project_instructions.md`
- Changelog entry referencing this build log
- Verify both file writes

---

## Conflict Resolutions

| Conflict | Resolution | Decided by |
|----------|-----------|------------|
| AP-43 already taken | Renumbered to AP-44 | User, 2026-02-17 |
| Section ②: abstract said collapsed, existing rule says expanded | Keep existing: ①② expanded, ③+ collapsed | User, 2026-02-17 |
| Entity selector bare `default:` vs abstract's "no bare null" | Keep existing: entity selectors use `default:` (bare null) as exception | User, 2026-02-17 |

---

## Pre-Build Checklist

- [x] Abstract drafted and approved by user
- [x] Identify exact section numbers for rule placement — §3.2, after line 149
- [x] Identify anti-pattern catalog file and current AP count — `06_anti_patterns_and_workflow.md`, AP-43 is last, new = AP-44
- [x] Resolve AP number collision (AP-43 → AP-44)
- [x] Resolve conflict: Section ② collapse behavior
- [x] Resolve conflict: Entity selector bare default exception
- [x] Write §3.2 additions (type-appropriate defaults table + cross-ref)
- [x] Write AP-44 entry in catalog table + full description
- [x] Cross-reference both pieces
- [x] Update version / changelog
- [x] Verify file writes

---

## Edit Log

| # | Action | File | Lines | Result | Timestamp |
|---|--------|------|-------|--------|-----------|
| 1 | Abstract drafted and reviewed | — | — | Approved by user | 2026-02-17 |
| 2 | Build log created | this file | — | Created | 2026-02-17 |
| 3 | Discovery: AP-43 already taken | `06_anti_patterns_and_workflow.md` | 74 | Renumbered to AP-44 | 2026-02-17 |
| 4 | Discovery: §3.2 foundation already exists | `01_blueprint_patterns.md` | 146–149 | Prior session work confirmed | 2026-02-17 |
| 5 | Conflict resolution (3 items) | — | — | All resolved by user | 2026-02-17 |
| 6 | Build log updated with reduced scope | this file | — | Ready for edits | 2026-02-17 |
| 7 | Recovery: Edit 1 (§3.2 defaults table) already live | `01_blueprint_patterns.md` | 149+ | Prior session wrote it; confirmed match to spec | 2026-02-17 |
| 8 | Recovery: Edit 2 (AP-44 table row) already live | `06_anti_patterns_and_workflow.md` | 75 | Prior session wrote it; all 5 detection flags present | 2026-02-17 |
| 9 | Edit 3: Version bump 3.22 → 3.24 | `ha_style_guide_project_instructions.md` | 3 | ✅ Verified | 2026-02-17 |
| 10 | Edit 3: v3.24 changelog entry added | `ha_style_guide_project_instructions.md` | 310–312 | ✅ Verified | 2026-02-17 |
| 11 | Build log finalized — status → completed | this file | — | All checkboxes checked | 2026-02-17 |

---

## Notes

- Original abstract scope was larger than needed — prior session already laid the foundation
- Remaining work is additive only (new content after existing rules, new AP entry)
- Entity selector `default:` (bare null) is a documented exception to the "no bare null" rule
- `input_boolean` edge case confirmed: always requires explicit default regardless of section
