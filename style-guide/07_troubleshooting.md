# Home Assistant Style Guide — Troubleshooting & Debugging

Section 13 — Trace reading, Developer Tools, common failure modes, log analysis, and domain-specific debugging.

---

## 13. TROUBLESHOOTING & DEBUGGING

### 13.1 Automation traces — your first stop

Traces are the single most useful debugging tool in HA. Every automation run records a step-by-step execution trace showing exactly what happened, what values were evaluated, and where things went wrong.

**Accessing traces:**
- Settings → Automations → click the automation → Traces (top-right clock icon)
- Or: Developer Tools → States → find the automation entity → check `last_triggered`

**What each trace node tells you:**

| Node color | Meaning |
|---|---|
| **Green** | Step executed successfully |
| **Gray** | Step was skipped (condition failed, `choose` branch not taken) |
| **Red** | Step threw an error |
| **No node at all** | Execution never reached this step — something above it stopped the run |

**Reading a trace effectively:**

1. **Start at the trigger node.** Verify it fired for the reason you expected. Click it to see `trigger.to_state`, `trigger.from_state`, and any `trigger.id`. If the trigger data looks wrong, the problem is upstream of your automation.

2. **Check the condition node.** If it's gray, your conditions blocked the run. Click it to see each individual condition's result — HA shows `true`/`false` per condition. This is where 90% of "my automation never runs" issues die.

3. **Walk the action nodes in order.** Each green node shows the data it was called with — expand it to verify entity IDs, action data, and template evaluations resolved correctly. If a node is green but the result wasn't what you expected, the action succeeded but your *data* was wrong.

4. **Check `choose`/`if` branches.** The trace shows which branch was taken (green) and which were skipped (gray). If the wrong branch fires, click the condition node on each branch to see why.

5. **Look at the `changed_variables` section** at the top of the trace. This shows every variable and its resolved value at the start of the run — invaluable for catching template evaluation issues.

**Increasing trace history:**

The default is 5 stored traces. During active development, bump it up per automation:

```yaml
automation:
  - alias: "My automation"
    trace:
      stored_traces: 20
    triggers:
      # ...
```

> **Note:** `stored_traces` is configured *inside* each automation definition, not as a standalone top-level block. There is no global setting — each automation must be configured individually.

Reduce back to 5–10 once stable. Each trace consumes memory, and HA doesn't persist them across restarts.

### 13.2 Quick tests from the automation editor

Before diving into traces or Developer Tools, use the built-in testing features in the automation editor itself:

**Run Actions button (three-dot menu → Run actions):**
Executes all actions in the automation, **skipping all triggers and conditions**. Useful for verifying your action sequence works in isolation. Note: automations that depend on `trigger.id`, trigger variables, or data from previous `choose` branches won't work correctly this way — those values are undefined during a manual run.

**Per-step testing (visual editor only):**
In the automation editor UI, each individual condition and action has its own three-dot menu with a test option:
- **Testing a condition** highlights it green (passed) or red (failed) based on current HA state — invaluable for catching logic errors without triggering the full automation.
- **Testing an action** executes just that single action step.
- For compound conditions (e.g., `and` blocks), you can test the whole block or drill into individual sub-conditions.

**Automation: Trigger via Developer Tools:**
Developer Tools → Actions → search for "Automation: Trigger" → pick your automation. This method lets you choose whether to **skip or evaluate conditions**, giving you more control than the editor's "Run Actions" button. You can also pass additional trigger data in YAML mode for testing specific trigger scenarios.

### 13.3 Developer Tools patterns

**States tab — check entity values before assuming:**

