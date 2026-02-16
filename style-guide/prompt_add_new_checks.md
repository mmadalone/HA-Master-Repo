Working in `/Users/madalone/_Claude Projects/HA Master Style Guide/`.

Talk like Quark from DS9. I encourage you to curse.

---

## Overview

Read `09_qa_audit_checklist.md` fully before making any changes. You're adding 11 new checks (8 in existing categories + 3 in a new "Blueprint Validation" category) and wiring them into the existing structure. Follow the exact format, severity conventions, and cross-reference style already used in the file.

---

## Task 1 — Add 11 new checks to `09_qa_audit_checklist.md`

Insert these checks into their respective category sections, after the last existing check in each category. For the BP checks, create a new "9 — Blueprint Validation" category section. For PERF-1, create a new "10 — Performance" category section. Match the existing heading format (`### ID: Title [SEVERITY]`), include `**Check:**`, `**Fix pattern:**` (with ❌/✅ examples where applicable), and a `📋 QA Check:` callout at the end of each.

### Check 1 — Insert after CQ-6 in "4 — Code Quality & Patterns"

```markdown
### CQ-7: Template Safety / Jinja Robustness [WARNING]

**Check:** Every Jinja2 template in YAML examples must handle missing or unavailable entities gracefully. Flag any template that:
1. Uses `states('sensor.x')` without a `| default(...)` filter or an `{% if %}` availability guard
2. Accesses `.attributes.something` without checking the entity exists first
3. Pipes template output into TTS or conversation agents without guarding against `None`/`unavailable`/`unknown` results

**Fix pattern:**
```yaml
# ❌ WRONG — blows up if entity is unavailable
action:
  - alias: "Announce temperature"
    action: tts.speak
    data:
      message: "It's {{ states('sensor.outdoor_temp') }} degrees"

# ✅ CORRECT — guarded template
action:
  - alias: "Announce temperature"
    action: tts.speak
    data:
      message: >-
        {% set temp = states('sensor.outdoor_temp') | default('unknown') %}
        {% if temp not in ['unknown', 'unavailable'] %}
          It's {{ temp }} degrees
        {% else %}
          Temperature sensor is not available right now
        {% endif %}
```

**Special attention:** Blueprint inputs that feed into templates — the user's selected entity might not exist or might go offline. Always guard.

📋 QA Check: Run on every YAML example that contains `{{ }}` or `{% %}` blocks.
```

### Check 2 — Insert after CQ-7

```markdown
### CQ-8: Idempotency / Re-trigger Safety [WARNING]

**Check:** Every automation example must be safe to fire twice in rapid succession without producing unintended side effects. Flag these violations:

| Dangerous | Safe | Why |
|-----------|------|-----|
| `homeassistant.toggle` | `homeassistant.turn_on` / `turn_off` | Toggle reverses on re-trigger |
| `input_number.increment` without guard | `input_number.set_value` with absolute value | Increment doubles on re-trigger |
| No `mode:` specified on automations with slow actions | `mode: single` or `mode: restart` | Default `mode: single` is fine, but document it explicitly |
| Stateful sequences with no cooldown | `for:` duration on trigger or `delay:` with `mode: restart` | Prevents rapid-fire execution |

**Fix pattern:**
```yaml
# ❌ WRONG — GPS bounce triggers this twice, lights flash
action:
  - alias: "Toggle hallway"
    action: homeassistant.toggle
    target:
      entity_id: light.hallway

# ✅ CORRECT — idempotent, safe on re-trigger
action:
  - alias: "Turn on hallway"
    action: homeassistant.turn_on
    target:
      entity_id: light.hallway
```

**Exception:** Examples that explicitly demonstrate toggle behavior or counting are exempt if clearly labeled.

📋 QA Check: Run on every automation example. Flag any use of `toggle`, `increment`, or `decrement` without explicit justification.
```

### Check 3 — Insert after SEC-2 in "1 — Security"

