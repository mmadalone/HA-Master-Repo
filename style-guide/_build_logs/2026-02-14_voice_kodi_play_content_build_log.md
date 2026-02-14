# Build Log — voice_kodi_play_content

| Field | Value |
|-------|-------|
| **Date** | 2026-02-14 |
| **Status** | complete |
| **Mode** | BUILD |
| **Target file** | `HA_CONFIG/blueprints/script/madalone/voice_kodi_play_content.yaml` |
| **Source** | `scripts.yaml` → `voice_play_bedtime_kodi` (existing raw script) |
| **Git checkpoint** | `checkpoint_20260214_173941` (commit `691657b1`) |
| **Header image** | `voice_kodi_play_content-header.jpeg` — approved (user-selected from prior generation) |

## Scope

Convert the existing `voice_play_bedtime_kodi` raw script into a reusable, shareable script blueprint. Generalize naming (strip bedtime context), add configurable inputs (Kodi entity, JSON-RPC timeout, error handling mode), preserve all routing logic.

## Decisions

1. **Blueprint name:** `voice_kodi_play_content` — general-purpose, no bedtime branding
2. **Domain:** script
3. **Three routing paths preserved:** movie/episode (play_media), favourite (Player.Open), tvshow_continue (JSON-RPC chain)
4. **New inputs:** Kodi entity selector, JSON-RPC timeout (default 10s), error notification mode (logbook vs notify)
5. **Existing `bedtime_routine_plus.yaml` migration:** will need script entity reference update (separate task)
6. **Header image:** Star Trek Lower Decks style — user selected `image-1771086930590.jpeg`, renamed to convention

## Chunks

- [x] Single pass — 327 lines, under threshold for chunked generation
- Blueprint header, inputs (2 collapsible sections), fields, variables, all 3 routing paths, error handling

## Files Modified

- `HA_CONFIG/blueprints/script/madalone/voice_kodi_play_content.yaml` — 327 lines, written in single pass
- `GIT_REPO/images/header/voice_kodi_play_content-header.jpeg` — header image (user-selected)

## Anti-Pattern Self-Check

- AP-02: No hardcoded entity_ids — all from !input ✅
- AP-04: All wait_for_trigger have timeout + continue_on_error ✅
- AP-09: Collapsible input sections (①②) ✅
- AP-10: Modern action: syntax throughout ✅
- AP-11: Every action has alias ✅
- AP-15: Header image present and file exists ✅
- AP-16: All states()/state_attr() have | default() guards ✅
- AP-38: Reasoning-first before code ✅
- AP-39: Build log on disk before first write ✅

## Outstanding

- [ ] User: reload scripts in Developer Tools → YAML
- [ ] User: create instance from blueprint, verify inputs resolve
- [ ] User: test each routing path (movie, favourite, tvshow_continue)
- [ ] Update bedtime_routine_plus agent function registration to use new blueprint instance (separate task)
- [x] Generate README (§11.14) — `readme/script/voice_kodi_play_content-readme.md`
- [ ] Pending: user decision on removing old voice_play_bedtime_kodi raw script
