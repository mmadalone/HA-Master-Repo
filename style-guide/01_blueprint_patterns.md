# Home Assistant Style Guide — Blueprint Patterns

Sections 3 and 4 — Blueprint YAML structure, inputs, variables, templates, and script standards.

---

## 3. BLUEPRINT STRUCTURE & YAML FORMATTING

### 3.1 Blueprint header and description image
Every blueprint must include a header image in its `description:` field. See §11.1 step 4 for image generation specs (1K, 16:9, Rick & Morty style). Allowed formats: `.jpeg`, `.jpg`, `.png`, `.webp`. Always ask the user for an image — never skip this step.

Every blueprint must include:
```yaml
blueprint:
  name: <Clear, descriptive name>
  author: <Author name>
  source_url: <GitHub URL if shared, omit if private>
  description: '![Image](<url>)

    # <Blueprint name>

    <What it does, in 2-3 sentences. Include key behaviors and safeguards.>

    ### Recent changes
    - **v3:** Added timeout handling for all wait steps
    - **v2:** Migrated service: → action: syntax throughout
    - **v1:** Initial version'
  domain: automation
  homeassistant:
    min_version: <minimum HA version — REQUIRED if using newer features>
  input:
    ...
```

**Header fields:**
- `author:` — Always include. Even for personal blueprints, it identifies ownership.
- `source_url:` — Include if the blueprint lives on GitHub or will be shared. This enables one-click reimport/update in the HA UI. Omit for strictly private blueprints. Use `GIT_REPO_URL` as the base (defined in Project Instructions).
- `description:` image URL — Use `HEADER_IMG_RAW` + `<blueprint_name>-header.<ext>` (defined in Project Instructions). Never use `github.com/blob/...` — blob URLs render HTML, not the image binary. See §11.1 step 4 for full image specs.
- `min_version:` — **Required** when using features from a specific HA version. Always verify which version introduced the features you use.
- `icon:` — **NOT valid** in the `blueprint:` schema block. HA will reject it with `extra keys not allowed @ data['blueprint']['icon']`. Icons are only available on **instances** created from blueprints, not the blueprint definition itself. See also §4.1.

> 📋 **QA Check VER-2:** Blueprint examples must include `min_version` when using modern syntax. See `09_qa_audit_checklist.md`.

**Key `min_version` thresholds:**

| Version | Feature introduced |
|---|---|
| `2024.2.0` | `conversation_agent:` blueprint selector (shows all installed agents, not just built-in) |
| `2024.4.0` | Labels and categories for automations, scripts, entities |
| `2024.6.0` | Collapsible input sections in blueprints |
| `2024.8.0` | `action:` syntax (replaces legacy `service:` — not deprecated, still works) |
| `2024.10.0` | `triggers:`, `conditions:`, `actions:` (plural syntax); `trigger:` keyword replacing `platform:` inside trigger definitions |
| `2025.12.0` | Purpose-specific triggers (Labs feature — experimental, opt-in via Settings > System > Labs; still expanding as of 2026.2) |

**Image rule (project standard — not an HA requirement):** Every blueprint MUST have an image in its description. When creating or updating a blueprint, ask the user if they want to provide an image. If they don't have one, generate one using the default specs in §11.1 step 4.

**Recent changes (project standard):** The blueprint description MUST include the last 3 version changes. Each entry is a single line, max ~80 characters — verb-first, no articles, no fluff. If a version touched multiple things, pick the most significant change.

### 3.2 Collapsible input sections (MANDATORY)
All blueprint inputs MUST be organized into collapsible sections grouped by **stage/phase of the automation flow**. Use the nested `input:` pattern:

