# 06_anti_patterns_and_workflow — Changelog

## v3 — 2026-02-11
- Added AP-39 (⚠️ WARNING): review/audit of 3+ files without audit log in `_build_logs/`.
- Added mandatory Step 0 to §11.2: create audit log before first scan on multi-file reviews.
- Enhanced issue format in §11.8.1: added AP-ID and line number fields to both structured markdown table and lightweight flat-file formats.
- Updated both example schemas (markdown Issues Found table + flat issues.log) to match new format.

## v2 — 2026-02-11
- Expanded §11.8 from build-only crash recovery to cover audits and multi-file scans.
- Added audit log format (`[SCANNED]`, `[ISSUE]`, `[IN_PROGRESS]`, `[FIXED]`, `[SKIPPED]`) alongside existing build log schema.
- Removed incorrect exemption "Review/audit tasks (no state to lose)" from "When NOT to bother" list.
- Added session header spec and severity mapping to §1.11 taxonomy.

## v1 — 2026-02-11
- Baseline before §11.8 audit expansion.
