# Build Log — PVR Channel Tracker Feedback Loop Fix

- **Date:** 2026-02-14
- **Mode:** TROUBLESHOOT → BUILD escalation
- **Scope:** `blueprints/automation/madalone/pvr_channel_tracker.yaml`
- **Checkpoint:** `checkpoint_20260214_223730` (base: `caeb3879`)
- **Status:** completed
- **Commit:** `104c3223`

## Problem

Trigger 2 (`media_title` attribute change) fires without debounce. With `mode: restart`,
rapid attribute churn (PVR EPG updates, metadata refreshes) causes a tight loop:
trigger → `kodi.call_method` → wait killed by restart → trigger again. Kodi's JSON-RPC
connection becomes overwhelmed and the integration goes unresponsive.

Evidence: 4 triggers in 2.5 minutes, all `wait_for_trigger` timeouts, helper always empty.
Manual `kodi.call_method` also produced no `kodi_call_method_result` event after integration
went unresponsive. Reconnecting the integration restored function briefly, then the
automation re-triggered the loop.

## Fix

1. Add `for: "00:00:02"` debounce on trigger 2 (media_title attribute change)
2. ~~Add condition: skip if `media_title` matches helper~~ — **dropped:** helper stores channel
   name (e.g., "BBC One") while `media_title` is program name (e.g., "Night Court"). Comparing
   them is meaningless. Debounce alone breaks the loop.
3. Bump blueprint changelog to v1.1

## Decisions

- 2-second debounce chosen: long enough to absorb EPG chatter, short enough to catch real channel switches
- Skip-if-unchanged condition placed after existing conditions to preserve PVR fingerprint check order
