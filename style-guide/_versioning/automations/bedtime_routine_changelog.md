# bedtime_routine — Changelog

## v4.1.1 — 2026-02-13
- Fixed LLM error messages being spoken as TTS announcements
- Added `response_type != 'error'` guard to all 5 response extraction blocks
- Affects: bedtime_message (×2), settling_message, gn_context_message, goodnight_message
- Root cause: conversation.process returns errors in speech.plain.speech field

## v4.1.0 — 2026-02-13
- Added optional presence sensor gate (3 new inputs in ① Trigger section)
- Configurable ANY/ALL sensor logic via `presence_require_all` boolean
- Minimum presence duration (0–300 minutes) with `last_changed` validation
- Fail-open on unavailable/unknown sensors (log warning, allow routine)
- Manual trigger bypasses presence gate entirely
- Logbook entry on gate failure with sensor list, mode, and duration
- Temp switch cleanup on abort path

## v4 — 2026-02-12
- Added "preset" audiobook mode — direct URI play via music_assistant.play_media, no LLM conversation
- Preset mode: media players pause with fallback to stop (conversational modes keep legacy stop)
- Preset mode: reordered flow — TTS announcement first, then TV/lights/media, then audiobook
- Added settling-in contextual TTS (⑥) — optional LLM announcement with sensor context after audiobook starts
- Added final goodnight contextual TTS (⑦) — optional LLM announcement with sensor context after bathroom guard
- Countdown negotiation disabled in preset mode (fixed countdown, no satellite conversation)
- audiobook_media_type default changed from "audiobook" to "auto" (better for URI-based playback)
- Architecture: top-level choose branches preset vs conversational, shared preamble and tail

## v3 — 2026-02-11
- Bumped min_version to 2024.10.0 (was 2024.6.0 — file already used plural syntax)
- Fixed mixed singular/plural top-level keys: condition → conditions, action → actions
- Added error-path cleanup: temporary switches now turn off on mid-run failures
- Replaced em-dash section dividers with box-style (§3.2 compliance)

## v2 — pre-2026-02-11 (original)
- IR state guard (skip IR if TV already off via CEC); media player multi-stop before lights-off

## v1 — initial
- Initial version
