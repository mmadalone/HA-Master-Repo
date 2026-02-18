# Build Log: Goodnight Negotiator LLM Driven — Full Audit Remediation

| Field             | Value                                                        |
|-------------------|--------------------------------------------------------------|
| **Date**          | 2026-02-18                                                   |
| **Blueprint**     | `goodnight_negotiator_llm_driven.yaml`                       |
| **Domain**        | script                                                       |
| **Location**      | `HA_CONFIG/blueprints/script/madalone/`                      |
| **Type**          | Full compliance audit remediation                            |
| **Status**        | ✅ COMPLETE                                                  |
| **Prior version** | Unversioned (~1,038 lines)                                   |
| **Target version**| v2.0.0                                                       |

## Audit Findings (pre-build)

### ERRORS (must fix)
- E1: `service:` used everywhere — needs `action:` (AP-01, ~30+ occurrences)
- E2: Zero `alias:` fields on any action step (~60+ missing)
- E3: Missing blueprint metadata (author, source_url, min_version)
- E4: No collapsible input sections (5 groups need conversion)
- E5: Raw `!input devices_targets` used directly in action targets (AP-02)
- E6: `persona_agent_id` input missing `default:`

### WARNINGS (should fix)
- W1: Music playback block duplicated 4× (DRY violation)
- W2: `conversation.process` calls missing `continue_on_error: true` (4×)
- W3: No version tracking
- W4: `assist_satellite` input missing `default:`
- W5: `music_player` input missing `default:`
- W6: Template safety — `music_id | trim` without `| default('')` guard

### INFO (recommended)
- I1: Comment style inconsistency
- I2: `mode: single` positioning
- I3: Hardcoded "Miquel" in LLM prompts
- I4: `default: []` on `ir_off_scripts` silently does nothing

## Remediation Order
1. E1: `service:` → `action:` global conversion
2. E2: Add `alias:` to all action steps
3. E3+E4+E6+W3+W4+W5: Metadata + collapsible sections + defaults
4. E5: Remove raw `!input` from sequence body
5. W2: `continue_on_error: true` on conversation.process calls
6. W6: Template safety on music_id
7. W1: DRY — consolidate music playback block
8. INFO items as time permits

## Edit Log

### E1: `service:` → `action:` (AP-01)
- **Before:** 40 occurrences of `- service:` across all action steps
- **Method:** Global sed replacement `s/- service:/- action:/g`
- **After:** 0 occurrences of `service:` remaining; 40 `- action:` confirmed
- **Verification:** Desktop Commander content search returns 0 matches for `- service:`
- **Status:** ✅ COMPLETE

### E2: Add `alias:` to all action steps
- **Before:** 0 alias fields in entire file (1,038 lines)
- **Method:** Full file rewrite — every action step, choose, variables, delay, wait_template, and stop gets a descriptive alias
- **After:** 95 alias fields following "What — Why" pattern
- **Pattern examples:**
  - `"Variables — capture all inputs for template use"`
  - `"TV ask — LLM generates yes/no question"`
  - `"Music fallback exhausted — no confirmation, no music"`
  - `"Devices fallback exhausted — critical policy turns off anyway"`
- **Verification:** Desktop Commander content search returns 95 matches for `alias:`
- **Status:** ✅ COMPLETE

### E3: Collapsible input sections (AP-07)
- **Before:** Flat input block with comment-block dividers (`# ====`), no `section` wrappers
- **Method:** Full rewrite — 5 collapsible sections with icons and Unicode circle numbers
- **After:** 5 sections:
  - ① Persona & Prompts (`section_persona`, icon: mdi:robot-outline)
  - ② Voice Device & Behavior (`section_voice`, icon: mdi:account-voice)
  - ③ Stage 1 — TV / IR (`section_tv`, icon: mdi:television-off)
  - ④ Stage 2 — Devices (`section_devices`, icon: mdi:power-plug-off)
  - ⑤ Stage 3 — Music (`section_music`, icon: mdi:music-note)
- **Defaults gate:** All inputs have explicit `default:` values (bare `default:` for entity selectors per AP-43)
- **Verification:** 5× `collapsed: true` confirmed
- **Status:** ✅ COMPLETE

