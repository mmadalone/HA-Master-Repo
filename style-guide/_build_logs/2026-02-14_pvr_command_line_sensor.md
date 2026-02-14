# Build Log — MadTeeVee PVR Command-Line Sensor

- **Date:** 2026-02-14
- **Mode:** BUILD (escalated from TROUBLESHOOT)
- **Scope:** `configuration.yaml`, `secrets.yaml`
- **Checkpoint:** `checkpoint_20260214_231629` (base: `6136f943`)
- **Status:** in-progress

## Rationale

The Kodi HA integration's websocket event pipeline (`kodi_call_method_result`) is unreliable
for PVR channel detection. Direct HTTP JSON-RPC calls to Kodi work flawlessly (confirmed via
curl testing). Replace the event-based blueprint approach with a polling command_line sensor
that calls `Player.GetItem` over HTTP every 30 seconds.

## Changes

1. Add `kodi_madteevee_jsonrpc_auth` to `secrets.yaml` (Kodi HTTP credentials)
2. Add `command_line:` sensor block to `configuration.yaml` — polls Kodi's JSON-RPC
   endpoint, extracts PVR channel data, exposes as sensor with attributes

## Decisions

- 30-second poll interval: balances responsiveness vs Kodi load
- Python3 inline parsing in command: sanitizes output, handles errors, strips COLOR tags
- Kodi credentials in secrets.yaml as auth string (not full URL — cleaner)
- Blueprint stays for now (debounce fix makes it functional), sensor is the reliable path
