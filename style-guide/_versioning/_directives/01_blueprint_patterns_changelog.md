# 01_blueprint_patterns — Changelog

## v4 — 2026-02-10
- §4.1: Clarified that `icon:` applies to standalone scripts only, NOT to `blueprint:` schema
- Added warning callout: HA rejects `icon:` inside blueprint definitions with `extra keys not allowed`
- Scoped heading from "Every script" to "Every standalone script (created via UI or YAML)"
- Triggered by: runtime error on announce_music_follow_me_llm blueprint

## v3 — 2026-02-09
- §3.2: Added circled number emoji (①②③) as accepted alternative to "Stage N —" pattern for input section names
- Both patterns are valid; must be consistent within a single blueprint

## v2 — 2026-02-08
- §3.5: Dropped mandatory numbered comments requirement — `alias:` is now the sole required annotation
- §3.5: Aliases must describe "what — why"; YAML comments demoted to optional for complex cases only
- §3.5: Updated code examples to show alias-only pattern
- §4.2: Updated to match new §3.5 (alias-only, comments optional)
- Rationale: numbered comments duplicated information already in aliases, added file bloat with no runtime or trace benefit

## v1 — 2026-02-08
- Baseline after audit edits:
  - Expanded `min_version` into table with 5 thresholds (2024.1.0 through 2025.12.0)
  - Added §3.4 caveat: repeat loop variables NOT re-evaluated unless redefined locally
- ⚠️ VERSIONING GAP: pre-audit state was not captured. These edits were applied before the §2.1 scope was tightened to cover documentation files.
