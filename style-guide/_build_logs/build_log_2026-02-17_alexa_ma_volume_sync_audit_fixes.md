# Build Log — alexa_ma_volume_sync.yaml audit fixes

| Field | Value |
|-------|-------|
| **Date** | 2026-02-17 |
| **Mode** | BUILD (escalated from AUDIT) |
| **Target file** | `blueprints/automation/madalone/alexa_ma_volume_sync.yaml` |
| **Blueprint version** | v3 → v4 |
| **Status** | completed |
| **Checkpoint** | `checkpoint_20260217_104425` (commit `443a5680`) |
| **Audit source** | In-chat audit findings, 2026-02-17 |

## Decisions

1. **AP-16 fix (❌ ERROR):** Add `| default('off')` to all three unguarded `states()` calls — ducking flag check, source playing check, target playing check.
2. **AP-09a fix (⚠️ WARNING):** The `ducking_flag` input is an entity selector inside a collapsed section with no `default:`. Entity selectors can't have a universal safe default. Move the input description to clarify it's required, and add `default: []` as empty-entity fallback so the section collapse behavior works. Also add a guard in the condition so an unconfigured ducking flag doesn't block sync.
3. **ℹ️ INFO items:** Not fixing — documented only. Redundant mute sync and post-cooldown tolerance gap are harmless edge cases.
4. **Changelog:** Bump to v4, document the fixes.

## Edit Log

| # | Time | File | Lines | Description | Status |
|---|------|------|-------|-------------|--------|
| 1 | 10:44 | alexa_ma_volume_sync.yaml | L281 | AP-16: Add default() guard to ducking flag states() | ✅ |
| 2 | 10:44 | alexa_ma_volume_sync.yaml | L295-296 | AP-16: Add default() guards to 2x playing states() | ✅ |
| 3 | 10:44 | alexa_ma_volume_sync.yaml | L107-108 | AP-09a: Add default="" to ducking_flag input + description | ✅ |
| 4 | 10:45 | alexa_ma_volume_sync.yaml | L37-40 | Changelog bump v3 → v4 | ✅ |
