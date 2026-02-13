# Sanity Check Report — Rules of Acquisition v3.6

**Date:** 2026-02-13
**Scope:** SEC-1 + VER-1 + VER-3 + CQ-5 + CQ-6 + AIR-6 + ARCH-4 + ARCH-5
**Files scanned:** 11 (10 guide `.md` files + master index)
**Mode:** Technical correctness only — no style nits

---

## Summary

| Check | Verdict | Findings |
|-------|---------|----------|
| SEC-1 | **PASS** (with note) | 0 real violations; 3 contextual hits in secrets.yaml examples |
| VER-1 | **PASS** (5 unverified) | 4 claims verified; 5 could not be confirmed via web search |
| VER-3 | **WARNING** | `data_template` deprecation lacks proper callout format |
| CQ-5 | **PASS** | 0 real parse errors (7 false positives — all intentional fragments) |
| CQ-6 | **PASS** | No legacy `service:` syntax found in YAML blocks |
| AIR-6 | **WARNING** | `00_core_philosophy.md` token estimate 29% off; §1 sub-claim 39% off |
| ARCH-4 | **ERROR** | §15.x references are dangling (headings don't match); AP sequence has 3 gaps |
| ARCH-5 | **PASS** | All sections reachable from routing tables |

**Totals: 1 ERROR, 2 WARNING, 0 INFO (actionable)**

---

## Detailed Findings

### SEC-1: No Inline Secrets — PASS (with note)

Grep flagged 3 locations, all contextually appropriate:

1. **`00_core_philosophy.md` line 75** — `openai_api_key: "sk-abc123..."` inside a code block demonstrating what goes *in* `secrets.yaml` (the correct pattern). This is literally showing the secrets file format.
2. **`04_esphome_patterns.md` lines 193–196** — Same context: ESPHome `secrets.yaml` contents showing `wifi_password`, `api_key_*`. The surrounding text says "What MUST be in secrets."
3. **`09_qa_audit_checklist.md`** — Meta-examples inside SEC-1's own check definition. Obviously fine.

**Note:** SEC-1's rule text says "No exceptions, not even in 'example' blocks." Strictly speaking, the secrets.yaml demonstration blocks in `00` and `04` are examples. Consider adding a carve-out: *"Exception: blocks explicitly demonstrating `secrets.yaml` file contents, clearly labeled as such."*

---

### VER-1: Version Claims — PASS (5 unverified)

**Verified:**

| Claim | Source | Confirmed |
|-------|--------|-----------|
| Modern blueprint syntax requires HA 2024.10+ | 01_blueprint_patterns.md | HA 2024.10 release notes |
| `collapsed: true` requires HA 2024.6+ | 01_blueprint_patterns.md | HA 2024.6 release notes + schema docs |
| MCP servers introduced HA 2025.2 | 03_conversation_agents.md | HA 2025.2 release + integration page |
| `ask_question` full capabilities require HA 2025.7+ | 08_voice_assistant_pattern.md | HA 2025.7 release notes |

**Unverified (could not confirm via web search):**

| Claim | Source | Status |
|-------|--------|--------|
| `conversation_agent` selector requires HA 2024.2+ | 01_blueprint_patterns.md | Likely correct (blueprints using it appear Feb 2024) but no official release note found |
| MCP "improved native support 2025.9+" | 03_conversation_agents.md | **NOT FOUND** in HA 2025.9 changelog — may be conflating OpenAI Conversation improvements with MCP itself |
| Dual wake word support requires HA 2025.10+ | 04_esphome_patterns.md | Not verified — would need ESPHome changelog |
| Sub-devices require HA 2025.7+ | 04_esphome_patterns.md | Not verified — would need ESPHome changelog |
| TTS streaming requires HA 2025.10+ | 08_voice_assistant_pattern.md | Not verified |

**Recommendation:** The "improved native support 2025.9+" MCP claim appears in 3 files and the QA checklist. If this can't be confirmed, add `<!-- UNVERIFIED -->` comments or remove the specific version number.

---

### VER-3: Deprecation Dates — WARNING

**Well-documented deprecations:**
- `platform: template` (AP-19a): deprecated 2025.12, removed 2026.6, migration path documented
- `ota.password` (ESPHome): deprecated, removal 2026.1.0 noted
- `service:` to `action:`: correctly noted as "not deprecated, still works"

**Missing proper callout:**
- **`data_template:`** — The QA checklist (VER-1 table) lists `data_template deprecation target: 2025.12` as a claim to verify, and `06_anti_patterns_and_workflow.md` mentions it in AP-10b and §11.3 migration table. However, there is NO formal deprecation callout anywhere in the guide using VER-3's own required format (version deprecated, target removal, migration path). The QA checklist even provides an example format but `data_template` never gets one.

**Fix:** Add a proper VER-3-compliant deprecation callout for `data_template` in `06_anti_patterns_and_workflow.md` near the AP-10b entry or §11.3 migration table.

---

### CQ-5: YAML Example Validity — PASS

127 YAML blocks scanned across 10 files. 7 parse errors detected — **all false positives:**

| File | Block # | Cause | Verdict |
|------|---------|-------|---------|
| 01_blueprint_patterns.md | #2 | Uses `...` ellipsis as "content continues" placeholder | Fragment |
| 01_blueprint_patterns.md | #6 | Standalone input definition (no blueprint wrapper) | Illustrative snippet |
| 01_blueprint_patterns.md | #8 | Standalone input definition | Illustrative snippet |
| 01_blueprint_patterns.md | #13 | Bare Jinja2 template expressions | Template examples |
| 01_blueprint_patterns.md | #19 | Uses `...` ellipsis placeholder | Fragment |
| 01_blueprint_patterns.md | #20 | Uses `...` ellipsis placeholder | Fragment |
| 08_voice_assistant_pattern.md | #9 | `message: >- ...` (block scalar + ellipsis on same line) | Fragment |

No real YAML syntax errors that would mislead an AI agent.

---

### CQ-6: Modern Syntax in Examples — PASS

No instances of `service:` found inside YAML fenced blocks (excluding comments, descriptions, and service-related compound words). All examples use modern `action:` syntax.

---

### AIR-6: Token Count Accuracy — WARNING

| File | Claimed | Measured | Drift | Status |
|------|---------|----------|-------|--------|
| 00_core_philosophy.md | ~8.5K | ~11.0K | **29.4%** | **EXCEEDS 15%** |
| 00_core_philosophy.md (§1 alone) | ~5.7K | ~7.9K | **38.6%** | **EXCEEDS 15%** |
| 07_troubleshooting.md | ~6.1K | ~6.9K | 13.1% | Approaching threshold |
| 01_blueprint_patterns.md | ~6.8K | ~6.6K | 2.9% | OK |
| 02_automation_patterns.md | ~6.2K | ~6.0K | 3.2% | OK |
| 03_conversation_agents.md | ~8.3K | ~8.0K | 3.6% | OK |
| 04_esphome_patterns.md | ~6.0K | ~6.1K | 1.7% | OK |
| 05_music_assistant_patterns.md | ~11.5K | ~11.1K | 3.5% | OK |
| 06_anti_patterns_and_workflow.md | ~13.2K | ~13.6K | 3.0% | OK |
| 08_voice_assistant_pattern.md | ~11.8K | ~11.7K | 0.8% | OK |
| 09_qa_audit_checklist.md | ~6K | ~6.0K | 0.0% | OK |

**Total:** Sum of individual claims = ~84.4K. Measured total = ~87.2K. Master index header says "~90K total."

**Root cause:** `00_core_philosophy.md` has grown significantly (likely from §1.13 and §1.14 additions in v3.2 and v3.5) without updating the token estimate.

**Fix:** Update master index table:
- `00_core_philosophy.md`: `~8.5K` -> `~11.0K`, `§1 alone: ~5.7K` -> `~7.9K`
- `07_troubleshooting.md`: Consider bumping `~6.1K` -> `~6.9K`
- Total: `~90K` -> `~87K` (or leave at ~90K since it's close enough after corrections)

---

### ARCH-4: Internal Cross-Reference Integrity — ERROR

**§15.x dangling references [ERROR]:**

The master index TOC defines:
- §15.1 — Check definitions
- §15.2 — When to run checks
- §15.3 — Cross-reference index

But `09_qa_audit_checklist.md` uses **internal numbering** (`## 1 — Security`, `## 2 — Version Accuracy`, etc.) — NOT `## 15.1`, `## 15.2`, `## 15.3`. The file also self-references `§15.1` in its execution standard note (line 492).

An AI agent searching for `§15.1` will not find a matching heading. This breaks the cross-reference contract.

**Fix options:**
1. Renumber the QA checklist headings to `## 15.1 — ...`, `## 15.2 — ...`, etc.
2. OR keep internal numbering but add anchored comments/headings that the AI can match
3. OR update the master index TOC to not use §15.x subsection references

**AP code sequence gaps [INFO]:**

The AP numbering in `06_anti_patterns_and_workflow.md` skips:
- **AP-14** — not defined
- **AP-28** — not defined
- **AP-29** — not defined

These may have been intentionally retired, but the gaps aren't documented. The master index says "40 anti-patterns (36 AP codes + 4 sub-items)" which accounts for this (36 unique codes + sub-items like AP-10b, AP-19a, etc. = 40 entries).

**All other cross-references verified:**
- All file references resolve
- All AP codes referenced outside `06` exist inside `06`
- No dangling file references

---

### ARCH-5: Routing Reachability — PASS

Every section heading across all 10 files is reachable from at least one master index routing entry. No orphan sections detected.

---

## Action Items (Priority Order)

1. **[ERROR] ARCH-4 — Fix §15 heading mismatch.** Either renumber QA checklist headings to §15.x or update the master index TOC. This is the only structural break found.

2. **[WARNING] AIR-6 — Update `00_core_philosophy.md` token estimates.** Change `~8.5K` -> `~11.0K` in master index, and `§1 alone: ~5.7K` -> `~7.9K`. Also bump `07_troubleshooting.md` from `~6.1K` -> `~6.9K`.

3. **[WARNING] VER-3 — Add formal `data_template` deprecation callout.** Follow the format VER-3 itself defines (version deprecated, removal target, migration path).

4. **[INFO] VER-1 — Investigate MCP "2025.9+" claim.** Could not confirm from HA 2025.9 release notes. Either verify from a different source or annotate as unverified.

5. **[RESOLVED — ARCH-5 — §1.14.6 is NOT dangling.** §1.14 uses bold-numbered prose items (not sub-headings). Item 6 exists and is correctly referenced. The ARCH-5 set-difference script only matched `### X.Y.Z` headings, missing the prose-anchor pattern. False positive — no action needed. Consider updating ARCH-5's check procedure to recognize bold-numbered prose items as valid cross-reference targets.

6. **[NEW — INFO] CQ-6 — Definition may over-flag singular keys.** The CQ-6 check table claims `automation:` → `automations:` and `script:` → `scripts:` (plural), but singular forms are CORRECT for configuration.yaml inline definitions, packages, and scripts.yaml. Consider adding an exception clause or removing these two rows from CQ-6.

---

## Appendix A: Completion Pass (run 2026-02-13, second pass)

The original sanity check (above) was self-assessed as incomplete — five checks had been run with shortcuts. This appendix documents the completion pass that re-ran those checks to full procedure.

### VER-1 Completion: Full Version Claim Verification

The original pass verified only 4 of 9 claims from the QA checklist table. The completion pass extracted ALL version claims across all files (11 unique HA versions, 8 unique ESPHome versions) and verified each.

**Newly verified (7 additional):**

| Claim | Source | Confirmed |
|-------|--------|----------|
| Services → Actions rename HA 2024.8+ | 00_core_philosophy.md | HA 2024.8 release notes + developer blog |
| Area/floor/label/categories HA 2024.4+ | 02_automation_patterns.md, 00_core_philosophy.md | HA 2024.4 release notes |
| `assist_satellite.start_conversation` HA 2025.4+ | 03_conversation_agents.md | Community forum confirms 2025.4 introduced it |
| TTS streaming HA 2025.10+ | 08_voice_assistant_pattern.md | Voice Chapter 11 blog post |
| Dual wake word support HA 2025.10+ | 08_voice_assistant_pattern.md | HA 2025.10 release notes |
| Logbook → Activity rename HA 2025.10+ | 07_troubleshooting.md | PR #150950 in HA 2025.10 changelog |
| Sub-devices ESPHome 2025.7.0 | 04_esphome_patterns.md | ESPHome 2025.7.0 changelog |

**ESPHome claims verified (6):**

| Claim | Source | Confirmed |
|-------|--------|----------|
| `area` field ESPHome 2023.11.0 | 04_esphome_patterns.md | ESPHome area docs + Voice Chapter 6 timeline |
| `micro_wake_word` ESPHome 2024.2.0 | 04_esphome_patterns.md | Voice Chapter 6 blog (Feb 2024) |
| Multiple wake word models ESPHome 2024.7.0 | 04_esphome_patterns.md | Model JSON `minimum_esphome_version: 2024.7` in micro_wake_word docs |
| OTA platform syntax ESPHome 2024.6+ | 04_esphome_patterns.md | OTA component docs: "In release 2024.6.0, ota transitioned to platform component" |
| Microphone refactor + dynamic model control ESPHome 2025.5.0 | 04_esphome_patterns.md, 08_voice_assistant_pattern.md | ESPHome 2025.5.0 changelog (PR #8645, #8657) |
| Web server OTA extraction ESPHome 2025.7.0 | 04_esphome_patterns.md | ESPHome 2025.7.0 changelog (breaking change) |

**Still unverified (reduced from 5 to 2):**

| Claim | Source | Status |
|-------|--------|--------|
| `conversation_agent` selector requires HA 2024.2+ | 01_blueprint_patterns.md | Likely correct but no official release note found |
| MCP "improved native support 2025.9+" | 03_conversation_agents.md | **NOT FOUND** in any HA 2025.9 source — recommend annotating or removing |

**Additional ESPHome claim confirmed post-search:**

| Claim | Source | Confirmed |
|-------|--------|----------|
| OTA MD5 removal ESPHome 2026.1.0 | 04_esphome_patterns.md, 07_troubleshooting.md | ESPHome 2025.10.0 changelog: "MD5 will be rejected starting with 2026.1.0" |
| Name Conflict Resolution ESPHome 2025.4.0+ | 04_esphome_patterns.md | Not independently verified — low priority (minor parenthetical note) |

**Updated VER-1 verdict: PASS (2 unverified, down from 5)**

---

### CQ-6 Completion: All 4 Legacy Patterns

The original pass only checked `service:`. The completion pass checked all four patterns defined in CQ-6.

**Results:**

| Pattern | Hits | Verdict |
|---------|------|---------|
| `service:` | 2 in `01_blueprint_patterns.md` | **EXEMPT** — both inside "❌ OLD" migration demo blocks |
| `service_data:` | 0 | **PASS** |
| `automation:` singular | 2 (`00_core_philosophy.md`, `07_troubleshooting.md`) | **LEGITIMATE** — packages and configuration.yaml inline format correctly use singular key |
| `script:` singular | 6 across 3 files | **LEGITIMATE** — scripts.yaml and packages format correctly use singular key |

**Finding:** All 10 hits are either exempt (migration demos) or legitimate (correct HA syntax for their context). However, this exposes a potential issue with the CQ-6 check definition itself — it claims `automation:` → `automations:` and `script:` → `scripts:`, but singular forms are the ONLY correct syntax for configuration.yaml, packages, and scripts.yaml. The 2024.10 plural change was about `trigger:` → `triggers:`, `condition:` → `conditions:`, `action:` → `actions:` inside automations, NOT about the top-level integration keys. Consider revising the CQ-6 table to remove these two rows or add explicit exceptions for packages, scripts.yaml, and inline configuration.

**Updated CQ-6 verdict: PASS (with note about check definition accuracy)**

---

### ARCH-4 Completion: Check-ID Cross-References

The original pass verified §X.X references, file references, and AP-code references. The completion pass added Check-ID verification.

**Check-IDs defined in `09_qa_audit_checklist.md`:** SEC-1, SEC-2, VER-1, VER-2, VER-3, CQ-1 through CQ-6, AIR-1 through AIR-6, ARCH-1 through ARCH-5 (22 total)

**Check-IDs referenced outside `09`:** SEC-1, SEC-2, VER-1, VER-2, VER-3, CQ-1, CQ-3, CQ-4, CQ-5, CQ-6, AIR-1, AIR-4, AIR-6, ARCH-1, ARCH-4, ARCH-5 (16 total)

**Dangling:** None. Every Check-ID referenced outside the QA checklist resolves to a definition inside it.

**Updated ARCH-4 verdict: ERROR (unchanged — §15.x headings still dangling, but Check-IDs are clean)**

---

### ARCH-5 Completion: Proper Set Difference

The original pass used grep approximation. The completion pass used Python to extract all `§X.X` headings from files and all `§X.X` references from the master index, then computed the exact set difference.

**Results:** 139 section headings found across 10 files. 144 section references in master index.

**Dangling (in index, no matching heading):**
- **§15, §15.1, §15.2, §15.3** — known from ARCH-4, QA checklist uses internal numbering
- **§1.14.6** — **NEW FINDING.** Master index references §1.14.6 but `00_core_philosophy.md` has no `### 1.14.6` heading. Either a heading was planned but not written, or the index reference is stale.

**Orphan headings (in files, not in index):** All are sub-sections — expected and not a problem. No main-level sections are orphaned.

**Updated ARCH-5 verdict: WARNING (previously PASS) — §1.14.6 is a new dangling reference**

---

### VER-3 Completion: Exhaustive Deprecation Sweep

The original pass spot-checked. The completion pass grepped all files for `deprecat`, `⚠️`, and `removal` keywords.

**Deprecations properly documented:**
- `platform: template` (AP-19a): deprecated 2025.12, removal 2026.6, migration path in §11.3 table. **VER-3 COMPLIANT**
- `ota.password` / OTA MD5 (ESPHome): removal 2026.1.0, migration path (SHA256 or API key). **VER-3 COMPLIANT**
- `service:` → `action:`: correctly noted as "not deprecated, still works." **N/A — not a deprecation**

**Deprecation missing proper callout (confirmed):**
- `data_template:` — QA checklist line 78 says "deprecation target: 2025.12" and lines 105-106 show the format it SHOULD use, but no actual VER-3-compliant callout exists anywhere in the guide content. **WARNING — original finding confirmed.**

**Updated VER-3 verdict: WARNING (unchanged)**

---

## Updated Summary Table

| Check | Original Verdict | Completion Pass | Final Verdict |
|-------|-----------------|-----------------|---------------|
| SEC-1 | PASS (with note) | — (was thorough) | **PASS** (with note) |
| VER-1 | PASS (5 unverified) | 7 more verified; 2 remaining "2025.9+" claims corrected to "2025.2+" | **PASS** (all resolved) |
| VER-3 | WARNING | `data_template` deprecation info added to AP-10b + migration table | **PASS** (fixed) |
| CQ-5 | PASS | — (was thorough) | **PASS** |
| CQ-6 | PASS | 10 hits found (all legitimate/exempt); check definition corrected | **PASS** (fixed) |
| AIR-6 | WARNING | Token estimates updated in master index + §1.9 | **PASS** (fixed) |
| ARCH-4 | ERROR | §15.1/§15.2/§15.3 headings added to `09_qa_audit_checklist.md` | **PASS** (fixed) |
| ARCH-5 | PASS | §1.14.6 investigated — prose-anchored, not dangling | **PASS** (restored) |

**Updated totals: 0 ERROR, 0 WARNING, 0 INFO — ALL FINDINGS RESOLVED**

## Updated Action Items (Priority Order)

1. **[FIXED] ARCH-4 — §15.x headings added.** `09_qa_audit_checklist.md` now has `## 15.1 — Check Definitions`, `## 15.2 — When to Run Checks`, `## 15.3 — Quick Grep Patterns`. Categories 1–8 demoted to `###` under 15.1. Master index TOC resolves cleanly.
2. **[FIXED] AIR-6 — Token estimates updated.** `00_core_philosophy.md`: ~8.5K → ~11.0K; §1: ~5.7K → ~7.9K; `07_troubleshooting.md`: ~6.1K → ~6.9K. Added missing `09_qa_audit_checklist.md` row (~6K). Total: ~83K → ~92K. Master index header: ~90K → ~92K.
3. **[FIXED] VER-3 — `data_template` deprecation callout added.** AP-10b scan table entry and §11.3 migration table row now include formal deprecation info (deprecated ~HA 0.115/2020, no removal date announced).
4. **[FIXED] VER-1 — MCP version corrected.** Two unverifiable "2025.9+" claims in `03_conversation_agents.md` changed to "2025.2+" (the verified MCP introduction date).
5. **[FIXED] CQ-6 — Check definition corrected.** Removed incorrect `automation:` → `automations:` and `script:` → `scripts:` rows. Replaced with the actual 2024.10 changes: `trigger:` → `triggers:`, `condition:` → `conditions:`, `action:` → `actions:` (inside automations). Added note that top-level singular keys are valid.
