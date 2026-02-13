# 06_anti_patterns_and_workflow — Changelog

## v4 — 2026-02-08
- Anti-pattern #11: Removed "numbered comment" requirement — now requires only `alias:` with "what — why" format
- Aligns with §3.5 v2 changes (comments demoted to optional)

## v3 — 2026-02-08
- Added "Development Environment (35–36)" anti-pattern subsection: #35 prohibits container/sandbox tools for user filesystem ops, #36 prohibits single-pass generation of files over ~150 lines
- Added §11.5: Chunked file generation — mandatory procedure for files over ~150 lines (outline → chunk → confirm → repeat)
- Added §11.6: Checkpointing before complex builds — conditional summary step when extended design discussion precedes file creation
- Root cause: context compression during long generation passes was causing dropped sections and forgotten decisions

## v2 — 2026-02-08
- Added §11.0: universal pre-flight step — references §2.2 checklist, applies to ALL workflows, per-file versioning required
- Strengthened anti-pattern #12: now references §2.2 pre-flight and §2.1 scope explicitly, calls out "just docs" and "small change" as non-exemptions
- Root cause: seven files were edited without versioning because §11 had no enforcement hook

## v1 — 2026-02-08
- Baseline after audit edits (grouping headers for anti-patterns: General 1–23, ESPHome 24–28, Music Assistant 29–34)
- NOTE: v1 includes unversioned audit edits — the pre-audit state was not captured due to the versioning gap this fix addresses
