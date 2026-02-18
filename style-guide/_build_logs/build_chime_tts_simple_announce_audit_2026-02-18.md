# Build Log — chime_tts_simple_announce.yaml

| Field         | Value                                                    |
|---------------|----------------------------------------------------------|
| **File**      | `blueprints/script/madalone/chime_tts_simple_announce.yaml` |
| **Task**      | Style guide compliance audit + remediation               |
| **Mode**      | BUILD                                                    |
| **Status**    | completed                                                |
| **Started**   | 2026-02-18                                               |
| **Operator**  | Claude (Quark edition)                                   |

---

## Audit Findings

### ERRORS (must fix)

| # | Violation | Location | Detail |
|---|-----------|----------|--------|
| E1 | AP-01: Legacy `service:` keyword | sequence[0] | Must be `action:` per 2024.10+ syntax |
| E2 | No collapsible input sections | `input:` block | Inputs must be organized into numbered collapsible sections (①②③) with `collapsed:` property |
| E3 | Missing `source_url:` | blueprint metadata | Required for all published blueprints |
| E4 | Missing version tracking | blueprint description | No version string in description block |
| E5 | Missing `continue_on_error: true` | sequence[0] | `chime_tts.say` is external service — non-critical calls need error guard |
| E6 | Missing `homeassistant: min_version:` | blueprint metadata | Required for 2024.10+ syntax enforcement |
| E7 | No header image | repo | Must generate per style guide image premise rules |

### WARNINGS (should fix)

| # | Violation | Location | Detail |
|---|-----------|----------|--------|
| W1 | Verbose input descriptions | multiple inputs | Descriptions include usage examples that belong in README, not blueprint UI |
| W2 | No `icon:` on inputs | all inputs | Icon selectors improve UI discoverability |
| W3 | Volume input UX | `volume_level` | -1 sentinel value is non-obvious; consider documenting better or using input_boolean toggle |

---

## Remediation Plan

1. Restructure inputs into 3 collapsible sections:
   - ① Media Players (collapsed: false)
   - ② Message & TTS Settings (collapsed: true)
   - ③ Chime & Volume (collapsed: true)
2. All sections get sensible `default:` values — no `default:` (null)
3. Replace `service:` → `action:`
4. Add `source_url:`, `homeassistant: min_version:`, version in description
5. Add `continue_on_error: true` on the chime_tts action
6. Tighten descriptions, add `icon:` hints
7. Generate header image (Rick & Quark premise)

---

## Changelog

- v2.0 — Full style guide compliance rewrite (all E1–E7 resolved, W1–W2 resolved)

## Files Modified
- `blueprints/script/madalone/chime_tts_simple_announce.yaml` — rewritten
- `images/header/chime_tts_simple_announce.jpeg` — generated
