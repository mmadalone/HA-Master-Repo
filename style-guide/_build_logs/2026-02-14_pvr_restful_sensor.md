# Build Log — MadTeeVee PVR RESTful Sensor

- **Date:** 2026-02-14
- **Mode:** BUILD
- **Scope:** `secrets.yaml`, `configuration.yaml`, `template.yaml`
- **Checkpoint:** `checkpoint_20260214_232959` (base: `6136f943`)
- **Status:** completed
- **Commit:** `34d5e83b`

## Rationale

Kodi HA integration's websocket event pipeline (`kodi_call_method_result`) is unreliable
for PVR channel detection — confirmed by direct curl testing showing HTTP JSON-RPC works
perfectly while the event path fails. RESTful sensor is HA-native best practice for
polling a JSON API endpoint.

## Changes

1. `secrets.yaml` — add `kodi_madteevee_jsonrpc_url` and `kodi_madteevee_jsonrpc_auth`
2. `configuration.yaml` — add `rest:` sensor block polling `Player.GetItem` every 30s
3. `template.yaml` — update `pvr_channel` attribute to read from REST sensor

## Decisions

- 30s scan interval: responsive enough for display, light on Kodi
- POST body requests Player.GetItem with channel/channeltype/channelnumber/title/season/episode
- State = channel name when PVR, "idle" when not PVR, "off" when no player active
- PVR detected by item.type == "channel" in response (more reliable than season/episode fingerprint)
- COLOR tag stripping in value_template for IPTV channels
- Blueprint remains as optional fast-path supplement
