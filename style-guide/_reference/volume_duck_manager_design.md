# Volume Duck Manager — Design Document
# ============================================================================
# Status:    PLANNED (abstract only — not yet built)
# Created:   2026-02-26
# Author:    madalone + Claude
# Location:  blueprints/script/madalone/volume_duck_manager.yaml (future)
# ============================================================================
#
# This document captures the full design for a centralized volume duck/restore
# script blueprint. It exists so any future session can pick this up and build
# it without re-analyzing the entire ecosystem.
#
# Related conversation: Claude Project "HA Master Style Guide", 2026-02-26
# ============================================================================

## 1. Problem Statement

The current HA setup has **6+ independent duck/restore systems**, each with its
own snapshot storage format, restore trigger logic, and state management:

| # | System                              | Snapshot Storage           | Mode      |
|---|-------------------------------------|----------------------------|-----------|
| 1 | voice_pe_duck_media_volumes         | Per-player input_number    | single    |
| 2 | voice_pe_restore_media_volumes      | Reads #1's input_numbers   | single    |
| 3 | homeassistantguide.info (3rd party) | scene.create snapshot      | restart   |
| 4 | notification_follow_me              | input_text JSON + refcount | parallel  |
| 5 | email_follow_me                     | Same as #4 (shared)        | parallel  |
| 6 | duck_refcount_watchdog              | Reads #4/#5's input_text   | single    |

Additionally, these systems **react to** duck state without ducking themselves:
- alexa_ma_volume_sync — gates on ducking_flag
- music_assistant_follow_me — gates on ducking_flag (voice_assistant_guard)
- goodnight_routine_music_assistant — uses satellite announce (duck-friendly)

### Failure modes observed:
- Rapid WhatsApp messages → volume ducks but never restores
- Voice PE trigger during notification duck → stores already-ducked volume
- 3rd-party blueprint's scene.create clobbers notification system's managed state
- ducking_flag is binary — can't distinguish which system is ducking
- Refcount only guards within notification/email blueprints, not cross-blueprint
- Any run dying mid-flight leaves refcount stranded until watchdog timeout (3 min)

### Root cause:
Distributed state with no central authority. Each system independently decides
to duck, stores snapshots in incompatible formats, and restores without awareness
of other active duck cycles.

## 2. Solution: Centralized Volume Duck Manager

A single **script blueprint** that owns all duck/restore logic. Every other
blueprint calls this script instead of doing inline volume manipulation.

### 2.1 File Location
```
blueprints/script/madalone/volume_duck_manager.yaml
```

### 2.2 Script Mode
```yaml
mode: queued
max: 10
```
Queued ensures atomic refcount operations. Max 10 covers worst-case WhatsApp
burst scenarios. NOT parallel — parallel would let two duck calls race on
the refcount increment.

### 2.3 Call Interface

Every caller passes exactly one variable:

```yaml
# To duck:
action: script.turn_on
target:
  entity_id: script.volume_duck_manager
data:
  variables:
    mode: "duck"

# To restore:
action: script.turn_on
target:
  entity_id: script.volume_duck_manager
data:
  variables:
    mode: "restore"
```

Zero duck logic in the caller. The caller doesn't need to know about players,
helpers, snapshots, or refcounts.

### 2.4 Blueprint Inputs (configured once at instantiation)

| Input                    | Type              | Purpose                                       |
|--------------------------|-------------------|-----------------------------------------------|
| duck_player_list         | entity (multiple) | All media players eligible for ducking         |
| duck_volume_level        | number (slider)   | Target volume during duck (0.0–1.0)           |
| duck_snapshot_helper     | input_text entity | JSON snapshot of pre-duck volumes              |
| duck_refcount_helper     | input_number entity| Tracks active duck cycles                     |
| ducking_flag             | input_boolean entity| Signal for external systems                   |
| announcement_players     | entity (multiple) | Players boosted for TTS (optional)             |
| announcement_volume      | number (slider)   | TTS boost level (optional)                     |

### 2.5 Internal Flow

#### Mode: duck
```
1. Increment refcount (input_number.set_value: current + 1)
2. IF refcount was 0 before increment (this is the first duck):
   a. Snapshot all player volumes → JSON array in input_text
      Format: [{"entity_id": "media_player.x", "volume": 0.45}, ...]
      Only snapshot players currently in "playing" state
      (non-playing players don't need restore)
   b. Turn ducking_flag ON
3. For each player in duck_player_list that is currently "playing":
   → media_player.volume_set to duck_volume_level
4. For each announcement_player (if configured):
   → media_player.volume_set to announcement_volume (boost for TTS)
```

