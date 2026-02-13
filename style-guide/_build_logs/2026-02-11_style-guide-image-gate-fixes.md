# Audit Log — Style guide AP-15 image gate & format fixes

## Session
- **Date started:** 2026-02-11
- **Status:** in-progress
- **Scope:** Fix AP-15 image gate to catch missing assets + allow all web formats + fix broken wake-up-guard image reference
- **Style guide sections loaded:** §3.1, §10 scan table, §10 #15, §11.1 step 4, §11.2
- **Style guide version:** 2.6 — 2026-02-11
- **Trigger:** Review of wake-up-guard.yaml revealed v6 "fixed" `.jpg` → `.jpeg` but the actual file on disk is `.jpg`, breaking the image. Root cause: style guide hardcoded `.jpeg` as the only allowed format and had no asset-existence verification step.

## Root cause analysis

1. §11.1 step 4 hardcodes `.jpeg` as the only filename extension — no technical reason to exclude `.jpg`, `.png`, `.webp`
2. AP-15 gate only checks for `![` markdown syntax presence — doesn't verify the referenced file exists on disk
3. §11.2 review workflow has no "verify referenced assets" step
4. Previous session's "fix" changed the blueprint reference to `.jpeg` but didn't rename the file → broken image

## Planned edits

| # | File | Edit | Description |
|---|------|------|-------------|
| 1 | `ha_style_guide_project_instructions.md` | AP-15 gate text | Add "or whose referenced image file does not exist on disk" |
| 2 | `06_anti_patterns_and_workflow.md` | AP-15 scan table (line ~30) | Expand trigger pattern to include missing-asset case |
| 3 | `06_anti_patterns_and_workflow.md` | Anti-pattern #15 prose (line ~145) | Add missing-asset check + allowed formats list |
| 4 | `06_anti_patterns_and_workflow.md` | §11.1 step 4 (line ~220) | Replace hardcoded `.jpeg` with allowed format list |
| 5 | `06_anti_patterns_and_workflow.md` | §11.2 (line ~234) | Add step 1b: verify referenced assets exist |
| 6 | `01_blueprint_patterns.md` | §3.1 (line ~10) | Remove hardcoded `.jpeg`, reference §11.1 for allowed formats |
| 7 | `wake-up-guard.yaml` | Image URL in description | Revert `.jpeg` → `.jpg` to match actual file on disk |

## Files modified
- [ ] `ha_style_guide_project_instructions.md` — edit 1
- [ ] `06_anti_patterns_and_workflow.md` — edits 2–5
- [ ] `01_blueprint_patterns.md` — edit 6
- [ ] `wake-up-guard.yaml` — edit 7

## Pre-flight
- [x] Build log created BEFORE any edits (AP-39)
- [ ] All edits applied
- [ ] Style guide version bumped if structural change
