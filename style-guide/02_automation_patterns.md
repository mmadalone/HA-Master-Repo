# Home Assistant Style Guide — Automation Patterns

Section 5 — Error handling, modes, timeouts, triggers, GPS bounce, helpers, area/label targeting.

---

## 5. AUTOMATION PATTERNS

### 5.1 Error handling — timeouts (MANDATORY)
Every `wait_for_trigger` MUST use `continue_on_timeout: true` with an explicit failure handler:

```yaml
- alias: "Wait for motion sensor"
  wait_for_trigger:
    - trigger: state
      entity_id: !input some_sensor
      to: "on"
  timeout: !input some_timeout
  continue_on_timeout: true

- alias: "Handle motion timeout"
  if:
    - condition: template
      value_template: "{{ not wait.completed }}"
  then:
    # Clean up any state that was set before this point
    - alias: "Cleanup — turn off temporary switches"
      action: switch.turn_off
      target: !input temporary_switches
    - stop: "Motion sensor timed out — cleaning up."
```

**Default to `continue_on_timeout: true`** for most automations. Always set it explicitly — never rely on HA's implicit default — so intent is clear in generated code.

**Exception — safety-critical waits:** For waits where timeout means "something went wrong" and continuing would be dangerous (e.g., verifying a garage door actually closed, confirming a lock engaged, checking that a heater turned off), use `continue_on_timeout: false` and pair it with a separate alert mechanism:

```yaml
# Safety-critical: garage door MUST close before we continue
- alias: "Wait for garage door to close — SAFETY CRITICAL"
  wait_for_trigger:
    - trigger: state
      entity_id: !input garage_door
      to: "closed"
  timeout: { minutes: 2 }
  continue_on_timeout: false  # Deliberately abort if door didn't close

# This only runs if the wait completed successfully.
# If it timed out, the automation stops HERE and the actions below never execute.
# Add a SEPARATE automation to alert on timeout if needed.
```

The distinction: **non-critical flows** (lights, music, welcome messages) → `true` + cleanup handler. **Safety-critical flows** (locks, garage doors, heaters, security) → `false` is acceptable when continuing would be worse than aborting.

**Critical: `wait_for_trigger` vs `wait_template` semantics**

These two are NOT interchangeable. The difference matters when refactoring:

- **`wait_for_trigger`** waits for a state **change** (transition). If the entity is *already* in the target state when the wait starts, it will NOT fire — it's waiting for a *transition to* that state, not the state itself.
- **`wait_template`** evaluates **immediately** and returns right away if the condition is already true. It only waits if the condition is currently false.

**This breaks naïve refactoring.** If you replace `wait_template` with `wait_for_trigger` without checking, your automation will hang forever when the state is already true.

**What this looks like when it breaks:**

```yaml
# ❌ BROKEN — refactored from wait_template to wait_for_trigger without thinking
# Original code used: wait_template: "{{ is_state('binary_sensor.door', 'on') }}"
# Developer "improved" it to:
- alias: "Wait for door to open"
  wait_for_trigger:
    - trigger: state
      entity_id: binary_sensor.front_door
      to: "on"
  timeout: { minutes: 10 }
  continue_on_timeout: true

# What happens: Door is ALREADY open when automation reaches this step.
# wait_for_trigger waits for a TRANSITION to "on" — but it's already "on".
# Automation hangs for 10 minutes, then hits timeout, then runs cleanup path.
# User sees: "I opened the door 5 minutes ago and the lights never came on!"
# Trace shows: wait_for_trigger timed out (wait.completed = false)
```

**Safe pattern when you need wait_for_trigger but the state might already be correct:**

```yaml
# 1) Check if already in target state — skip the wait entirely
- alias: "Check if door is already open"
  if:
    - condition: state
      entity_id: !input door_sensor
      state: "on"
  then:
    # Already open — skip straight to next step
    - alias: "Door already open — continue"
      action: logbook.log
      data:
        name: "Automation"
        message: "Door was already open, skipping wait."
  else:
    # Not open yet — wait for the transition
    - alias: "Wait for door to open"
      wait_for_trigger:
        - trigger: state
          entity_id: !input door_sensor
          to: "on"
      timeout: !input door_timeout
      continue_on_timeout: true

    - alias: "Handle door timeout"
      if:
        - condition: template
          value_template: "{{ not wait.completed }}"
      then:
        - stop: "Door never opened — aborting."
```

**When to use which:**
- `wait_for_trigger`: When you specifically need to wait for a *change* (motion sensor going ON, person arriving).
- `wait_template`: When you need to wait for a *condition to become true* and it might already be true (temperature above threshold, device available).

