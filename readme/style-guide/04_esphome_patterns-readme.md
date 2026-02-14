# ESPHome Patterns — Device Configs, Packages & Wake Words

![ESPHome Patterns header](https://raw.githubusercontent.com/mmadalone/HA-Master-Repo/main/images/style-guide/04_esphome_patterns-header.jpeg)

The hardware layer of the operation. This file governs ESPHome device configuration — from the YAML structure and substitutions system to GitHub packages, secrets management, custom wake word models, and the naming conventions that keep a fleet of ESP32 devices manageable. If you're soldering firmware onto silicon, these are the rules.

One section — §6 — with twelve subsections covering everything from config file structure to multi-device consistency and sub-device patterns for multi-function boards.

## What's Inside

**§6 — ESPHome Device Patterns** starts with config file structure (§6.1) — the mandatory layout every ESPHome YAML must follow. Substitutions (§6.2) are mandatory for device-specific values, keeping configs portable across hardware. GitHub packages (§6.3) document how to extend upstream packages without replacing them — the key to maintaining Voice PE satellites that track Nabu Casa's official configs while adding local customizations. Secrets (§6.4) follows the same `!secret` discipline as HA configs. Custom wake word models (§6.5) covers the microWakeWord integration with persona-specific wake words (Rick and Quark). Common component patterns (§6.6) documents frequently used ESPHome components with correct configuration. Debug and diagnostic sensors (§6.7) covers the sensors every device should expose for health monitoring. Device naming (§6.8) standardizes the naming scheme. Archiving old configs (§6.9) handles the lifecycle of decommissioned devices. Multi-device consistency (§6.10) establishes patterns for keeping multiple devices aligned. ESPHome-to-HA automation interaction (§6.11) documents the boundary between device-level logic and HA-level automation. Sub-devices (§6.12) covers multi-function boards that expose multiple logical devices from a single physical unit.

## When to Load

T1 (task-specific). Load in full when working on any ESPHome device configuration. This file is compact enough (~6K tokens) to load entirely for ESPHome tasks.

| Mode | When to load |
|------|-------------|
| BUILD | Any ESPHome device configuration task |
| TROUBLESHOOT | On demand — paired with §13.8 (debugging ESPHome devices) |
| AUDIT | When reviewing ESPHome config compliance |

## Key Concepts

**Substitutions are mandatory** (§6.2) — every device-specific value (name, friendly name, IP address, API key reference) goes into the `substitutions:` block. This makes configs portable: swap the substitutions and the same config works on a different device.

**GitHub packages — extend, don't replace** (§6.3) — Voice PE satellites use Nabu Casa's official ESPHome packages as a base. Local customizations extend the package through ESPHome's merge system rather than forking the entire config. This means upstream updates (new wake word engine versions, bug fixes) flow through automatically while local additions (custom wake words, diagnostic sensors) persist.

**Custom wake words** (§6.5) — the system uses persona-specific microWakeWord models. "Hey Rick" activates the Rick pipeline, "Hey Quark" activates the Quark pipeline. Each wake word maps to a specific voice assistant pipeline in HA, which routes to the corresponding conversation agent and TTS voice.

**Device-vs-automation boundary** (§6.11) — logic that depends only on the device's own sensors and actuators belongs in ESPHome (on-device automations). Logic that coordinates across devices or requires HA state belongs in HA automations. Mixing these creates debugging nightmares where you can't tell whether ESPHome or HA is making the decision.

**Multi-device consistency** (§6.10) — when multiple devices of the same type exist (multiple Voice PE satellites, multiple sensor nodes), their configs should be structurally identical with only substitution values differing. Config drift between devices of the same type is a maintenance time bomb.

## Related Files

| File | Relationship |
|------|-------------|
| `00_core_philosophy.md` | §1.6 (secrets management) applies to ESPHome's `!secret` usage |
| `08_voice_assistant_pattern.md` | §14.2 (Layer 1) details how ESPHome satellites fit into the voice stack |
| `07_troubleshooting.md` | §13.8 covers ESPHome-specific debugging |
| `06_anti_patterns_and_workflow.md` | AP-25 through AP-29 target ESPHome-specific anti-patterns |

## Sources & Acknowledgments

ESPHome patterns draw from official [ESPHome documentation](https://esphome.io/), Nabu Casa's [Voice PE reference configs](https://github.com/esphome/home-assistant-voice-pe), and the [microWakeWord](https://esphome.io/components/micro_wake_word.html) component documentation. Package extension patterns were developed through maintaining Voice PE satellites that track upstream while adding local customizations.

Cultural references: *Star Trek: Deep Space Nine* (Paramount), *Rick and Morty* (Adult Swim).

## Tooling & AI Disclosure

Developed collaboratively with **Claude** (Anthropic) via Claude Desktop. MCP tools: Desktop Commander, Filesystem MCP, git MCP, ripgrep, Context7, HA MCP, ha-ssh, Gemini.

## Author

**madalone** · [GitHub](https://github.com/mmadalone)

## License

See repository root for license details.
