# Music Assistant – Local LLM Enhanced Voice Support

![Music Assistant LLM Enhanced Voice](https://raw.githubusercontent.com/mmadalone/HA-Master-Repo/main/images/header/mass_llm_enhanced_assist-header.jpeg)

A voice-controlled music playback automation that uses an LLM conversation agent to parse natural-language voice commands into structured media queries, then plays them via Music Assistant. Supports area-based and player-based targeting with automatic fallback, player protection, URI shortcuts, and playback verification.

**This is a modified fork** of the official [Music Assistant voice-support LLM-enhanced blueprint](https://github.com/music-assistant/voice-support/blob/main/llm-enhanced-local-assist-blueprint/mass_llm_enhanced_assist_blueprint_en.yaml) by the Music Assistant Project (TheFes, JLo, and contributors). All upstream functionality is preserved; the additions below are by **madalone**.

## What This Fork Adds

The upstream blueprint provides the core LLM → JSON → play_media pipeline with area/player targeting, radio mode, and customizable prompts/responses. This fork layers the following on top:

### Player Blacklist & Divert (§③)

Permanently exclude specific MA players from receiving voice-triggered music — useful for TV-based players (e.g., a Chromecast-backed "MadTeeVee") that should never be hijacked by a voice command. When an area contains a blacklisted player, the blueprint expands the area into individual player entities and removes only the blacklisted ones, keeping the rest. If all targets are removed and divert is enabled, playback redirects to a designated fallback player instead of silently failing.

### Enqueue Mode (§②)

Adds a three-way selector for how new media enters the queue: "Replace" (clear and play immediately, upstream default), "Add" (append to end), or "Next" (insert after current track). The upstream blueprint always replaces.

### URI Override Shortcuts (§⑥)

Maps voice keywords directly to exact Music Assistant URIs, bypassing search entirely. Configured as one `keyword=uri` mapping per line. When the LLM extracts a `media_id` that matches a keyword (case-insensitive), the blueprint substitutes the URI directly. Solves the problem of playlists and media that are hard to find by name (e.g., "liked songs" → `library://playlist/157`).

### Playback Verification (§②, steps 8a–8b)

After calling `play_media`, waits a configurable delay (default 2s), then checks whether any target player is in `playing` or `buffering` state. If not, the voice response reports a failure instead of falsely claiming "Now playing…". This catches cases where MA is down, media wasn't found, or the player is unavailable — which `continue_on_error` alone would silently swallow.

### Pronoun Fix (v11)

The LLM prompt now instructs the agent to use second-person pronouns ("your liked songs") instead of echoing back first-person ("my liked songs"). A `regex_replace` safety net on `media_info` catches any LLM that ignores the instruction.

### LLM Error Gating (steps 2a, 4)

Two explicit bail-out gates: one after the `conversation.process` call (catches LLM timeout, crash, or empty response) and one after JSON parsing (catches malformed/garbage output). Both return clear user-facing error messages instead of silent failures or cryptic trace errors.

### Safe Delimiter Handling

Area and player names are internally joined with `|||` instead of commas for matching operations, because MA player friendly names can contain commas. The comma-delimited versions are preserved for LLM prompt readability.

### Execution Mode

Changed from the upstream's default `single` to `parallel` with `max: 10`, allowing concurrent voice commands from different rooms. Includes `trace: stored_traces: 15` for debugging.

### Style Guide Compliance (v12)

Collapsible input sections with numbered stage icons (①–⑥), `conversation_agent` selector, consistent section key/name conventions, descriptive aliases on every step, and `===` divider style throughout.

## Pipeline Flow

```
Voice command ("Play Pink Floyd in the kitchen")
            │
            ▼
┌───────────────────────────────────┐
│  ① LLM QUERY                      │
│  Assemble prompt from 7 sections   │
│  → conversation.process            │
│  → Parse JSON response             │
│  Gates: LLM failure / parse error  │
└───────────────┬───────────────────┘
                │
                ▼
┌───────────────────────────────────┐
│  ② RESOLVE TARGETS                 │
│  LLM areas/players → entity_ids    │
│  Fallback: device area → default   │
│  Safe |||  delimiter matching      │
└───────────────┬───────────────────┘
                │
                ▼
┌───────────────────────────────────┐
│  ③ PLAYER BLACKLIST & DIVERT       │
│  Remove protected players          │
│  Expand tainted areas → rescue     │
│  Divert to fallback if empty       │
└───────────────┬───────────────────┘
                │
                ▼
┌───────────────────────────────────┐
│  ④ URI OVERRIDE                    │
│  Match media_id to keyword map     │
│  Substitute exact URI if matched   │
└───────────────┬───────────────────┘
                │
                ▼
┌───────────────────────────────────┐
│  ⑤ PLAYBACK                       │
│  play_media (3 radio_mode branches)│
│  shuffle_set (separate call)       │
│  Verify: delay → state check       │
└───────────────┬───────────────────┘
                │
                ▼
┌───────────────────────────────────┐
│  ⑥ VOICE RESPONSE                  │
│  Failure → error message           │
│  Success → area/player/both/none   │
│  Pronoun regex safety net          │
└───────────────────────────────────┘
```

## Prerequisites

- **Home Assistant 2024.10.0+**
- **Music Assistant** integration with at least one player
- An **LLM conversation agent** (OpenAI, Ollama, Google AI, etc.) configured **without** house control — it only needs to return JSON
- A voice pipeline (Voice PE, browser, or conversation trigger)

## Installation

1. Copy `mass_llm_enhanced_assist_blueprint_en.yaml` into your blueprints directory:
   ```
   config/blueprints/automation/<your_namespace>/mass_llm_enhanced_assist_blueprint_en.yaml
   ```
   Or import via URL if hosted on GitHub.

2. Create a new automation from the blueprint: **Settings → Automations → Create Automation → Use Blueprint**

3. At minimum, select your **LLM conversation agent** in §①.

## Configuration

### ① Core Settings

| Input | Description |
|-------|-------------|
| **LLM conversation agent** | The agent that parses voice commands into JSON. Should have no house control. |
| **Default Player** | Fallback MA player when no area/player can be determined. Leave empty to return an error instead. |

### ② Playback Settings

| Input | Default | Description |
|-------|---------|-------------|
| **Radio Mode** | Use player settings | "Always" keeps adding songs, "Never" stops at queue end, "Use player settings" defers to the player's "Don't stop the music" setting |
| **Enqueue Mode** | Replace | "Replace" clears queue, "Add" appends, "Next" inserts after current track |
| **Playback verification delay** | 2 sec | How long to wait before checking if playback started. Increase for slow backends. |

### ③ Player Blacklist & Divert

| Input | Default | Description |
|-------|---------|-------------|
| **Blacklisted players** | (empty) | MA players that should never receive music from this automation |
| **Enable divert** | Off | Redirect to fallback player when blacklist removes all targets |
| **Divert fallback player** | (empty) | The player to divert to when divert is enabled |

### ④ Trigger & Response Settings

Customizable trigger sentences (`(shuffle|play|listen to) {query}` by default), combine word for multi-target responses, and five response templates with `<action_word>`, `<media_info>`, `<area_info>`, `<player_info>` placeholders. All translatable.

### ⑤ LLM Prompt Tuning

Seven individually editable prompt sections (intro, media_type, media_id, artist/album, examples, media_description, target, outro) that are concatenated and sent to the LLM. The default prompt works for most models. The intro section includes the second-person pronoun instruction for media_description.

### ⑥ Media URI Shortcuts

One mapping per line in `keyword=uri` format. Case-insensitive matching against the LLM-extracted `media_id`. Example:

```
liked songs=library://playlist/157
chill vibes=library://playlist/42
workout mix=spotify://playlist/abc123
```

## Target Resolution Order

1. LLM-extracted areas and/or players (fuzzy-matched against known MA entities)
2. Device area — if the trigger came from a physical voice satellite in an area with an MA player
3. Default player from blueprint config
4. Error response if none of the above resolves

## Upstream vs. Fork Feature Comparison

| Feature | Upstream | This Fork |
|---------|----------|-----------|
| LLM voice → JSON → play_media | Yes | Yes |
| Area + player targeting | Yes | Yes |
| Radio mode (3 options) | Yes | Yes |
| Customizable prompts & responses | Yes | Yes |
| Expose areas/players to LLM | Yes | Yes |
| Player blacklist & divert | — | Yes (§③) |
| Enqueue mode (replace/add/next) | — | Yes (§②) |
| URI override shortcuts | — | Yes (§⑥) |
| Playback verification | — | Yes (steps 8a–8b) |
| LLM failure gating | — | Yes (steps 2a, 4) |
| Pronoun fix (my → your) | — | Yes (v11) |
| Safe delimiter for comma-names | — | Yes (|||) |
| Parallel mode (max: 10) | — | Yes |
| Stored traces | — | 15 |
| Collapsible input sections | — | Yes (①–⑥) |

## Technical Notes

- Runs in `mode: parallel` / `max: 10` / `max_exceeded: silent` — allows concurrent voice commands from different rooms without blocking.
- `continue_on_error: true` is placed on each individual `play_media` branch (not the outer choose), so failures are caught per-branch and the playback verification step runs regardless.
- The LLM has no native timeout in HA service calls. Defense: configure the agent integration's own request timeout (OpenAI timeout, Ollama keep_alive, etc.). That timeout fires → agent returns error → `continue_on_error` catches it → gate 2a bails with a user-facing message.
- Shuffle is a separate `media_player.shuffle_set` call because `music_assistant.play_media` has no shuffle parameter.
- The blacklist expansion logic handles the case where an area contains both protected and unprotected MA players — it rescues the unprotected ones and only removes the blacklisted entities.
- `trace: stored_traces: 15` keeps debugging data for the last 15 runs.

## Changelog

- **v12:** Style guide compliance — `conversation_agent` selector, section key/name conventions, `===` divider style, collapsible input sections
- **v11:** Pronoun fix — voice responses now say "your liked songs" instead of echoing back "my liked songs". LLM prompt instructs second-person pronouns; `regex_replace` safety net on `media_info` as fallback
- **v10:** URI override layer — map voice keywords to exact Music Assistant URIs, bypassing search. Configurable `keyword=uri` mappings for playlists and media that are hard to find by name

## Acknowledgments

- **Music Assistant Project** — The upstream [LLM-enhanced voice blueprint](https://github.com/music-assistant/voice-support) by TheFes and contributors provides the core LLM → JSON → play_media pipeline that this fork builds upon.
- **JLo** — Original [GPT-powered music search blog post](https://github.com/music-assistant/voice-support/blob/main/README.md) that inspired the LLM-enhanced approach.

## Author

**Music Assistant Project** (original) · **madalone** (style-guide fixes and feature additions v10–v12)

## License

See repository for license details.
