# proactive_llm_sensors — Changelog

## v7 — 2026-02-12 (CURRENT)

- Section keys renamed from `stage_N_xxx` to descriptive names (§3.2)
- Section display names migrated from "Stage N —" to "① Name" convention (§3.2)
- Added three-line `===` comment dividers between input sections (§3.2)
- All computed template variables migrated from `>` to `>-` to prevent trailing newline truthiness (§3.7)
- Blueprint description updated to show v5/v6/v7 changes

## v6.2 — 2026-02-10

- Bumped min_version from 2024.6.0 → 2024.10.0 (plural keys + action syntax require it)
- Added `| default('')` to `unit_of_measurement` attribute output in sensor_context (was bare `is defined`)
- Added `default:` branch to TTS choose block with `stop:` for unrecognized tts_mode values

## v6.1 — 2026-02-10
- Stripped version tag from blueprint name, trimmed regressed v7/v8 from recent changes
- Added default: "" to bedtime_assist_satellite input
- Removed redundant action-local llm_prompt variable shadowing top-level
- Hardened last_triggered cooldown template with default fallback per §5.5
- Added | default('') to media_artist and media_content_type attribute outputs
- Explicit empty string in chosen_user_name else branch
- Documented implicit timeout on assist_satellite.ask_question in alias
- Added device_class: occupancy filter to presence sensor selector

## v6 — 2026-02-08
- Style guide compliance — collapsible input sections, aliases on all actions,
  service→action migration, template safety, error handling on LLM calls,
  user_name input replacing hardcoded name
- Added author, min_version, description image, recent changes to header
- Added trace: stored_traces: 15
- Bedtime fallback text no longer hardcodes any name

## v5 — pre-style-fixes
- Weekday controls + weekend profile with separate schedule, cooldown,
  prompt overrides, and bedtime behavior per weekend days
- Max nags per session, minimum presence duration, media playing block guard

## v4 — (pre-versioning)
- Max nags per session, minimum presence duration, media playing block guard
