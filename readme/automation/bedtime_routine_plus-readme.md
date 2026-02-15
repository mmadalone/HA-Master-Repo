# Bedtime Routine Plus – LLM-Driven Goodnight (Kodi)

![Bedtime Routine Plus header](https://raw.githubusercontent.com/mmadalone/HA-Master-Repo/main/images/header/bedtime_routine_plus-header.jpeg)

Fully LLM-orchestrated bedtime wind-down with Kodi media playback. The TV stays ON — Kodi plays movies, TV shows, or favourites selected via LLM conversation or preset configuration. Library pre-fetch injects the full Kodi catalog into the LLM context for intelligent content selection.

Four media modes: **curated** (pre-configured list), **freeform** (LLM picks from your library), **both** (curated + freeform fallback), and **preset** (fixed content, no conversation). All modes share the same bedtime flow: lights off (except living room lamp), countdown timer, bathroom occupancy guard, then final lamp-off. Optional TV sleep timer powers off the TV after a configurable delay.

> **Companion blueprint:** For audiobook/Music Assistant playback instead of Kodi, see `bedtime_routine.yaml`.

## How It Works

```
Trigger: scheduled time / manual input_boolean
                │
                ▼
┌─────────────────────────────────┐
│ Day-of-week gate (run_days)      │──── Wrong day → abort (manual bypasses)
│ Auto-reset manual trigger        │
│ Presence gate (ANY/ALL sensors)  │──── Nobody home → abort + cleanup
│ Initialize countdown helper      │
│ Activate temporary switches      │
│ Power-cycle speaker reset        │
└──────────────┬──────────────────┘
               │
               ▼
┌─────────────────────────────────┐
│ LLM bedtime announcement         │
│ (conversation.process)            │
│ "Lights out in X minutes"        │
└──────────────┬──────────────────┘
               │
      ┌────────┴────────┐
      │                  │
  Negotiation         One-shot TTS
  enabled?            (preset or
      │               negotiation off)
      ▼
  assist_satellite
  .start_conversation
  (agent can adjust
   countdown helper)
      │
      └────────┬────────┘
               │
               ▼
    Lights OFF (except lamp)
    Pause other media players
    Lower Kodi volume
               │
      ┌────────┴────────┐
      │                  │
   PRESET              CONVERSATIONAL
   MODE                (curated/freeform/both)
      │                  │
      ▼                  ▼
  Sleepy TV        Re-read countdown
  check            Sleepy TV check
      │                  │
  [already         JSON-RPC library
   playing?]       pre-fetch engine
      │            (4 parallel calls)
   NO → play            │
   preset          Build catalog string
   content         (genre-filtered)
      │                  │
      ▼                  ▼
  Settling-in      assist_satellite
  TTS (optional)   .start_conversation
      │            (media selection)
      ▼                  │
  Fixed countdown  Settling-in TTS
      │            (optional)
      ▼                  │
  Bathroom         Goodnight TTS
  guard            (conversation.process)
      │                  │
      ▼                  ▼
  Final goodnight  Negotiated countdown
  TTS (optional)         │
      │                  ▼
      └────────┐    Bathroom guard
               │         │
               │    Final goodnight
               │    TTS (optional)
               │         │
               └────┬────┘
                    │
                    ▼
          Lamp OFF → Cleanup
          Reset countdown helper
                    │
                    ▼
          ┌─────────────────┐
          │ TV Sleep Timer    │
          │ (optional)        │
          │ Wait X min → OFF  │
          │ (CEC or script)   │
          └─────────────────┘
```

## Key Design Decisions

### Four Media Modes

The blueprint supports four distinct content selection strategies, all sharing the same bedtime infrastructure (lights, countdown, bathroom guard, cleanup):

**Curated** — Presents a pre-configured list of Name=ContentID pairs to the user via multi-turn satellite conversation. The LLM offers only these options. Ideal for "pick from my favourites" flows.

**Freeform** — Pre-fetches the entire Kodi library via four JSON-RPC calls (in-progress shows, movies, recent episodes, favourites), filters by genre preferences/exclusions, and injects a structured catalog into the LLM context. The agent can suggest anything from your library matching the bedtime mood.

**Both** — Curated options offered first, with freeform as fallback. Gives the user their quick picks while still allowing "actually, play something else" flexibility.

**Preset** — Direct playback of a fixed content ID. No conversation, no media selection — maximum efficiency. The routine announces bedtime, plays the content, and proceeds to countdown.

### JSON-RPC Library Pre-Fetch Engine

In freeform/both modes, the blueprint makes four sequential `kodi.call_method` calls, each with `wait_for_trigger` on `kodi_call_method_result` events:

1. `VideoLibrary.GetInProgressTVShows` — Currently watching shows, sorted by last played (always offered first, bypasses genre filtering)
2. `VideoLibrary.GetMovies` — Full movie library with genre, year, runtime, playcount, file path
3. `VideoLibrary.GetRecentlyAddedEpisodes` — Latest additions with show title, season/episode, aired date
4. `Favourites.GetFavourites` — Kodi favourites with path and type filtering (media only)

Results are assembled into a structured catalog string with genre filtering applied: excluded genres remove movies entirely, while in-progress TV shows bypass the filter (you shouldn't stop watching a show because it has a thriller episode). The LLM receives preferred genres, excluded genres, and a bedtime mood descriptor to guide selection.

### Sleepy TV Detection

Before switching content, the blueprint checks if bedtime content is already playing on Kodi. Three detection methods: title contains match string, content ID matches preset, or playing state AND title match. If bedtime content is detected, the blueprint skips content switching — just lowers volume and proceeds. Prevents the annoying case where you've already started your rain sounds playlist and the automation tries to restart it.

### Day-of-Week Gate

The `run_days` input lets you restrict which days of the week the scheduled trigger fires. All seven days are selected by default, so existing instances are unaffected. Manual triggers bypass the gate entirely — if you explicitly toggled the boolean or yelled at Alexa, the routine runs regardless of what day it is. The condition uses a simple `today_key` derived from `now().weekday()` rather than the cross-midnight `effective_day_key` from `proactive_llm_sensors.yaml`, because bedtime fires at a single point in time rather than across a time window.

### Presence Sensor Gate

Optional gate that checks occupancy/presence/motion sensors before running the routine. Supports ANY (default) or ALL mode with configurable minimum duration. Manual triggers bypass the gate entirely — if you explicitly triggered bedtime, you're clearly home. Scheduled triggers check the gate. Failed gate aborts with cleanup.

### Kodi Content Type Auto-Detection

The `kodi_safe_content_type` variable auto-detects when a CHANNEL content type is misconfigured for a URI/path. If the user sets content type to CHANNEL but the content ID contains `://` or `/`, it falls back to `video` to prevent Kodi crashes.

### Bathroom Occupancy Guard

After the countdown expires, the blueprint checks the bathroom occupancy sensor. If occupied, it waits for the sensor to clear (with a max timeout to prevent infinite waits). After clearing, a grace period keeps the lamp on while the user walks from bathroom to bedroom. If the bathroom guard times out, the lamp turns off regardless — can't wait forever.

### Dual TTS Output Design

TTS announcements play on a separate media player from Kodi video. The `kodi_tts_player` input targets a bedroom speaker while Kodi content plays on the TV. This keeps spoken announcements from interrupting video playback.

### Response Type Guard

v5.1.1 added `response_type` checking on all LLM response extraction. If the conversation agent returns an error response, the blueprint falls back to static text instead of speaking the error message as TTS. The guard checks `response_type | default('') != 'error'` before accessing `speech.plain.speech`.

## Features

- **Four media modes** — Curated list, freeform library search, both combined, or preset direct play
- **JSON-RPC library pre-fetch** — Four API calls fetch your full Kodi catalog for LLM context injection
- **Genre filtering** — Excluded genres remove movies before the LLM sees them; preferred genres guide selection; in-progress shows bypass filtering
- **Sleepy TV detection** — Three methods to detect if bedtime content is already playing
- **LLM-driven content selection** — Multi-turn satellite conversation with full library catalog context
- **Countdown negotiation** — LLM can negotiate extra time via exposed `input_number` helper (conversational modes)
- **Presence sensor gate** — ANY/ALL mode with minimum duration, manual trigger bypass
- **Bathroom occupancy guard** — Wait for bathroom to clear with grace period and max timeout
- **Settling-in contextual TTS** — Optional post-content announcement with sensor context (temperature, weather, etc.)
- **Final goodnight contextual TTS** — Optional pre-lamp-off announcement with sensor context
- **TV sleep timer** — Delayed power-off via CEC or custom script after routine completes
- **Speaker power-cycle reset** — Smart plug reset clears stale audio connections
- **ElevenLabs voice profile** — Optional `voice_profile` in TTS options (DRY pattern across all speak calls)
- **Day-of-week gate** — Restrict scheduled triggers to selected days; manual triggers always bypass
- **Dual trigger** — Scheduled time and/or manual `input_boolean` (auto-resets on use)
- **Content type auto-detection** — Prevents CHANNEL crash on URI/path content IDs
- **Response type guard** — Prevents LLM error messages from being spoken as TTS
- **Logbook entries** — Key decisions logged (sleepy TV detection, presence gate failure, bathroom timeout)

## Prerequisites

- **Home Assistant 2024.10.0+**
- A **Kodi media_player** entity with JSON-RPC access
- A **conversation agent** (OpenAI, Ollama, Google AI, etc.) — ideally a dedicated bedtime agent with personality/permission rules
- One or more **Assist satellite** entities (Voice PE or compatible)
- A **TTS engine** entity (ElevenLabs, Piper, etc.)
- A **TTS output media_player** (separate from the TV — bedroom speaker)
- A **bathroom occupancy sensor** (`binary_sensor` with `device_class: occupancy`)
- An **`input_number` helper** for countdown minutes (min 1, max 30, step 1)
- Optional: **presence sensors**, **speaker reset switches**, **temporary switches**, **TV entity** for sleep timer

## Installation

1. Copy `bedtime_routine_plus.yaml` into your blueprints directory:
   ```
   config/blueprints/automation/<your_namespace>/bedtime_routine_plus.yaml
   ```
   Or import via URL if hosted on GitHub.

2. Create a new automation from the blueprint: **Settings → Automations → Create Automation → Use Blueprint**

3. At minimum, configure: Kodi entity, conversation agent, Assist satellites, TTS engine, TTS output player, bathroom sensor, countdown helper, and lights-off target.

## Configuration

### ① Trigger

| Input | Default | Description |
|-------|---------|-------------|
| **Scheduled bedtime** | (empty) | Time trigger — leave empty to disable |
| **Manual trigger boolean** | (empty) | `input_boolean` for voice/UI triggering — auto-resets on use |
| **Presence sensors** | (empty) | Occupancy/presence/motion sensors for gate — empty disables gate |
| **Minimum presence duration** | 0 min | Consecutive minutes sensor must report occupied |
| **Require ALL sensors** | false | ALL vs ANY mode for presence gate |
| **Run on these days** | All 7 days | Day-of-week gate for scheduled trigger — manual bypasses |

### ② Devices

| Input | Default | Description |
|-------|---------|-------------|
| **TV media player** | (empty) | CEC-capable TV entity for sleep timer |
| **TV off script** | (empty) | Custom power-off script (IR sequences, etc.) |
| **Lights to turn off** | (required) | Lights/switches killed immediately — supports area/label targeting |
| **Living room lamp** | (required) | Last light — stays on during countdown, off after bathroom guard |
| **Speaker reset switches** | (empty) | Smart plugs to power-cycle before TTS |
| **Speaker reset delay** | 2 sec | Pause between OFF and ON during power-cycle |
| **Media players to stop** | (empty) | Non-Kodi players to pause/stop (Kodi auto-excluded) |

### ③ AI Conversation

| Input | Default | Description |
|-------|---------|-------------|
| **Conversation agent** | conversation.quark_extended_bedtime | Dedicated bedtime agent |
| **Assist satellites** | (required) | Voice PE / satellite entities |
| **TTS engine** | (required) | Text-to-speech entity |
| **Voice profile** | (empty) | ElevenLabs voice name — empty for default |
| **Default countdown** | 4 min | Minutes before lamp-off (negotiable in conversational modes) |
| **Enable countdown negotiation** | true | Allow LLM to adjust countdown via helper |
| **Enable bedtime media offer** | true | Let LLM offer content (conversational modes) |
| **Bedtime prompt** | (default) | Prompt with `{{ countdown_minutes }}` variable |
| **Goodnight prompt** | (default) | Final goodnight prompt (conversational modes) |

### ④ Kodi Playback

| Input | Default | Description |
|-------|---------|-------------|
| **Kodi media player** | (required) | Kodi entity — stays playing, TV not turned off |
| **Kodi volume target** | 0.15 | Bedtime volume level |
| **Bedtime media mode** | curated | curated / freeform / both / preset |
| **Curated content list** | (empty) | Name=ContentID pairs, one per line |
| **Preset content ID** | (empty) | Direct URI/path for preset mode |
| **Kodi media content type** | DIRECTORY | DIRECTORY / video / CHANNEL / music |
| **TTS audio player** | (required) | Separate speaker for TTS (not the TV) |
| **Post-play delay** | 3 sec | Wait after play_media for Kodi attribute refresh |

### ⑤ Sleepy TV Detection

| Input | Default | Description |
|-------|---------|-------------|
| **Detection method** | media_title_contains | Title match / Content ID match / Playing + title |
| **Match string** | (empty) | String to match — empty disables detection |

### ⑥ Kodi Library & Genre Preferences

| Input | Default | Description |
|-------|---------|-------------|
| **Enable library pre-fetch** | true | Fetch via JSON-RPC — disable for curated/preset to save ~8s |
| **Fetch timeout** | 10 sec | Per-call timeout |
| **Max movies** | 50 | Movie library limit |
| **Max in-progress shows** | 20 | Currently-watching limit |
| **Max recent episodes** | 20 | Recently added limit |
| **Preferred genres** | (empty) | Comma-separated — LLM prioritizes these |
| **Excluded genres** | (empty) | Comma-separated — filtered OUT before LLM sees them |
| **Bedtime mood** | "Relaxing, calming..." | Freeform mood descriptor for LLM guidance |

### ⑦ Settling-In TTS

| Input | Default | Description |
|-------|---------|-------------|
| **Enable settling-in TTS** | false | Contextual announcement after content starts |
| **Settling-in prompt** | (default) | Prompt — sensor states auto-injected |
| **Context sensors** | (empty) | Entities injected as `entity_id: state` pairs |

### ⑧ Final Goodnight TTS

| Input | Default | Description |
|-------|---------|-------------|
| **Enable final goodnight TTS** | false | Contextual goodnight after bathroom clears |
| **Final goodnight prompt** | (default) | Prompt — sensor states auto-injected |
| **Goodnight sensors** | (empty) | Can differ from settling-in sensors (e.g., tomorrow's weather) |

### ⑨ Bathroom Guard & Timing

| Input | Default | Description |
|-------|---------|-------------|
| **Bathroom sensor** | (required) | Occupancy sensor — lamp stays on while occupied |
| **Grace period** | 2 min | Post-clear delay before lamp-off |
| **Max timeout** | 10 min | Maximum wait — lamp off regardless after this |
| **Countdown helper** | (required) | `input_number` entity for negotiated countdown |
| **Temporary switches** | (empty) | Activated during flow, cleaned up on exit |
| **Post-TTS delay** | 5 sec | Buffer after TTS speak for streaming audio finish |

### ⑩ TV Sleep Timer

| Input | Default | Description |
|-------|---------|-------------|
| **Enable TV sleep timer** | false | Delayed TV power-off after routine completes |
| **Sleep timer duration** | 60 min | Wait before power-off |
| **Power-off method** | cec | CEC (media_player.turn_off) or Script (custom) |

## Mode Comparison

| Feature | Curated | Freeform | Both | Preset |
|---------|---------|----------|------|--------|
| Library pre-fetch | No | Yes | Yes | No |
| Multi-turn conversation | Yes | Yes | Yes | No |
| Curated list offered | Yes | No | Yes (first) | No |
| Full library available | No | Yes | Yes (fallback) | No |
| Countdown negotiation | Configurable | Configurable | Configurable | Always off |
| Media offer toggle | Configurable | Configurable | Configurable | Always plays |
| Settling-in TTS | Optional | Optional | Optional | Optional |
| Final goodnight TTS | Optional | Optional | Optional | Optional |
| Goodnight prompt (③) | Used | Used | Used | Skipped (use ⑧) |

## Technical Notes

- Runs in `mode: single` — no overlapping bedtime runs. If the automation is already running, a second trigger is ignored.
- `trace: stored_traces: 15` for debugging complex multi-branch flows.
- The presence gate uses `state_attr(sensor, 'last_changed')` for minimum duration checks. Unavailable/unknown sensors are treated as passing (fail-open) to prevent false gate failures.
- `continue_on_error: true` on all LLM calls, media playback, and non-critical actions prevents any single failure from blocking the bedtime flow.
- The `kodi_safe_content_type` variable auto-corrects CHANNEL → video when the content ID contains URI separators, preventing Kodi PVR crashes.
- Response type guard (`response_type | default('') != 'error'`) on all LLM response extraction prevents error messages from being spoken as TTS.
- The catalog string uses Jinja2 `namespace()` for genre filtering loops and structured sections (CURATED, IN-PROGRESS, MOVIES, RECENT, FAVOURITES) with selection instructions appended.
- In-progress TV shows bypass genre exclusion — you shouldn't stop watching a show mid-season because it has a thriller episode.
- The voice profile is passed via `options.voice_profile` in `tts.speak` — DRY pattern with `choose` blocks selecting profile vs. default TTS.
- Media players to stop use pause-then-stop fallback: `media_player.media_pause` first, `media_player.media_stop` as fallback for players where pause fails.
- The day-of-week condition checks `trigger.id` to bypass for manual triggers. Uses `now().weekday()` mapped to `['mon','tue','wed','thu','fri','sat','sun']` — same pattern as `proactive_llm_sensors.yaml` but without cross-midnight day attribution (not needed for single-fire-time triggers).
- The manual trigger boolean is auto-reset as the very first action — before any condition can abort — ensuring it's always cleaned up.
- Bathroom guard has three paths: occupied → wait + grace, recently cleared → wait remaining grace, long-cleared → proceed immediately.
- The TV sleep timer fires after the entire routine completes (lamp off + cleanup done), meaning total delay = countdown + bathroom guard + sleep timer minutes.

## Changelog

- **v5.3.0:** Weekday active logic — `run_days` input gates scheduled triggers by day of week. Manual triggers bypass the gate. Ported from `proactive_llm_sensors.yaml`.
- **v5.2.0:** Sleepy TV — added PVR channel detection method using REST sensor. New input: PVR channel sensor entity. Genres now optional when PVR detection active.
- **v5.1.2:** Fixed Kodi CHANNEL crash — auto-detect content type from URI pattern
- **v5.1.1:** Fixed LLM error messages spoken as TTS — added `response_type` guard
- **v5.1.0:** Optional presence sensor gate — skip routine if nobody home (configurable ANY/ALL, min duration, manual trigger bypass)
- **v5:** Initial release — Kodi playback with JSON-RPC library pre-fetch, genre filtering, sleepy TV detection, and TV sleep timer

## Author

**madalone**

## License

See repository for license details.