### E4+E6+W3+W4+W5: Metadata + missing defaults
- **Before:** No author, source_url, min_version, or version tracking
- **After:**
  - `author: madalone`
  - `source_url:` pointing to GIT_REPO_URL
  - `homeassistant: min_version: "2024.10.0"`
  - Description changed from `>` to `|` with `v2.0.0` version header
  - `persona_agent_id` → `default:` (bare)
  - `assist_satellite` → `default:` (bare)
  - `music_player` → `default:` (bare)
- **Status:** ✅ COMPLETE

### E5: Remove raw `!input` from mid-sequence (mixed usage)
- **Before:** `- variables: devices_targets: !input devices_targets` declared mid-sequence (orphaned), plus `!input devices_targets` used directly in `target:` blocks
- **After:** Orphaned mid-sequence variable removed. `target: !input devices_targets` kept in action blocks (correct HA pattern for target selectors — cannot be templated)
- **Status:** ✅ COMPLETE

### W2: `continue_on_error: true` on all external calls
- **Before:** Only on `assist_satellite.*` calls
- **After:** 40 `continue_on_error: true` entries covering:
  - `conversation.process` ×4 (LLM calls — previously unguarded!)
  - `media_player.*` ×9
  - `music_assistant.play_media` ×4
  - `script.turn_on` ×5
  - `homeassistant.turn_off` ×5
  - `assist_satellite.*` ×13
- **Verification:** Desktop Commander content search returns 40 matches
- **Status:** ✅ COMPLETE

### W6: Template safety on `music_id`
- **Before:** `{{ music_id | trim }}` and `{{ (music_id | trim) != '' }}` without `default('')` guard
- **After:** All occurrences use `{{ (music_id | default('') | trim) != '' }}`
- **Verification:** Spot-checked lines 853, 1100 — guard present. Search for bare `music_id | trim` returns 0
- **Status:** ✅ COMPLETE

## Deferred Items

### W1: DRY — music playback block duplicated 4×
- Music volume+queue+wait+nudge block is copy-pasted in 4 branches (just_do, confirmed, fallback confirmed, safe_default)
- **Recommendation:** Extract to YAML anchor or shared script in a future version
- **Risk:** Low — all 4 copies are identical; drift risk is cosmetic
- **Status:** ⏳ DEFERRED to future version

### INFO items (I1–I4)
- I1: Comment style — standardized during rewrite (═ for stage headers, ─ for subsections)
- I2: `mode: single` positioning — moved to between input block and sequence ✅
- I3: Hardcoded "Miquel" — cosmetic, deferred
- I4: `default: []` on `ir_off_scripts` — documented behavior, deferred
- **Status:** I1+I2 ✅ COMPLETE; I3+I4 ⏳ DEFERRED

## Final State

| Field             | Value                                                        |
|-------------------|--------------------------------------------------------------|
| **Status**        | ✅ COMPLETE (core compliance)                                |
| **Final version** | v2.0.0                                                       |
| **Total lines**   | 1,182 (was 1,038)                                           |
| **HA config**     | ✅ valid                                                     |

### Completed Fixes Summary
| # | Item | Type | Count |
|---|------|------|-------|
| E1 | `service:` → `action:` | AP-01 | 40 replacements |
| E2 | `alias:` on all action steps | AP-03 | 95 aliases added |
| E3 | 5 collapsible input sections | AP-07 | 5 sections |
| E4 | `source_url:` + `author:` + `min_version:` | Metadata | 3 fields |
| E5 | Orphaned `devices_targets` variable removed | Mixed !input | 1 removal |
| E6 | Entity selector defaults added | AP-43 | 3 inputs |
| W2 | `continue_on_error: true` on external calls | Error handling | 40 entries |
| W3 | `v2.0.0` version header in description | Versioning | 1 addition |
| W6 | `music_id | default('') | trim` safety | Template safety | 4 guards |
| I1 | Standardized comment headers | Style | Full file |
| I2 | `mode:` positioning corrected | Style | 1 move |
| — | Header image link added to description | Metadata | 1 addition |
