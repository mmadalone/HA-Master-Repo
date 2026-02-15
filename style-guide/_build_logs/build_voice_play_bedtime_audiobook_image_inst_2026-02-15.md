# Build Log — voice_play_bedtime_audiobook instantiation + header image

| Field | Value |
|-------|-------|
| **Date** | 2026-02-15 |
| **Files** | `blueprints/script/madalone/voice_play_bedtime_audiobook.yaml`, `scripts.yaml` |
| **Task** | Add header image to blueprint; replace standalone script with use_blueprint instantiation |
| **Mode** | BUILD |
| **Status** | completed |

## Decisions
- Generate header image (Rick & Morty style, 1K, 16:9)
- Add image reference to blueprint description
- Replace standalone script in scripts.yaml with use_blueprint: instantiation
- Keep alias, description, icon from original script
- Blueprint inputs: default_volume=0.35, media_type=audiobook, enqueue=replace (matching original)
