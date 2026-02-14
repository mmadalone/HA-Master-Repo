# Conversation Agents — Prompt Standards & Multi-Agent Coordination

![Conversation Agents header](https://raw.githubusercontent.com/mmadalone/HA-Master-Repo/main/images/style-guide/03_conversation_agents-header.jpeg)

The bartender's guide to AI personalities. This file governs how conversation agents are designed, structured, and coordinated — from the system prompt skeleton to tool exposure patterns, MCP server integration, and the rules for running multiple agents without them stepping on each other's damn toes.

One section — §8 — covering the full lifecycle of conversation agent development for Home Assistant's Extended OpenAI Conversation integration and compatible alternatives.

## What's Inside

**§8 — Conversation Agent Prompt Standards** opens with the cardinal rule: follow the integration's official documentation (§8.1), not assumptions about how OpenAI's API works. Separation from blueprints (§8.2) enforces the principle that static personality and permissions live in the agent's system prompt, while dynamic per-run context passes through `extra_system_prompt` from blueprints. Mandatory prompt sections (§8.3) defines the skeleton every agent needs — role/persona, permissions table, available tools, response format rules, and behavioral constraints. The example skeleton (§8.3.1) provides a concrete template. Tool/function exposure patterns (§8.3.2) documents how to wire HA scripts as callable tools for the agent. MCP servers as tool sources (§8.3.3) covers the HA 2025.2+ capability for external tool integration. Agent naming (§8.4) standardizes the `<persona>_<context>` convention. Multi-agent coordination (§8.5) addresses the patterns for multiple agents sharing a system without conflicts. Voice pipeline constraints (§8.6) documents the limitations agents face when responding through voice satellites versus text interfaces.

## When to Load

T1 (task-specific). Load when creating or editing conversation agents or their prompts. Pairs with Voice Assistant Pattern (§14) for agents operating in voice pipelines.

| Mode | When to load |
|------|-------------|
| BUILD | Agent creation, prompt editing, tool exposure configuration |
| TROUBLESHOOT | On demand — §8.6 (voice constraints) for voice pipeline debugging |
| AUDIT | When reviewing agent prompt compliance |

## Key Concepts

**Separation from blueprints** (§8.2) — the single most important rule for agent architecture. The agent's system prompt handles everything static: personality, permissions, available tools, response format rules. The blueprint passes only dynamic, per-run context via `extra_system_prompt` — things like current countdown value, active media player, or sensor states. Never bake large LLM prompts into blueprint YAML.

**Mandatory prompt sections** (§8.3) — every agent needs a role definition, a permissions table (what it can and cannot do), a list of available tools with usage examples, response format rules, and behavioral constraints. Missing any of these leads to agents that hallucinate capabilities or produce responses that break the calling blueprint's expectations.

**Tool exposure** (§8.3.2) — HA scripts exposed as conversation agent tools follow the thin-wrapper pattern. The script does one thing (play media, adjust volume, set a timer), and the agent's prompt documents when and how to call it. The agent doesn't call HA services directly — it calls exposed scripts that handle the service calls with proper error handling.

**Multi-agent coordination** (§8.5) — when multiple agents exist (Rick for general use, Quark for bedtime, etc.), each needs clear boundaries on what it controls. Shared state goes through helpers, not direct agent-to-agent communication. No agent should modify another agent's resources without explicit design.

**Voice pipeline constraints** (§8.6) — agents responding through voice satellites face hard limits: no markdown, no long responses (TTS has practical length limits), no visual elements. Agents must adapt their response format based on whether they're in a text or voice context.

## Related Files

| File | Relationship |
|------|-------------|
| `00_core_philosophy.md` | §1.2 (separation of concerns) is the foundation for §8.2 |
| `08_voice_assistant_pattern.md` | §14.4 (Layer 3) details how agents fit into the voice stack |
| `05_music_assistant_patterns.md` | §7.8 (voice playback) documents the script-as-tool pattern agents use for MA |
| `06_anti_patterns_and_workflow.md` | §11.4 defines the workflow for producing agent prompts |

## Sources & Acknowledgments

Agent prompt patterns draw from the [Extended OpenAI Conversation](https://github.com/jekalmin/extended_openai_conversation) integration documentation and general LLM prompt engineering best practices adapted for Home Assistant's conversation architecture. MCP server integration follows HA 2025.2+ documentation.

Cultural references: *Star Trek: Deep Space Nine* (Paramount) — Quark and Rick personas. *Rick and Morty* (Adult Swim).

## Tooling & AI Disclosure

Developed collaboratively with **Claude** (Anthropic) via Claude Desktop. MCP tools: Desktop Commander, Filesystem MCP, git MCP, ripgrep, Context7, HA MCP, ha-ssh, Gemini.

## Author

**madalone** · [GitHub](https://github.com/mmadalone)

## License

See repository root for license details.
