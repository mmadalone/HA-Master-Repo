# Build Log — PVR Channel Tracker v1.2

- **Date:** 2026-02-14
- **Mode:** BUILD
- **Scope:** `blueprints/automation/madalone/pvr_channel_tracker.yaml` + `template.yaml`
- **Checkpoint:** `checkpoint_20260214_225220` (base: `104c3223`)
- **Status:** in-progress

## Problem 1 — IPTV fingerprinting too strict

PVR condition checks `media_season == -1 and media_episode == -1`. Some IPTV channels
(e.g., TV3 via IPTV Simple Client) don't set these attributes at all — they're absent,
not -1. The `| int(-99)` fallback returns -99, condition fails, automation never fires.

## Problem 2 — [COLOR] markup in EPG data

Some IPTV providers embed Kodi color tags in EPG titles:
`Benidorm Fest [COLOR tomato]T5[/COLOR] [COLOR goldenrod]Final[/COLOR]`
These need stripping before storage and display.

## Fix

1. Widen PVR fingerprint: `media_season < 0` (catches -1) OR attribute is absent (catches IPTV)
2. Add `label` and `title` to Player.GetItem properties for channel name fallback
3. Add `regex_replace` to strip `[COLOR xxx]...[/COLOR]` tags from channel name in blueprint
4. Add `[COLOR]` stripping to template sensor's `media_title` display
5. Bump changelog to v1.2

## Decisions

- Fingerprint uses `< 0` rather than `in [-1, -99]` — more future-proof against other negative values
- Channel name extraction order: `channel` → `label` → empty string
- COLOR stripping applied at both storage (blueprint) and display (template sensor) layers
