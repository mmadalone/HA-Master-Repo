# Build Log — §1.13 tool assignment rewrite

## Session
- **Date started:** 2026-02-14
- **Status:** in-progress
- **Scope:** Rewrite §1.13 to assign tools by operation type (read/search/edit/write) instead of by tool identity
- **Style guide sections loaded:** §1 (full — editing §1.13), §2.3 (pre-flight)
- **Style guide version:** 3.9 → 3.10
- **Files in scope:** 2

## File Queue
- [ ] PENDING — 00_core_philosophy.md | §1.13 full rewrite
- [ ] PENDING — ha_style_guide_project_instructions.md | version bump

## Planned Changes

### 00_core_philosophy.md
1. Replace entire §1.13 section with operation-based tool assignment
2. Filesystem MCP becomes primary for: reads, searches, line-based edits
3. Desktop Commander becomes primary for: writes (especially append mode for 30KB+)
4. Known quirks table added to prevent rediscovery of tool-specific gotchas
5. HA MCP, ha-ssh, gemini, automation traces sections unchanged

### ha_style_guide_project_instructions.md
6. Version bump 3.9 → 3.10

## Issues Found
| # | File | AP-ID | Severity | Line | Description | Status |
|---|------|-------|----------|------|-------------|--------|
| 1 | 00_core_philosophy | no-AP | ⚠️ WARNING | §1.13 | Tool assignment by identity causes 5-10 wasted calls per session from Desktop Commander search/read reliability gaps | OPEN |

## Fixes Applied
| # | File | Description | Issue ref |
|---|------|-------------|-----------|

## Current State
Build log created. No edits started yet.
