# Audit Log — coming_home.yaml single-file compliance audit

## Session
- **Date started:** 2026-02-19
- **Status:** completed
- **Scope:** coming_home.yaml — full anti-pattern scan (§10), security checklist (§10.5), structural review
- **Style guide sections loaded:** §10 (scan tables), §10.5 (security), §11.2 (review workflow), §11.8.1 (audit log)
- **Style guide version:** 3.25

## File Queue
- [x] SCANNED — coming_home.yaml | issues: 2

## Issues Found
| # | File | AP-ID | Severity | Line | Description | Suggested fix | Status |
|---|------|-------|----------|------|-------------|---------------|--------|
| 1 | coming_home.yaml | AP-22 | ⚠️ WARNING | L50 | `min_version: "2024.10.0"` is too low — `assist_satellite.start_conversation` was introduced in HA 2025.2, Voice PE support landed in 2025.4. Current min_version allows installs on HA versions that lack the core action this blueprint depends on. | Change to `min_version: "2025.4.0"` | OPEN |
| 2 | coming_home.yaml | no-AP | ℹ️ INFO | — | No `source_url:` in blueprint metadata. Project convention for GitHub-hosted blueprints — enables "Check for updates" in HA UI. | Add `source_url: "https://github.com/mmadalone/HA-Master-Repo/blob/main/automation/coming_home.yaml"` under `homeassistant:` block | OPEN |

## Info-Level Observations (no fix required)
1. **Header image:** ✅ exists at `HEADER_IMG` (coming_home-header.jpeg, 671KB)
2. **README companion:** ✅ exists at `readme/automation/coming_home-readme.md`
3. **Versioning directory:** No `_versioning/` entry found (may be SMB permissions or not yet created)
4. **Empty defaults on critical inputs:** `conversation_agent` defaults to `""`, `assist_satellites` defaults to `{}`. Blueprint description documents these are required for function. The `continue_on_error: true` + fallback greeting handles missing conversation_agent gracefully. Missing satellites means the automation runs but produces no audible output — by design per restart-safe philosophy.
5. **Nesting depth:** Deepest path (entrance-clear timeout → choose → sequence) hits 4 levels — right at AP-08 threshold but not over.
6. **Action block length:** ~196 lines — under the 200-line AP-08 threshold.

## Security Checklist (§10.5)
| # | Check | Result |
|---|-------|--------|
| S1 | Secrets | ✅ PASS — no raw API keys, passwords, or tokens |
| S2 | Input validation | ✅ PASS — selectors constrain types, templates have `\| default()` guards |
| S3 | Template injection | ✅ PASS — user-provided text flows to LLM conversation text and TTS, not to service call data |
| S4 | Target constraints | ✅ PASS — all service calls use explicit entity lists from `!input` |
| S5 | Agent permissions | ✅ N/A — blueprint calls an agent, doesn't define one |
| S6 | Log hygiene | ✅ PASS — logbook message contains person_name (expected) and truncated greeting (80 chars) |
| S7 | Rate limiting | ✅ PASS — cooldown_seconds (default 900s) gates execution, plus physical presence required |

## Anti-Pattern Scan Summary
| AP-ID | Result | Notes |
|-------|--------|-------|
| AP-01 | ✅ PASS | No LLM system prompt in YAML — uses !input for greeting prompt |
| AP-02 | ✅ PASS | All entity_ids from !input or input-derived variables |
| AP-03 | ✅ PASS | No device_id usage |
| AP-04 | ✅ PASS | Both wait_for_trigger have timeout + continue_on_timeout + wait.completed handling |
| AP-06 | ✅ PASS | Arrival switches cleaned on all exit paths (timeout, abort, normal, restart preamble) |
| AP-08 | ✅ PASS | Action block ~196 lines, nesting depth 4 (at threshold, not over) |
| AP-09 | ✅ PASS | 4 collapsible input sections |
| AP-09a | ✅ PASS | All 12 inputs have explicit defaults |
| AP-10/10a/10b | ✅ PASS | Modern syntax throughout (action:, trigger:, data:) |
| AP-11 | ✅ PASS | All action steps have aliases |
| AP-15 | ✅ PASS | Header image exists on disk |
| AP-16 | ✅ PASS | All states()/state_attr() have \| default() guards |
| AP-17 | ✅ PASS | continue_on_error only on non-critical or fallback-protected actions |
| AP-20 | ✅ PASS | Both wait_for_trigger wrapped with if pre-checks for already-true state |
| AP-21 | ✅ PASS | No raw secrets |
| AP-22 | ⚠️ ISSUE | min_version too low — see Issue #1 |
| AP-23 | ✅ PASS | Restart-safe cleanup preamble as first action |
| AP-24 | ✅ PASS | Uses conversation_agent selector, not entity selector |
| AP-42 | ✅ PASS | min_version nested correctly under homeassistant: |
| AP-44 | ✅ PASS | Section ① collapsed: false, ②③④ collapsed: true, all inputs have defaults |

## Current State
Audit complete. 1 warning (AP-22, min_version), 1 info (missing source_url). Security checklist clean. Blueprint is well-hardened — v4.x remediation series addressed all major structural concerns.
