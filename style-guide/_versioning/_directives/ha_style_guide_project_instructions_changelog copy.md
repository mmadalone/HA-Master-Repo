# ha_style_guide_project_instructions — Changelog

## v7 — 2026-02-08
- Updated TOC: added Development Environment (35–36) under §10 anti-patterns
- Updated TOC: added §11.5 Chunked file generation and §11.6 Checkpointing before complex builds
- Updated stats: 77 → 80 subsections, 34 → 36 anti-patterns

## v6 — 2026-02-08
- Updated TOC: §2 subsections renumbered (2.1 Scope, 2.2 Pre-flight, 2.3 Workflow, 2.4 Active file)
- Updated TOC: added §11.0 Universal pre-flight
- Updated subsection count: 74 → 77

## v5 — 2026-02-08
- Added full TOC with all 74 subsections
- Added 07_troubleshooting.md to doc table
- Updated stats: 13 sections · 74 subsections · 34 anti-patterns · 8 files
- Added section numbering explanation note
- ⚠️ VERSIONING GAP: v4→v5 edits were applied before the §2.1 scope was tightened. v4 state was not backed up.

## v4 — 2026-02-08
- Split monolithic style guide into 7 focused documents:
  - 00_core_philosophy.md (§1, §2, §9, §12)
  - 01_blueprint_patterns.md (§3, §4)
  - 02_automation_patterns.md (§5)
  - 03_conversation_agents.md (§8)
  - 04_esphome_patterns.md (§6)
  - 05_music_assistant_patterns.md (§7)
  - 06_anti_patterns_and_workflow.md (§10, §11)
- Main file now serves as master index with cross-reference table
- All section numbers preserved for cross-referencing between docs
- No content changes — pure structural reorganization

## v3 — 2026-02-08
- Added section 8: Music Assistant Patterns (MA-specific action syntax, media_player.play_media with enqueue modes, search_media usage, transfer_queue, voice-friendly patterns, TTS interruption handling, MA-specific anti-patterns 29-33)
- Renumbered sections 8-11 → 9-12
- Recovery note: v2 was recovered from transcript after an in-place edit violation

## v2 — 2026-02-08
- Added section 6: ESPHome Device Patterns (substitutions, packages, secrets, wake words, config structure, common components, debug sensors, archiving, naming conventions)
- Added ESPHome-specific anti-patterns to section 9 (items 24-28)
- Renumbered sections 6-10 → 7-11

## v1 — 2026-02-08
- Initial version (established baseline for versioning)
