# Voice Assistant Pattern — The 6-Layer Voice Interaction Chain

![Voice Assistant Pattern header](https://raw.githubusercontent.com/mmadalone/HA-Master-Repo/main/images/style-guide/08_voice_assistant_pattern-header.jpeg)

The architecture blueprint for the entire voice stack — from the moment sound hits an ESPHome microphone to the moment a TTS response plays through a speaker. This file documents the complete 6-layer model that connects ESPHome Voice PE satellites, HA voice pipelines, conversation agents, orchestration blueprints, tool scripts, and shared helper state into a coherent voice interaction system.

At ~11.8K tokens, this is the third largest file in the guide. It's an end-to-end architecture reference, not a collection of isolated patterns — each layer depends on the layers above and below it.

## What's Inside

**§14 — Voice Assistant Pattern** opens with the architecture overview (§14.1) defining the six layers and their relationships. Each subsequent section details one layer:

**Layer 1: ESPHome Voice PE satellites** (§14.2) — the physical hardware. Device configs, microphone/speaker setup, wake word detection (persona-specific: "Hey Rick" and "Hey Quark"), and the key principles for satellite configuration. Cross-references §6 (ESPHome Patterns) for device config standards.

**Layer 2: HA Voice Pipeline** (§14.3) — the pipeline-to-satellite mapping. Each satellite connects to a specific voice pipeline, which determines the STT engine, conversation agent, and TTS engine. Pipeline configuration determines which persona responds on which device.

**Layer 3: Conversation agents** (§14.4) — the intelligence layer. Agent naming, prompt structure, separation of concerns, and tool exposure. Cross-references §8 (Conversation Agents) for prompt standards.

**Layer 4: Blueprints / orchestration** (§14.5) — the automation layer that coordinates multi-step voice interactions. Documents key blueprints: Coming Home (welcome announcements), Proactive LLM Sensors (context-aware proactive announcements), and Voice Active Media Controls (voice-to-media-action bridge).

**Layer 5: Tool scripts** (§14.6) — the thin wrappers that agents call to control HA. Documents the script-as-tool pattern and the script blueprint pattern for generating consistent tool scripts.

**Layer 6: Helpers / shared state** (§14.7) — the glue between layers. Ducking flags, volume storage, voice command bridges (input_booleans that Alexa toggles to trigger HA automations), and persona-specific state helpers.

**TTS output patterns** (§14.8) covers ElevenLabs voice routing and post-TTS delay timing. **Data flow summary** (§14.9) traces two complete paths: interactive conversation (wake word → STT → agent → TTS) and one-shot announcement (automation → agent → TTS). **Common gotchas** (§14.10) catalogs voice-specific anti-patterns. **File locations** (§14.11) provides a quick reference for where each component lives on disk. **Style guide cross-references** (§14.12) maps each layer to its corresponding pattern doc.

## When to Load

T3 (reference only). Load when building voice-related features or debugging voice pipeline issues. For focused tasks, load only the relevant layer sections.

| Mode | When to load |
|------|-------------|
| BUILD | Voice-related blueprint/automation/agent work. Load relevant layers only. |
| TROUBLESHOOT | Voice pipeline debugging — paired with §13 (Troubleshooting) |
| AUDIT | When reviewing voice stack compliance |

## Key Concepts

**The 6-layer model** — voice interactions traverse all six layers. A failure at any layer breaks the entire chain. Understanding which layer owns which responsibility is essential for both building and debugging. The most common mistake is putting logic in the wrong layer (e.g., media control logic in the agent prompt instead of a tool script).

**Pipeline-to-persona mapping** — each physical satellite connects to a specific voice pipeline. The pipeline determines the full chain: which STT engine transcribes speech, which conversation agent processes the intent, and which TTS voice responds. Persona switching (Rick vs Quark) is handled by wake word → pipeline mapping, not by runtime logic.

**Tool scripts as the agent-to-HA bridge** — agents never call HA services directly. They call exposed scripts that wrap service calls with error handling, volume management, and state tracking. This separation means agent prompts stay focused on conversation logic while scripts handle the mechanical details.

**Ducking and volume coordination** — when TTS needs to speak over music, the system uses helper flags to coordinate: set ducking flag → lower volume → play TTS → wait → restore volume → clear flag. Multiple components check these flags to avoid conflicts (e.g., two automations trying to TTS simultaneously).

**Data flow tracing** — the two canonical paths (interactive conversation and one-shot announcement) show exactly which components are involved and in what order. These are the primary debugging references when voice interactions fail at any point.

## Related Files

| File | Relationship |
|------|-------------|
| `04_esphome_patterns.md` | §6 provides Layer 1 device config standards |
| `03_conversation_agents.md` | §8 provides Layer 3 agent prompt standards |
| `05_music_assistant_patterns.md` | §7.8–§7.10 detail MA-specific voice interaction patterns |
| `02_automation_patterns.md` | §5 provides the automation patterns used in Layer 4 blueprints |
| `07_troubleshooting.md` | §13 covers debugging when the voice chain breaks |

## Sources & Acknowledgments

The voice stack architecture draws from official [Home Assistant Voice documentation](https://www.home-assistant.io/voice_control/), [ESPHome Voice PE documentation](https://esphome.io/components/voice_assistant.html), [Extended OpenAI Conversation](https://github.com/jekalmin/extended_openai_conversation) integration, and [ElevenLabs TTS](https://elevenlabs.io/) documentation. The 6-layer model and data flow patterns are original architectural documentation developed to map the complete voice interaction chain.

Cultural references: *Star Trek: Deep Space Nine* (Paramount) — Quark persona and wake word. *Rick and Morty* (Adult Swim) — Rick persona and wake word.

## Tooling & AI Disclosure

Developed collaboratively with **Claude** (Anthropic) via Claude Desktop. MCP tools: Desktop Commander, Filesystem MCP, git MCP, ripgrep, Context7, HA MCP, ha-ssh, Gemini.

## Author

**madalone** · [GitHub](https://github.com/mmadalone)

## License

See repository root for license details.
