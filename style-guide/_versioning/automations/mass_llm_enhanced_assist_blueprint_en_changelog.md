# mass_llm_enhanced_assist_blueprint_en — Changelog

## v12 — 2026-02-12
- **M1:** Replaced remote GitHub header image URL with local `/local/blueprint-images/mass_llm_enhanced_assist-header.jpeg` (AP-15)
- **M2:** Moved blueprint from `music-assistant/` to `madalone/` author directory — automations.yaml path already updated in prior session
- **Note:** Fixes 1/3/4/5 from style compliance audit (AP-24 conversation_agent selector, §3.2 section keys, §3.2 Unicode display names, §3.2 === dividers) were already applied in a prior session. This version completes the remaining AP-15 image fix and relocates the file.

## v11 — 2026-02-12
- **M1:** Added pronoun instruction to `llm_prompt_intro` default — LLM now instructed to use second-person pronouns (your/yours) in `media_description` instead of echoing first-person (my/mine) from user utterance
- **M2:** Added `regex_replace('(?i)\\bmy\\b', 'your')` safety net on `media_info` variable — catches cases where LLM ignores the prompt instruction
- **M3:** Updated description changelog to v11, trimmed entries older than v9

## v10 — 2026-02-12
- **M1:** New `stage_5_shortcuts` collapsible input section with `uri_override_map` text input for keyword→URI mappings
- **M2:** New step `5j · Apply URI override mappings` — variable block with `final_media_id` that intercepts `llm_action_data_media_id` before play_media calls. Case-insensitive exact match against user-defined keyword=uri pairs
- **M3:** Updated description changelog to v10
- **M4:** Updated all three play_media branches (7a/7b/7c) `media_id` from `llm_action_data_media_id` to `final_media_id`
- **Note:** v9 backup is the v10 state — no pre-v10 snapshot was taken before the session that made these changes crashed. v8→v10 is the effective diff.

## v8 — 2026-02-09
- **M2:** Removed empty `condition: []` block (no-op, HA treats missing key identically)
- **M3:** Removed `source_url` — no public fork yet; upstream ref preserved as comment
- **M4:** Exposed playback verification delay as `playback_verify_delay` input (Stage 2, default 2s, slider 1–10s) — was hardcoded 2-second delay in step 8a
- **L1:** Stable-release comment cleanup: stripped all `Fix #N` changelog references from inline comments; preserved "why" explanations (timeout defense, from_json behavior, delimiter rationale, etc.)
- Updated description changelog to v8, trimmed older entries for readability

## v7 — 2026-02-09
- **Fix #25:** Fixed critical `from_json` parse failure that killed every voice request — two bugs:
  - **Whitespace injection:** `llm_cleaned` used `>-` folded block with non-trimmed Jinja tags (`{% %}` instead of `{%- -%}`), injecting literal spaces/newlines before the JSON string. `from_json` is strict and threw `ValueError` on the leading whitespace.
  - **Exception guard:** `from_json | default({}, true)` only catches *undefined* values, not the `ValueError` that `from_json` throws on malformed input. The "error handling" never actually handled errors.
  - Fix: Added `{%- -%}` trim markers on all Jinja control tags in `llm_cleaned`; replaced naked `from_json | default()` in `llm_result` with shape-check guard (`startswith('{') and endswith('}')`) that returns `{{ {} }}` for non-JSON input — `from_json` is only called on strings that look like JSON objects.
  - Root cause: regression introduced in v3 when monolithic parsing was refactored into the 4-variable pipeline. Upstream v1 had no error handling but also no whitespace bug — single-line `'{{ ... | from_json }}'` avoided YAML folding entirely.

## v6 — 2026-02-08
- **Fix #20:** Added timeout documentation + LLM-agent timeout recommendation on `conversation.process` call — `continue_on_error` catches crashes but not hangs; the agent's own timeout config is the primary defense (§5.1)
- **Fix #21:** Added post-playback state verification + error-aware response routing — play_media failures with `continue_on_error` no longer produce false "Now playing…" success messages (§5.2, anti-pattern #17)
- **Fix #22:** Blueprint name hyphen-minus → en-dash (§9.1)
- **Fix #23:** Skipped — file location decision deferred (see notes)
- **Fix #24:** Improved step 8 alias with "why" context — explains shuffle is a separate call because play_media lacks a shuffle param (§3.5)
- Updated description changelog to include v6 changes