#### Mode: restore
```
1. Decrement refcount (input_number.set_value: max(0, current - 1))
2. IF refcount is now 0 (this was the last active duck cycle):
   a. Parse JSON snapshot from input_text
   b. For each player in snapshot:
      → media_player.volume_set to stored volume
   c. Restore announcement players to their snapshot volumes
   d. Clear snapshot helper (set to "")
   e. Turn ducking_flag OFF
3. IF refcount is still > 0:
   → Do nothing. Other duck cycles are still active.
```

### 2.6 Snapshot Format (input_text JSON)

```json
[
  {"entity_id": "media_player.living_room", "volume": 0.45},
  {"entity_id": "media_player.bathroom", "volume": 0.30},
  {"entity_id": "media_player.voice_pe_living_room", "volume": 0.65}
]
```

First-write-wins: the snapshot is only written when refcount goes 0→1.
Subsequent duck calls read/use the existing snapshot. This prevents
the "snapshot the already-ducked volume" race condition.

### 2.7 Existing Helpers (reused)

These helpers already exist and will be reused as-is:

| Helper                            | Type          | Current Location              |
|-----------------------------------|---------------|-------------------------------|
| input_boolean.ducking_flag        | input_boolean | helpers_input_boolean.yaml:42 |
| input_number.duck_refcount        | input_number  | helpers_input_number.yaml:215 |
| input_text.notification_duck_snapshot | input_text | helpers_input_text.yaml:337   |

No new helpers needed. The per-player input_number helpers (voice_pe_*_volume,
*_volume_before, etc.) remain for backward compatibility during transition
but are NOT used by the central manager.

## 3. Migration Plan — What Changes

### 3.1 Blueprints to Refactor (strip inline duck logic)

| Blueprint                         | Change                                           |
|-----------------------------------|--------------------------------------------------|
| notification_follow_me            | Remove all inline duck/restore sections (§⑦).    |
|                                   | Replace with script.turn_on calls at duck/restore |
|                                   | points. Remove per-run snapshot variables.         |
| email_follow_me                   | Same treatment as notification_follow_me.          |
| notification_replay (script)      | Same — strip duck section, add script calls.       |
| voice_pe_duck_media_volumes       | Becomes **thin wrapper**: keeps satellite triggers |
|                                   | (idle→listening, idle→responding), action body     |
|                                   | replaced with single script.turn_on mode: duck.    |
| voice_pe_restore_media_volumes    | Becomes **thin wrapper**: keeps satellite→idle      |
|                                   | trigger + restore_delay, action body replaced with |
|                                   | single script.turn_on mode: restore.               |

### 3.2 Blueprints to Delete

| Blueprint                                                      | Reason                        |
|----------------------------------------------------------------|-------------------------------|
| homeassistantguide.info/pause_or_reduce_volume_of_media_player | Incompatible scene.create     |
| _when_assist_satellite_is_active.yaml                          | storage + mode:restart.       |
|                                                                | Replaced by thin wrappers     |
|                                                                | calling central manager.      |

### 3.3 Blueprints Unchanged

| Blueprint                                    | Why                                       |
|----------------------------------------------|-------------------------------------------|
| duck_refcount_watchdog                       | Kept as separate safety net. Already reads |
|                                              | the same shared helpers. No changes needed.|
| alexa_ma_volume_sync                         | Only reads ducking_flag as gate. Unchanged.|
| music_assistant_follow_me_multi_room_advanced| Only reads ducking_flag as gate. Unchanged.|
| goodnight_routine_music_assistant            | Uses satellite announce (duck-friendly),   |
|                                              | doesn't do inline ducking. Unchanged.      |

### 3.4 Per-Player input_number Helpers (backward compat)

These helpers are NOT used by the central manager but are left in place
during transition. They can be removed in a future cleanup pass once all
blueprints are confirmed migrated:

- input_number.voice_pe_2nd_pop
- input_number.voice_pe_alexa
- input_number.voice_pe_bathroom_volume
- input_number.voice_pe_livingroom_player_volume
- input_number.voice_pe_tv_volume
- input_number.voice_pe_workshop_volume
- input_number.40pfs6009_12_volume_before
- input_number.alexa_volume_before
- input_number.home_assistant_voice_living_room_media_player_esp_vol_before_announce
- (and any others in the "Volume before ducking" section of helpers_input_number.yaml)

## 4. Architecture Diagram

