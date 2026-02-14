# Build Log — Sleepy TV PVR Detection + PVR Tracker Cleanup

- **Date:** 2026-02-14 (scoped, not started)
- **Mode:** BUILD
- **Status:** pending
- **Depends on:** RESTful PVR sensor (commit `34d5e83b`, sensor `sensor.madteevee_pvr_channel`)
- **Blueprint:** `bedtime_routine_plus.yaml` (2020 lines, current version v5.1.2)
- **Cleanup target:** `pvr_channel_tracker.yaml` (deprecated by REST sensor)

---

## Context

On 2026-02-14 we replaced the event-based PVR channel detection blueprint
(`pvr_channel_tracker.yaml`) with a RESTful sensor that polls Kodi's HTTP
JSON-RPC endpoint every 30 seconds. The REST sensor (`sensor.madteevee_pvr_channel`)
is confirmed working — state is channel name, attributes carry title, channeltype,
channelnumber. See build log `2026-02-14_pvr_restful_sensor.md` and commits:

- `6136f943` — checkpoint before REST sensor build
- `34d5e83b` — REST sensor added to configuration.yaml, template.yaml updated

The old blueprint used Kodi integration's websocket event pipeline which was
unreliable — `kodi_call_method_result` events didn't fire consistently, causing
timeouts. A feedback loop bug (fixed in v1.1 with debounce) also hammered the
websocket until the integration died. The REST sensor bypasses all of this.

---

## Part 1 — Bedtime Blueprint: Add PVR Channel Detection Method

### What

Add a fourth Sleepy TV detection method to `bedtime_routine_plus.yaml`:
`pvr_channel_matches`. When selected, checks `sensor.madteevee_pvr_channel`
(or a user-specified PVR sensor entity) against the match string, instead of
checking Kodi's `media_title` or `media_content_id`.

### Why

Current detection methods match against `media_title` (programme name) or
`media_content_id`. For PVR content, programme names rotate every 30–60 minutes,
so title-based detection breaks when the show changes. Channel names are stable —
"A Punt" stays "A Punt" all night. The REST sensor provides reliable channel state.

The active automation instance ("Bedtime NOW - Kodi - Rick", id `1770944526838`)
currently uses `media_content_id_matches` with match string `SleepyTV` — this
works because PseudoTV Live's content ID contains the channel name. But direct
PVR channel matching is cleaner and works for native PVR channels too.

### Changes

**File: `blueprints/automation/madalone/bedtime_routine_plus.yaml`**

#### 1. New input: `sleepytv_pvr_sensor` (in section ⑤, after `sleepytv_match_string`)

```yaml
        sleepytv_pvr_sensor:
          name: PVR channel sensor
          description: >
            REST sensor entity that reports the current PVR channel name.
            Only used when detection method is "PVR channel matches".
            Default: sensor.madteevee_pvr_channel
          default: sensor.madteevee_pvr_channel
          selector:
            entity:
              domain: sensor
```

Current ⑤ section ends at line ~453. Insert after `sleepytv_match_string` block.

#### 2. New option in `sleepytv_detection_method` selector (line ~435)

Add to the `options:` list:

```yaml
                - label: "PVR channel matches (REST sensor)"
                  value: pvr_channel_matches
```

#### 3. New variable: `sleepytv_pvr_sensor` (in variables block, ~line 825)

```yaml
  sleepytv_pvr_entity: !input sleepytv_pvr_sensor
```

#### 4. Update `is_sleepytv_active` template (~lines 871–889)

Add a new branch before the `{% else %}` fallback:

```jinja
      {% elif sleepytv_detection == 'pvr_channel_matches' %}
        {% set pvr_ch = states(sleepytv_pvr_entity) | default('') %}
        {{ pvr_ch not in ['off', 'not_pvr', 'unknown', 'unavailable', '']
           and match | lower in pvr_ch | lower }}
```

Full updated template:

```yaml
  is_sleepytv_active: >-
    {% set match = sleepytv_match | default('') | string %}
    {% if match | length == 0 %}
      false
    {% else %}
      {% set kodi_state = states(kodi_entity) | default('unknown') %}
      {% set kodi_title = state_attr(kodi_entity, 'media_title') | default('') %}
      {% set kodi_content_id = state_attr(kodi_entity, 'media_content_id') | default('') %}
      {% if sleepytv_detection == 'media_title_contains' %}
        {{ match in kodi_title }}
      {% elif sleepytv_detection == 'media_content_id_matches' %}
        {{ kodi_content_id == kodi_preset_content_id }}
      {% elif sleepytv_detection == 'state_playing_and_title' %}
        {{ kodi_state == 'playing' and match in kodi_title }}
      {% elif sleepytv_detection == 'pvr_channel_matches' %}
        {% set pvr_ch = states(sleepytv_pvr_entity) | default('') %}
        {{ pvr_ch not in ['off', 'not_pvr', 'unknown', 'unavailable', '']
           and match | lower in pvr_ch | lower }}
      {% else %}
        false
      {% endif %}
    {% endif %}
```

