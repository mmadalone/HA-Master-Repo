# Home Assistant Style Guide — Blueprint Patterns

Sections 3 and 4 — Blueprint YAML structure, inputs, variables, templates, and script standards.

---

## 3. BLUEPRINT STRUCTURE & YAML FORMATTING

### 3.1 Blueprint header and description image
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
    - **v4:** <most recent change>
    - **v3:** <previous change>
    - **v2:** <earlier change>
    - **v1:** Initial version'
  domain: automation
  homeassistant:
    min_version: <minimum HA version — REQUIRED if using newer features>
  input:
    ...
```

**Header fields:**
- `author:` — Always include. Even for personal blueprints, it identifies ownership.
- `source_url:` — Include if the blueprint lives on GitHub or will be shared. This enables one-click reimport/update in the HA UI. Omit for strictly private blueprints.
- `min_version:` — **Required** when using features from a specific HA version. Always verify which version introduced the features you use.

**Key `min_version` thresholds:**

| Version | Feature introduced |
|---|---|
| `2024.1.0` | `action:` syntax (replacing deprecated `service:`) |
| `2024.2.0` | `trigger:` keyword (replacing `platform:` at top level of trigger lists) |
| `2024.4.0` | Labels and categories for automations, scripts, entities |
| `2024.6.0` | Collapsible input sections in blueprints |
| `2025.12.0` | Semantic/purpose-specific triggers (Labs — see §5.11) |

**Image rule:** Every blueprint MUST have an image in its description. When creating or updating a blueprint, ask the user if they want to provide an image. If they don't have one, search for a relevant, freely usable image that fits the blueprint's purpose.

**Recent changes:** The blueprint description MUST include the last 4 version changes (or fewer if the blueprint has fewer versions). This gives users a quick changelog right in the HA UI.

### 3.2 Collapsible input sections (MANDATORY)
All blueprint inputs MUST be organized into collapsible sections grouped by **stage/phase of the automation flow**. Use the nested `input:` pattern:

```yaml
input:
  # Top-level inputs that don't belong to a stage (rare — e.g. person entity)
  person_entity:
    name: Person
    ...

  stage_1_detection:
    name: "Stage 1 — Detection & triggers"
    icon: mdi:motion-sensor
    description: Configure how arrival/presence is detected.
    input:
      entrance_sensor:
        name: Entrance occupancy sensor
        ...
      entrance_wait_timeout:
        name: Entrance wait timeout
        ...

  stage_2_preparation:
    name: "Stage 2 — Device preparation"
    icon: mdi:cog
    description: Devices to reset or prepare before the main flow.
    input:
      reset_switches:
        name: Reset switches
        ...

  stage_3_conversation:
    name: "Stage 3 — AI conversation"
    icon: mdi:robot
    description: Conversation agent and satellite settings.
    input:
      conversation_agent:
        name: Conversation agent
        ...

  stage_4_cleanup:
    name: "Stage 4 — Cleanup & timing"
    icon: mdi:broom
    description: Post-flow cleanup and cooldown settings.
    input:
      post_conversation_delay:
        name: Post-conversation delay
        ...
```

**Rules for sections:**
- Section names follow the pattern: `"Stage N — <Phase name>"`
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

action:
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

### 3.5 Action aliases (MANDATORY)
Every distinct step or phase in the action sequence MUST have an `alias:` field. This is what shows up in HA's trace UI and is the primary documentation for each step.

**Aliases must describe both the *what* and the *why*.** A good alias makes YAML comments redundant — it's readable in the raw file AND in traces.

```yaml
action:
  - alias: "Wait for entrance sensor — GPS alone isn't enough, need physical presence"
    wait_for_trigger:
      - platform: state
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
- Every action gets an `alias:` — no exceptions. Every `choose` branch, every `if/then`, every service call.
- Write aliases as `"What — why"` when the reason isn't obvious from the action itself.
- For simple, self-evident actions (e.g., `light.turn_on` targeting a variable called `welcome_lights`), a short alias like `"Turn on welcome lights"` is fine — don't force a reason when there isn't one.
- YAML comments (`#`) are **optional** — use them only when the alias alone can't convey complex reasoning (e.g., explaining a non-obvious template, documenting a workaround for a HA bug, or noting why a particular approach was chosen over an alternative).

### 3.6 Template safety (MANDATORY)
All templates MUST use `| default()` filters to handle unavailable/unknown entities gracefully:

```yaml
# GOOD — safe against unavailable entities
"{{ states('sensor.temperature') | float(0) }}"
"{{ state_attr(entity, 'friendly_name') | default('unknown') }}"
"{{ states(person_entity) | default('unknown') }}"

# BAD — will fail or produce errors if entity is unavailable
"{{ states('sensor.temperature') | float }}"
"{{ state_attr(entity, 'friendly_name') }}"
```

**Rules:**
- Every `states()` call that feeds into math MUST have `| float(0)` or `| int(0)` with an explicit default.
- Every `state_attr()` call MUST have `| default(fallback_value)`.
- Every template condition should handle the `unavailable` and `unknown` states explicitly when they could affect logic.
- In `wait_for_trigger` templates, guard against the entity not existing at all.

### 3.7 YAML formatting
- 2-space indentation throughout.
- Use `>-` for multi-line strings that should fold into one line (templates, prompts).
- Use `>` for multi-line strings that should preserve paragraph breaks (descriptions).
- Use `|` only when literal newlines matter (shell commands, code blocks).
- No trailing whitespace.
- Blank line between each top-level action step.

---

## 4. SCRIPT STANDARDS

### 4.1 Required fields
Every script MUST include:
- `alias`: Human-readable name
- `description`: What the script does and why it exists
- `icon`: Appropriate `mdi:` icon

### 4.2 Inline explanations
Script sequences follow the same alias rules as blueprint actions (see §3.5). Every step gets a descriptive `alias:` that covers the what and why. YAML comments are optional — use them only when the alias can't carry the full explanation.

### 4.3 Changelog in description
For scripts that are actively developed (not simple one-liners), include the last 4 changes in the `description` field, same format as blueprints.
