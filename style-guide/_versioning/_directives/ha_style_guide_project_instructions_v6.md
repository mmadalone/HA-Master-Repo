# Home Assistant Style Guide — Master Index

You are helping the user build and maintain Home Assistant blueprints, automations, scripts, conversation agent prompts, and related configuration. You have direct filesystem access to their HA config via SMB mount.

**HA config path:** `/Users/madalone/Library/Containers/nz.co.pixeleyes.AutoMounter/Data/Mounts/Home Assistant/SMB/config/`

---

## Style Guide Documents

This style guide is split across multiple focused documents. **Read ALL of them** — they are interdependent. The section numbers are preserved across files for cross-referencing.

| Doc | Sections | Covers |
|-----|----------|--------|
| [Core Philosophy](00_core_philosophy.md) | §1, §2, §9, §12 | Design principles, versioning workflow, naming conventions, communication style |
| [Blueprint Patterns](01_blueprint_patterns.md) | §3, §4 | Blueprint YAML structure, inputs, variables, templates, script standards |
| [Automation Patterns](02_automation_patterns.md) | §5 | Error handling, modes, timeouts, triggers, GPS bounce, helpers, area/label targeting |
| [Conversation Agents](03_conversation_agents.md) | §8 | Agent prompt structure, separation from blueprints, naming conventions |
| [ESPHome Patterns](04_esphome_patterns.md) | §6 | Device config structure, packages, secrets, wake words, naming |
| [Music Assistant Patterns](05_music_assistant_patterns.md) | §7 | MA players, play_media, TTS duck/restore, volume sync, voice bridges |
| [Anti-Patterns & Workflow](06_anti_patterns_and_workflow.md) | §10, §11 | Things to never do, build/review/edit workflows |
| [Troubleshooting & Debugging](07_troubleshooting.md) | §13 | Traces, Developer Tools, failure modes, log analysis, domain-specific debugging |

> **Note on section numbering:** Section numbers are preserved from the original unified guide and are non-sequential across files. This is intentional — it allows stable cross-references (e.g., “see §5.1”) regardless of how files are reorganized.

---

## Full Table of Contents

**13 top-level sections · 77 subsections · 34 anti-patterns · 8 files**

### [Core Philosophy](00_core_philosophy.md)

- **§1** — Core Philosophy
  - §1.1 — Modular over monolithic
  - §1.2 — Separation of concerns
  - §1.3 — Never remove features without asking
  - §1.4 — Follow official HA best practices and integration docs
  - §1.5 — Use `entity_id` over `device_id`
  - §1.6 — Secrets management
- **§2** — File Versioning (Mandatory)
  - §2.1 — Scope — what gets versioned
  - §2.2 — Pre-flight checklist (MANDATORY)
  - §2.3 — Version control workflow
  - §2.4 — The active file
- **§9** — Naming Conventions & Organization
  - §9.1 — Blueprints
  - §9.2 — Scripts
  - §9.3 — Helpers
  - §9.4 — Automations
  - §9.5 — Automation categories and labels
  - §9.6 — Packages — feature-based config organization
- **§12** — Communication Style

### [Blueprint Patterns](01_blueprint_patterns.md)

- **§3** — Blueprint Structure & YAML Formatting
  - §3.1 — Blueprint header and description image
  - §3.2 — Collapsible input sections (Mandatory)
  - §3.3 — Input definitions
  - §3.4 — Variables block
  - §3.5 — Action labels and comments (Mandatory)
  - §3.6 — Template safety (Mandatory)
  - §3.7 — YAML formatting
- **§4** — Script Standards
  - §4.1 — Required fields
  - §4.2 — Inline explanations
  - §4.3 — Changelog in description

### [Automation Patterns](02_automation_patterns.md)

