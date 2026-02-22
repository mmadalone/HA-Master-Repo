# Notification Follow-Me

![Notification Follow-Me header](https://raw.githubusercontent.com/mmadalone/HA-Master-Repo/main/images/header/notification-follow-me-header.jpeg)

When a messaging notification arrives on your phone (WhatsApp, Signal, SMS, or any selected app), this blueprint determines which room you're in via FP2 presence sensors, routes to the nearest voice satellite, and has a conversation agent summarize the message — completely hands-free. Uses the Android Companion App's `last_notification` sensor as the sole data source, since all existing WhatsApp/Signal integrations are outbound-only.

Includes a dual notification filter (VIP contacts for messaging apps, VIP apps for non-messaging), configurable cooldown to tame group chat floods, quiet hours with DND stacking, media message detection, and a mobile push fallback when no satellite is in range.

## How It Works

```
┌─────────────────────────────────────────────────────────┐
│                      TRIGGER                            │
│  ┌───────────────────────────────────────────────────┐  │
│  │ sensor.last_notification state change             │  │
│  │ (Android Companion App — Allow List at phone)     │  │
│  └──────────────────────┬────────────────────────────┘  │
└─────────────────────────┼───────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│                  CONDITION GATES                        │
│  • Master toggle ON?                                    │
│  • DND sensor not active? (if configured)               │
│  • Outside quiet hours? (if enabled)                    │
└────────────────────────┬────────────────────────────────┘
                         │ all pass
                         ▼
┌─────────────────────────────────────────────────────────┐
│                  ACTION SEQUENCE                        │
│  1. Extract notification attributes                     │
│     (sender, text, package, category, post_time)        │
│                                                         │
│  2. Dual filter gate                                    │
│     • category=msg → check sender against VIP Contacts  │
│     • category≠msg → check package against VIP Apps     │
│                                                         │
│  3. Cooldown enforcement                                │
│     (suppress if last announcement < N seconds ago)     │
│                                                         │
│  4. Resolve presence → satellite                        │
│     (parallel-array: sensor[N] → satellite[N])          │
│                                                         │
│  5. Gate: satellite found OR fallback enabled?           │
│                                                         │
│  6. Prepare message for LLM                             │
│     • Truncate to char cap                              │
│     • Detect media messages → "check your phone" nudge  │
│     • Build structured context for agent                │
│                                                         │
│  7. conversation.process → LLM generates summary        │
│                                                         │
│  8. Route announcement                                  │
│     ├─ Satellite found → TTS delivery (standard or      │
│     │                    ElevenLabs with voice profile)  │
│     └─ No satellite → mobile push (if configured)       │
│                                                         │
│  9. Update last-announced timestamp                     │
│ 10. Log to system_log                                   │
└─────────────────────────────────────────────────────────┘
```

## Key Design Decisions

### Data source: last_notification sensor
All existing WhatsApp and Signal integrations (MaNish, Green-API, CallMeBot, Whatsigram) are outbound-only — they can send messages but cannot read incoming ones. The Android Companion App's `last_notification` sensor is the only viable inbound path. It fires instantly on notification post and exposes sender, message text, package name, and category attributes. The phone-level Allow List filters at the OS layer before the sensor even updates.

### Dual filter model
Messaging apps (WhatsApp, Signal, SMS) set `category: msg` and are filtered by sender name against a VIP Contacts list. Non-messaging apps (banking alerts, etc.) are identified by package name against a VIP Apps list and bypass contact filtering entirely. This separation prevents banking alerts from needing a "sender name" while keeping messaging noise under control.

### Parallel-array presence routing
Reuses the proven pattern from the Music Assistant Follow-Me blueprints: the user provides two parallel lists — presence sensors and target satellites — where index N in one maps to index N in the other. When presence is detected, the first active sensor's index resolves to the corresponding satellite. This avoids complex per-zone configuration while remaining fully flexible.

### Media message detection
WhatsApp and Signal send placeholder text for non-text messages (voice notes, photos, videos, stickers). The blueprint pattern-matches these against known strings and replaces the LLM prompt with a "check your phone" nudge instead of trying to summarize binary content descriptions.

## Features

- **Hands-free notification announcements** — incoming messages are summarized and spoken via the nearest satellite without touching your phone.
- **Dual notification filter** — VIP contacts for messaging apps, VIP apps for non-messaging packages. Both use comma-separated input_text helpers for easy editing.
- **Configurable cooldown** — prevents rapid-fire announcements from group chats or notification storms. Default 60 seconds.
- **Belt-and-suspenders quiet hours** — DND sensor gate AND optional time-window inputs, checked independently. Either one suppresses announcements.
- **LLM-powered summarization** — conversation agent paraphrases the message naturally instead of reading it verbatim. Personality driven by agent's system prompt.
- **Media message detection** — voice messages, photos, videos, stickers, and documents trigger a "check your phone" fallback instead of nonsensical LLM summaries.
- **Mobile push fallback** — when no presence is detected in a satellite-equipped zone, optionally sends a push notification instead of dropping silently.
- **Dual TTS mode** — standard `tts.speak` or ElevenLabs custom integration with voice profile selection.
- **Message character cap** — truncates long messages before LLM processing to control token usage. Default 500 characters.

## Prerequisites

- **Home Assistant 2024.10.0+**
- **Android Companion App** with Notification Listener permission and Allow List configured
- **Presence sensors** — binary sensors for room presence (e.g., Aqara FP2 zone groups)
- **Voice satellites** — ESPHome Voice PE or any media_player entity capable of TTS
- **Conversation agent** — Extended OpenAI Conversation, OpenAI Conversation, or any agent supporting `conversation.process`
- **TTS integration** — any `tts.*` entity, or the HACS ElevenLabs custom integration for voice profile support
- **input_text helpers** — two: one for VIP contact names, one for VIP app package names
- **input_boolean helper** — master on/off toggle
- **input_datetime helper** — cooldown timestamp tracker (date + time enabled)

## Installation

1. Copy `notification_follow_me.yaml` to `config/blueprints/automation/madalone/`.
2. Reload blueprints: **Settings → Automations & Scenes → Blueprints → ⟳**.
3. Create a new automation from the **"Notification Follow-Me (v1)"** blueprint.
4. Or import directly via: `https://github.com/mmadalone/HA-Master-Repo/blob/main/automation/notification_follow_me.yaml`

## Configuration

### ① Core setup
| Input | Default | Description |
|-------|---------|-------------|
| Notification sensor | _(empty)_ | Android Companion App `last_notification` sensor |
| Master enable toggle | _(empty)_ | input_boolean to enable/disable all announcements |
| Conversation agent | _(empty)_ | LLM agent for natural-language summarization |
| LLM summarization prompt | _(built-in)_ | Instructions for how the agent should summarize; data injection is automatic |

### ② Presence routing
| Input | Default | Description |
|-------|---------|-------------|
| Presence sensors | _(empty)_ | Binary sensors indicating presence, in priority order |
| Target satellites | _(empty)_ | Media player entities paired 1:1 with presence sensors |
| No-presence fallback | `silent` | What to do when no zone is active: `mobile_push` or `silent` |
| Mobile notify service | _(empty)_ | Service name for push notifications (only used with mobile_push fallback) |

### ③ Notification filtering
| Input | Default | Description |
|-------|---------|-------------|
| VIP contacts helper | _(empty)_ | input_text with comma-separated sender names for messaging apps |
| VIP apps helper | _(empty)_ | input_text with comma-separated package names for non-messaging apps |
| Cooldown | `60` sec | Minimum seconds between announcements |
| Last announced helper | _(empty)_ | input_datetime for cooldown tracking |
| Message character cap | `500` | Max characters sent to LLM (truncated with "...") |

### ④ Quiet hours & DND
| Input | Default | Description |
|-------|---------|-------------|
| DND sensor | _(empty)_ | Phone DND sensor — suppresses when active |
| Enable quiet hours | `false` | Enable time-based suppression window |
| Quiet hours start | `23:00` | When quiet hours begin |
| Quiet hours end | `07:00` | When quiet hours end |

### ⑤ TTS configuration
| Input | Default | Description |
|-------|---------|-------------|
| TTS mode | `standard_tts_entity` | Standard TTS or ElevenLabs custom service |
| TTS entity | _(none)_ | TTS entity for `tts.speak` calls |
| ElevenLabs voice profile | _(empty)_ | Voice profile name for ElevenLabs custom mode |

## Supported Notification Sources

| App | Package | Attributes available |
|-----|---------|---------------------|
| Signal | `org.thoughtcrime.securesms` | sender, text, category, group flag, rich message array |
| WhatsApp | `com.whatsapp` | sender, text, category (no group flag, no rich array) |
| SMS | _(device default)_ | TBD — add to phone Allow List |
| Banking / other | _(per app)_ | Routed via VIP Apps filter, bypasses contact check |

## Technical Notes

- **Automation mode:** `single` / `max_exceeded: silent` — prevents overlapping runs from rapid notification bursts.
- **Template safety:** All `states()` and `state_attr()` calls use `| default()` guards for unavailable/unknown entities.
- **Defensive error handling:** `continue_on_error: true` on the `conversation.process` call and TTS delivery — if the LLM or satellite fails, the automation logs a warning and completes gracefully.
- **TTS fallback:** The `choose` block includes a `default:` branch that logs a `system_log.write` warning and falls back to standard TTS if an unknown `tts_mode` is configured.
- **Cooldown via input_datetime:** Uses an `input_datetime` helper instead of a timer entity, allowing cooldown state to survive HA restarts and be inspected in the UI.
- **Cross-app compatibility:** Designed around the common attribute subset (`android.title`, `android.text`, `package`, `category`) shared by both Signal and WhatsApp. Signal-only attributes (rich message array, group flag) are treated as optional bonuses.

## Helpers Required

| Helper | Type | Entity ID |
|--------|------|-----------|
| Notification follow-me enabled | `input_boolean` | `input_boolean.notification_follow_me` |
| VIP contacts | `input_text` | `input_text.notification_vip_contacts` |
| VIP apps | `input_text` | `input_text.notification_vip_apps` |
| Last announced timestamp | `input_datetime` | `input_datetime.notification_last_announced` |

## Changelog

- **v1:** Initial release — dual filter model, parallel-array presence routing, LLM summarization, cooldown, quiet hours, media message detection, mobile push fallback, dual TTS mode.

## Author

**madalone**

## License

MIT