```markdown
### SEC-3: Template Injection via Blueprint Inputs [ERROR]

**Check:** Any blueprint `input:` with a `text` or `template` selector whose value is inserted into a Jinja2 template block MUST be sanitized or constrained. Flag when:
1. A `text` input is dropped directly into `{{ input_variable }}` inside a template that executes actions, REST calls, or shell commands
2. A `text` input is concatenated into a conversation agent prompt without escaping
3. No `pattern:` constraint is applied to free-text inputs that reach sensitive contexts

**Risk contexts (highest to lowest):**
- `rest_command:` bodies and URLs — can exfiltrate data
- `shell_command:` arguments — can execute arbitrary commands
- `conversation.process` prompts — can override agent instructions
- `tts.speak` messages — low risk but can produce unexpected speech

**Fix pattern:**
```yaml
# ❌ WRONG — user input goes straight into a REST body
input:
  custom_message:
    name: "Custom message"
    selector:
      text:

action:
  - action: rest_command.send_notification
    data:
      payload: '{"text": "{{ custom_message }}"}'

# ✅ BETTER — constrained input with validation
input:
  custom_message:
    name: "Custom message"
    description: "Alphanumeric only, max 100 chars"
    selector:
      text:
        multiline: false

# And validate in the action sequence before use:
action:
  - alias: "Validate input length"
    condition: template
    value_template: "{{ custom_message | length <= 100 }}"
  - action: rest_command.send_notification
    data:
      payload: '{"text": "{{ custom_message | replace('\"', '') }}"}'
```

📋 QA Check: Run on every blueprint that has a `text` or `template` selector input. Trace where the input value flows.
```

### Check 4 — Insert after AIR-6 in "3 — AI-Readability & Vibe Coding Readiness"

```markdown
### AIR-7: Contradictory Guidance Detection [WARNING]

**Check:** Scan for topics covered in multiple files where the guidance conflicts. Common contradiction zones:

| Topic | Files that may conflict |
|-------|------------------------|
| Error handling strategy | 01 (blueprint patterns) vs 02 (automation patterns) vs 06 (anti-patterns) |
| `continue_on_error` usage | 01 vs 06 |
| Volume management approach | 05 (Music Assistant) vs 08 (voice assistant) |
| TTS provider selection | 03 (conversation agents) vs 08 (voice assistant) |
| Entity naming conventions | 00 (core philosophy) vs any file with examples |

**How to check:**
1. Identify all topics that appear in 2+ files (grep for shared keywords)
2. For each shared topic, extract the specific guidance from each file
3. Flag if the guidance differs in: recommended approach, threshold values, severity, or exceptions

**Severity escalation:**
- Two files give different numbers for the same threshold → WARNING
- Two files recommend opposite approaches for the same scenario → ERROR
- A pattern in one file is an anti-pattern in another without explicit cross-reference → ERROR

📋 QA Check: Run after any substantive content change. Especially important when editing 06_anti_patterns — every anti-pattern must not accidentally contradict a recommended pattern elsewhere.
```

### Check 5 — Insert after CQ-8

```markdown
### CQ-9: Entity Availability Guards [WARNING]

**Check:** Automation and blueprint examples that act on entities which may be optional or offline MUST include availability checks before the action. Flag when:
1. Blueprint inputs with `entity` selectors have no availability guard before use
2. Examples use `media_player`, `climate`, or `cover` entities without checking state != `unavailable`
3. Multi-entity sequences don't handle partial availability (e.g., 2 of 3 speakers are online)

**Fix pattern:**
```yaml
# ❌ WRONG — fails silently if speaker is offline
action:
  - alias: "Play music"
    action: media_player.play_media
    target:
      entity_id: !input target_speaker
    data:
      media_content_id: "some_uri"
      media_content_type: "music"

# ✅ CORRECT — checks availability first
action:
  - alias: "Check speaker available"
    condition: template
    value_template: >-
      {{ not is_state(target_speaker, 'unavailable') }}
  - alias: "Play music"
    action: media_player.play_media
    target:
      entity_id: !input target_speaker
    data:
      media_content_id: "some_uri"
      media_content_type: "music"
```

**Exception:** Examples explicitly demonstrating error handling or fallback patterns are exempt.

📋 QA Check: Run on every example that targets entities from blueprint inputs or entities that depend on network/cloud services.
```

### Check 6 — Insert in "8 — Periodic Maintenance Checks" after MAINT-4

