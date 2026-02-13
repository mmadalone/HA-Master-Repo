# 05_music_assistant_patterns — Changelog

## v1 — 2026-02-08
- Baseline after audit edits:
  - Added MA 2.x compatibility banner at top
  - Replaced fragile `data: >` templated dict with proper `choose` block for radio_mode pattern — more verbose but trace-friendly and version-safe
- ⚠️ VERSIONING GAP: pre-audit state was not captured. These edits were applied before the §2.1 scope was tightened to cover documentation files.
