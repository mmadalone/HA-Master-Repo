# Voice Assistant Blueprint Pattern — End-to-End Reference

> **Scope:** This document covers the complete voice assistant architecture as implemented in this Home Assistant instance — from the moment someone says a wake word to the moment TTS audio comes out of a speaker. Every layer, every handoff, every damn gotcha.

---

## Architecture Overview

The voice assistant pattern is a multi-layer stack. Each layer has a single responsibility, and they connect through well-defined interfaces. Here's the full chain:

```
┌─────────────────────────────────────────────────────────────────────┐
│                        VOICE INTERACTION CHAIN                      │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  1. ESPHome Voice PE Satellite                                      │
│     └─ Wake word detection (micro_wake_word)                        │
│     └─ Audio capture → HA voice pipeline                            │
│                                                                     │
│  2. HA Voice Pipeline                                               │
│     └─ STT (speech-to-text)                                         │
│     └─ Conversation agent (intent processing / LLM)                 │
│     └─ TTS (text-to-speech) → back to satellite speaker             │
│                                                                     │
│  3. Conversation Agent (persona)                                    │
│     └─ Static system prompt (personality, permissions, rules)        │
│     └─ Tool scripts (exposed as LLM functions)                      │
│     └─ Dynamic context via extra_system_prompt (from blueprints)     │
│                                                                     │
│  4. Blueprints (orchestration)                                      │
│     └─ Triggers (presence, time, events, GPS)                       │
│     └─ Conversation initiation (start_conversation, ask_question)   │
│     └─ TTS announcements (tts.speak, assist_satellite.announce)     │
│     └─ Device control via service calls                             │
│                                                                     │
│  5. Tool Scripts (thin wrappers)                                    │
│     └─ Single-purpose scripts exposed to LLM agents                 │
│     └─ Trigger centralized automations with command variables        │
│                                                                     │
│  6. Helpers (shared state)                                          │
│     └─ Ducking flags (input_boolean)                                │
│     └─ Volume storage (input_number)                                │
│     └─ Voice command bridges (input_boolean for Alexa)              │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Layer 1: ESPHome Voice PE Satellites

The physical hardware. Each satellite is an ESPHome-flashed Home Assistant Voice Preview Edition device with a microphone array, speaker, and onboard wake word processing.

### Device Configs

Two satellites exist in this setup, each assigned to a room and persona:

| Satellite | Hostname | Friendly Name | Persona | Wake Words |
|-----------|----------|---------------|---------|------------|
| Workshop  | `home-assistant-voice-0905c5` | HA Workshop | Rick | `hey_rick`, `yo_rick` |
| Living Room | `home-assistant-voice-0a0109` | HA Living Room | Quark | `hey_quark`, `yo_quark` |

### Config Structure

Every satellite config follows the mandatory section order from §6.1:

```yaml
# ── Identity ──────────────────────────────────────────
substitutions:
  name: home-assistant-voice-0905c5
  friendly_name: HA Workshop

# ── Base package ──────────────────────────────────────
packages:
  Nabu Casa.Home Assistant Voice PE:
    github://esphome/home-assistant-voice-pe/home-assistant-voice.yaml

# ── Core config ───────────────────────────────────────
esphome:
  name: ${name}
  name_add_mac_suffix: false
  friendly_name: ${friendly_name}

# ── Connectivity ──────────────────────────────────────
api:
  encryption:
    key: !secret api_key_workshop    # ⚠️ SHOULD be !secret, not inline

wifi:
  ssid: !secret wifi_ssid
  password: !secret wifi_password

# ── Persona wake words ────────────────────────────────
# 🔽 Rick's wake words — Workshop satellite
micro_wake_word:
  models:
    - id: hey_rick
      model: http://homeassistant.local:8123/local/microwake/hey_rick.json
    - id: yo_rick
      model: http://homeassistant.local:8123/local/microwake/yo_rick.json
