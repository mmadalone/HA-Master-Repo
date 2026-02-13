# Build Log — LLM Response Error Guard Fix

**Date:** 2026-02-13
**Status:** completed
**Task:** Add `response_type != 'error'` guard to all LLM response extraction blocks
**Root cause:** Trace shows conversation.process returning error messages in `speech.plain.speech` — extracted and spoken as TTS
**Files in scope:** 2
**Changes per file:** 5 extraction blocks each = 10 total edits

## Scope

| File | Current Version | Target Version | Blocks to fix |
|------|----------------|----------------|---------------|
| `bedtime_routine.yaml` | v4.1.0 | v4.1.1 | bedtime×2, settling, gn_context, goodnight |
| `bedtime_routine_plus.yaml` | v5.1.0 | v5.1.1 | bedtime×2, settling, gn_context, goodnight |

## Fix Pattern

**Before:**
```jinja
{% if X_response is defined
   and X_response.response is defined
   and X_response.response.speech is defined %}
```

**After:**
```jinja
{% if X_response is defined
   and X_response.response is defined
   and X_response.response.response_type | default('') != 'error'
   and X_response.response.speech is defined %}
```

## Pre-flight

- [x] Backup v4.1.0 / v5.1.0
- [x] Edits applied (10 blocks + 10 indentation fixes)
- [x] YAML validation: both files VALID
- [x] Changelogs updated
- [x] Description version bumps applied

## Bonus Fix — Kodi CHANNEL Crash (v5.1.2)

**Root cause:** `kodi_media_content_type` set to `CHANNEL` + PseudoTV `plugin://` URI → Kodi tries `int("plugin://...")` → fatal crash. `continue_on_error` doesn't catch it (integration-level validation error).

**Fix:**
- Added `kodi_safe_content_type` derived variable (auto-overrides CHANNEL when URI contains `://` or `/`)
- Updated `play_media` action to use `kodi_safe_content_type`
- 3 edits: variable + action + version bump
- YAML validated ✅
