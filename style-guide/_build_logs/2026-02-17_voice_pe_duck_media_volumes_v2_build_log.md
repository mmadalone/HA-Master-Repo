# Build Log — voice_pe_duck_media_volumes.yaml v2.0 Remediation

| Field            | Value |
|------------------|-------|
| **File**         | `blueprints/automation/madalone/voice_pe_duck_media_volumes.yaml` |
| **Date**         | 2026-02-17 |
| **Status**       | completed |
| **Version**      | v1.0 → v2.0 |
| **Trigger**      | Full compliance audit remediation |

## Audit Findings Summary

| Severity | ID   | Description | Status |
|----------|------|-------------|--------|
| Critical | C-1  | Deprecated singular top-level keys (trigger/condition/action) | ✅ fixed — `triggers:`, `conditions:`, `actions:` |
| Critical | C-2  | `service:` → `action:` (~30 occurrences) | ✅ fixed — all calls use `action:` |
| Critical | C-3  | No collapsible input sections | ✅ fixed — 3 sections (core=false, announce=true, media=true) |
| Critical | C-4  | `default: input_number.dummy_placeholder` sentinel pattern | ✅ fixed — bare `default:` on all optional inputs |
| High     | H-1  | No action aliases | ✅ fixed — alias on every action step |
| High     | H-2  | Missing `continue_on_error` on volume store actions | ✅ fixed — all stores have `continue_on_error: true` |
| High     | H-3  | Inconsistent Alexa-safe template (announcement players) | ✅ fixed — identical template on media + announcement stores |
| High     | H-4  | No version/changelog/source_url metadata | ✅ fixed — v2.0.0 in description, `source_url:` added |
| Medium   | M-1  | Massive code duplication (8× store, 8× duck blocks) | ✅ fixed — `repeat: for_each:` with computed lists |
| Medium   | M-2  | Optional media players 2–8 have no defaults (required) | ✅ fixed — all player slots optional via bare `default:` |
| Medium   | M-3  | Inverted `choose` for ducking flag check | ✅ fixed — replaced with `if/then` |
| Medium   | M-4  | Announcement player 1 required but confusing | ✅ fixed — all announcement players optional with clear descriptions |
| Low      | L-1  | Description ASCII formatting | ✅ fixed — clean prose, no ASCII art |
| Low      | L-2  | `condition: []` → `conditions: []` | ✅ fixed |

## Structural Changes

### Before → After

| Metric | v1.0 | v2.0 |
|--------|------|------|
| Total lines | 664 | 479 |
| Top-level keys | singular | plural |
| Service keyword | `service:` (30×) | `action:` (8×, via repeat) |
| Input sections | 0 (flat) | 3 (collapsible) |
| Action aliases | 0 | 12 |
| Code duplication | 8× store + 8× duck blocks | 3 `repeat: for_each:` loops |
| Optional player defaults | `input_number.dummy_placeholder` | bare `default:` |
| Alexa-safe template | media players only | media + announcement players |

### Design Decisions

1. **Announcement volume store moved inside flag guard** — In v1.0, announcement
   player volumes were stored on EVERY trigger (not protected by ducking flag).
   This meant the second trigger in a conversation would overwrite the "before"
   volume with the boosted announcement volume. v2.0 stores announcement
   volumes once per conversation alongside media player volumes.

2. **All players optional** — v1.0 required media_player_1, media_player_2, etc.
   v2.0 makes every slot optional. The computed `media_players` and
   `announcement_players` lists filter out unconfigured slots at runtime.
   If nothing is configured, the automation runs but does nothing (no-op).

3. **`repeat: for_each:` with namespace lists** — Variables section builds
   filtered lists of `{entity, helper}` dicts using Jinja namespace pattern.
   All three action phases iterate these lists instead of duplicating blocks.

## HA Config Validation

✅ `ha_check_config` returned: Configuration is valid
