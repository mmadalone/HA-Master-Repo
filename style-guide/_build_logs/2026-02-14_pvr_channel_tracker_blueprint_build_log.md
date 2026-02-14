# Build Log — PVR Channel Tracker Blueprint

**Date:** 2026-02-14 · **Status:** in-progress
**Style guide sections loaded:** §1 (Core Philosophy), §2.3 (pre-flight), §3/§4 (blueprint patterns)
**Mode:** BUILD
**Git checkpoint:** `checkpoint_20260214_215949` (`45fa38d1`)

## Task
Create a new blueprint `pvr_channel_tracker.yaml` that monitors a Kodi media_player for PVR content (fingerprinted by season/episode = -1) and queries the active channel name via `kodi.call_method` → `Player.GetItem`. Channel name is stored in a user-provided `input_text` helper. Uses `wait_for_trigger` to catch the `kodi_call_method_result` event inline (single automation, no event-bus coordination).

Additionally: create the `input_text.madteevee_pvr_channel` helper and update `sensor.madteevee_now_playing` template sensor to expose a `pvr_channel` attribute and enrich the Live TV state string.

## Decisions
- Single automation via `wait_for_trigger` on `kodi_call_method_result` — avoids dual-automation complexity
- Blueprint parameterized with 3 inputs: `kodi_entity`, `pvr_channel_helper`, `query_timeout`
- PVR fingerprint: `media_season == -1 AND media_episode == -1` (how Kodi marks PVR/live content)
- `Player.GetItem` with `playerid: 1` (video player) and `properties: [channel, channeltype]`
- `wait_for_trigger` timeout: configurable, default 5s, `continue_on_timeout: true`
- `mode: restart` — channel switches kill previous run, no stale data
- Template sensor enrichment: `Live TV: <title> (<channel>)` when channel is available
- PseudoTV virtual channels may or may not return `channel` via `Player.GetItem` — will need live testing
- Header image: approved — `pvr_channel_tracker-header.jpeg` (Rick & Quark crossover, low-angle heist shot)

## Target file(s)
- `HA_CONFIG/blueprints/automation/madalone/pvr_channel_tracker.yaml` — NEW (the blueprint)
- `HA_CONFIG/helpers_input_text.yaml` — APPEND `madteevee_pvr_channel` entry
- `HA_CONFIG/template.yaml` — EDIT `madteevee_now_playing` sensor (add channel var + pvr_channel attr)
- `HA_CONFIG/automations.yaml` — APPEND blueprint instance

## Chunks
1. Blueprint file — header, inputs, triggers, actions (single file, est. ~80–100 lines)
2. Helper entry in `helpers_input_text.yaml`
3. Template sensor update in `template.yaml`
4. Automation instance in `automations.yaml`

## Files modified
- `images/header/pvr_channel_tracker-header.jpeg` — NEW (header image, approved)

## Current state
Header image approved. Git checkpoint active. Ready to write chunk 1 (blueprint file).

## Recovery (for cold-start sessions)
- **Resume from:** Pre-chunk-1 — header image done, no YAML written yet
- **Next action:** Write chunk 1 (blueprint file)
- **Decisions still open:** None — design is locked
- **Blockers:** None — pending PseudoTV `Player.GetItem` channel response is a post-build test item, not a blocker
- **Context recovery:** search "pvr channel tracker blueprint kodi" or "madteevee pvr channel"
