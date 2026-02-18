# Version History: Goodnight Routine – Bedtime Negotiator (Music Assistant)

| Field         | Value                                                |
|---------------|------------------------------------------------------|
| **File**      | `blueprints/script/madalone/goodnight_routine_music_assistant.yaml` |
| **Domain**    | script                                               |
| **Author**    | madalone                                             |

## Changelog

### v2.0.0 — 2026-02-18 — Full compliance rebuild

**Type:** Major rewrite — audit remediation

**Changes:**
- Reorganised all inputs into 6 collapsible sections (①–⑥) with proper
  `collapsed:` properties and sensible defaults on every input
- Added `alias:` to every action, choose, if, variables, and condition step
- Added `continue_on_error: true` to all external service calls
  (assist_satellite, tts.speak, music_assistant.play_media, etc.)
- Fixed all `states()` calls with `| default('')` guards
- Deduplicated triple-copied music playback block into single unified block
- Removed dead `music_allowed: false` variable (set but never read)
- Fixed Stage 2→3 coupling bug — IR NO answer no longer blocks music stage
- Added `source_url`, `author`, `homeassistant.min_version: "2024.10.0"`
- Added header image (Rick & Quark bedtime negotiator theme)
- Expanded voice answer sentence lists (added "go ahead", "do it", "skip")
- Added `| default('')` guards on `.id` attribute access for response variables
- Updated blueprint description with structured flow documentation and
  recent changes section
- `music_volume` default changed from 0 to 0.15 (sensible non-zero default)

**Lines:** 1,297 → 1,259 (despite all additions — dedup saved ~90 lines)

### v1.0.0 — Pre-2026-02-18 — Original unversioned

**Type:** Initial implementation

**Notes:** No version tracking, no collapsible sections, no aliases,
no error handling. Functional but non-compliant with Rules of Acquisition.
