# Build Log — IMG_PREMISES dynamic image premise selection

| Field | Value |
|-------|-------|
| **Date** | 2026-02-15 |
| **Task** | Replace hardcoded "Rick & Morty style" image default with dynamic IMG_PREMISES selection |
| **Mode** | BUILD |
| **Status** | completed |
| **Style guide version** | 3.15 → 3.16 |
| **Files in scope** | 3 (`06_anti_patterns_and_workflow.md`, `ha_style_guide_project_instructions.md`, `01_blueprint_patterns.md`) |

## Decisions
- IMG_PREMISES is semicolon-delimited, defined in project instructions (already done by user)
- AI reads list, presents numbered options, waits for user pick before generating
- If IMG_PREMISES missing/empty, fall back to generic "scene themed around blueprint features"
- Resolution (1K), aspect ratio (16:9), filename convention, cleanup rules unchanged
- Only the creative direction/style becomes dynamic

## Edits Planned
| # | File | Location | Description |
|---|------|----------|-------------|
| 1 | `06_anti_patterns_and_workflow.md` | §11.1 step 4 (~L234-242) | Replace hardcoded style with IMG_PREMISES selection flow |
| 2 | `ha_style_guide_project_instructions.md` | HEADER IMAGE GATE callout (~L39) | Update parenthetical: "Rick & Morty style" → IMG_PREMISES ref |
| 3 | `06_anti_patterns_and_workflow.md` | Rule #15 prose (~L150) | Same parenthetical fix |
| 4 | `01_blueprint_patterns.md` | §3.1 (~L10) | Same parenthetical fix |
| 5 | `ha_style_guide_project_instructions.md` | Changelog | Add v3.16 entry |

## Changes Applied
- [x] Edit 1: §11.1 step 4 — replaced `- **Style:** Rick & Morty (Adult Swim cartoon)` with IMG_PREMISES selection flow
- [x] Edit 2: Master index HEADER IMAGE GATE callout — parenthetical updated
- [x] Edit 3: Rule #15 prose — parenthetical updated
- [x] Edit 4: §3.1 blueprint header — parenthetical updated
- [x] Edit 5: Changelog — added v3.16 entry, bumped version number

## Verification
- ripgrep `Rick & Morty style)` — only match is changelog (describes what was replaced) ✅
- ripgrep `premise from .IMG_PREMISES.` — 3 active refs + 1 changelog ✅

## README Updates (GIT_REPO/readme/style-guide/)
- [x] `06_anti_patterns_and_workflow-readme.md` — AP count 42→43, added §11.14 to workflow paragraph, added IMG_PREMISES to §11.1 ceremony description
- [x] `ha_style_guide_project_instructions-readme.md` — AP count 42→43, changelog version v3.14→v3.16, added IMG_PREMISES to operational modes Key Concepts
- [x] `01_blueprint_patterns-readme.md` — added IMG_PREMISES note to §3.1 description
- ripgrep `IMG_PREMISES` in readme/style-guide/ — 3 hits (one per file) ✅
- ripgrep `42 anti-patterns` in readme/style-guide/ — 0 stale hits ✅
