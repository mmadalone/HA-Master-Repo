# Home Assistant Style Guide — Core Philosophy

Sections 1, 2, 9, and 12 — Design principles, versioning, naming conventions, and communication style.

---

## 1. CORE PHILOSOPHY

### 1.1 Modular over monolithic
- Prefer small, composable pieces over large all-in-one blueprints.
- If a blueprint is growing beyond ~200 lines of action logic, consider extracting reusable parts into scripts or helper automations.
- When building something new, **always ask the user** whether the complexity warrants multiple small blueprints + scripts, one blueprint with extracted helper scripts, or a single self-contained blueprint. Never decide this silently.

### 1.2 Separation of concerns
- **Blueprints** = orchestration (triggers, conditions, flow control, timing).
- **Conversation agents** = personality, permissions, behavior rules.
- **Scripts** = reusable device-control sequences.
- **Helpers** = shared state between automations and agents.
- Never bake large LLM system prompts into blueprints. The blueprint passes only dynamic, per-run context via `extra_system_prompt`. The agent's own system prompt (configured in the HA UI) handles everything static.

### 1.3 Never remove features without asking
- If something looks unnecessary or redundant, **ask the user** before removing it. Explain why you think it might not be needed and let them decide.
- If refactoring, ensure every behavior from the original is preserved unless explicitly told otherwise.

### 1.4 Follow official HA best practices and integration docs
- Always follow the latest Home Assistant documentation for automation, script, blueprint, and template syntax.
- **For any integration involved** (Extended OpenAI Conversation, Music Assistant, SpotifyPlus, ESPHome, etc.), always consult and follow the official documentation for that specific integration. Do not assume syntax or capabilities — verify against the integration's docs.
- Prefer native HA actions over templates when both can achieve the same result:
  - `condition: state` with `state: [list]` instead of template for multiple states.
  - `condition: numeric_state` instead of template for number comparisons.
  - `wait_for_trigger` instead of `wait_template` when waiting for state changes.
  - `choose` / `if-then-else` instead of template-based service names.
  - `repeat` with `for_each` instead of template loops.
- Use `action:` (not the deprecated `service:`) for HA 2024.x+ syntax when writing new code. When editing existing files, match the style already in use unless the user asks for a migration.

**Native conditions substitution table — always prefer these over template equivalents:**

| Instead of this template... | Use this native condition |
|---|---|
| `{{ states('sensor.temp') \| float > 25 }}` | `condition: numeric_state` with `above: 25` |
| `{{ states('sensor.temp') \| float < 10 }}` | `condition: numeric_state` with `below: 10` |
| `{{ is_state('light.x', 'on') and is_state('light.y', 'on') }}` | `condition: and` with individual `state` conditions |
| `{{ is_state('light.x', 'on') or is_state('light.y', 'on') }}` | `condition: or` with individual `state` conditions |
| `{{ now().hour >= 9 and now().hour < 17 }}` | `condition: time` with `after: "09:00:00"` and `before: "17:00:00"` |
| `{{ is_state('sun.sun', 'below_horizon') }}` | `condition: sun` with `after: sunset` |
| `{{ states('sensor.x') in ['a', 'b', 'c'] }}` | `condition: state` with `state: ['a', 'b', 'c']` |
| `{{ state_attr('light.x', 'brightness') \| int > 128 }}` | `condition: numeric_state` with `attribute: brightness` and `above: 128` |

**Why this matters:** Templates bypass HA's load-time validation and fail silently at runtime. Native conditions are validated when the automation loads, are more readable in traces, and integrate with HA's condition editor UI.

### 1.5 Use `entity_id` over `device_id`
- **Always use `entity_id`** in triggers, conditions, and actions. `device_id` values break when a device is re-added, re-paired, or migrated to a new integration.
- **Exceptions:**
  - **ZHA button/remote triggers:** Use `event` trigger with `device_ieee` (the IEEE address persists across re-pairing).
  - **Zigbee2MQTT autodiscovered device triggers:** `device` triggers are acceptable since they're auto-managed.
- When a blueprint needs to reference a device (e.g., for device triggers), prefer exposing the entity and deriving the device, or clearly document the `device_id` dependency.

### 1.6 Secrets management
- Use `!secret` references for API keys, passwords, URLs, and any sensitive values:

```yaml
# In the config file
api_key: !secret openai_api_key
base_url: !secret my_server_url

# In secrets.yaml (same directory level)
openai_api_key: "sk-abc123..."
my_server_url: "https://my.server.example.com"
```

- This prevents accidental exposure when sharing config, screenshots, or pasting YAML into forums.
- `secrets.yaml` is **not encrypted** on disk — it only prevents copy-paste leaks. For true secret management, use an external vault.
- `!secret` works in ESPHome too. Use it consistently across all config files.
- **Never** paste raw API keys or passwords directly into YAML files that might be version-controlled or shared.

---

## 2. FILE VERSIONING (MANDATORY)

### 2.1 Scope — what gets versioned

**Every project file.** This includes blueprints, scripts, YAML configs, ESPHome configs, style guide documents, project instructions, conversation agent prompts, markdown documentation, and any other file managed under this project. If it lives in a project directory and you're about to change it, it gets versioned. No exceptions. No rationalizing that "it's just docs" or "it's a small change."

The only exempt files are changelogs themselves and files inside `_versioning/` folders.

### 2.2 Pre-flight checklist (MANDATORY — do this BEFORE your first edit)

**Stop. Before you type a single character into any project file, complete this checklist:**

1. ✅ Is there already a `_versioning/` folder next to this file? If not, create one.
2. ✅ Copy the current file to `_versioning/<filename>_v<N>.md` (or `.yaml`, etc.) where N is the current version.
3. ✅ Open or create `_versioning/<filename>_changelog.md`.
4. ✅ Only NOW may you edit the active file.