> 📋 **QA Check AIR-1:** Replace vague guidance ("use good judgment") with concrete thresholds and ranges. See `09_qa_audit_checklist.md`.

> 📋 **QA Check CQ-7:** Every Jinja2 template must handle missing/unavailable entities — guard `states()` with `| default()` and check for `unavailable`/`unknown`. See `09_qa_audit_checklist.md`.

### 5.2 Error handling — non-critical action failures
For actions that might fail but shouldn't kill the entire automation (notifications to flaky services, TTS to a speaker that might be offline, API calls to external services), use `continue_on_error: true`:

```yaml
- alias: "Send notification (non-critical)"
  continue_on_error: true
  action: notify.mobile_app
  data:
    message: "{{ person_name }} arrived home."

- alias: "This still runs even if notification failed"
  action: light.turn_on
  target: !input welcome_lights
```

**Rules:**
- Only use `continue_on_error` on genuinely non-critical steps. If the action is part of the core flow, let it fail loudly.
- When using `continue_on_error`, consider adding a fallback or logging mechanism so failures don't go completely unnoticed.
- **Never** blanket-apply `continue_on_error: true` to everything — that masks real bugs.

### 5.3 Cleanup on failure
If the automation turns on temporary switches, sets helpers, or creates any transient state:
- Every failure path (timeout, error, unexpected condition) MUST clean up that state before stopping.
- Consider a separate failsafe automation that cleans up after a maximum duration, as a safety net for crashes.

> 📋 **QA Check CQ-3:** Stateful operations need cleanup on all failure paths — restore mechanisms are mandatory. See `09_qa_audit_checklist.md`.

### 5.4 Mode selection (deep dive)

**Mode selection table:**

| Scenario | Mode | Reason |
|----------|------|--------|
| Arrival / departure | `restart` | New trigger should replace in-progress run |
| Motion light with timeout | `restart` | Re-trigger must reset the timer |
| Bedtime / conversation flows | `single` | Use lock helpers to prevent overlap |
| Notification / alert | `parallel` | Multiple instances are fine |
| Sequential processing (door locks) | `queued` | Events should process in order |
| Debounced sensor reaction | `single` or `queued` | Depends on whether events should stack |

**Critical mode behaviors that affect your automation logic:**

1. **Mode applies to the entire automation, not per-trigger.** You cannot have one trigger run in `single` mode and another in `parallel`. If you need different concurrency behavior for different triggers, split into separate automations.

2. **`single` mode** (default): If the automation is already running, new triggers are silently dropped. The trigger event is lost — it does NOT queue up.

3. **`restart` mode**: A new trigger *interrupts* the current run. However, HA evaluates the automation's **conditions** before interrupting — if conditions fail, the current run continues undisturbed and the new trigger is discarded.

4. **`queued` mode**: Triggers queue up and execute in order. **Important:** Conditions are evaluated at **trigger time** (when the event enters the queue), NOT at execution time (when the queued run starts). This means a condition might pass when queued but the world may have changed by the time it actually runs. Default `max` is 10.

5. **`parallel` mode**: Multiple instances run simultaneously. Default `max` is 10. Be extremely careful with shared state — two parallel runs can race each other when reading/writing helpers.

6. **`max` and `max_exceeded`**: For `queued` and `parallel` modes, you can set `max:` to limit concurrent/queued runs. When exceeded, the behavior depends on `max_exceeded:` which defaults to `warning` (logs a warning). Set to `silent` to drop silently, or to any valid log severity level: `debug`, `info`, `warning` (default), `error`, `critical`.

```yaml
mode: queued
max: 5
max_exceeded: silent  # Don't log warnings for busy automations
```