```markdown
### MAINT-5: Community Alignment Check [INFO]

**Check:** Periodically compare guide patterns against:
1. Official HA blueprint exchange: trending blueprints may reveal new conventions
2. HA community forums: recurring questions may indicate the guide missed a common use case
3. HA Discord / GitHub discussions: core devs may signal upcoming pattern changes

**What to look for:**
- Community-standard patterns the guide doesn't cover
- Patterns the guide recommends that the community has moved away from
- New HA features with community-established best practices not yet in the guide

**Frequency:** After every major HA release, or quarterly — whichever comes first.

📋 QA Check: Low priority. Run when updating the guide for a new HA release (pairs with MAINT-1/2/3).
```

### New category — Create "9 — Blueprint Validation" section after "8 — Periodic Maintenance Checks"

Add a new `---` separator and category header, then insert these 3 checks:

### Check 7 — BP-1

```markdown
## 9 — Blueprint Validation

These checks apply specifically to newly created or modified blueprint YAML files, not to the style guide prose.

### BP-1: Blueprint Metadata Completeness [ERROR]

**Check:** Every blueprint file MUST include all required metadata fields with valid content. Flag when any of these are missing or empty:

| Field | Required | Validation |
|-------|----------|------------|
| `blueprint.name` | YES | Non-empty, descriptive (not just "My Blueprint") |
| `blueprint.description` | YES | 1-2 sentences, max 160 characters (UI display truncation) |
| `blueprint.domain` | YES | Must be `automation` or `script` |
| `blueprint.homeassistant.min_version` | YES | Must match the highest-version feature used in the blueprint |
| `blueprint.source_url` | RECOMMENDED | URL to the blueprint's source (GitHub, community forum) |
| `blueprint.author` | RECOMMENDED | Attribution |
| Every `input:` → `name` | YES | Human-readable label |
| Every `input:` → `description` | YES | Explains what the input does and any constraints |
| Every `input:` → `default` | RECOMMENDED | Sensible default where possible; required for optional inputs |

**min_version cross-check:** The `min_version` value must be >= the highest version-dependent feature in the blueprint. Cross-reference against VER-1's verification table:

```yaml
# ❌ WRONG — uses collapsed sections (2024.6+) but claims 2024.2
blueprint:
  homeassistant:
    min_version: "2024.2.0"
  input:
    advanced:
      collapsed: true  # Requires 2024.6+

# ✅ CORRECT
blueprint:
  homeassistant:
    min_version: "2024.6.0"
```

📋 QA Check: Run on every new or modified blueprint file. This is the first check to run — if metadata is wrong, everything downstream is suspect.
```

### Check 8 — BP-2

```markdown
### BP-2: Selector Correctness [WARNING]

**Check:** Every blueprint `input:` must use the most appropriate selector type for its purpose. Flag these mismatches:

| Input purpose | Wrong selector | Correct selector |
|---------------|---------------|-----------------|
| Picking an entity | `text:` | `entity:` with `filter:` by domain/device_class |
| Picking a device | `entity:` | `device:` with `filter:` by integration/manufacturer |
| Picking an area | `text:` | `area:` |
| Picking a conversation agent | `entity:` filtered to `conversation` | `conversation_agent:` (native selector) |
| Yes/no toggle | `text:` or `input_boolean` entity | `boolean:` |
| Numeric value with range | `text:` | `number:` with `min:`/`max:`/`step:` |
| Choosing from fixed options | `text:` | `select:` with `options:` list |
| Time of day | `text:` | `time:` |
| Duration | `number:` in seconds | `duration:` |

**Also flag:**
- `entity:` selectors without `filter:` — the user sees ALL entities, making selection overwhelming and error-prone
- `entity:` selectors with `multiple: true` but no guidance on how many to select
- `number:` selectors without `min:`/`max:` — allows nonsensical values

**Fix pattern:**
```yaml
# ❌ WRONG — raw text for entity selection
input:
  speaker:
    name: "Speaker"
    selector:
      text:

# ✅ CORRECT — proper entity selector with domain filter
input:
  speaker:
    name: "Target speaker"
    description: "Media player to use for audio output"
    selector:
      entity:
        filter:
          domain: media_player
