# Build Log — §1.13 tool assignment rewrite

## Session
- **Date started:** 2026-02-14
- **Date completed:** 2026-02-14
- **Status:** ✅ COMPLETE
- **Scope:** Rewrite §1.13 to assign tools by operation type (read/search/edit/write) instead of by tool identity
- **Style guide sections loaded:** §1 (full — editing §1.13), §2.3 (pre-flight)
- **Style guide version:** 3.9 → 3.10
- **Files in scope:** 2

## File Queue
- [x] DONE — 00_core_philosophy.md | §1.13 full rewrite (lines 254–307)
- [x] DONE — ha_style_guide_project_instructions.md | version bump, TOC update, changelog, token estimate

## Planned Changes

### 00_core_philosophy.md
1. ✅ Replace entire §1.13 section with operation-based tool assignment
2. ✅ ripgrep added as primary search tool (was not in original plan — installed same day)
3. ✅ Filesystem MCP blanket prohibition lifted — authorized for reads and line-range targeting only
4. ✅ Desktop Commander remains primary for writes, edits, and append mode for 30KB+
5. ✅ Known quirks table (§1.13.3) added to prevent rediscovery of tool-specific gotchas
6. ✅ HA MCP, ha-ssh, gemini, automation traces sections preserved (restructured into §1.13.2)
7. ✅ Section expanded from flat table to four subsections: §1.13.1–§1.13.4

### ha_style_guide_project_instructions.md
8. ✅ Version bump 3.9 → 3.10
9. ✅ TOC entry expanded with subsection references
10. ✅ Changelog v3.10 entry added
11. ✅ Token estimate updated: §1 ~7.9K → ~8.9K, file ~11.0K → ~12.0K

## Pre-edit validation
- ripgrep head-to-head vs Desktop Commander `start_search` conducted on `06_anti_patterns_and_workflow.md`
- Two queries tested: "Image cleanup" and "HEADER_IMG_RAW"
- Results: ripgrep — single call, full context, line numbers, multi-match. DC — 2 calls, filename only, no content.
- Confirmed the 5–10 wasted calls per session figure cited in the "why this matters" section.

## Issues Found
| # | File | AP-ID | Severity | Line | Description | Status |
|---|------|-------|----------|------|-------------|--------|
| 1 | 00_core_philosophy | no-AP | ⚠️ WARNING | §1.13 | Tool assignment by identity causes 5-10 wasted calls per session from Desktop Commander search/read reliability gaps | ✅ FIXED |

## Fixes Applied
| # | File | Description | Issue ref |
|---|------|-------------|-----------|
| 1 | 00_core_philosophy.md | §1.13 rewritten: operation-based routing, ripgrep primary for search, FS MCP authorized for reads, known quirks table added | Issue #1 |
| 2 | ha_style_guide_project_instructions.md | Version 3.10, TOC subsections, changelog, token estimates | — |

## Current State
Build complete. Both files verified. Commit message:

```
[docs] style guide v3.10: rewrite §1.13 — operation-based tool routing

- Replaced tool-identity routing with operation-based assignment
- ripgrep added as primary search tool (single-call context+line numbers)
- Filesystem MCP prohibition lifted for reads/line-range targeting
- Known quirks table (§1.13.3) prevents rediscovery of tool-specific gotchas
- Section expanded to four subsections: §1.13.1–§1.13.4
```