**Concurrency pitfalls:**
- Two automations that both read-then-write the same helper can race each other even in `single` mode (they're separate automations). Use an `input_boolean` as a lock if this matters.
- `restart` mode does NOT guarantee cleanup of the interrupted run. If your automation sets state in step 1 and cleans up in step 10, a restart at step 5 leaves dirty state. Design your automations so early steps are idempotent or use a failsafe cleanup.

### 5.5 GPS bounce / re-trigger protection

**First line of defense: zone radius.** Before adding code-level bounce protection, configure your Home zone radius in Settings → Areas & Zones → Home. A larger radius (e.g., 200–300m instead of the default 100m) absorbs most GPS jitter naturally. Only add the template-based cooldown below when zone radius alone isn't enough — for example, when your device tracker switches between GPS and Wi-Fi location sources, causing jumps that exceed the zone radius.

Any automation triggered by `person` state changes (home/not_home) MUST include a cooldown condition:

```yaml
conditions:
  - condition: template
    value_template: >-
      {{ (now() - (this.attributes.last_triggered
         | default(as_datetime('2000-01-01'), true)))
         .total_seconds() > cooldown_seconds }}
```

Expose the cooldown duration as a blueprint input with a sensible default (e.g., 900 seconds).

**Why a template here (per §1.4):** There is no native condition for "time since last triggered." The `this.attributes.last_triggered` context variable and the elapsed-time math have no built-in equivalent. This is a legitimate template use case — document it if someone flags it as inconsistent with the native-first rule.

**Scope warning:** The `this` variable is only available inside automation triggers and conditions. It is NOT available in scripts called by automations. If you extract this cooldown pattern into a standalone script, `this` will be undefined and the template will silently evaluate incorrectly. Keep cooldown logic in the automation itself.

> 📋 **QA Check ZONE-1:** GPS bounce protection requires zone radius guidance and manual protection patterns. See `09_qa_audit_checklist.md`.

### 5.6 Trigger IDs + Choose pattern
When an automation has multiple triggers that should lead to different actions, assign `id:` to each trigger and use `choose` with `trigger.id` conditions:

```yaml
triggers:
  - trigger: state
    entity_id: !input motion_sensor
    to: "on"
    id: motion_detected

  - trigger: state
    entity_id: !input motion_sensor
    to: "off"
    for: !input no_motion_delay
    id: motion_cleared

  - trigger: time
    at: !input off_time
    id: scheduled_off

actions:
  - alias: "Route action by trigger"
    choose:
      - alias: "Motion detected — turn on lights"
        conditions:
          - condition: trigger
            id: motion_detected
        sequence:
          - alias: "Turn on lights"
            action: light.turn_on
            target: !input target_lights

      - alias: "Motion cleared — turn off lights"
        conditions:
          - condition: trigger
            id:
              - motion_cleared
              - scheduled_off
        sequence:
          - alias: "Turn off lights"
            action: light.turn_off
            target: !input target_lights
```

**Rules:**
- Every trigger in a multi-trigger automation MUST have an `id:` field.
- Use descriptive IDs: `motion_detected`, `door_opened`, `scheduled_off` — not `trigger_1`, `trigger_2`.
- Use `choose` (not `if/then/elif`) when routing between 3+ trigger paths — it's more readable in traces.
- Multiple trigger IDs can match the same `choose` branch using a list: `id: [motion_cleared, scheduled_off]`.

> 📋 **QA Check PERF-1:** Flag `platform: state` without `entity_id:` and `time_pattern` with intervals under 5 seconds — both cause unnecessary event bus load. See `09_qa_audit_checklist.md`.

### 5.7 Order of operations
When an automation involves both waiting for conditions and preparing devices:
1. Wait for the triggering condition first (e.g., sensor detection)
2. THEN prepare devices (e.g., reset speakers)
3. Don't prepare devices before confirming the trigger — it disrupts things unnecessarily if the trigger never fires.

### 5.8 Debugging: stored traces
During development of complex automations, increase the stored trace count beyond the default of 5:

```yaml
trace:
  stored_traces: 20
```

Add this at the automation level. This gives more history to debug intermittent issues. Consider reducing back to 5-10 for production once the automation is stable, to save resources.

### 5.9 Area, floor, and label targeting
Since HA 2024.4+, actions support **area**, **floor**, **label**, and **device_id** targets directly. Prefer area/floor/label over explicit entity lists when controlling groups of devices — they automatically include new devices added to an area without updating the automation. Use `device_id` when you need to target all entities belonging to a specific device (e.g., a multi-sensor) without hardcoding individual entity IDs.

**Area targeting — control all entities of a domain in a room:**

```yaml
# Turn off all lights in the living room — includes any future lights added
- alias: "Turn off living room lights"
  action: light.turn_off
  target:
    area_id: living_room

# Target multiple areas at once
- alias: "Turn off all downstairs lights"
  action: light.turn_off
  target:
    area_id:
      - living_room
      - kitchen
      - hallway
```

**Floor targeting — control an entire floor:**

```yaml
# Turn off everything on the ground floor
- alias: "Ground floor lights off"
  action: light.turn_off
  target:
    floor_id: ground_floor
```

**Label targeting — cross-domain device groups:**

Labels are the most powerful grouping tool. They work across domains and areas, letting you create logical groups like "all entertainment devices", "high power consumers", or "bedtime shutdown devices":

```yaml
# Turn off everything labeled "bedtime_off" — could be lights, switches, media
- alias: "Bedtime — shut down labeled devices"
  action: homeassistant.turn_off
  target:
    label_id: bedtime_off

# Target multiple labels
- alias: "Party mode — activate entertainment"
  action: homeassistant.turn_on
  target:
    label_id:
      - entertainment
      - mood_lighting
```

**When to use which:**
- **Entity list**: When you need specific entities and the list is small and stable.
- **Area**: When you want "all lights in the kitchen" behavior that auto-includes new devices.
- **Floor**: When you want to control an entire level of the house.
- **Label**: When you need a logical group that crosses area/domain boundaries (e.g., "bedtime_off" includes lights, TV, speakers across multiple rooms).

**Blueprint inputs for area/label targeting:**

```yaml
target_area:
  name: Target area
  description: Which room to control. All matching devices in this area will be affected.
  selector:
    area: {}

target_labels:
  name: Shutdown labels
  description: >
    Labels applied to devices that should be turned off.
    All entities with any of these labels will be targeted.
  selector:
    label:
      multiple: true
```

**Best practice:** When building automations that control "a group of devices", default to area or label targeting over entity lists. Add new devices to the appropriate area/label in HA — the automation picks them up automatically with zero config changes.

> 📋 **QA Check CQ-9:** Actions targeting entities from blueprint inputs or network-dependent services must include availability guards before use. See `09_qa_audit_checklist.md`.

**`expand()` for template-based area/label operations:**

When you need to iterate over entities in an area or with a label inside a template (e.g., counting, filtering, conditional logic), use the `expand()` function:

```yaml
# Count how many lights are on in the living room
variables:
  lights_on_count: >-
    {{ expand(area_entities('living_room'))
       | selectattr('domain', 'eq', 'light')
       | selectattr('state', 'eq', 'on')
       | list | count }}

# Get all media players with a specific label that are currently playing
variables:
  active_speakers: >-
    {{ expand(label_entities('music_zone'))
       | selectattr('domain', 'eq', 'media_player')
       | selectattr('state', 'eq', 'playing')
       | map(attribute='entity_id')
       | list }}
```

`expand()` resolves entity IDs, groups, areas, and labels into full state objects you can filter with Jinja. It's the template-side equivalent of area/label targeting in actions.

### 5.10 Helper selection decision matrix
Before creating a template sensor, check if a built-in helper or integration does the job. Template sensors are harder to debug, don't validate at load time, and require more maintenance.

**Use this decision matrix:**

| You need... | Use this | NOT a template for... |
|---|---|---|
| Average/min/max/sum of multiple sensors | `min_max` integration (`ha_create_config_entry_helper` type `min_max`) | Averaging temperature sensors, finding highest humidity |
| Any-on / all-on binary logic | `group` helper (binary sensor group) | "Are any windows open?", "Are all doors locked?" |
| Rate of change (per time unit) | `derivative` integration | "How fast is temperature rising?", "Power draw trend" |
| Threshold crossing with hysteresis | `threshold` integration | "Is temperature too high?" with separate on/off points to avoid flapping |
| Consumption tracking with tariffs | `utility_meter` helper | Daily/monthly energy, water, gas usage with peak/off-peak |
| Weekly on/off schedule | `schedule` helper | "Is it work hours?", "Is it quiet time?" |
| Counting events | `counter` helper | Door open count, motion trigger count |
| Trend detection (rising/falling) | `trend` integration | "Is temperature trending up over the last hour?" |
| Numeric filtering (low-pass, outlier) | `filter` integration | Smoothing noisy sensor readings |
| Statistical analysis (mean over time) | `statistics` integration | "Average temperature over last 24 hours" |

**When a template sensor IS the right choice:**
- Complex conditional logic that combines multiple different types of data.
- String formatting or text generation (e.g., "3 lights are on in the kitchen").
- Calculations involving attributes from multiple unrelated entities.
- Custom state representations not covered by any built-in helper.

**Rule of thumb:** If the built-in helper can do 80% of what you need, use it. If you need the last 20%, create the template sensor but document why the built-in wasn't sufficient.

### 5.11 Purpose-specific triggers (HA 2025.12+ Labs)

> ⚠️ **AI CODE GENERATION RULE:** Do NOT use purpose-specific triggers in generated code unless the user explicitly requests Labs/experimental features. Always default to standard `trigger: state` / `trigger: numeric_state` patterns. These triggers require manual opt-in via Settings → System → Labs and will fail silently on instances that haven't enabled them.

HA 2025.12 introduced **domain-specific semantic triggers** as an experimental Labs feature. These replace verbose state/numeric_state patterns with intent-based triggers.

> ⚠️ **AI CODE GEN NOTE:** The YAML examples below are **illustrative of the concept**, based on the UI automation editor's behavior. The exact YAML serialization for all trigger types is still evolving as new domains are added (2026.1 added button, climate, device_tracker triggers; 2026.2 added calendar, person, vacuum triggers and the first purpose-specific conditions). Do NOT generate these in blueprints — they are primarily a UI-editor feature.

```yaml
# Instead of this:
triggers:
  - trigger: state
    entity_id: binary_sensor.kitchen_motion
    to: "on"

# The UI editor now lets you pick (2025.12+ Labs, illustrative YAML):
triggers:
  - trigger: light.turned_on
    area_id: kitchen

# Instead of this:
triggers:
  - trigger: numeric_state
    entity_id: climate.living_room
    attribute: hvac_action
    to: "heating"

# The UI editor now lets you pick (illustrative YAML):
triggers:
  - trigger: climate.started_heating
    area_id: living_room
```

**Key benefits:**
- Support area/floor/label targeting directly in the trigger (no entity_id needed).
- More readable — intent is clear from the trigger type.
- Target-first workflow: pick an area, then HA suggests relevant triggers.

**Current status (as of HA 2026.2, February 2026):** Purpose-specific triggers remain a **Labs** feature — opt-in via Settings → System → Labs. The domain coverage has expanded steadily: 2025.12 introduced the first batch (light, cover, lock, motion/occupancy, and numeric state semantic triggers), 2026.1 added button press, climate mode, and device_tracker triggers, and 2026.2 brought calendar event (start/end), person presence (arrives home/leaves), vacuum docking, and media player state triggers — plus the first **purpose-specific conditions** (checking entity states using the same semantic language). When writing new automations, consider noting this as a future simplification opportunity in comments, but **don't use Labs features in production blueprints shared with others** unless `min_version` is set and the feature has graduated from Labs.

### 5.12 Idempotency — every action safe to run twice

Automations get re-triggered, restarted, and re-run constantly — GPS bounces, sensor flaps, mode restarts, HA reboots mid-execution, users manually triggering for testing. **Every action in your automation should be safe to execute twice in a row without unintended side effects.**

**Idempotent (safe to repeat):**
- `light.turn_on` / `light.turn_off` — already on? Stays on. No harm.
- `input_boolean.turn_on` — already on? No change.
- `climate.set_temperature` with explicit value — sets to 22°C again? Fine.
- `media_player.volume_set` with explicit level — sets to 0.5 again? Fine.

**NOT idempotent (dangerous to repeat):**
- `input_boolean.toggle` — run twice and you're back where you started. Always use explicit `turn_on` / `turn_off`.
- `counter.increment` — double-count if re-triggered.
- `input_number.set_value` with `{{ current + 5 }}` — increments twice on re-trigger.
- `notify.send_message` — user gets duplicate notifications.
- `script.turn_on` for scripts with side effects — may queue or double-execute depending on script mode.

**Rules:**
- **Prefer explicit state-setting over toggling.** Use `turn_on` / `turn_off`, not `toggle`. Use `input_number.set_value` with an absolute value, not relative math.
- **Guard non-idempotent actions with state checks:**
  ```yaml
  # ❌ Non-idempotent — double-sends on restart
  - action: notify.mobile_app
    data: { message: "Welcome home!" }

  # ✅ Idempotent — only sends if we haven't already
  - if:
      - condition: state
        entity_id: input_boolean.welcome_sent
        state: "off"
    then:
      - action: notify.mobile_app
        data: { message: "Welcome home!" }
      - action: input_boolean.turn_on
        target: { entity_id: input_boolean.welcome_sent }
  ```
- **For `restart` mode automations**, assume every action before a `wait_for_trigger` will execute again on re-trigger. Design accordingly.
- When reviewing existing code, flag any `toggle`, `increment`, or relative `set_value` as potential idempotency issues.

**Idempotency test — the "run twice" check:**
After generating any automation, mentally (or actually) run it twice in quick succession. The second run should be a no-op — no duplicate notifications, no double-toggled states, no incremented counters. If the second run produces a different outcome than the first, you have an idempotency bug. Fix it before shipping.

```
Test procedure:
1. Set all helpers/entities to their initial state.
2. Trigger the automation. Note the end state.
3. Without resetting anything, trigger it again immediately.
4. ✅ PASS: End state is identical to step 2. No extra side effects.
5. ❌ FAIL: Something changed — find the non-idempotent action and guard it.
```

> 📋 **QA Check CQ-8:** Flag any use of `toggle`, `increment`, or `decrement` without explicit justification — automations must be safe to fire twice in rapid succession. See `09_qa_audit_checklist.md`.