```

### Key Principles

**One persona per satellite.** The Workshop gets Rick's wake words. The Living Room gets Quark's. Don't dump every wake word on every device — it degrades detection accuracy and confuses the user about which persona they're talking to.

**Extend, don't replace.** The `micro_wake_word.models` list is *appended* to the base package's default models (like `okay_nabu`). You only specify what you're adding — see §6.3.

**Wake word model hosting.** Custom `.json` and `.tflite` files live in `/config/www/microwake/` and are served via `http://homeassistant.local:8123/local/microwake/`. Each model needs both files:
- `hey_rick.json` — model metadata
- `hey_rick.tflite` — the actual TFLite inference model

### Current Config Issues to Note

Both satellite configs have **inline API encryption keys** instead of `!secret` references. Per §6.4 and anti-pattern #24, these should be migrated to `/config/esphome/secrets.yaml` as `!secret api_key_workshop` and `!secret api_key_living_room`.

---

## Layer 2: HA Voice Pipeline

The Voice Pipeline is configured in the HA UI (Settings → Voice Assistants). Each pipeline connects:

1. **STT engine** — converts microphone audio to text
2. **Conversation agent** — processes the text (intent matching or LLM)
3. **TTS engine** — converts the response back to speech

Each satellite is assigned a pipeline. The pipeline determines which conversation agent handles the interaction — this is how "Hey Rick" in the Workshop routes to Rick's agent, and "Hey Quark" in the Living Room routes to Quark's.

### Pipeline-to-Satellite Mapping

The pipeline assignment happens in the satellite's device config within HA (Settings → Devices → select the Voice PE → Configure). The key setting is which voice pipeline the satellite uses by default.

Blueprints can override this by targeting specific conversation agents directly via `conversation.process` or `assist_satellite.start_conversation` with an explicit `extra_system_prompt`.

---

## Layer 3: Conversation Agents

This is where personality lives. The conversation agent is configured through whichever integration you're using (Extended OpenAI Conversation, OpenAI Conversation, etc.) and holds the **static system prompt**.

### Agent Naming Convention (§8.4)

Pattern: `<Persona> - <Integration>[ - <Variant>]`

Examples from this setup:
- `Rick - Extended` — general purpose
- `Rick - Extended - Coming Home` — scenario-specific for arrival flow
- `Quark - Extended - Verbose` — detailed responses

### Mandatory Prompt Sections (§8.3)

Every agent prompt MUST contain these four sections in order:

**1. PERSONALITY** — Who the agent is, tone, mannerisms, response length constraints.

**2. PERMISSIONS** — Explicit allowlist of devices with entity IDs and allowed services. Table format:

```
| Device             | Entity ID                | Allowed services                         |
|--------------------|--------------------------|------------------------------------------|
| Workshop lights    | light.workshop_lights    | light.turn_on / light.turn_off / toggle  |
| Workshop speaker   | media_player.workshop    | media_player.volume_set / media_pause    |
```

Followed by: *"You are NOT allowed to control any devices outside this list."*

**3. RULES** — Behavioral rules for the scenario, decision trees, what to do on unclear input, what NOT to do.

**4. STYLE** — Output constraints (max sentences, no emojis, no entity names spoken aloud, "act first, talk second").

### Separation of Concerns — The Golden Rule (§1.2, §8.2)

This is arguably the most important architectural decision in the entire stack:

- **The agent's static system prompt** handles everything that doesn't change per invocation: personality, device permissions, behavioral rules, output style.
- **The blueprint** passes only **dynamic, per-run context** via `extra_system_prompt`: who triggered the automation, what time it is, what sensor readings are relevant right now.

Anti-pattern #1 exists for a reason: **never bake large LLM system prompts into blueprints.** The blueprint's `extra_system_prompt` should be short — just the facts that change.

```yaml
# GOOD — blueprint passes only dynamic context
extra_system_prompt: >-
  {{ person_name }} just arrived home and heard: "{{ welcome_line }}".
  This is an arrival conversation.

# BAD — blueprint contains the entire personality/rules/permissions prompt
extra_system_prompt: >-
  You are Rick, a sarcastic AI assistant. You may control the following
  devices: light.workshop_lights, light.living_room... [500 more lines]
```

