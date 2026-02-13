# bedtime_routine — Changelog

## v1 — 2026-02-09
- Initial version: LLM-orchestrated bedtime with TV shutdown (CEC + IR + script), lights-off, countdown negotiation, audiobook offer, bathroom guard, goodnight message
- Three stackable TV-off methods: media_player, script, IR remote
- Audiobook modes: curated, freeform, both
- Bathroom occupancy guard with grace period and max timeout
- Speaker reset (power-cycle) support
- ElevenLabs voice profile support

## v2 — 2026-02-09
- Added IR state guard: IR blast skipped if CEC media_player already reports off/standby/unavailable (prevents IR toggle-on when TV is already off)
- Added media_players_stop input: target selector for media players to stop before lights-off (Chromecast, Sonos, MA players, etc.)
