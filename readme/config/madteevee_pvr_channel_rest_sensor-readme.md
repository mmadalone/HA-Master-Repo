# MadTeeVee PVR Channel — RESTful Sensor

## Overview

A `rest:` platform sensor that polls Kodi's HTTP JSON-RPC endpoint directly for
live PVR channel detection. Bypasses the Kodi HA integration's websocket event
pipeline, which proved unreliable for `kodi_call_method_result` events.

**Entity:** `sensor.madteevee_pvr_channel`
**Unique ID:** `madteevee_pvr_channel_rest`
**Defined in:** `configuration.yaml` (`rest:` block)
**Credentials:** `secrets.yaml` (`kodi_madteevee_*`)
**Commit:** `34d5e83b` (2026-02-14)

## How It Works

```
Every 30 seconds
    │
    ▼
┌──────────────────────────────────┐
│  HTTP POST to Kodi JSON-RPC     │
│  http://192.168.2.217:8080/     │
│  jsonrpc                        │
│                                 │
│  Method: Player.GetItem         │
│  Params: playerid 1,            │
│    props [title, channel,       │
│    channeltype, channelnumber]   │
└──────────┬───────────────────────┘
           │
           ▼
┌──────────────────────────────────┐
│  Response parsing                │
│                                  │
│  result.item.type == "channel"?  │
├──────┬──────────┬────────────────┤
│ YES  │ NO item  │ item but       │
│      │          │ not channel    │
▼      ▼          ▼                │
Channel "off"    "not_pvr"         │
name                               │
(stripped                          │
of COLOR                           │
tags)                              │
└──────────────────────────────────┘
           │
           ▼
┌──────────────────────────────────┐
│  sensor.madteevee_pvr_channel    │
│                                  │
│  State: "A Punt" / "off" /      │
│         "not_pvr"                │
│                                  │
│  Attributes:                     │
│    title: "El retrovisor"        │
│    channeltype: "tv"             │
│    channelnumber: 5              │
│    type: "channel"               │
└──────────────────────────────────┘
```

## Why REST Instead of Events

The Kodi HA integration communicates over websocket (port 9090). Calling
`kodi.call_method` for `Player.GetItem` fires the JSON-RPC request successfully,
but the response event (`kodi_call_method_result`) fails to arrive reliably.
This was confirmed through extensive testing on 2026-02-14:

- Direct HTTP calls to port 8080 work 100% of the time
- Websocket event delivery is intermittent — `wait_for_trigger` timeouts
- Rapid event-triggered queries caused a feedback loop that killed the
  Kodi integration entirely (fixed with debounce in PVR tracker v1.1,
  but the underlying event pipeline remained unreliable)

The `rest:` platform uses HTTP directly, avoiding the websocket path entirely.
HA handles polling, parsing, error recovery, and unavailable states natively.

## Configuration

### secrets.yaml

```yaml
kodi_madteevee_jsonrpc_url: "http://192.168.2.217:8080/jsonrpc"
kodi_madteevee_user: "kodi"
kodi_madteevee_pass: "hehehe"
```

### configuration.yaml

```yaml
rest:
  - resource: !secret kodi_madteevee_jsonrpc_url
    method: POST
    authentication: basic
    username: !secret kodi_madteevee_user
    password: !secret kodi_madteevee_pass
    headers:
      Content-Type: "application/json"
    payload: >-
      {"jsonrpc":"2.0","id":1,"method":"Player.GetItem","params":{"playerid":1,
      "properties":["title","channel","channeltype","channelnumber"]}}
    scan_interval: 30
    timeout: 5
    sensor:
      - name: "MadTeeVee PVR Channel"
        unique_id: madteevee_pvr_channel_rest
        icon: mdi:television-guide
        value_template: >-
          {% set item = value_json.get('result', {}).get('item', {}) %}
          {% if item.get('type') == 'channel' %}
            {{ item.get('channel', '')
               | regex_replace('\[COLOR [^\]]*\]', '')
               | regex_replace('\[/COLOR\]', '') | trim }}
          {% elif item %}
            not_pvr
          {% else %}
            off
          {% endif %}
        json_attributes_path: "$.result.item"
        json_attributes:
          - title
          - channeltype
          - channelnumber
          - type
```

## State Values

| State | Meaning |
|-------|---------|
| Channel name (e.g., "A Punt") | PVR/live TV playing — state is the channel name with IPTV `[COLOR]` tags stripped |
| `not_pvr` | Kodi is playing something (movie, TV show, file) but not PVR content |
| `off` | No active player / Kodi idle / empty response |
| `unavailable` | Kodi unreachable (powered off, network down, HTTP timeout) |

## Attributes

| Attribute | Source | Example |
|-----------|--------|---------|
| `title` | Current programme name | `"El retrovisor"` |
| `channeltype` | PVR channel type | `"tv"` or `"radio"` |
| `channelnumber` | Channel number in EPG | `5` |
| `type` | Kodi item type | `"channel"` (always, when PVR) |

Attributes are only populated when a PVR channel is active. When state is
`off` or `not_pvr`, attributes may be stale from the last PVR session or
absent entirely.

## Downstream Consumers

### Template sensor: `sensor.madteevee_now_playing`

Defined in `template.yaml`. Reads from this REST sensor for PVR context:

- **State string:** `"Live TV: <programme> (<channel>)"` when PVR active
- **Attribute `pvr_channel`:** channel name (empty string when not PVR)
- **Attribute `pvr_channel_number`:** channel number
- **Attribute `pvr_programme`:** programme title with COLOR tags stripped

### Bedtime blueprint: `bedtime_routine_plus.yaml`

Planned (build log `2026-02-15_sleepytv_pvr_detection_and_tracker_cleanup.md`):
new `pvr_channel_matches` Sleepy TV detection method will check this sensor
instead of `media_title` for stable channel-based detection.

## IPTV COLOR Tag Handling

IPTV Simple Client injects `[COLOR rrggbb]...[/COLOR]` markup into channel
names and programme titles. The `value_template` strips these tags using
`regex_replace` before storing the state. The downstream template sensor
applies the same stripping to the `title` attribute via `pvr_programme`.

## Replaces

This sensor supersedes the `pvr_channel_tracker.yaml` blueprint (v1.2) and
its companion `input_text.madteevee_pvr_channel` helper. The blueprint is
scheduled for deletion (see cleanup build log). The REST sensor is more
reliable, simpler, and requires no automation instance or helper entity.

## Operational Notes

- **Restart required:** `rest:` sensors require a full HA restart to load.
  They cannot be reloaded via the UI or `homeassistant.reload_config_entry`.
- **Scan interval:** 30 seconds. Responsive enough for display and detection,
  light enough to not burden Kodi. Adjustable in `configuration.yaml`.
- **Timeout:** 5 seconds. If Kodi doesn't respond within 5s, the sensor
  goes `unavailable` until the next successful poll.
- **Error recovery:** The `rest:` platform handles connection failures
  natively — sensor transitions to `unavailable` and recovers automatically
  on the next successful poll. No manual intervention needed.
- **Recorder:** Consider adding to `recorder: exclude:` if the 30-second
  state changes create excessive database writes. Current channel switches
  are infrequent enough that this hasn't been an issue.

## Changelog

| Version | Date | Description |
|---------|------|-------------|
| v1.0 | 2026-02-14 | Initial — REST sensor, template sensor integration, secrets |

## Author

**madalone**