### Tool Exposure (§8.3.2)

When using integrations that support function/tool calling, agents interact with the home through **exposed scripts** — not raw services. This is a critical security boundary:

- The PERMISSIONS section in the prompt is a **second line of defense**, not the first.
- The **first line of defense** is which scripts you expose as tools.
- Never expose raw `homeassistant.turn_off` or system-modifying services.

Each exposed script gets a `description` field written **for the LLM**, not for humans:

```yaml
description: >-
  Pauses whatever is currently playing on the nearest speaker.
  Call this when the user says "pause", "stop the music", "shut up".
  Do NOT call this for volume changes — use voice_volume_set instead.
```

---

## Layer 4: Blueprints (Orchestration)

Blueprints are the orchestration layer — they handle triggers, conditions, timing, flow control, and conversation initiation. They do NOT contain personality or device rules.

### Blueprint Categories in This Setup

| Blueprint | Pattern | Trigger | Conversation Style |
|-----------|---------|---------|-------------------|
| **Coming Home** | Arrival welcome | Person entity `not_home` → `home` | `assist_satellite.start_conversation` — interactive, multi-turn |
| **Proactive LLM Sensors** | Presence-based suggestions | Presence sensor ON + time_pattern (nag) | `tts.speak` — one-shot announcement, optional `ask_question` |
| **LLM Alarm** | Wake-up alarm | Time trigger + weekday filter | `tts.speak` — one-shot, then mobile notification wait |
| **Voice Active Media Controls** | Media control hub | Programmatic (`automation.trigger` from scripts) | No conversation — pure device control |

### The Coming Home Pattern (Interactive Conversation)

This is the most complex blueprint and the canonical example of how all layers interact. Flow:

```
GPS arrives → wait for entrance sensor → reset speakers →
turn on temp switches → wait for entrance clear →
generate AI greeting via conversation.process →
start interactive conversation on satellite via
  assist_satellite.start_conversation →
delay → cleanup temp switches
```

Key architectural decisions:

**1. Two-stage arrival confirmation.** GPS trigger alone isn't reliable (bounces, tunnels). The blueprint waits for a physical entrance occupancy sensor before proceeding. GPS bounce protection is handled by a cooldown condition using `this.attributes.last_triggered`.

**2. Speaker reset before conversation.** Toggling power switches clears stale Bluetooth connections on the Voice PE. This is a hardware workaround, but it's in the blueprint because it's timing-sensitive (must happen after entrance confirmation, before conversation starts).

**3. Greeting generation is separate from the conversation.** The blueprint calls `conversation.process` to generate a one-shot greeting line, then passes that line to `assist_satellite.start_conversation` as the `start_message`. The interactive conversation that follows uses the agent's own system prompt — the blueprint just provides arrival context via `extra_system_prompt`.

```yaml
# Generate the greeting (one-shot, no conversation)
- action: conversation.process
  data:
    agent_id: !input conversation_agent
    text: !input ai_greeting_prompt
  response_variable: ai_greeting

# Start the interactive conversation on the satellite
- action: assist_satellite.start_conversation
  target: !input assist_satellites
  data:
    preannounce: true
    start_message: "{{ welcome_line }}"
    extra_system_prompt: >-
      {{ person_name }} just arrived home and heard: "{{ welcome_line }}".
      This is an arrival conversation.
```

**4. Guaranteed cleanup.** Every exit path (timeout, entrance never cleared, normal completion) turns off the temporary switches. This is mandatory per §5.1 and anti-pattern #6.

### The Proactive LLM Sensors Pattern (One-Shot Announcements)

A simpler but more featureful blueprint. It generates context-aware messages when presence is detected in a room during configured time windows.

