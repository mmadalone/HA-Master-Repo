### Voice PE Media Management

| Blueprint | File | Purpose |
|-----------|------|---------|
| **Duck Media Volumes** | `voice_pe_duck_media_volumes.yaml` | Lowers volume on up to 8 media players when Voice PE starts listening, boosts announcement player volume for clear TTS output. Alexa-safe volume storage. |
| **Restore Media Volumes** | `voice_pe_restore_media_volumes.yaml` | Companion to Duck — restores all player volumes when the satellite returns to idle, with configurable delay to handle multi-turn conversations |
| **Resume Media** | `voice_pe_resume_media.yaml` | Resumes playback only on players that were actually playing before the voice conversation started, using convention-based helper booleans |

## Voice PE Media Management

### Duck / Restore Volume Pair

These two blueprints work together to manage media volume during Voice PE conversations.

```
Satellite: idle ──→ listening/responding
                         │
              ┌──────────┴──────────┐
              │   DUCK BLUEPRINT     │
              │                      │
              │ 1. Flag ON (first    │
              │    time only)        │
              │ 2. Store volumes in  │
              │    input_number      │
              │    helpers           │
              │ 3. Duck playing      │
              │    players to low    │
              │    volume            │
              │ 4. Boost announce    │
              │    players for TTS   │
              └──────────────────────┘

Satellite: * ──→ idle (after delay)
                         │
              ┌──────────┴──────────┐
              │  RESTORE BLUEPRINT   │
              │                      │
              │ 1. Read stored       │
              │    volumes from      │
              │    helpers           │
              │ 2. Restore all       │
              │    players           │
              │ 3. Wait 3s cooldown  │
              │ 4. Flag OFF          │
              └──────────────────────┘
```

**Key design decisions:**

- **Alexa-safe volume storage** — If a player doesn't expose `volume_level` (common after HA restarts with Alexa integrations), the blueprint keeps the last stored helper value instead of overwriting it with 0. Prevents silent speakers.
- **Ducking flag** — An `input_boolean` prevents overwriting stored volumes during multi-state satellite transitions within a single conversation.
- **Announcement volume boost** — Separate volume level for Voice PE announcement players so TTS output is heard clearly even while other players are ducked.
- **8 media players + 4 announcement players** — Supports large setups with explicit per-player helpers. HA blueprint limitations prevent dynamic lists with paired helpers, so each slot is configured individually.
- **Configurable restore delay** — Prevents volume bouncing during multi-turn conversations where the satellite briefly returns to idle between turns. 2–3 seconds recommended.
- **3-second post-restore cooldown** — Ensures the volume sync cooldown expires before clearing the ducking flag, preventing race conditions.

**Required helpers (per player):**
- `input_number` (0.0–1.0) for each media player and announcement player to store pre-duck volume
- `input_boolean` for the ducking active flag

### Resume Media

Works with a companion "mark & pause" automation. Uses a convention-based naming pattern to track which players were actually playing:

```
media_player.SOMETHING  →  input_boolean.SOMETHING_was_playing
```

Examples:
```
media_player.madteevee           → input_boolean.madteevee_was_playing
media_player.workshop            → input_boolean.workshop_was_playing
media_player.miquel_s_echo_pop   → input_boolean.miquel_s_echo_pop_was_playing
```

The blueprint iterates over configured players, checks each `_was_playing` helper, resumes only those that were actually playing, then resets all helpers. Triggers when any selected satellite transitions from `responding` to `idle`.

---

## Installation

### 1. Import Blueprints

Copy the YAML files into your blueprints directory:

```
config/blueprints/automation/<your_namespace>/
├── voice_pe_duck_media_volumes.yaml
├── voice_pe_restore_media_volumes.yaml
└── voice_pe_resume_media.yaml
```

Or import via URL if hosted on GitHub.

### 2. Create Helpers

| Helper type | Purpose | Used by |
|-------------|---------|---------|
| `input_boolean` | Ducking active flag | Duck, Restore |
| `input_number` (0–1) | Volume storage per media player | Duck, Restore |
| `input_number` (0–1) | Volume storage per announcement player | Duck, Restore |
| `input_boolean` | `<player>_was_playing` per managed player | Resume Media |

### 3. Create Automations

**Settings → Automations → Create Automation → Use Blueprint**

Make sure paired blueprints share the same helper entities:
- **Duck + Restore** — Same ducking flag, same volume helpers, same player/announcement player configuration

## Technical Notes

- All blueprints require **Home Assistant 2024.10.0** or newer.
- Duck and Restore run `mode: single` — prevents race conditions on volume storage.
- The `notify_service` input in Wake-Up Guard uses a text selector because HA blueprints have no native notify-service selector. Typos will only fail at runtime.
- Duck blueprint uses `service:` (pre-2024.10 syntax) rather than `action:` in some places for broader compatibility.

## Author

**madalone**