Before debugging an automation, verify the entities it depends on are in the state you think they're in. Common surprises:
- Entity shows `unavailable` (device offline, integration error)
- Entity shows `unknown` (just restarted, integration hasn't polled yet)
- Attribute you're reading doesn't exist on that entity (wrong entity type)
- State value is a string `"25.3"`, not a number — your template needs `| float`

**Pro move:** Filter by typing the entity ID prefix. `binary_sensor.motion` shows all motion sensors instantly.

**Actions tab — test actions in isolation:**

Before embedding an action in an automation, test it here first:
1. Pick the action (e.g., `light.turn_on`)
2. Fill in the target and data
3. Click "Perform action"
4. Check if the device actually responded

This eliminates the "is my automation wrong or is the device not responding?" question in one step.

> **Terminology note (HA 2024.8+):** The Developer Tools tab formerly called "Services" is now called "Actions." The YAML key `service:` was replaced by `action:`. Old `service:` syntax still works but all new code should use `action:`.

**Template tab — the Jinja2 playground:**

Test any template expression live against your current HA state:

```jinja2
{# Paste this in the Template editor to debug #}
Entity state: {{ states('sensor.temperature') }}
As float: {{ states('sensor.temperature') | float(0) }}
Attribute: {{ state_attr('light.workshop', 'brightness') | default('no brightness attr') }}
Last triggered: {{ states.automation.coming_home.attributes.last_triggered | default('never') }}
Time since: {{ (now() - states.automation.coming_home.attributes.last_triggered | default(now(), true)).total_seconds() }}
```

The right pane updates in real time as you type. Use this to verify every template expression before putting it in a blueprint.

**Events tab — watch triggers fire in real time:**

1. Subscribe to `state_changed` and filter by your entity to watch state transitions.
2. Subscribe to `call_service` to see what actions are being called and by whom.
3. Subscribe to `automation_triggered` to see which automations are firing and why.

This is essential for debugging "the automation triggers too often" or "something keeps turning my lights on" problems.

### 13.4 The "why didn't my automation trigger?" flowchart

Work through this in order. Stop at the first failure — that's your bug.

**Step 1 — Is the automation enabled?**
- Settings → Automations → check the toggle. Disabled automations don't trigger.
- Also check: `Developer Tools → States → automation.your_automation` — state should be `on`.

**Step 2 — Did the trigger event actually happen?**
- Check the entity's state history (click the entity → History).
- For state triggers: did the entity actually transition from → to the states you specified?
- For `for:` duration triggers: did the entity stay in that state for the full duration without bouncing?
- For time triggers: is HA's timezone correct? (Settings → General → Time Zone)

**Step 3 — Did conditions block the run?**
- Look at the automation's trace. If there's a trace with a gray condition node, conditions blocked it.
- Click the condition node to see which specific condition returned `false`.
- Common traps:
  - `condition: state` comparing against `"on"` (string) when the state is `"On"` or `"ON"` (case sensitive).
  - `condition: numeric_state` when the entity is `unavailable` — numeric conditions fail on non-numeric states.
  - `condition: time` with `before`/`after` that crosses midnight (use two conditions OR a template).
  - GPS bounce cooldown (§5.5) blocking a legitimate trigger because the last one was too recent.

**Step 4 — Is the automation in `single` mode and already running?**
- If `mode: single` (the default), a trigger while the automation is already running is silently dropped. No trace, no log, nothing.
- Check: is there a long-running `wait_for_trigger` or `delay` in the automation that's holding it open?
- Fix: Change to `mode: restart` if a new trigger should interrupt the current run, or `mode: queued` if events should stack.

**Step 5 — Is the automation disabled by an error?**
- After certain errors, HA may disable an automation. Check the logs for `Setup of automation <name> failed`.
- Invalid YAML, broken templates, or references to non-existent entities can cause this.
- Fix the error and reload automations (Developer Tools → YAML → Reload Automations).

**Step 6 — Is it a blueprint input resolution failure?**
- If a blueprint `!input` reference points to an entity that no longer exists (renamed, deleted, re-paired), the automation may fail silently at setup.
- Check: Settings → Automations → click the automation → verify all inputs have valid values.
- Symptom: the automation appears enabled but never triggers and produces no traces.

### 13.5 Common failure modes and symptoms

Each failure mode maps to one or more anti-patterns from §10. The `AP-XX` references help you connect symptoms to root causes and prevention rules.

**"Template evaluates to empty string"** — *see AP-16*

Symptom: Action runs but does nothing. Target entity is blank. No error in logs.

Cause: A template variable resolved to `''` because the entity was `unavailable` or the `| default()` fell through to an empty string.

Diagnosis: Check the trace's `changed_variables` — look for any variable that's `''`, `None`, or `unknown`.

Fix: Add explicit guards:
```yaml
- alias: "Skip if target entity is empty"
  condition: template
  value_template: "{{ target_entity | default('') | length > 0 }}"
```

**"Action targets wrong entity"** — *see AP-02*

Symptom: The wrong light turns on, the wrong speaker plays music.

Cause: Usually a list-index mismatch in paired-list patterns (§7.5, §7.6). Alexa player list and MA player list are in different orders.

Diagnosis: Check the trace — expand the action node and look at `target.entity_id`. Is it the entity you expected?

Fix: Verify paired lists are in the same order. Add a `logbook.log` or `system_log.write` step before the action that prints the resolved target for debugging. (`logbook.log` writes to the Activity panel; `system_log.write` writes to `home-assistant.log` — use whichever suits your workflow.)

**"Automation fires twice"** — *see AP-23*

Symptom: Lights toggle on then immediately off. TTS speaks the same message twice. 

Cause: Multiple triggers matching the same event. Common with `state` triggers that don't specify `from:` — they fire on ANY state change, including attribute-only changes.

Diagnosis: Check the automation's trace list — are there two traces within seconds of each other?

Fix: Add `from:` and `to:` to state triggers. Or add `not_from:` / `not_to:` with `['unavailable', 'unknown']` to filter out transient states:

```yaml
triggers:
  - trigger: state
    entity_id: binary_sensor.motion
    from: "off"
    to: "on"
```

**"Action succeeds but device doesn't respond"**

Symptom: Trace shows green (success) on the action, but the physical device didn't do anything.

Cause: HA acknowledged the action, but the device is offline, unreachable, or the integration has a stale connection.

Diagnosis:
1. Try the same action in Developer Tools → Actions. Same result?
2. Check the device's entity state — is it `unavailable`?
3. Check the integration's config entry — is it in an error state?

Fix: This is a device/integration issue, not an automation issue. Check the device's connectivity, restart the integration, or power-cycle the device.

**"Variable has stale value inside repeat loop"** — *see §3.4 caveat*

Symptom: A `repeat` loop does the same thing every iteration despite the state changing between iterations.

Cause: Top-level variables are evaluated once at automation start, not per-iteration (see §3.4 caveat).

Fix: Define a local `variables:` block inside the `repeat.sequence`:
```yaml
repeat:
  count: 5
  sequence:
    - variables:
        current_temp: "{{ states('sensor.temperature') | float(0) }}"
    - alias: "Act on current temperature"
      # current_temp is fresh each iteration
```

**"`wait_for_trigger` hangs forever"** — *see AP-04, AP-20*

Symptom: Automation starts, reaches a `wait_for_trigger`, and never continues. Eventually the timeout fires (if you have one — and you damn well better per §5.1).

Cause: The entity was already in the target state when the wait started. `wait_for_trigger` waits for a *transition*, not a *condition* (see §5.1).

Fix: Add a pre-check before the wait:
```yaml
- if:
    - condition: state
      entity_id: !input door_sensor
      state: "on"
  then:
    - alias: "Already in target state — skip wait"
  else:
    - alias: "Wait for state transition"
      wait_for_trigger:
        - trigger: state
          entity_id: !input door_sensor
          to: "on"
      timeout: ...
      continue_on_timeout: true
```

### 13.6 Log analysis

**Configuring targeted logging:**

Don't turn on `DEBUG` for everything — it'll flood your logs and tank performance. Target specific integrations:

```yaml
# In configuration.yaml
logger:
  default: warning
  logs:
    # Automation execution
    homeassistant.components.automation: info

    # Blueprint/script issues
    homeassistant.components.script: info

    # Music Assistant
    custom_components.music_assistant: debug

    # Extended OpenAI Conversation
    custom_components.extended_openai_conversation: debug

    # ESPHome device communication
    homeassistant.components.esphome: info

    # Template rendering errors
    homeassistant.helpers.template: warning
```

Reload after changes: Developer Tools → YAML → Reload Logger.

**What to look for in logs:**

| Log pattern | What it means |
|---|---|
| `Error while executing automation` | Action threw an exception — check the full traceback |
| `Setup of automation X failed` | YAML parse error or invalid entity reference — automation is dead until fixed |
| `Template X resulted in: None` | Template returned nothing — missing `| default()` |
| `Entity not found: sensor.xxx` | The entity doesn't exist — renamed, deleted, or integration not loaded |
| `Timeout while executing action call` | The device didn't respond within HA's internal timeout |
| `Already running` | `single` mode automation was triggered while still executing |
| `Exceeded maximum` | `queued`/`parallel` mode hit `max:` limit — triggers being dropped |

**Reading logs from the command line (HA OS):**

```bash
# SSH into HA OS, then:
ha core logs --follow           # Live stream
ha core logs | grep automation  # Filter for automation issues
ha core logs | grep -i error    # All errors
```

**Reading logs from the UI:**

Settings → System → Logs. Use the search box to filter. The "Show raw logs" toggle gives you the full traceback instead of the summarized version.

> **Terminology note (HA 2025.10+):** The UI "Logbook" panel has been renamed to **"Activity"**. The underlying YAML action `logbook.log` and integration name `logbook:` in `configuration.yaml` remain unchanged. When referring users to the UI, say "Activity panel"; when writing YAML, continue using `logbook.log` and `logbook:`.

### 13.7 Debugging Music Assistant issues

**"Music doesn't play after `music_assistant.play_media`"**

Diagnosis checklist:
1. Is the MA player entity `available`? (Check Developer Tools → States)
2. Is the MA server running? (Settings → Integrations → Music Assistant → check status)
3. Did you use `music_assistant.play_media` or the generic `media_player.play_media`? (§7.2 — use the MA-specific one)
4. Does the `media_id` exactly match what MA knows? Try searching in the MA UI first.
5. Is `media_type` correct? An album name passed with `media_type: track` will fail to resolve.

**"Volume doesn't restore after TTS"**

Diagnosis checklist:
1. Is the ducking flag (`input_boolean.voice_pe_ducking`) stuck ON? Check its state — if it's stuck, the volume restore step probably errored or the automation was killed mid-duck.
2. Is the `post_tts_delay` long enough? ElevenLabs streams asynchronously — if the delay is too short, volume restores while TTS is still playing (§7.4).
3. Check the automation trace — did the restore step actually fire? If the automation errored or timed out between duck and restore, volume stays ducked.

Manual recovery:
```yaml
# In Developer Tools → Actions:
action: input_boolean.turn_off
target:
  entity_id: input_boolean.voice_pe_ducking
# Then manually set the volume back
```

**"Volume sync keeps firing / feedback loop"**

Symptom: Volume changes rapidly between two values, logs show volume sync automation firing repeatedly.

Cause: The tolerance threshold is too tight, or the ducking flag isn't being checked. Two volume-change events bounce back and forth forever.

Fix:
1. Increase the tolerance threshold (the minimum difference that triggers a sync). 0.02 (2%) is usually the floor.
2. Verify the ducking flag check is in the conditions (§7.4).
3. Add a short cooldown delay at the end of the sync automation to absorb rounding-induced re-triggers.

### 13.8 Debugging ESPHome devices

**"ESPHome device shows as unavailable in HA"**

Diagnosis:
1. Can you reach the device's web server? `http://<device-ip>/` (if web_server is enabled, §6.6).
2. Can you ping it? `ping <device-ip>`
3. Check ESPHome dashboard — is the device showing as online?
4. Check HA logs for `esphome` entries — look for connection refused, timeout, or API key mismatch errors.

Common causes:
- WiFi signal too weak — check `sensor.xxx_wifi_signal` if you have a WiFi signal sensor (§6.7).
- API encryption key mismatch — the key in HA doesn't match the one on the device. Re-adopt the device in ESPHome dashboard.
- Device ran out of memory (heap) — check heap free sensor. Below 20KB is trouble.
- mDNS not working — some routers/VLANs block mDNS. Use a static IP in the ESPHome wifi config.

**"Wake word not triggering"**

Diagnosis:
1. Check the Voice PE satellite's state in HA — is it `idle` (listening) or `unavailable`?
2. Check the ESPHome logs (ESPHome dashboard → Logs) for microphone activity. You should see wake word processing logs.
3. Is the custom model file accessible? Try navigating to the model URL in a browser: `http://homeassistant.local:8123/local/microwake/hey_rick.json`
4. Is the microphone physically working? Check if the on-device voice activity detection (VAD) is triggering.

**"OTA update fails"**

Common causes:
- Device is unreachable (see unavailable diagnosis above).
- Not enough free heap/flash — large configs with many components can run out of space.
- OTA password mismatch — check `!secret ota_password` matches in both ESPHome secrets and the device's compiled firmware. Note: OTA **MD5** password auth was removed in ESPHome 2026.1.0 (passwords now require SHA256). If you're on 2026.1.0+ and OTA fails with an auth error, ensure your password config uses SHA256 (the new default) or remove the password and rely on API encryption key auth.
- For ESPHome 2024.6+: missing `platform: esphome` in the OTA config (§6.6).

### 13.9 Debugging conversation agents

**"Agent doesn't call the right action / uses wrong entity"**

Diagnosis:
1. Check the tool/script descriptions (§8.3.2). Is the description clear enough for the LLM to pick the right tool?
2. Check the PERMISSIONS table in the system prompt — is the entity listed? Is the action listed?
3. Check the integration's debug logs (Extended OpenAI Conversation, etc.) — most log the full LLM request/response including tool calls.

Fix: Make tool descriptions more explicit. Instead of "controls lights", write "turns on the workshop ceiling lights. Call this when the user says 'turn on the lights', 'lights on', or 'I need light'."

**"Agent prompt templates aren't rendering correctly"**

Diagnosis: If your conversation agent system prompt uses Jinja2 templates (e.g., `{{ states('sensor.x') }}` in `extra_system_prompt`), test them in **Developer Tools → Template** first. Paste the template portion and verify it renders the values you expect against current HA state. This is the fastest way to catch template syntax errors, missing `| default()` guards, and entity reference typos in agent prompts — without waiting for a full conversation round-trip.

**"Agent hallucinates entity IDs or actions"**

Cause: The system prompt doesn't explicitly constrain the agent, or the PERMISSIONS table is missing/incomplete.

Fix:
1. Add the explicit constraint: "You are NOT allowed to control any devices outside this list."
2. Make sure every entity the agent should use is in the PERMISSIONS table with exact entity IDs.
3. Reduce exposed tools to only what's needed — fewer options means fewer hallucination targets (§8.3.2).

**"Agent responds but no action happens"**

Diagnosis:
1. Check the integration's logs — did the LLM actually generate a tool/function call, or just text?
2. If it generated a tool call, check: did the tool call succeed? Look for errors in the response.
3. If the tool call succeeded, check the underlying automation/script's trace — did IT work?

This is a three-layer debug: LLM → tool/script → device. Work from the top down.

### 13.10 The nuclear options — escalation ladder

When nothing else works, escalate one step at a time. **Never skip levels** — each step is more disruptive than the last.

| Level | Action | Disruption | When to use |
|-------|--------|------------|-------------|
| **1** | **Reload automations** — Developer Tools → YAML → Reload Automations | ⭐ None — re-parses YAML, no downtime | Changed automation YAML, need HA to pick it up |
| **2** | **Reload specific component** — Developer Tools → YAML → individual reload buttons (scripts, scenes, groups, input helpers, etc.) | ⭐ None — targeted reload | Changed scripts, helpers, or scene definitions |
| **3** | **Check config validity** — Developer Tools → YAML → Check Configuration | ⭐ None — read-only validation | **Always run this before level 4+.** A YAML error can prevent HA from starting. (Button requires Advanced Mode: Settings → People → your user → Advanced Mode toggle) |
| **4** | **Restart Home Assistant** — Settings → System → Restart | ⚠️ **1–5 min downtime** — all automations stop, integrations reconnect | Reload didn't fix it, integration is stuck, entity won't update |
| **5** | **Hard restart (HA OS)** — SSH in, run `ha core restart` | ⚠️ **1–5 min downtime** — same as above but bypasses unresponsive UI | UI is frozen/unresponsive, can't reach restart button |
| **6** | **Restore from backup** | ❌ **Destructive** — rolls back ALL changes since backup | Everything is worse after restart. Last resort. Try to undo changes manually first (§11). |

**Rule of thumb:** Start at level 1. Move to the next level only if the previous one didn't fix it. And always pass through level 3 before hitting level 4+, or you might be staring at a boot loop like a damn Ferengi who forgot to read the fine print.