Key features:
- **Nag mode** — can repeat messages at configurable intervals while presence persists, with max nag limits per session
- **Weekday/weekend profiles** — separate time windows, cooldowns, and LLM prompts for weekdays vs weekends
- **Sensor context injection** — feeds arbitrary entity states into the LLM prompt as live context
- **Bedtime question** — optional follow-up using `assist_satellite.ask_question` with yes/no parsing, can trigger a bedtime script
- **ElevenLabs voice profile routing** — conditional `options.voice_profile` inclusion using `choose` blocks (not templated dicts)

The LLM prompt assembly pattern:

```yaml
- action: conversation.process
  data:
    agent_id: !input conversation_agent
    text: >
      {{ llm_prompt }}

      context:
      - area: {{ area_name }}
      - time_of_day: {{ tod_label }}
      - trigger_type: {{ trigger.platform }}
      - current_time: {{ now().strftime('%Y-%m-%d %H:%M') }}
      - extra_entities:
      {{ sensor_context }}

      task:
      respond with ONE short, natural sentence you would say out loud
      maximum 220 characters. do not include quotation marks.
```

**Response extraction with robust fallback** — always handle the case where the LLM returns garbage or nothing:

```yaml
proactive_message: >
  {% set resp = ai_result.response if ai_result is defined else none %}
  {% if resp is not none
        and resp.speech is defined
        and resp.speech.plain is defined
        and resp.speech.plain.speech is defined %}
    {% set txt = resp.speech.plain.speech | trim %}
    {% if not txt %}
      {{ fallback | trim }}
    {% else %}
      {{ txt }}
    {% endif %}
  {% else %}
    {{ fallback | trim }}
  {% endif %}
```

Every single one of those `is defined` checks matters. The response object structure varies between conversation integrations, and any of those keys could be missing.

### The Voice Active Media Controls Pattern (Command Hub)

This is a pure automation — no voice pipeline, no conversation. It exists as the centralized brain for media control, invoked programmatically by thin wrapper scripts.

Architecture:

```
LLM Agent sees user say "pause the music"
  → calls script.voice_media_pause (exposed tool)
    → script calls automation.trigger with command: "pause_active"
      → automation finds highest-priority playing media_player
        → pauses it
```

Three commands: `pause_active`, `stop_radio`, `shut_up`.

The automation uses `expand()` with `selectattr` for priority-based player resolution:

```yaml
active_target: >-
  {% set active = expand(candidates)
     | selectattr('state', 'in', ['playing', 'paused'])
     | list %}
  {{ active[0].entity_id if active | count > 0 else 'none' }}
```

Mode is `parallel` with `max_exceeded: silent` — multiple commands can arrive in quick succession.

---

## Layer 5: Tool Scripts (Thin Wrappers)

These are the bridge between the LLM agent and the automation layer. Each script does exactly one thing: pass a command to the Voice Active Media Controls automation.

### Script Blueprint Pattern

Each script blueprint:
1. Accepts a single input: which automation to trigger
2. Validates the automation exists and is enabled
3. Calls `automation.trigger` with `skip_condition: true` and a `command` variable
4. Includes configurable phrase lists for documentation (copied into agent prompts)

```yaml
sequence:
  # Validate the automation is available
  - if:
      - condition: template
        value_template: "{{ missing_or_disabled }}"
    then:
      - service: persistent_notification.create
        data:
          title: "Voice – Pause Active Media – Misconfiguration"
          message: >- ...
      - stop: "Active media automation not available"

  # Fire the command
  - service: automation.trigger
    target:
      entity_id: "{{ active_media_automation }}"
    data:
      skip_condition: true
      variables:
        command: "pause_active"
```

### Current Tool Scripts

| Script Blueprint | Command | LLM Trigger Phrases |
|-----------------|---------|-------------------|
| `voice_media_pause` | `pause_active` | "pause", "pause it", "stop the music", "pause the TV" |
| `voice_stop_radio` | `stop_radio` | "stop radio", "turn off the radio" |
| `voice_shut_up` | `shut_up` | "shut up", "be quiet", "stop everything" |

### Why This Architecture?

**Single source of truth.** All media control logic lives in one automation. Adding a new media player means updating one config, not three scripts.

