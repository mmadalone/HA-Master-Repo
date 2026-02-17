# Build Log — Music Follow-Me People Guard

**Date:** 2026-02-17
**Blueprint:** N/A — standalone automation + helper
**Mode:** BUILD
**Status:** planned

## Scope

New standalone automation that watches Aqara FP2 `derived_zone_people_count` sensors
and auto-disables music follow-me when multiple people are detected. Fully decoupled
from the follow-me blueprint — communicates via the existing `input_boolean.music_follow_me`
kill switch.

## Rationale

Follow-me is a solo feature. When 2+ people occupy monitored areas, transferring music
to track one person's movement actively harms the experience for others. Rather than
embedding FP2 awareness into the follow-me blueprint (added complexity, version risk,
breaks users without FP2s), we build a separate automation that flips the existing kill
switch. The 3rd Rule of Acquisition: never spend more for an acquisition than you have to.

## Architecture

```
input_boolean.music_follow_me_people_guard   ← master enable (new helper)
    └─► automation.music_follow_me_people_guard  ← watches FP2 sensors (new)
        └─► input_boolean.music_follow_me        ← existing kill switch (untouched)
            └─► follow-me blueprint               ← existing (untouched)
```

## New Entities

### Helpers

| Entity ID | Type | File | Purpose |
|---|---|---|---|
| `input_boolean.music_follow_me_people_guard` | input_boolean | `helpers_input_boolean.yaml` | Master enable/disable for people-count guard feature |
| `input_number.follow_me_people_threshold` | input_number | `helpers_input_number.yaml` | Zone count that triggers disable (default: 2, min: 2, max: 5) |
| `input_number.follow_me_people_stabilization` | input_number | `helpers_input_number.yaml` | Seconds count must stay above threshold before disabling (default: 30) |
| `input_number.follow_me_people_grace_period` | input_number | `helpers_input_number.yaml` | Seconds count must stay at/below 1 before re-enabling (default: 60) |

### Automation

| Entity ID | File | Purpose |
|---|---|---|
| `automation.music_follow_me_people_guard` | `automations.yaml` (via HA MCP) | Watches FP2 sensors, flips kill switch |

## Files Touched

| File | Action | Notes |
|---|---|---|
| `helpers_input_boolean.yaml` | EDIT | Add `music_follow_me_people_guard` |
| `helpers_input_number.yaml` | EDIT | Add threshold, stabilization, grace period helpers |
| `automations.yaml` | CREATE (via HA MCP) | New automation `music_follow_me_people_guard` |

## Design Decisions

1. **Decoupled from follow-me blueprint** — no changes to `music_follow_me.yaml`. The
   automation communicates exclusively through `input_boolean.music_follow_me` which the
   blueprint already respects. Zero coupling, zero breakage risk.

2. **Optional by default** — `input_boolean.music_follow_me_people_guard` defaults to off.
   Users must explicitly enable the feature. If off, the automation short-circuits at the
   first condition and does nothing.

3. **Uses `derived_zone_people_count` only** — the cloud-based `_10s` statistics and
   `people_counting` sensors are unreliable (cumulative event counters, not occupancy).
   The local derived count (occupied zone count) is the only trustworthy signal.

4. **Hysteresis via stabilization + grace period** — prevents false triggers from zone
   straddling (1 person spanning 2 zones reads as count=2 momentarily). Stabilization
   delay requires the elevated count to hold steady before disabling. Grace period
   prevents follow-me from snapping back on the instant a guest steps out briefly.

5. **Configurable threshold** — default 2, but exposed as `input_number` so users can
   tune. A user who lives alone might set it to 2 (any multi-zone occupancy = guest).
   A couple might set it to 3 (both of them is normal, 3+ means guests).

6. **Two-trigger design** — one trigger path for "disable" (count rises above threshold),
   one for "re-enable" (count drops to threshold - 1 or below). Each has its own
   `for:` duration sourced from the respective input_number helper.

7. **FP2 sensor scope** — automation triggers on state changes from both
   `sensor.aqara_fp2_main_room_zone_based_people_count` and
   `sensor.aqara_fp2_presence_sensor_fp2_zone_based_people_count` (bathroom).
   Additional FP2s can be added to the trigger list as they're deployed.

8. **Does NOT auto-re-enable if user manually disabled** — if the user (or voice command,
   or another automation) turned off `input_boolean.music_follow_me` independently of
   this guard, the re-enable path should check that the guard was the one that disabled
   it. Use an `input_boolean.follow_me_guard_active` or attribute flag to track this.
   *Decision pending: simplest approach may be a hidden helper boolean that records
   "guard turned this off" so re-enable only fires when guard was the cause.*

## Edge Cases

| Scenario | Expected Behavior |
|---|---|
| 1 person, straddling 2 zones | Count flickers to 2 briefly; stabilization delay (30s default) absorbs it — no false disable |
| 2 people, one leaves temporarily | Count drops to 1; grace period (60s default) prevents premature re-enable |
| User manually disables follow-me | Guard does NOT re-enable it — only re-enables what it disabled |
| People guard toggle is off | Automation short-circuits, follow-me operates normally |
| FP2 goes unavailable | Automation should not fire on `unavailable`/`unknown` states — template guard required |
| Nobody home (count = 0 everywhere) | Existing follow-me timeout/fade handles this — guard is neutral |

## Pre-Flight Checklist

- [ ] Verify `input_boolean.music_follow_me` exists and is respected by follow-me blueprint
- [ ] Verify `derived_zone_people_count` sensor entity IDs on both FP2s
- [ ] Check `helpers_input_boolean.yaml` for existing entries — avoid duplicates
- [ ] Check `helpers_input_number.yaml` for existing entries — avoid duplicates
- [ ] Template safety: all `states()` calls get `| default()` guards
- [ ] `continue_on_error: true` not needed (no external service calls)
- [ ] Action aliases on all action blocks for debug traces

## Open Questions

1. **Hidden "guard was the cause" helper** — add `input_boolean.follow_me_guard_active`
   (set true when guard disables, cleared on re-enable)? Or is that overengineering
   for a v1? Could just accept that re-enable fires regardless and let the user deal.
2. **Voice integration** — should Rick/Quark be able to say "people guard is now active"
   when it triggers? Low priority but would be a nice touch.
3. **Notification** — optional notify when guard disables/re-enables follow-me?
   Could be a future enhancement.
