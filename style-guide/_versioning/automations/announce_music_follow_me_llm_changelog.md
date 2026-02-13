# announce_music_follow_me_llm — Changelog

## v2 — 2026-02-10
- **CRITICAL FIX:** Replaced `omit`-based TTS `options:` with `choose` block to prevent `Invalid options found: ['voice_profile']` error on non-ElevenLabs TTS engines (§7.9)
- Migrated all `service:` calls to `action:` syntax (§1.4, anti-pattern #10)
- Changed `llm_agent_id` input selector from `entity: domain: conversation` to `conversation_agent:` to expose all installed agents including Extended OpenAI (§3.3, anti-pattern #24)
- Added `author:`, `min_version:`, header image, and formatted description with changelog (§3.1)
- Reorganized inputs into collapsible sections (§3.2)
- Added `description:` to all inputs (§3.3)
- Added `alias:` to every action, choose branch, and variables block (§3.5)
- ~~Added `icon:` (§4.1)~~ — REVERTED: `icon:` is not a valid blueprint schema key
- Standardized template safety to `| default()` throughout (§3.6)

## v1 — pre-2026-02-10
- Original version (pre-versioning baseline)
