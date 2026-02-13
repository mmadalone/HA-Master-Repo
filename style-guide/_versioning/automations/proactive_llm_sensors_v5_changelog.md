# proactive_llm_sensors_v5 — Changelog

## v8 — 2026-02-10
- **Enriched `sensor_context` template for media player entities:**
  - Media players now include `media_title`, `media_artist`, and `media_content_type`
    attributes when state is `playing` — gives the LLM actual content to reference
    instead of just "playing"/"idle"
  - Non-media entities unchanged (still show state + unit_of_measurement)
  - Fixes issue where LLM would comment on idle TV instead of actively-playing
    workshop speaker because it had no content context to differentiate them
- Updated description block to show v8 changes

## v7 — 2026-02-08
- **Name system overhaul — multi-name with random selection:**
  - Replaced single `user_name` input with three inputs:
    - `user_names`: comma-separated real names/nicknames (e.g. "Miquel, Miky, boss")
    - `fallback_names`: direct-speech generic terms for TTS (e.g. "friend, hey there, mate")
    - `llm_fallback_names`: 3rd-person reference terms for LLM prompts (e.g. "the user, the person")
  - Three computed variables resolve once per run:
    - `chosen_user_name`: random pick from user_names (empty if none set)
    - `chosen_direct_name`: user name if available, otherwise random from fallback_names
    - `chosen_llm_name`: user name if available, otherwise random from llm_fallback_names
  - All three template references in actions updated to use new variables
  - Same name used consistently throughout a single run (LLM prompt, fallback, bedtime)
- **Minor violations cleared:**
  - #15/#16: Select option labels — already done in v6
  - #17: Blank line consistency — verified consistent
  - #18: bedtime_help_script default — already done in v6
- Updated description block to show v7 changes (last 4 versions)

## v6 — 2026-02-08
- **Critical style guide fixes:**
  - Added `author:`, `min_version:`, description image, and recent changes to blueprint header (§3.1)
  - Reorganized all inputs into collapsible Stage sections (§3.2)
  - Added `alias:` to every action step missing one (§3.5)
  - Migrated `service:` calls to `action:` for consistency (§1.4)
  - Added `| default()` safety to all templates missing fallbacks (§3.6)
  - Added `continue_on_error: true` on `conversation.process` calls with fallback handling
  - Added `trigger: state` / `trigger: time_pattern` modern syntax
- **Moderate style guide fixes:**
  - Added `trace: stored_traces: 15` for complex automation debugging (§5.8)
  - Reviewed template conditions — all confirmed justified (§1.4 false positive)
  - Made `user_name` input optional (default: empty string, fallbacks via `default('x', true)`)
  - Bedtime fallback text no longer hardcodes any name

## v5 — pre-style-fixes (backed up as v5)
- State before style guide critical fixes were applied
