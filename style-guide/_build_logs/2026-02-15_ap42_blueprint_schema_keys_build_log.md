# Edit Log — AP-42 blueprint schema key whitelist
**Date:** 2026-02-15 · **Status:** complete
**File(s):** `01_blueprint_patterns.md`, `06_anti_patterns_and_workflow.md`, `ha_style_guide_project_instructions.md`
**Changes:** (1) Added explicit valid `blueprint:` top-level key whitelist to §3.1 — `name`, `author`, `description`, `domain`, `source_url`, `homeassistant`, `input`. Documents common mistakes with `min_version` and `icon`. (2) Added AP-42 (❌ ERROR) to §10 scan table — catches any key under `blueprint:` not in the whitelist. (3) Added prose rule #42 to General section. (4) Updated AP numbering note (AP-41→AP-42), section header (1-24 → 1-24, 42), master index AP count (42→43), version bump (3.14→3.15), changelog entry.
**Git:** checkpoint created before edit: N/A (PROJECT_DIR files — Post-Edit Publish Workflow)