**Clean LLM tools.** The agent sees simple, single-purpose scripts with clear descriptions. It doesn't need to understand priority resolution or player state checking.

**Testability.** You can trigger the automation manually with any command from Developer Tools → Services without going through the LLM.

---

## Layer 6: Helpers (Shared State)

Helpers are the glue between automations that need to coordinate. Three patterns dominate the voice assistant stack:

### Ducking Flags (`input_boolean`)

When TTS speaks over active music, the volume needs to be ducked (lowered), then restored. A shared `input_boolean` (e.g., `input_boolean.voice_pe_ducking`) acts as a coordination flag:

- Set ON before ducking volume
- Other automations (like volume sync) check this flag and pause their behavior
- Set OFF after restoring volume

Without this flag (anti-pattern #32), volume sync automations will fight the duck/restore cycle and create feedback loops that sound like a DJ having a stroke.

### Volume Storage (`input_number`)

The Voice PE duck/restore blueprints store each player's pre-duck volume in dedicated `input_number` helpers (range 0.0–1.0). This survives across the async duck/restore cycle and handles the edge case where a player doesn't expose `volume_level` right after an HA restart.

### Voice Command Bridges (`input_boolean` for Alexa)

Alexa can't call MA services directly. The bridge pattern:

```
"Alexa, turn on Radio Klara" → input_boolean.radio_klara ON
  → automation triggers → presence detection → MA play
```

**Critical rule (anti-pattern #33):** Auto-reset the boolean FIRST, before any conditions. If a condition aborts the run and the boolean stays ON, the next voice command can't toggle it.

---

## TTS Output Patterns

### Three Ways to Speak

| Method | Use When | Ducks Music? | Interactive? |
|--------|----------|-------------|-------------|
| `tts.speak` | One-shot announcements to any media_player | Manual duck/restore needed | No |
| `assist_satellite.announce` | One-shot to Voice PE satellites | Auto-ducks (satellite enters "responding" state) | No |
| `assist_satellite.start_conversation` | Interactive multi-turn dialog | Auto-ducks via pipeline | Yes |
| `assist_satellite.ask_question` | Yes/no or multiple-choice questions | Auto-ducks via pipeline | Limited (structured answers) |

### ElevenLabs Voice Profile Routing

When using ElevenLabs custom TTS, the `voice_profile` option must be conditionally included — sending an empty profile to non-ElevenLabs engines will choke:

```yaml
- choose:
    - conditions:
        - condition: template
          value_template: "{{ voice_profile | default('') | string | length > 0 }}"
      sequence:
        - action: tts.speak
          target:
            entity_id: !input tts_engine
          data:
            media_player_entity_id: "{{ player }}"
            message: "{{ message }}"
            options:
              voice_profile: !input voice_profile
  default:
    - action: tts.speak
      target:
        entity_id: !input tts_engine
      data:
        media_player_entity_id: "{{ player }}"
        message: "{{ message }}"
```

### Post-TTS Delay (Anti-Pattern #31)

ElevenLabs and other streaming TTS engines return from `tts.speak` *before* the audio finishes playing. **Always** include a configurable delay before restoring volume or starting the next action. Default: 5 seconds. Expose it as a blueprint input.

---

## Data Flow Summary

Here's the complete data flow for the two primary patterns:

### Interactive Conversation (Coming Home)

```
1. Person entity: not_home → home (GPS)
2. Blueprint condition: cooldown check passes
3. Blueprint waits: entrance occupancy sensor → on
4. Blueprint action: reset speaker switches (off → delay → on)
5. Blueprint action: turn on temporary switches
6. Blueprint waits: entrance sensor → off (person moved past door)
7. Blueprint calls: conversation.process (generate greeting line)
   └─ Agent receives: greeting prompt with {{ person_name }}
   └─ Agent returns: snarky one-liner
8. Blueprint calls: assist_satellite.start_conversation
   └─ Satellite receives: start_message (the greeting) + extra_system_prompt (arrival context)
   └─ Satellite speaks: the greeting via TTS
   └─ Satellite listens: for user's voice response
   └─ Pipeline processes: STT → Conversation Agent → TTS
   └─ Agent uses: its own static system prompt + extra_system_prompt + exposed tool scripts
   └─ Conversation continues: until user stops talking or satellite times out
9. Blueprint waits: post_conversation_delay
10. Blueprint action: turn off temporary switches (cleanup)
```

### One-Shot Announcement (Proactive LLM Sensors)

```
1. Presence sensor: off → on (or time_pattern tick while present)
2. Blueprint conditions: day-of-week, time window, cooldown, media not playing, min presence
3. Blueprint builds: sensor_context from context_entities
4. Blueprint calls: conversation.process (generate proactive message)
   └─ Agent receives: llm_prompt + area + time + sensor context + task constraints
   └─ Agent returns: one short sentence
5. Blueprint extracts: response with multi-level fallback
6. Blueprint calls: tts.speak (with conditional ElevenLabs voice_profile)
   └─ TTS engine speaks: through the area's media_player
7. (Optional) Blueprint waits: bedtime_question_delay
8. (Optional) Blueprint calls: conversation.process (generate bedtime question)
9. (Optional) Blueprint calls: assist_satellite.ask_question
   └─ Satellite asks: the LLM-generated question
   └─ Satellite listens: for yes/no response
   └─ If "yes": blueprint calls bedtime_help_script
```

---

## Common Gotchas & Anti-Patterns

These are the ones that'll bite you in the ass if you're not careful:

1. **Inline API keys in ESPHome configs** (#24) — Both current satellite configs have this. Migrate to `!secret`.

2. **`tts.speak` returns before audio finishes** (#31) — Always add a post-TTS delay before restoring volume or starting the next step.

3. **Ducking flag coordination** (#32) — Every TTS-over-music flow needs the shared `input_boolean` flag. Volume sync automations MUST check it.

4. **Input boolean bridges: reset FIRST** (#33) — Before any condition that could abort the run.

5. **`wait_for_trigger` vs `wait_template`** (§5.1) — `wait_for_trigger` waits for a *transition*. If the state is already true, it hangs forever. Use the check-first pattern.

6. **LLM response extraction** — Never trust the response structure. Check `is defined` at every level. Always have a fallback.

7. **`continue_on_timeout: true` on every wait** (#4) — With explicit timeout handlers that clean up state.

8. **One persona per satellite, one agent per scenario** — Don't mix Rick and Quark on the same device. Don't use a general-purpose agent for a scenario that needs specific rules.

---

## File Locations Reference

| Component | Path |
|-----------|------|
| ESPHome satellite configs | `/config/esphome/home-assistant-voice-*.yaml` |
| ESPHome secrets | `/config/esphome/secrets.yaml` |
| Custom wake word models | `/config/www/microwake/*.json` + `*.tflite` |
| Automation blueprints | `/config/blueprints/automation/madalone/` |
| Script blueprints | `/config/blueprints/script/madalone/` |
| Voice PE duck/restore blueprints | `/config/blueprints/automation/voice_pe/` |
| Conversation agent prompts | Configured in HA UI (integration settings) |
| Voice pipeline config | HA UI → Settings → Voice Assistants |

---

## Style Guide Cross-References

| Topic | Section |
|-------|---------|
| Blueprint YAML structure | §3 (Blueprint Patterns) |
| Input sections (mandatory) | §3.2 |
| Template safety | §3.6 |
| Timeout handling | §5.1 (Automation Patterns) |
| GPS bounce protection | §5.5 |
| Conversation agent prompts | §8 (Conversation Agents) |
| Agent naming | §8.4 |
| ESPHome config structure | §6.1 (ESPHome Patterns) |
| Wake word models | §6.5 |
| TTS duck/restore | §7.4 (Music Assistant Patterns) |
| Voice command bridges | §7.7 |
| Unified media control | §7.8 |
| All anti-patterns | §10 |