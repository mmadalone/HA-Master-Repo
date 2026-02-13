# 00_core_philosophy — Changelog

## v4 — 2026-02-08
- §2.2: Changed `blueprints/` subdir to `automations/` in the versioning tree
- §2.2: Updated routing table — automations go to `automations/`, blueprints now also route to `automations/`
- §2.2: Added §2.2.1 "Missing subdir" rule — Claude must ask user before creating new subdirs or choosing placement when no matching folder exists
- §2.4: Updated workflow examples to reflect `automations/` rename

## v3 — 2026-02-08
- Rewrote §2 versioning directives: all versioning now centralized under `_versioning/` in the project dir
- Added §2.2 (Centralized versioning location) with routing table for `_directives/`, `blueprints/`, `scripts/` subdirs
- Explicit prohibition: no `_versioning/` folders under HA config dir or next to files
- Renumbered §2.2→§2.3 (pre-flight), §2.3→§2.4 (workflow), §2.4→§2.5 (active file)
- §2.5: clarified that HA always references the unversioned original, never the versioned backups

## v2 — 2026-02-08
- Tightened §2.1: scope expanded from "blueprint, script, or configuration file" to ALL project files — no exceptions
- Added §2.2: mandatory pre-flight checklist — must complete BEFORE first edit, with mid-edit recovery instructions
- Renumbered §2.2→§2.3 (workflow) and §2.2→§2.4 (active file)
- Root cause: seven files were edited without versioning because the old scope left wiggle room for "it's just docs"

## v1 — 2026-02-08
- Initial versioned baseline (split from monolithic style guide in v4 of project instructions)