```yaml
input:
  # Top-level inputs that don't belong to a stage (rare — e.g. person entity)
  person_entity:
    name: Person
    ...

  # ===========================================================================
  # ① DETECTION & TRIGGERS
  # ===========================================================================
  detection:
    name: "① Detection & triggers"
    icon: mdi:motion-sensor
    description: Configure how arrival/presence is detected.
    input:
      entrance_sensor:
        name: Entrance occupancy sensor
        ...
      entrance_wait_timeout:
        name: Entrance wait timeout
        ...

  # ===========================================================================
  # ② DEVICE PREPARATION
  # ===========================================================================
  preparation:
    name: "② Device preparation"
    icon: mdi:cog
    description: Devices to reset or prepare before the main flow.
    input:
      reset_switches:
        name: Reset switches
        ...

  # ===========================================================================
  # ③ AI CONVERSATION
  # ===========================================================================
  conversation:
    name: "③ AI conversation"
    icon: mdi:robot
    description: Conversation agent and satellite settings.
    input:
      conversation_agent:
        name: Conversation agent
        ...

  # ===========================================================================
  # ④ CLEANUP & TIMING
  # ===========================================================================
  cleanup:
    name: "④ Cleanup & timing"
    icon: mdi:broom
    description: Post-flow cleanup and cooldown settings.
    input:
      post_conversation_delay:
        name: Post-conversation delay
        ...
```

**Rules for sections:**
- Section display names use circled Unicode numbers: `"① <Phase name>"` (e.g., `"① Schedule"`, `"② Sync settings"`)
- Section YAML keys use descriptive names (e.g., `device_pairs:`, `sync_settings:`) — NOT `stage_N_xxx` or `section_N_xxx` prefixed names
- YAML comment dividers use the three-line `===` box style:
  ```yaml
  # ===========================================================================
  # ① DEVICE PAIRS
  # ===========================================================================
  ```
- Do NOT use single-line em-dash dividers (`# ── Stage 1 — ...`) — that's the old convention
- Each section gets an appropriate `mdi:` icon
- Each section gets a short `description` explaining what it configures
- Inputs within a section are ordered logically (most important first)
- If a blueprint only has 3-4 inputs total, sections are optional but still preferred

### 3.3 Input definitions
- Every input MUST have `name` and `description`.
- The `description` must explain **what the input does and why** — not just what it is. Users should understand the feature's purpose from the description alone.
- Use `default` values wherever a sensible default exists.
- Use appropriate `selector` types — never leave inputs untyped.
- **Use `select` (dropdown) selectors whenever the input has a finite set of valid options.** This prevents user error and makes configuration clearer:

```yaml
mode_selector:
  name: Operating mode
  description: >
    Choose how the automation behaves when triggered multiple times.
    "cautious" waits for confirmation; "aggressive" acts immediately.
  default: cautious
  selector:
    select:
      options:
        - label: "Cautious — wait for confirmation"
          value: cautious
        - label: "Aggressive — act immediately"
          value: aggressive
```

- **Use multi-select (`multiple: true`) when the user may want to choose more than one option** and it makes logical sense:

```yaml
enabled_features:
  name: Enabled features
  description: Choose which features this automation should use.
  default:
    - lights
    - music
  selector:
    select:
      multiple: true
      options:
        - label: "Lights control"
          value: lights
        - label: "Music playback"
          value: music
        - label: "TV control"
          value: tv
        - label: "Game mode"
          value: game_mode
```