#### 5. `kodi_preferred_genres` — ensure default is empty string

Check input definition (~line 517). If `default:` is missing or non-empty,
set to `default: ""`. The `.split(',')` call at line 1567 handles empty
strings gracefully already (`'' | split(',') | reject('eq', '') | list` = `[]`).
This makes genres optional when PVR channel detection is used and the content
selection phase is skipped entirely.

#### 6. Version bump

Update description changelog to v5.2.0:

```
- **v5.2.0:** Sleepy TV — added PVR channel detection method using REST sensor.
  New input: PVR channel sensor entity. Genres now optional when PVR detection active.
```

### Affected automation instance

"Bedtime NOW - Kodi - Rick" (id `1770944526838`):
- Currently: `sleepytv_detection_method: media_content_id_matches`
- Optionally update to: `pvr_channel_matches` with match `SleepyTV`
- Current method still works — no forced migration needed

---

## Part 2 — Delete PVR Channel Tracker Blueprint + Cleanup

### What

Remove the deprecated `pvr_channel_tracker.yaml` blueprint, its orphaned
automation entity, and the `input_text.madteevee_pvr_channel` helper.

### Why

The REST sensor (`sensor.madteevee_pvr_channel`, commit `34d5e83b`) fully
replaces this blueprint. The blueprint's event-based approach via
`kodi.call_method` → `kodi_call_method_result` was unreliable — websocket
events failed silently, and the feedback loop bug (v1.1 fix) proved the
architecture was fragile. The REST sensor polls HTTP JSON-RPC directly,
bypassing the entire event pipeline.

### Cleanup checklist

#### 1. Delete blueprint file

```
rm /config/blueprints/automation/madalone/pvr_channel_tracker.yaml
```

#### 2. Remove orphaned automation entity

Entity `automation.pvr_channel_tracker_madteevee` exists in entity registry
with `orphaned_timestamp: 1771109215` (already orphaned — automation instance
was removed from automations.yaml). Use HA MCP:

```
ha_remove_entity_registry_entry: automation.pvr_channel_tracker_madteevee
```

#### 3. Remove input_text helper

**File: `helpers_input_text.yaml`** — delete lines 335–342:

```yaml
# MadTeeVee — PVR channel tracking
########################################

madteevee_pvr_channel:
  name: MadTeeVee PVR channel
  icon: mdi:television-guide
  max: 255
  mode: text
```

File is 342 lines total — these are the last 8 lines.

#### 4. Verify no remaining references

As of 2026-02-14, grep confirms:
- `template.yaml` — already updated to use `sensor.madteevee_pvr_channel` (commit `34d5e83b`)
- `automations.yaml` — no references to `pvr_channel_tracker` or `input_text.madteevee_pvr_channel`
- `configuration.yaml` — no references
- No other files reference the helper or blueprint

**Re-run this grep before deleting to confirm nothing has changed:**

```bash
grep -rn "input_text.madteevee_pvr_channel\|pvr_channel_tracker" /config/ \
  --include="*.yaml" | grep -v ".git/"
```

Expected: zero results.

#### 5. Archive in git repo (optional)

The blueprint is already committed at `6136f943` (v1.2). Git history preserves
it. No need to archive separately unless desired.

---

## Execution order

1. **Bedtime blueprint patch first** (Part 1) — edit, validate, commit
2. **PVR tracker cleanup second** (Part 2) — delete, remove entity, commit
3. Reload automations (Part 1 doesn't need restart; Part 2 needs input_text reload)
4. Test: confirm `sensor.madteevee_pvr_channel` still reports correctly
5. Test: trigger bedtime routine manually, verify sleepy TV detection with new method

---

## Files touched (summary)

| File | Action |
|---|---|
| `blueprints/automation/madalone/bedtime_routine_plus.yaml` | Edit — new input, new detection method, version bump |
| `blueprints/automation/madalone/pvr_channel_tracker.yaml` | **Delete** |
| `helpers_input_text.yaml` | Edit — remove `madteevee_pvr_channel` (lines 335–342) |
| Entity registry | Remove orphaned `automation.pvr_channel_tracker_madteevee` |