## v5 — 2026-02-08
- **Fix #19 (review fix #4):** Added explicit `condition: []` before top-level `variables:` block — matches prescribed structure order per §3.4
- **Fix #19 (review fix #5):** Changed `actions:` (plural) to `action:` (singular) — canonical HA 2024.x+ syntax per §1.4
- **Fix #19 (review fix #6):** Moved `continue_on_error: true` from outer `choose` wrapper to each individual `music_assistant.play_media` action — avoids blanket error suppression (anti-pattern #17, §5.2)
- **Fix #19 (review fix #8):** Added `| reject('none')` on `prompt.values()` join — guards against null prompt inputs producing empty sections (§3.6)
- **Fix #19 (review fix #9):** Replaced dict-key + `| trim` response routing with explicit `choose` block — each branch visible in traces, no whitespace-sensitive string keys

## v4 — 2026-02-08
- **Fix #11:** Added `area_names_safe` / `player_names_safe` with `|||` delimiter for internal target matching — comma-separated names no longer break `.split()` resolution. Original `area_names` / `player_names` kept for LLM prompt compatibility.
- **Fix #12:** Added `continue_on_error: true` on `conversation.process` call with immediate validation gate — a hung or crashed LLM agent no longer silently kills the automation (§5.1, §5.2)
- **Fix #13:** Broke monolithic target resolution into named intermediate variables (`llm_requested_players`, `llm_player_search`, `llm_resolved_players`, etc.) — each sub-step is now visible in HA traces for debugging (§5.8)
- **Fix #14:** Added null guard on `trigger.device_id` — API/text pipeline calls that don't originate from a physical device no longer risk `area_id(None)` exceptions (§3.6)
- **Fix #15:** Added `continue_on_error: true` on `play_media` choose block — failed playback (MA offline, bad media_id) no longer crashes before voice response (§5.2)
- **Fix #16:** Moved shuffle word detection from response input defaults to `action_word` variable with `<action_word>` placeholder — users translating responses no longer need Jinja knowledge
- **Fix #17:** Added comment documenting `mode: parallel` rationale (§5.4)
- **Fix #18:** Added `trace: stored_traces: 15` for LLM debugging (§5.8)
- Updated trigger alias to follow numbered step pattern; added explanatory comment block on trigger

## v3 — 2026-02-08
- **Fix #1:** Added empty-list guards on `area_info` and `player_info` to prevent index crash
- **Fix #2:** Added `enqueue_mode` as user-configurable input (default: `replace`) per §7.2
- **Fix #3:** Replaced `none` sentinel values in artist/album with safe empty-string pattern
- **Fix #4:** Moved input-resolution variables to top-level `variables:` block per §3.4
- **Fix #6:** Added `| default('')` on `trigger.sentence` access per §3.6
- **Fix #7:** Removed dead `llm_prompt` legacy input (was cluttering the UI)
- **Fix #8:** Added explicit `collapsed: false` on stage_1 and stage_2 input sections
- **Fix #9:** Renamed blueprint from redundant "...Blueprint" to concise title per §9.1
- **Fix #10:** Removed unused `version` variable

## v2 — 2026-02-08
- **Error handling:** Added try/catch on LLM JSON parsing with user-facing error response
- **Template safety:** Added `| default()` on all `states()`, `state_attr()`, and dict access calls
- **Comments:** Added numbered comments on every action step per §3.5
- **radio_mode:** Refactored from ambiguous template expression to explicit `choose` block per §7.2
- **play_media:** Replaced templated `data:` dict with explicit `choose` branches for media type combos
- **Header:** Added `author:` field, fixed "converation" typo, restructured input sections to stage pattern
- **Mode:** Added `max: 10` and `max_exceeded: silent` to `parallel` mode
- **shuffle_set:** Added `continue_on_error: true` (non-critical action)
- **Description:** Added Recent Changes section per §3.1

## v1 — 2025-04-04 (upstream)
- Original version from music-assistant/voice-support repo (version 20250404)