```

📋 QA Check: Run on every new or modified blueprint. Check each `input:` entry against the table above.
```

### Check 9 — BP-3

```markdown
### BP-3: Edge Case / Instantiation Safety [WARNING]

**Check:** Mentally (or actually) instantiate the blueprint with edge-case inputs and verify it doesn't break. Test these scenarios:

| Scenario | What to check |
|----------|---------------|
| All optional inputs left blank | Do defaults produce a working automation? Do templates handle missing values? |
| `multiple: true` entity selector with 0 entities | Does the action sequence handle an empty list? |
| `multiple: true` entity selector with 1 entity | Does it still work (no list-vs-string bugs)? |
| `number:` input at min value | Does the automation behave sensibly (e.g., delay of 0 seconds)? |
| `number:` input at max value | No overflow, no absurd behavior (e.g., volume 100% at 3 AM)? |
| Target entity is unavailable | Does CQ-9 availability guard catch it, or does it fail silently? |
| Automation fires during HA restart | Are entity states `unknown` briefly? Does the blueprint handle that? |

**Integration with other checks:**
- BP-3 failures often trace back to CQ-7 (template safety) or CQ-9 (availability guards) violations
- If BP-3 finds a failure, check whether the root cause is already caught by another check — if not, that's a gap

**Reporting format:**
```
[WARNING] BP-3 | blueprint_name.yaml | Scenario: all optional inputs blank | input "custom_message" has no default, template renders "None"
```

📋 QA Check: Run on every new blueprint before sharing or deploying. This is the final validation — the "would a real user hit this?" check.
```

### New category — Create "10 — Performance" section after "9 — Blueprint Validation"

### Check 10 — PERF-1

```markdown
## 10 — Performance

### PERF-1: Resource-Aware Triggers [WARNING]

**Check:** Flag automation triggers and templates that cause unnecessary load on the HA event bus. Violations:

| Pattern | Problem | Fix |
|---------|---------|-----|
| `platform: state` without `entity_id:` | Fires on EVERY state change in the entire instance | Always specify `entity_id:` or use a more specific trigger |
| `platform: state` with broad `entity_id:` like `sensor.*` | Still fires too often on busy domains | Narrow to specific entities or use `attribute:` filter |
| Template trigger using `states.sensor` or `states.binary_sensor` | Iterates ALL entities in domain on every evaluation | Reference specific entities with `states('sensor.x')` |
| `platform: time_pattern` with `seconds: "*"` or `/1` | Evaluates every second — rarely justified | Use `/5`, `/10`, `/15`, or `/30` unless sub-second precision is required |
| Multiple triggers where one would suffice with `or` conditions | Extra event listeners for no benefit | Consolidate where possible |

**Fix pattern:**
```yaml
# ❌ WRONG — fires on every single state change in HA
triggers:
  - platform: state

# ❌ STILL BAD — broad domain match
triggers:
  - platform: state
    entity_id: sensor.*

# ✅ CORRECT — specific entity
triggers:
  - platform: state
    entity_id: sensor.outdoor_temperature
    attribute: temperature

# ❌ WRONG — evaluates every second
triggers:
  - platform: time_pattern
    seconds: "/1"

# ✅ CORRECT — evaluates every 30 seconds (sufficient for most monitoring)
triggers:
  - platform: time_pattern
    seconds: "/30"
```

**Context:** With a busy HA instance (Aqara sensors, Sonos speakers, Music Assistant, multiple conversation agents, ESPHome devices), unfiltered triggers can generate hundreds of unnecessary evaluations per minute, degrading system responsiveness.

📋 QA Check: Run on every automation and blueprint. Flag any `platform: state` without `entity_id:` and any `time_pattern` with intervals under 5 seconds.
```

### Check 11 — Insert after CQ-9 in "4 — Code Quality & Patterns"