```
┌─────────────────────────┐   ┌─────────────────────────┐
│  notification_follow_me │   │    email_follow_me       │
│  (parallel mode)        │   │    (parallel mode)       │
└──────────┬──────────────┘   └──────────┬──────────────┘
           │ script.turn_on               │ script.turn_on
           │ mode: duck/restore           │ mode: duck/restore
           ▼                              ▼
┌──────────────────────────────────────────────────────────┐
│              volume_duck_manager (queued, max 10)        │
│                                                          │
│  ┌─────────┐  ┌──────────────┐  ┌───────────────────┐   │
│  │refcount │  │ JSON snapshot│  │  ducking_flag      │   │
│  │(in_num) │  │ (input_text) │  │  (input_boolean)   │   │
│  └─────────┘  └──────────────┘  └───────────────────┘   │
│                                                          │
│  duck:    refcount++ → snapshot (if first) → volume_set  │
│  restore: refcount-- → restore (if last) → clear state   │
└──────────────────────────────────────────────────────────┘
           ▲                              ▲
           │ script.turn_on               │ script.turn_on
           │ mode: duck/restore           │ mode: duck/restore
┌──────────┴──────────────┐   ┌──────────┴──────────────┐
│ voice_pe_duck (wrapper) │   │ voice_pe_restore (wrap.) │
│ trigger: sat→listening  │   │ trigger: sat→idle        │
└─────────────────────────┘   └─────────────────────────┘

                    ┌──────────────────────┐
                    │ duck_refcount_watchdog│ (separate safety net)
                    │ monitors same helpers │
                    └──────────────────────┘

External gate consumers (read-only):
  • alexa_ma_volume_sync      → checks ducking_flag
  • music_assistant_follow_me → checks ducking_flag
```

## 5. Scenario Walkthroughs

### 5.1 Rapid WhatsApp Burst (3 messages in 2 seconds)

```
t=0.0s  Msg1 arrives → notification_follow_me run1 → calls duck
        Manager: refcount 0→1, snapshot volumes, flag ON, duck players
t=0.5s  Msg2 arrives → run2 → calls duck
        Manager: refcount 1→2, skip snapshot (already exists), duck players (no-op, already ducked)
t=1.0s  Msg3 arrives → run3 → calls duck
        Manager: refcount 2→3, skip snapshot, duck players (no-op)
t=4.0s  run1 TTS done → calls restore
        Manager: refcount 3→2, NOT last → do nothing
t=5.5s  run2 TTS done → calls restore
        Manager: refcount 2→1, NOT last → do nothing
t=7.0s  run3 TTS done → calls restore
        Manager: refcount 1→0, LAST → restore all from snapshot, clear flag
✅ Volumes restored correctly.
```

### 5.2 Voice PE + Notification Collision

```
t=0.0s  "Hey Rick" wake word → voice_pe_duck wrapper → calls duck
        Manager: refcount 0→1, snapshot, flag ON, duck players
t=0.5s  WhatsApp arrives → notification_follow_me → calls duck
        Manager: refcount 1→2, skip snapshot (correct — original volumes preserved)
t=3.0s  Rick finishes talking → voice_pe_restore wrapper → calls restore
        Manager: refcount 2→1, NOT last → do nothing (notification still active)
t=6.0s  Notification TTS done → calls restore
        Manager: refcount 1→0, LAST → restore from snapshot (original pre-duck volumes)
✅ No "restore to ducked level" bug.
```

### 5.3 Mid-Flight Death (run killed by automation reload)

```
t=0.0s  Notification → calls duck. Manager: refcount 0→1, snapshot, duck.
t=1.0s  User reloads automations. Notification run killed.
        restore never called. Refcount stuck at 1.
t=1.0s  Watchdog's automation_reloaded trigger fires.
        Sees refcount > 0 → force-restores from snapshot, clears everything.
✅ Watchdog catches it within seconds, not 3 minutes.
```

## 6. Open Items / Future Considerations

- [ ] Decide whether announcement player boost belongs in the central
      manager or stays in the Voice PE thin wrappers (argument for wrappers:
      only Voice PE needs TTS boost, notifications use satellite announce)
- [ ] Consider whether the snapshot should include ALL configured players
      or only those currently playing. Current design: only playing.
      Pro: smaller snapshot. Con: if a player starts playing DURING a duck
      cycle, it plays at full volume (not ducked). Probably fine.
- [ ] Test with `mode: queued, max: 10` under real WhatsApp burst load
      to confirm queue doesn't overflow
- [ ] After migration is stable, schedule cleanup pass to remove the
      per-player input_number helpers listed in §3.4
- [ ] Evaluate whether notification_follow_me's satellite volume snapshot
      (input_text for the TTS player's own volume) should also be folded
      into the central manager or remain per-blueprint
- [ ] The goodnight_routine_music_assistant script uses satellite announce
      mode which triggers the Voice PE duck/restore wrappers indirectly —
      verify this still works cleanly through the central manager

## 7. Build Priority

This should be built BEFORE any new blueprints that need duck/restore
(e.g., proactive_bedtime_escalation). Building new blueprints with inline
duck logic and then refactoring them later is double work.

Suggested build order:
1. Build volume_duck_manager.yaml script blueprint
2. Refactor voice_pe_duck + voice_pe_restore into thin wrappers
3. Delete homeassistantguide.info 3rd-party blueprint
4. Refactor notification_follow_me (largest change)
5. Refactor email_follow_me
6. Refactor notification_replay
7. Verify watchdog still works with central state
8. Integration test: WhatsApp burst + Voice PE collision
