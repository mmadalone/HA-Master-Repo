# Troubleshooting & Debugging — Traces, Logs & Failure Modes

![Troubleshooting header](https://raw.githubusercontent.com/mmadalone/HA-Master-Repo/main/images/style-guide/07_troubleshooting-header.jpeg)

The diagnostic bay. When something breaks — and in a system this complex, something always breaks — this is where you start. Automation traces, Developer Tools patterns, the "why didn't my automation trigger?" decision flowchart, common failure modes with symptoms and fixes, log analysis protocols, and domain-specific debugging guides for Music Assistant, ESPHome, and conversation agents.

One section — §13 — covering the full debugging toolkit from first symptoms to nuclear options.

## What's Inside

**§13 — Troubleshooting & Debugging** opens with automation traces (§13.1) — always the first stop. Traces show exactly what happened, in what order, with what values. Quick tests from the automation editor (§13.2) documents how to trigger automations manually for isolated testing. Developer Tools patterns (§13.3) covers the States, Actions, and Template tabs for real-time inspection.

The "why didn't my automation trigger?" flowchart (§13.4) is the single most useful debugging reference — a decision tree that walks through every reason an automation might not fire: disabled, mode conflict, condition failure, entity unavailable, trigger misconfiguration. Common failure modes (§13.5) maps symptoms to root causes with fix guidance.

Log analysis (§13.6) includes the AI log file access protocol (§13.6.1) — a mandatory procedure for how the AI reads HA logs via ha-ssh without dumping thousands of lines into context. The live troubleshooting protocol (§13.6.2) handles debugging long-running automations with a round-based workflow that prevents stale reads.

Domain-specific sections cover Music Assistant (§13.7) — queue state issues, volume sync failures, TTS conflicts; ESPHome (§13.8) — OTA failures, sensor drift, WiFi disconnects; and conversation agents (§13.9) — tool registration failures, hallucinated service calls, response format errors. The nuclear options (§13.10) documents the last-resort approaches: full HA restart, integration reload, entity registry cleanup.

## When to Load

This is the primary file for TROUBLESHOOT mode. Load it first for any debugging task, then add domain-specific pattern docs on demand.

| Mode | When to load |
|------|-------------|
| BUILD | Not loaded by default. Reference §13.1 (traces) if verifying a build. |
| TROUBLESHOOT | Always — this is the TROUBLESHOOT mode's core file |
| AUDIT | Not loaded by default |

## Key Concepts

**Traces first** (§13.1) — before touching anything, check the automation trace. It shows trigger evaluation, condition results, action execution order, variable values at each step, and where failures occurred. The AI cannot reliably retrieve traces via API — the user checks Settings → Automations → Traces.

**The trigger flowchart** (§13.4) — a systematic checklist for "why didn't it fire?" Covers: is the automation enabled? Is the mode blocking a re-trigger? Did the trigger entity change state? Is the trigger configuration correct? Did a condition block execution? Are there entity availability issues? This eliminates guesswork and ensures no common cause is overlooked.

**AI log protocol** (§13.6.1) — the AI reads logs via ha-ssh with surgical grep commands, never by dumping the full log. Logs are filtered by timestamp, component, and severity before entering context. This prevents thousands of irrelevant log lines from consuming the token budget.

**Live troubleshooting** (§13.6.2) — for automations that take minutes to complete, a round-based protocol: capture baseline log state, trigger the automation, wait for the user to confirm completion, then read the new log entries. The AI never polls logs in a loop.

**Domain-specific debugging** — each major integration (MA, ESPHome, agents) has its own failure mode catalog because their failure patterns are fundamentally different. MA fails on queue state and volume sync. ESPHome fails on connectivity and firmware. Agents fail on tool registration and response parsing.

## Related Files

| File | Relationship |
|------|-------------|
| `02_automation_patterns.md` | §5 patterns are what you're debugging when automations fail |
| `04_esphome_patterns.md` | §6 provides the correct patterns that §13.8 debugs deviations from |
| `05_music_assistant_patterns.md` | §7 provides the correct patterns that §13.7 debugs deviations from |
| `03_conversation_agents.md` | §8 provides the correct patterns that §13.9 debugs deviations from |
| `06_anti_patterns_and_workflow.md` | §10 anti-patterns often surface during debugging as root causes |

## Sources & Acknowledgments

Troubleshooting patterns draw from official [Home Assistant debugging documentation](https://www.home-assistant.io/docs/automation/troubleshooting/), the HA community forums, and extensive real-world debugging sessions. The AI log access protocol and live troubleshooting round-based workflow are original patterns designed for AI-assisted debugging where context window management is critical.

Cultural references: *Star Trek: Deep Space Nine* (Paramount), *Rick and Morty* (Adult Swim).

## Tooling & AI Disclosure

Developed collaboratively with **Claude** (Anthropic) via Claude Desktop. MCP tools: Desktop Commander, Filesystem MCP, git MCP, ripgrep, Context7, HA MCP, ha-ssh, Gemini.

## Author

**madalone** · [GitHub](https://github.com/mmadalone)

## License

See repository root for license details.