```markdown
### CQ-10: Observability for Multi-Step Flows [INFO]

**Check:** Any automation or blueprint with 3+ sequential actions involving external services (LLM calls, TTS, REST, Music Assistant) SHOULD include observability hooks for debugging. Flag when a multi-step flow has:
1. No `logbook.log` or `persistent_notification.create` on failure paths
2. No way to determine which step failed after the fact
3. Error handling that silently swallows failures (e.g., `continue_on_error: true` with no logging)

**What qualifies as a "multi-step flow":**
- LLM → TTS → speaker routing
- Presence detection → music selection → volume duck → playback
- Any sequence with 2+ network-dependent actions in a row

**Fix pattern:**
```yaml
# ❌ WRONG — if the LLM call fails, you'll never know why the speaker stayed silent
actions:
  - alias: "Get LLM response"
    action: conversation.process
    data:
      text: "What's the weather?"
      agent_id: !input conversation_agent
    response_variable: llm_response
    continue_on_error: true
  - alias: "Speak response"
    action: tts.speak
    data:
      message: "{{ llm_response.response.speech.plain.speech }}"

# ✅ CORRECT — logs failure, notifies on critical errors
actions:
  - alias: "Get LLM response"
    action: conversation.process
    data:
      text: "What's the weather?"
      agent_id: !input conversation_agent
    response_variable: llm_response
  - alias: "Check LLM response valid"
    if:
      - condition: template
        value_template: "{{ llm_response is defined and llm_response.response is defined }}"
    then:
      - alias: "Speak response"
        action: tts.speak
        data:
          message: "{{ llm_response.response.speech.plain.speech }}"
    else:
      - alias: "Log LLM failure"
        action: logbook.log
        data:
          name: "Blueprint Debug"
          message: "LLM call failed or returned empty response"
          entity_id: !input conversation_agent
```

**Note:** This is [INFO] severity — not every 3-step automation needs full observability. But if you've spent 20 minutes staring at a trace wondering why your proactive LLM blueprint went silent, you'll wish you had it.

📋 QA Check: Run on multi-step blueprints involving LLM, TTS, or Music Assistant flows. Suggest — don't enforce.
```

---

## Task 2 — Update the trigger tables and command definitions

In the `## 15.2 — When to Run Checks` section:

### Automatic triggers table — update these rows:

| Row to find (match by trigger text) | New checks to append |
|--------------------------------------|----------------------|
| `Generating or reviewing any YAML output` | Add `CQ-7, CQ-8, CQ-9, CQ-10, PERF-1` to the existing list |
| `Editing a style guide .md file` | Add `AIR-7` to the existing list |

### Add one new row to the automatic triggers table:

| Trigger | Checks to suggest |
|---------|-------------------|
| Blueprint has `text` or `template` selector inputs | SEC-3 (template injection review) |
| Creating or materially editing a blueprint YAML file | BP-1 (metadata), BP-2 (selectors), BP-3 (edge cases), PERF-1, plus SEC-1, SEC-3, CQ-1 through CQ-10, VER-2 |

### User-triggered commands table — update these rows:

| Command to find | Updated description |
|-----------------|---------------------|
| `sanity check` | Add `SEC-3, CQ-7, CQ-8, CQ-9, PERF-1` to the existing combination (becomes: SEC-1 + SEC-3 + VER-1 + VER-3 + CQ-5 + CQ-6 + CQ-7 + CQ-8 + CQ-9 + PERF-1 + AIR-6 + ARCH-4 + ARCH-5) |
| `run maintenance` | Update to `MAINT-1 through MAINT-5` |
| `check vibe readiness` | Update to `AIR-1 through AIR-7` |

### Add one new row to the user-triggered commands table:

| Command | What it does |
|---------|--------------|
| `check blueprint` or `check blueprint <filename>` | Full blueprint validation: BP-1 (metadata) + BP-2 (selectors) + BP-3 (edge cases) + SEC-1 + SEC-3 + CQ-5 + CQ-6 + CQ-7 + CQ-8 + CQ-9 + CQ-10 + PERF-1 + VER-2. The complete pre-deployment checklist for a blueprint file. |

---

## Task 3 — Update the grep patterns appendix

In `## 15.3 — Quick Grep Patterns`, add these at the end (before any closing `---`):

