# Build Log — MAINT-3 Undocumented Features Remediation

## Metadata
| Field | Value |
|-------|-------|
| Date | 2026-02-16 |
| Mode | BUILD |
| Scope | Style guide documentation gaps — MA 2.7, ESPHome 2025.10/2026.1, HA 2025.12–2026.2 |
| Trigger | Deep-pass audit finding MAINT-3 (WARNING): multiple undocumented platform features |
| Style Guide Version | 3.22 |

## Objective
Add version-specific documentation for new platform features across three domains. Keep additions surgical — compatibility notes, version caveats, and pattern implications only. No new pattern sections.

## Pre-Flight
- [x] Git checkpoint: style guide files in PROJECT_DIR
- [x] Build log created before first edit (AP-39)
- [x] Header image gate: N/A (no new blueprint)
- [x] Research completed via web search — all features verified against official sources

## Decisions
- **MA 2.7 Sendspin**: Add to §7 compatibility note + §7.10 (TTS coexistence) as new player provider context. Document in §7.2 "Other MA-specific actions" area. NOT creating a new section — Sendspin is a player provider, not a new automation pattern.
- **MA 2.7 user management**: Add brief note to §7 compatibility block. Impacts player entity naming (users may see per-user players). No new patterns needed.
- **MA 2.7 AirPlay 2**: Add to §7.1 player provider landscape mention. Brief note only.
- **ESPHome API password removal**: Update §6.4 (secrets). This also closes VER-1 from the audit (API password removal not documented). CRITICAL — configs with `password:` now FAIL to build in 2026.1.
- **ESPHome ESP-IDF default**: Update §6.1 (config structure). Brief note on framework change.
- **HA purpose-specific triggers (2025.12 Labs → 2026.2 GA)**: Update §5.11 which already references these. Add new trigger types from 2026.2.
- **"choose selector for blueprints"**: DROPPED — not verified. No evidence found in HA docs or release notes. Likely audit hallucination.
- **"AI conversation insights" / "AI Tasks"**: DROPPED from this scope — would need separate deep research and likely a new §8 subsection. Flagged for future session.

## Files Modified
| File | Section | Change |
|------|---------|--------|
| `05_music_assistant_patterns.md` | §7 compat note, §7.1, §7.10 | MA 2.7: Sendspin, AirPlay 2, user management, remote streaming |
| `04_esphome_patterns.md` | §6.1, §6.4 | ESPHome 2026.1: API password removal, ESP-IDF default |
| `02_automation_patterns.md` | §5.11 | HA 2026.2: expanded purpose-specific trigger types |

## Edit Log
1. `05_music_assistant_patterns.md` L9 — Updated compat note from "MA 2.x" to "MA 2.7" with feature summary (Sendspin, AirPlay 2, user mgmt, remote streaming, crossfade, scrobbling, DSP, external sources)
2. `05_music_assistant_patterns.md` L60 — Added player provider landscape block documenting AirPlay 2 and Sendspin as new providers, with Cast dual-entity note
3. `05_music_assistant_patterns.md` L822 — Added Sendspin/Voice PE coexistence note to §7.10 clarifying TTS patterns remain unchanged
4. `04_esphome_patterns.md` L178 — Added ⚠️ callout: API `password:` fully removed in 2026.1.0, configs now fail to build (also closes VER-1)
5. `04_esphome_patterns.md` L55 — Added framework change note: ESP-IDF now default for ESP32/C3/S2/S3, WiFi roaming automatic
6. `02_automation_patterns.md` L451 — Updated §5.11 status paragraph with 2026.2 trigger/condition expansion details

## Dropped Items
- "choose selector for blueprints" — not verified in HA docs or release notes. Likely audit hallucination.
- "AI conversation insights / AI Tasks" — out of scope, would need separate research and new §8 subsection. Flagged for future session.
- "Add-ons → Apps" rebranding (2026.2) — terminology change, no impact on automation/blueprint patterns.

## Current State
All 6 edits applied and verified via ripgrep. Three style guide files updated. No structural changes — all additions are compatibility notes, version caveats, and pattern clarifications within existing sections.

## Status
completed