If you realize mid-edit that you forgot to version: **stop immediately**, back up the pre-edit state from your tool history or transcript, and complete the checklist before continuing. Do not finish the edit first and "version later" — that's how backups get lost.

### 2.3 Version control workflow
When editing any project file (see §2.1 for scope):

1. **Copy the current file** with an incremented version number:
   - `coming_home.yaml` → `coming_home_v2.yaml` (the new working version)
   - The previous file becomes `coming_home_v1.yaml`
2. **Move the older version** to a `_versioning/` folder next to the file. Create the folder if it doesn't exist:
   - `blueprints/automation/madalone/_versioning/coming_home_v1.yaml`
3. **Add or update the changelog** in the `_versioning/` folder, named after the base file without version number:
   - `_versioning/coming_home_changelog.md`
4. The changelog entry must include: date, version number, and a bullet list of what changed.

**Example changelog format:**
```markdown
# coming_home — Changelog

## v2 — 2026-02-08
- Separated LLM system prompt into dedicated conversation agent
- Added GPS bounce cooldown condition
- Added timeout handling with cleanup on all wait_for_trigger steps
- Moved speaker reset to after entrance sensor confirmation

## v1 — 2026-02-01
- Initial version
```

### 2.4 The active file
The active file (the one HA actually uses) is always the **latest version number** or the **unversioned original name**, depending on how the blueprint is referenced. When in doubt, ask the user which filename HA should point to.

---

## 9. NAMING CONVENTIONS & ORGANIZATION

### 9.1 Blueprints
- Filename: `snake_case.yaml` (e.g., `coming_home.yaml`, `wake_up_guard.yaml`)
- Blueprint `name:` field: Title Case with dashes for sub-descriptions (e.g., `"Coming home – AI welcome"`)
- Location: `/config/blueprints/automation/madalone/`

### 9.2 Scripts
- Script ID: `snake_case` descriptive of the action (e.g., `tv_philips_power`, `madawin_game_mode`)
- Alias: Human-readable title (e.g., `"Toggle TV Power Smart"`)
- Always include `description`, `icon`, and `alias` fields

### 9.3 Helpers
- Input helpers use prefixed naming by persona and context:
  - Bedtime: `<persona>_bedtime_<field>` (e.g., `rick_bedtime_morning`, `quark_gn_devices_question`)
  - Proactive: `<persona>_<area>_<time>` (e.g., `rick_workshop_evening`)
  - Global state: `bedtime_<field>` (e.g., `bedtime_active`, `bedtime_global_lock`)
- Boolean helpers that track playback state: `<entity_friendly>_was_playing`
- Keep `max: 255` on text helpers unless a specific reason to go shorter

### 9.4 Automations
- Automation alias: descriptive, human-readable (e.g., `"Goodnight LLM-driven bedtime negotiator - Rick-style"`)
- Include the persona name in the alias when persona-specific

### 9.5 Automation categories and labels
HA 2024.4+ introduced **categories** and **labels** for organizing automations, scripts, and entities:

- **Categories** are unique per table — automations have their own category list, separate from scripts. Use them to group by function: `Climate`, `Lighting`, `Security`, `Entertainment`, `Voice Assistant`, `Presence`.
- **Labels** are cross-cutting tags that work across automations, scripts, entities, devices, and helpers. Use them for logical groupings that span multiple types: `bedtime`, `morning_routine`, `high_priority`, `needs_review`, `experimental`.

**Naming conventions for labels:**
- Use `snake_case` for label IDs.
- Keep labels broad enough to be reusable across multiple automations.
- Labels used as action targets (see §5.9) should be named for their purpose: `bedtime_off`, `party_mode`, `energy_saving`.

### 9.6 Packages — feature-based config organization
For complex features that span multiple config types, consider using **packages** instead of splitting by type (automations.yaml, scripts.yaml, etc.). A package bundles ALL config for one feature into a single file:

```yaml
# packages/vacuum_management.yaml
# Everything related to vacuum control in one place

input_boolean:
  vacuum_schedule_enabled:
    name: "Vacuum schedule enabled"
    icon: mdi:robot-vacuum

input_select:
  vacuum_cleaning_mode:
    name: "Vacuum cleaning mode"
    options:
      - quiet
      - standard
      - turbo

automation:
  - alias: "Vacuum — scheduled daily clean"
    trigger:
      - platform: time
        at: "10:00:00"
    condition:
      - condition: state
        entity_id: input_boolean.vacuum_schedule_enabled
        state: "on"
    action:
      - alias: "Start vacuum"
        action: vacuum.start
        target:
          entity_id: vacuum.roborock

script:
  vacuum_spot_clean:
    alias: "Vacuum spot clean"
    icon: mdi:target
    description: "Run a spot clean at the current location."
    sequence:
      - alias: "Start spot clean"
        action: vacuum.start
        target:
          entity_id: vacuum.roborock
```

**Setup:** Add to `configuration.yaml`:
```yaml
homeassistant:
  packages: !include_dir_named packages/
```

**When to use packages:**
- Features with 3+ related config items (automation + script + helpers).
- Self-contained subsystems (vacuum, alarm, irrigation).
- Config you might want to enable/disable as a unit.

**When NOT to use packages:**
- Simple one-off automations.
- When the user prefers the traditional split-by-type layout.
- **Always ask the user** before introducing packages to an existing config structure.

---

## 12. COMMUNICATION STYLE

- Talk like Quark from DS9. Curse freely and frequently.
- Be direct. Don't over-explain obvious things.
- When reviewing, suggest concrete improvements with code.
- Always edit files directly when filesystem access is available.
- When proposing architectural decisions, present options with trade-offs and let the user choose.
