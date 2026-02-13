# llm_alarm — Changelog

## v4 — 2026-02-09 (FINAL)
- Added `collapsed: true` to stages 3 (LLM), 4 (Notifications), 5 (Snooze & music)
- Stages 1–2 remain expanded (required inputs — must be configured on every instance)
- Added `default: ""` to `llm_agent` (gated behind LLM toggle) and `music_script` (description notes it's required)
- Stripped hardcoded "miquel" from `tts_message` default and notification message
- Improved `notify_service` description: expected format `notify.mobile_app_<device>`, where to find it
- Audited violation #14 (inconsistent input-to-variable resolution) — no fix needed; mixed `!input` / variable pattern is correct
- Reviewed #18 (`media_player.media_stop`) — confirmed intended usage, no change
- **Review complete — all violations addressed or reviewed**

## v3 — 2026-02-09
- DRY: Extracted `tts_options` variable — eliminates duplicated voice_profile choose blocks at both TTS call sites (§1.1)
- Separation of concerns: Stripped behavioral LLM instructions (speech rate, time format, name) from `conversation.process` text — these belong in the agent's system prompt (§1.2)
- Kept structured meta payload (times, window duration, word count target, sensor context)
- Template safety: Defensive `or {}` chain on LLM response traversal — prevents None-attribute errors when LLM call fails or returns unexpected shape (§3.6)
- Added inline comments citing style guide sections for each fix

## v2 — 2026-02-09
- Added collapsible input sections (5 stages: Schedule, TTS, LLM, Notifications, Timing)
- Migrated all `service:` calls to `action:` syntax (HA 2024.1+)
- Added `author: madalone` to blueprint header
- Added description image (Rick & Morty style wake-up scene)
- Added `min_version: "2024.6.0"` (collapsible input sections requirement)
- Added recent changes section to description
- Removed placeholder `source_url`
- Fixed `>` to `>-` on template value_templates
- Added missing `alias:` on "Stop or play music after snooze" choose branch
- Added comment explaining why weekday condition uses a template

## v1 — 2026-02-09
- Initial version (pre-style-guide review)