- **§5** — Automation Patterns
  - §5.1 — Error handling — timeouts (Mandatory)
  - §5.2 — Error handling — non-critical action failures
  - §5.3 — Cleanup on failure
  - §5.4 — Mode selection (deep dive)
  - §5.5 — GPS bounce / re-trigger protection
  - §5.6 — Trigger IDs + Choose pattern
  - §5.7 — Order of operations
  - §5.8 — Debugging: stored traces
  - §5.9 — Area, floor, and label targeting
  - §5.10 — Helper selection decision matrix
  - §5.11 — Purpose-specific triggers (HA 2025.12+ Labs)

### [Conversation Agents](03_conversation_agents.md)

- **§8** — Conversation Agent Prompt Standards
  - §8.1 — Follow the integration's official documentation
  - §8.2 — Separation from blueprints
  - §8.3 — Mandatory prompt sections
  - §8.3.1 — Example prompt skeleton
  - §8.3.2 — Tool/function exposure patterns
  - §8.4 — Agent naming convention
  - §8.5 — Multi-agent coordination

### [ESPHome Patterns](04_esphome_patterns.md)

- **§6** — ESPHome Device Patterns
  - §6.1 — Config file structure (Mandatory)
  - §6.2 — Substitutions (Mandatory)
  - §6.3 — GitHub packages — extending without replacing
  - §6.4 — Secrets in ESPHome (Mandatory)
  - §6.5 — Custom wake word models
  - §6.6 — Common component patterns
  - §6.7 — Debug and diagnostic sensors
  - §6.8 — ESPHome device naming conventions
  - §6.9 — Archiving old configs
  - §6.10 — Multi-device consistency
  - §6.11 — ESPHome and HA automation interaction

### [Music Assistant Patterns](05_music_assistant_patterns.md)

- **§7** — Music Assistant Patterns
  - §7.1 — MA players vs generic media_players
  - §7.2 — `music_assistant.play_media` — not `media_player.play_media`
  - §7.3 — Stop vs Pause — when to use which
  - §7.4 — TTS interruption and resume (duck/restore pattern)
  - §7.5 — Volume sync between platforms (Alexa ↔ MA)
  - §7.6 — Presence-aware player selection
  - §7.7 — Voice command → MA playback bridge (input_boolean pattern)
  - §7.8 — Unified voice media control pattern
  - §7.9 — MA + TTS coexistence on Voice PE speakers
  - §7.10 — Extra zone mappings for shared speakers

### [Anti-Patterns & Workflow](06_anti_patterns_and_workflow.md)

- **§10** — Anti-Patterns (Never Do These)
  - General (1–23)
  - ESPHome (24–28)
  - Music Assistant (29–34)
- **§11** — Workflow
  - §11.0 — Universal pre-flight (applies to ALL workflows)
  - §11.1 — When the user asks to build something new
  - §11.2 — When the user asks to review/improve something
  - §11.3 — When editing existing files
  - §11.4 — When producing conversation agent prompts

### [Troubleshooting & Debugging](07_troubleshooting.md)

- **§13** — Troubleshooting & Debugging
  - §13.1 — Automation traces — your first stop
  - §13.2 — Developer Tools patterns
  - §13.3 — The "why didn't my automation trigger?" flowchart
  - §13.4 — Common failure modes and symptoms
  - §13.5 — Log analysis
  - §13.6 — Debugging Music Assistant issues
  - §13.7 — Debugging ESPHome devices
  - §13.8 — Debugging conversation agents
  - §13.9 — The nuclear options

---

## Quick Reference — When to Read What

- **Building a new blueprint?** → Core Philosophy + Blueprint Patterns + Anti-Patterns & Workflow
- **Writing automation logic?** → Automation Patterns (especially §5.1 timeouts, §5.4 modes)
- **Setting up a conversation agent?** → Conversation Agents + Core Philosophy §1.2
- **Configuring an ESPHome device?** → ESPHome Patterns
- **Working with Music Assistant?** → Music Assistant Patterns + Automation Patterns §5.1
- **Reviewing existing code?** → Anti-Patterns & Workflow §11.2 + the relevant pattern doc
- **Something isn't working?** → Troubleshooting & Debugging (start at §13.3 flowchart)
- **Reading logs or traces?** → Troubleshooting §13.1 (traces) and §13.5 (logs)
