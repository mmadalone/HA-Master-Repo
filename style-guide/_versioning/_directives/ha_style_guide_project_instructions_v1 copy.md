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
| [Voice Assistant Pattern](08_voice_assistant_pattern.md) | (ref) | End-to-end voice stack architecture: ESPHome satellites, pipelines, agents, blueprints, tool scripts, helpers, TTS |

> **Note on section numbering:** Section numbers are preserved from the original unified guide and are non-sequential across files. This is intentional — it allows stable cross-references (e.g., "see §5.1") regardless of how files are reorganized.
