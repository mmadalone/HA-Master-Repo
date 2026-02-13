# bedtime_routine_plus — Changelog

## v5.1.2 — 2026-02-13
- Fixed fatal crash: Kodi `CHANNEL` content type with plugin:// URI causes `int()` parse error
- Added `kodi_safe_content_type` derived variable — auto-detects URI patterns and overrides to `video`
- Logic: if content_type is CHANNEL and content_id contains `://` or `/`, use `video` instead
- Root cause: PseudoTV Live uses plugin:// URIs but CHANNEL type expects numeric PVR channel IDs

## v5.1.1 — 2026-02-13
- Fixed LLM error messages being spoken as TTS announcements
- Added `response_type != 'error'` guard to all 5 response extraction blocks
- Affects: bedtime_message, settling_message (×2), gn_context_message, goodnight_message
- Root cause: conversation.process returns errors in speech.plain.speech field

## v5.1.0 — 2026-02-13
- Added optional presence sensor gate (3 new inputs in ① Trigger section)
- Configurable ANY/ALL sensor logic via `presence_require_all` boolean
- Minimum presence duration (0–300 minutes) with `last_changed` validation
- Fail-open on unavailable/unknown sensors (log warning, allow routine)
- Manual trigger bypasses presence gate entirely
- Logbook entry on gate failure with sensor list, mode, and duration
- Temp switch cleanup on abort path

## v5 — 2026-02-13
- Initial release — Kodi playback with JSON-RPC library pre-fetch, genre filtering, sleepy TV detection, and TV sleep timer