```bash
# CQ-7: Find unguarded Jinja templates
grep -n "states('" *.md | grep -v 'default\|unknown\|unavailable'

# CQ-8: Find toggle/increment usage (potential re-trigger issues)
grep -rn 'homeassistant.toggle\|input_number.increment\|input_number.decrement' *.md *.yaml

# SEC-3: Find text inputs that may reach templates
grep -n 'selector:' *.md -A2 | grep 'text:'

# CQ-9: Find entity actions without availability checks
# (Rough — needs manual review of surrounding context)
grep -n 'media_player\.\|climate\.\|cover\.' *.md | grep -v 'unavailable'

# AIR-7: Find topics covered in multiple files (contradiction candidates)
for term in "continue_on_error" "volume" "tts" "error handling" "naming"; do
  echo "=== $term ===" && grep -l "$term" *.md
done

# BP-1: Check blueprint metadata completeness
for f in *.yaml; do
  echo "=== $f ===" && grep -c 'name:\|description:\|domain:\|min_version:\|source_url:' "$f"
done

# BP-2: Find text selectors that should probably be typed selectors
grep -n 'selector:' *.yaml -A2 | grep 'text:'

# BP-3: Find multiple:true inputs (edge case candidates)
grep -n 'multiple: true' *.yaml

# PERF-1: Find unfiltered state triggers
grep -n 'platform: state' *.md *.yaml | grep -v 'entity_id:'

# PERF-1: Find broad template iterations
grep -rn 'states\.sensor\|states\.binary_sensor\|states\.switch' *.md *.yaml

# PERF-1: Find aggressive time patterns
grep -n 'time_pattern' *.md *.yaml -A3 | grep -E 'seconds:.*(/1"|/1$|\*)'

# CQ-10: Find multi-step flows without logging (rough — look for conversation.process or tts without logbook)
grep -l 'conversation.process\|tts.speak\|music_assistant' *.md *.yaml | xargs grep -L 'logbook.log\|persistent_notification'
```

---

## Task 4 — Wire cross-references into existing guide files

Add one-line cross-reference callouts in the existing guide files, same format as the existing ones:

```markdown
> 📋 **QA Check [CHECK-ID]:** Brief reminder. See `09_qa_audit_checklist.md`.
```

Placement:

| File | Check | Where to place |
|------|-------|----------------|
| `01_blueprint_patterns.md` | SEC-3 | Near any section about blueprint `input:` definitions or text selectors |
| `01_blueprint_patterns.md` | CQ-8 | Near any section about automation modes (`mode: single/restart/queued`) |
| `01_blueprint_patterns.md` | BP-1 | Near any section about blueprint metadata (`name`, `description`, `domain`, `min_version`) |
| `01_blueprint_patterns.md` | BP-2 | Near any section about selector types or input definitions |
| `01_blueprint_patterns.md` | BP-3 | Near any section about defaults, optional inputs, or blueprint testing |
| `02_automation_patterns.md` | CQ-7 | Near any section about templates or Jinja usage |
| `02_automation_patterns.md` | CQ-8 | Near any section about trigger behavior or re-trigger handling |
| `02_automation_patterns.md` | CQ-9 | Near any section about entity targeting or optional entities |
| `05_music_assistant_patterns.md` | CQ-9 | Near any section about speaker targeting or media_player actions |
| `06_anti_patterns_and_workflow.md` | AIR-7 | Near the top of the file or near any section about maintaining consistency |
| `06_anti_patterns_and_workflow.md` | PERF-1 | Near any anti-pattern about broad triggers or performance pitfalls |
| `08_voice_assistant_pattern.md` | CQ-7 | Near any section about TTS templates or conversation response templates |
| `08_voice_assistant_pattern.md` | CQ-10 | Near any multi-step LLM → TTS flow examples |
| `02_automation_patterns.md` | PERF-1 | Near any section about trigger types or state triggers |
| `03_conversation_agents.md` | CQ-10 | Near any section about conversation.process flows or multi-agent patterns |

**Rules:**
- Read each file BEFORE editing — don't guess at section names
- One-line callouts only — don't bloat
- Don't restructure or rewrite anything — only add cross-references
- If a placement target doesn't exist in the file, skip it and tell me

---

## Task 5 — Show me the changes

After all edits, give me:
1. A summary of what was added/changed per file
2. Any placements you skipped and why
3. The new full `sanity check` combination for my reference
4. The new full `check blueprint` combination for my reference