- Entity inputs should specify `domain` (and `device_class` where applicable) in the selector filter.
- **Conversation agent inputs MUST use the `conversation_agent:` selector** — never `entity: domain: conversation`. The `entity` selector only shows built-in HA Conversation agents, hiding Extended OpenAI Conversation, OpenAI Conversation, and other third-party agents. The `conversation_agent:` selector shows **all** installed conversation agents and outputs their ID. The corresponding `conversation.process` call uses `agent_id:` to reference the selected agent. **Requires HA 2024.2+** — the selector was introduced in that release and fails silently on older installs. *(Verified against official HA selector docs, 2025.12.1 — see https://www.home-assistant.io/docs/blueprint/selectors/#conversation-agent-selector)*:

```yaml
# ✅ CORRECT — shows all conversation agents including Extended OpenAI
conversation_agent:
  name: Conversation / LLM agent
  description: >
    Conversation agent that generates messages. Can be OpenAI
    Conversation, Extended OpenAI Conversation, Llama, or any
    agent that supports conversation.process.
  selector:
    conversation_agent:

# Action usage:
- action: conversation.process
  data:
    agent_id: !input conversation_agent
    text: "{{ my_prompt }}"
```

```yaml
# ❌ WRONG — only shows built-in HA agents, hides Extended OpenAI etc.
conversation_agent:
  selector:
    entity:
      domain: conversation
```

- **Use `target:` selector when actions need flexible targeting.** The `target:` selector is distinct from `entity:` — it lets users pick any combination of entities, devices, areas, or labels. This is the preferred selector when the action uses a `target:` field (which most service calls do). The output is a dict with `entity_id`, `device_id`, `area_id`, and `label_id` lists. *(Note: device filter was removed from the target selector in October 2025 — only entity filters are supported.)*

```yaml
# ✅ target: selector — flexible targeting by entity, device, area, or label
light_target:
  name: Lights to control
  description: >-
    Select the lights this automation should control. You can pick
    individual entities, entire devices, areas, or labels.
  selector:
    target:
      entity:
        domain: light

# Usage in actions — pass directly to target:
- alias: "Turn on selected lights"
  action: light.turn_on
  target: !input light_target
```

```yaml
# When to use target: vs entity:
#   target: → action uses `target:` field, user may want area/device/label targeting
#   entity: → you need a single entity_id for templates, state checks, or triggers
```

- **Never hardcode entity IDs in the action section.** If an action references an entity, it must come from an `!input` reference or a variable derived from one.

### 3.4 Variables block
Declare a top-level `variables:` block immediately after `condition:` to resolve `!input` references into template-usable variables:

```yaml
variables:
  person_entity: !input person_entity
  person_name: "{{ state_attr(person_entity, 'friendly_name') | default('someone') }}"
```

This avoids repeating `!input` throughout the action section and makes templates cleaner.

**Variable scope and propagation:** All variables defined at the top level (including resolved `!input` values and trigger variables like `trigger.to_state`) are available inside `wait_for_trigger`, `choose`, `if/then`, and nested actions. You can use them in dynamic wait conditions.

**⚠️ Caveat — `repeat` loops:** Top-level variables are NOT re-evaluated on each iteration of a `repeat` loop. If a variable calls `states()` and you need it to reflect the *current* value each iteration, you must define a local `variables:` block inside the `repeat.sequence`. Otherwise you'll get the stale value from when the automation started.

```yaml
variables:
  target_person: !input person_entity
  person_name: "{{ state_attr(target_person, 'friendly_name') | default('someone') }}"

actions:
  # The wait_for_trigger can reference variables defined above
  - alias: "Wait for person to leave the zone"
    wait_for_trigger:
      - trigger: state
        entity_id: !input person_entity
        from: "home"
    timeout:
      minutes: 30
    continue_on_timeout: true

  # Trigger variables from the original trigger are also available
  - alias: "Log the original trigger"
    action: logbook.log
    data:
      name: "Automation"
      message: "Triggered by {{ trigger.to_state.state | default('unknown') }} for {{ person_name }}"
```

### 3.5 Action aliases (STRONGLY RECOMMENDED)
Every distinct step or phase in the action sequence SHOULD have an `alias:` field. Aliases are not required by HA for functionality — blueprints and automations work fine without them — but they are **strongly recommended** because they dramatically improve debugging. The `alias:` value is what shows up in HA's trace UI, making it the primary documentation for each step when something goes wrong.

**Why this matters so much:** Without aliases, traces show generic step types (`service`, `wait_for_trigger`, `choose`) with no context. Debugging a 15-step automation without aliases means clicking into every damn step to figure out what it does. With aliases, the trace reads like a story. This is especially critical for vibe-coded automations where the AI generated the logic — aliases are the breadcrumb trail.

> 📋 **QA Check CQ-1:** Every action step should have an `alias:` field for trace readability. See `09_qa_audit_checklist.md`.

**Aliases must describe both the *what* and the *why*.** A good alias makes YAML comments redundant — it's readable in the raw file AND in traces.

```yaml
actions:
  - alias: "Wait for entrance sensor — GPS alone isn't enough, need physical presence"
    wait_for_trigger:
      - trigger: state
        entity_id: !input entrance_sensor
        to: "on"
    timeout: !input entrance_timeout
    continue_on_timeout: true

  - alias: "Handle entrance timeout — clean up and bail if nobody showed"
    if:
      - condition: template
        value_template: "{{ not wait.completed }}"
    then:
      - stop: "Entrance sensor timed out — nobody detected."

  - alias: "Reset speakers — power-cycle to clear stale Bluetooth connections"
    action: switch.turn_off
    target: !input speaker_switches
```

**Rules:**
- Every action should get an `alias:`. Every `choose` branch, every `if/then`, every service call. The only acceptable omissions are trivially obvious one-liners in a simple automation (e.g., a single `light.turn_on`).
- Write aliases as `"What — why"` when the reason isn't obvious from the action itself.
- For simple, self-evident actions (e.g., `light.turn_on` targeting a variable called `welcome_lights`), a short alias like `"Turn on welcome lights"` is fine — don't force a reason when there isn't one.
- YAML comments (`#`) are **optional** — use them only when the alias alone can't convey complex reasoning (e.g., explaining a non-obvious template, documenting a workaround for a HA bug, or noting why a particular approach was chosen over an alternative).

### 3.6 Template safety (MANDATORY)
All templates MUST use `| default()` filters to handle unavailable/unknown entities gracefully.

**Basic pattern — always apply:**
```yaml
# ✅ Safe
"{{ states('sensor.temperature') | float(0) }}"
"{{ state_attr(entity, 'friendly_name') | default('unknown') }}"
"{{ states(person_entity) | default('unknown') }}"

# ❌ Broken — will fail or produce errors if entity is unavailable
"{{ states('sensor.temperature') | float }}"
"{{ state_attr(entity, 'friendly_name') }}"
```

**What broken templates actually look like at runtime:**

```yaml
# ❌ BROKEN — chained math without defaults
variables:
  volume_pct: "{{ (state_attr(speaker, 'volume_level') * 100) | int }}"
# When speaker is unavailable:
#   state_attr() returns None
#   None * 100 → TypeError: unsupported operand type(s)
#   Automation silently stops. No error in UI. Only visible in traces.
#   User sees: automation triggered but "nothing happened."

# ✅ FIXED
variables:
  volume_pct: "{{ (state_attr(speaker, 'volume_level') | float(0) * 100) | int }}"
```

```yaml
# ❌ BROKEN — list comprehension with unguarded states()
variables:
  active_players: >-
    {{ states.media_player
       | selectattr('state', 'eq', 'playing')
       | map(attribute='entity_id')
       | list }}
  first_player: "{{ active_players[0] }}"
# When no players are playing:
#   active_players = []
#   active_players[0] → IndexError
#   Trace shows: "Error: list index out of range"

# ✅ FIXED
variables:
  active_players: >-
    {{ states.media_player
       | selectattr('state', 'eq', 'playing')
       | map(attribute='entity_id')
       | list }}
  first_player: "{{ active_players[0] if active_players | count > 0 else 'none' }}"
```

```yaml
# ❌ BROKEN — variable scope stale in repeat loop
variables:
  current_temp: "{{ states('sensor.bedroom_temp') | float(0) }}"

actions:
  - repeat:
      while:
        - condition: template
          value_template: "{{ current_temp < 22 }}"
      sequence:
        - action: climate.set_temperature
          target: { entity_id: climate.bedroom }
          data: { temperature: 22 }
        - delay: { minutes: 5 }
# current_temp NEVER updates — it was resolved once at automation start.
# Loop runs forever (or until HA kills it). See §3.4 caveat.

# ✅ FIXED — re-read inside the loop
actions:
  - repeat:
      while:
        - condition: numeric_state
          entity_id: sensor.bedroom_temp
          below: 22
      sequence:
        - action: climate.set_temperature
          target: { entity_id: climate.bedroom }
          data: { temperature: 22 }
        - delay: { minutes: 5 }
```

**`| default()` vs no default — choosing deliberately:**

Not every value *should* have a fallback. For **required** blueprint inputs where silent failure is worse than a visible error, **omit the default** so the template fails loudly:

```yaml
# Optional value — graceful fallback is correct:
person_name: "{{ state_attr(person_entity, 'friendly_name') | default('someone') }}"

# Required value — fail loudly if missing (no | default):
agent_id: !input conversation_agent
# If the user didn't configure an agent, the action SHOULD fail with a clear error
# rather than silently passing an empty string to conversation.process.
```

The decision matrix: **optional inputs / runtime state** → use `| default(fallback)`. **Required inputs / user-configured values** → omit default so misconfiguration surfaces immediately. When in doubt, ask: "Would I rather this silently produces garbage, or loudly tells me something's wrong?" If the answer is "loudly" — skip the default.

**Rules:**
- Every `states()` call that feeds into math MUST have `| float(0)` or `| int(0)` with an explicit default.
- Every `state_attr()` call MUST have `| default(fallback_value)`.
- Every template condition should handle the `unavailable` and `unknown` states explicitly when they could affect logic.
- In `wait_for_trigger` templates, guard against the entity not existing at all.
- List operations (`[0]`, `| first`, `| last`) MUST guard against empty lists.
- Variables used in `repeat` loops that need current state MUST be re-read inside the loop (see §3.4 caveat) or use native conditions that HA re-evaluates each iteration.

### 3.7 YAML formatting
- 2-space indentation throughout.
- Use `>-` for multi-line strings that should fold into one line (templates, prompts).
- Use `>` for multi-line strings that should preserve paragraph breaks (descriptions).
- Use `|` only when literal newlines matter (shell commands, code blocks).
- No trailing whitespace.
- Blank line between each top-level action step.

**Multi-line string operators — the differences matter:**

```yaml
# >- folds lines into one, STRIPS final newline (use for templates/prompts)
prompt: >-
  You are a helpful assistant.
  The user's name is {{ person_name }}.
  Respond in one sentence.
# Result: "You are a helpful assistant. The user's name is Alice. Respond in one sentence."
# No trailing newline — clean for passing to APIs and conversation.process

# > folds lines into one, KEEPS final newline (use for descriptions)
description: >
  This automation turns on the porch light when
  someone arrives home after sunset.
# Result: "This automation turns on the porch light when someone arrives home after sunset.\n"
# Trailing newline — fine for display text, awkward in templates

# | preserves ALL newlines literally, KEEPS final newline (use for shell commands, code blocks)
command: |
  #!/bin/bash
  echo "Starting backup"
  rsync -av /config /backup/
# Result: "#!/bin/bash\necho \"Starting backup\"\nrsync -av /config /backup/\n"

# |- preserves ALL newlines literally, STRIPS final newline
# (use for multi-line templates where trailing newline breaks string comparisons)
value_template: |-
  {% set temp = states('sensor.temp') | float(0) %}
  {{ temp > 25 }}
# Result: "{% set temp = states('sensor.temp') | float(0) %}\n{{ temp > 25 }}"
# No trailing newline — critical when the result feeds into == comparisons or API payloads
```

**Rule of thumb:** Default to `>-` for single-paragraph templates and API call payloads. Use `|-` for multi-line Jinja that must preserve line breaks but NOT a trailing newline (template conditions, multi-line `value_template` blocks). Use `>` only for human-readable descriptions where a trailing newline is harmless. Use `|` when you explicitly need a trailing newline (shell scripts, heredocs).

### 3.8 HA 2024.10+ syntax (MANDATORY)
All blueprints MUST use the newer HA syntax introduced in 2024.10.0. This applies to both new blueprints and existing ones when they're next edited.

**Top-level keys — use plural form:**
```yaml
# ✅ CORRECT (2024.10+ syntax)
triggers:
  - alias: "Alexa volume changed"
    trigger: state
    ...

conditions:
  - condition: template
    ...

actions:
  - alias: "Sync volume"
    action: media_player.volume_set
    ...
```
```yaml
# ❌ OLD — do not use in new code
trigger:
  - platform: state
    ...

condition:
  - condition: template
    ...

action:
  - service: media_player.volume_set
    ...
```

**Inside trigger definitions — use `trigger:` keyword, not `platform:`:**
```yaml
# ✅ CORRECT
triggers:
  - alias: "Motion detected"
    trigger: state
    entity_id: !input motion_sensor
    to: "on"
```
```yaml
# ❌ OLD
trigger:
  - alias: "Motion detected"
    platform: state
    entity_id: !input motion_sensor
    to: "on"
```

**Inside action steps — use `action:` not `service:`:**
```yaml
# ✅ CORRECT
- alias: "Turn on lights"
  action: light.turn_on
  target:
    entity_id: "{{ target_light }}"
```
```yaml
# ❌ OLD
- alias: "Turn on lights"
  service: light.turn_on
  target:
    entity_id: "{{ target_light }}"
```

**Fleet note:** Older blueprints still using the legacy syntax are not broken — HA supports both. Update them to the new syntax when they're next touched for any reason. No need for a dedicated migration pass.

### 3.9 Minimal complete blueprint — copy-paste-ready reference
This skeleton includes every mandatory element from this guide. Copy it, replace the placeholders, and you've got a compliant starting point:

```yaml
blueprint:
  name: "My Blueprint — Short description"
  author: madalone
  description: >
    What this blueprint does, in 2–3 sentences.

    ### Recent changes
    - **v1:** Initial version
  domain: automation
  homeassistant:
    min_version: "2024.10.0"
  input:
    # ===========================================================================
    # ① CORE SETTINGS
    # ===========================================================================
    core_settings:
      name: "① Core settings"
      icon: mdi:cog
      description: Primary configuration.
      input:
        target_entity:
          name: Target entity
          description: The entity this automation acts on.
          selector:
            entity:
              domain: light

    # ===========================================================================
    # ② TIMING
    # ===========================================================================
    timing:
      name: "② Timing"
      icon: mdi:clock-outline
      description: Timeout and delay settings.
      input:
        wait_timeout:
          name: Wait timeout
          description: How long to wait before giving up (seconds).
          default: 30
          selector:
            number:
              min: 5
              max: 300
              unit_of_measurement: seconds

variables:
  target_entity: !input target_entity
  wait_timeout: !input wait_timeout

triggers:
  - alias: "Example trigger — entity turns on"
    trigger: state
    entity_id: !input target_entity
    to: "on"

conditions: []

actions:
  - alias: "Wait for entity to turn off"
    wait_for_trigger:
      - trigger: state
        entity_id: !input target_entity
        to: "off"
    timeout:
      seconds: "{{ wait_timeout }}"
    continue_on_timeout: true

  - alias: "Handle timeout — clean up if wait expired"
    if:
      - condition: template
        value_template: "{{ not wait.completed }}"
    then:
      - alias: "Log timeout"
        action: logbook.log
        data:
          name: "My Blueprint"
          message: "Wait timed out for {{ target_entity }}"
```

---

## 4. SCRIPT STANDARDS

### 4.1 Required fields
Every **standalone script** (created via UI or YAML) MUST include:
- `alias`: Human-readable name
- `description`: What the script does and why it exists
- `icon`: Appropriate `mdi:` icon

> **⚠️ Blueprint exception:** The `icon:` field is NOT valid inside the `blueprint:` schema block. HA will reject it with `extra keys not allowed @ data['blueprint']['icon']`. Script blueprints cannot set an icon — the icon is only available on the **instances** created from the blueprint, not the blueprint definition itself. Do not add `icon:` to the `blueprint:` header.

### 4.2 Inline explanations
Script sequences follow the same alias rules as blueprint actions (see §3.5). Every step gets a descriptive `alias:` that covers the what and why. YAML comments are optional — use them only when the alias can't carry the full explanation.

### 4.3 Changelog in description
For scripts that are actively developed (not simple one-liners), include the last 3 changes in the `description` field, same format as blueprints.
