# Audit Log — ups_notify.yaml style guide review

## Session
- **Date started:** 2026-02-11
- **Status:** completed
- **Scope:** Single blueprint review — `ups_notify.yaml` against §10 scan table, §3, §5
- **Style guide sections loaded:** §1, §3, §5 (partial), §10, §11.2
- **Style guide version:** 2.6 — 2026-02-11

## File Queue
- [x] SCANNED — ups_notify.yaml | issues: 14

## Issues Found
| # | File | AP-ID | Severity | Line | Description | Suggested fix | Status |
|---|------|-------|----------|------|-------------|---------------|--------|
| 1 | ups_notify.yaml | AP-15 | ⚠️ WARNING | L3 | No `![Image]` in description; no image on disk | Generated header image, user approved | FIXED |
| 2 | ups_notify.yaml | AP-09 | ⚠️ WARNING | inputs | No collapsible input sections | Wrapped into ① UPS sensors, ② Thresholds & notifications | FIXED |
| 3 | ups_notify.yaml | AP-10 | ⚠️ WARNING | L49,59,70 | `service:` used 3× — legacy syntax | Replaced with `action:` | FIXED |
| 4 | ups_notify.yaml | AP-10a | ⚠️ WARNING | L33,38 | `platform:` trigger prefix — legacy | Replaced with `trigger:` | FIXED |
| 5 | ups_notify.yaml | AP-10 | ⚠️ WARNING | L32,42,44 | Singular top-level keys | Migrated to `triggers:`, `conditions:`, `actions:` | FIXED |
| 6 | ups_notify.yaml | AP-16 | ❌ ERROR | L47 | `states()` without `\| default()` | Added `\| default('unknown')` | FIXED |
| 7 | ups_notify.yaml | AP-16 | ❌ ERROR | L49 | `states()` without `\| default()` | Added `\| default('0')` | FIXED |
| 8 | ups_notify.yaml | AP-16 | ❌ ERROR | L73 | `states()` without `\| default()` in low_battery branch | Added `\| default('unknown')` | FIXED |
| 9 | ups_notify.yaml | AP-11 | ⚠️ WARNING | L45–81 | Zero `alias:` fields anywhere in actions | Added descriptive aliases to every step | FIXED |
| 10 | ups_notify.yaml | no-AP | ⚠️ WARNING | header | Missing `author:` field | Added `author: madalone` | FIXED |
| 11 | ups_notify.yaml | no-AP | ⚠️ WARNING | header | Missing `min_version:` | Added `min_version: "2024.10.0"` | FIXED |
| 12 | ups_notify.yaml | no-AP | ℹ️ INFO | L3 | No "Recent changes" in description | Added v1/v2 change log | FIXED |
| 13 | ups_notify.yaml | no-AP | ℹ️ INFO | L7 | Fake `source_url` (`chatgpt.local`) | Removed entirely | FIXED |
| 14 | ups_notify.yaml | AP-13 | ℹ️ INFO | L28 | `text:` selector for notify service | Kept as-is; added description note explaining no native selector exists | FIXED |

## Fixes Applied
| # | File | Description | Issue ref |
|---|------|-------------|-----------|
| 1 | ups_notify.yaml | All 14 issues resolved in single rewrite | Issues #1–14 |

## Current State
All issues fixed. File written to SMB mount. v1 backup and changelog in `_versioning/automations/`.
