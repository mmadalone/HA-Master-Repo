# Home Assistant Style Guide — Master Index

![Master Index header](https://raw.githubusercontent.com/mmadalone/HA-Master-Repo/main/images/style-guide/ha_style_guide_project_instructions-header.jpeg)

The central routing hub for the entire Home Assistant Style Guide system. This file doesn't contain coding rules itself — it tells the AI *which* rules to load, *when* to load them, and *how much* context budget to spend. Think of it as the Grand Nagus's ledger: every section of the Rules of Acquisition is catalogued here, cross-referenced, and budgeted down to the token.

The style guide governs AI-assisted development of Home Assistant blueprints, automations, scripts, conversation agents, ESPHome devices, and Music Assistant integrations. At ~93K tokens across 10 files, it's far too large to load in full — the master index ensures only the relevant sections enter context for any given task.

## What's Inside

The master index defines three **operational modes** — BUILD, TROUBLESHOOT, and AUDIT — each with its own loading rules, enforcement gates, and token budgets. A task-specific routing table maps every common operation (new blueprint, debug automation, review existing code, QA check) to the exact files and sections the AI should load. The full table of contents catalogues all 15 top-level sections, 128 subsections, 42 anti-patterns, and 8 security checks across the guide.

The file also maintains the guide's **changelog**, tracking every structural change from the initial v2.6 through the current v3.14. Each entry references the build log that produced it, creating a complete audit trail.

## When to Load

This file's §1 routing table is loaded at the start of every session to determine what else needs loading. The full table of contents is reference material — load it only when navigating cross-references or verifying section numbers.

| Mode | What to load from this file |
|------|----------------------------|
| BUILD | Routing table (mode-specific + task-specific rows) |
| TROUBLESHOOT | Routing table (troubleshoot rows only) |
| AUDIT | Routing table (audit rows) + changelog (for version verification) |

## Key Concepts

**Operational modes** dictate everything. BUILD mode enforces the full ceremony — git versioning, build logs, header image gates, anti-pattern scans. TROUBLESHOOT mode strips that down to just "find and fix the problem." AUDIT mode is read-only with mandatory structured reporting. Mode escalation is one-way: TROUBLESHOOT can escalate to BUILD, but never the reverse.

**Token budget ceiling** is ~15K per task. The routing table exists specifically to stay under this limit while ensuring no critical rule is missed. Cross-domain tasks load pattern docs sequentially, not simultaneously.

**Log gates** (AP-39) are enforced at three points: BUILD-mode file edits, AUDIT-mode check commands, and BUILD escalation from audit findings. All are hard gates — the log must exist before the first write or check.

## Related Files

Every file in the style guide is routed through this index. The ten document files and their primary domains:

| File | Domain |
|------|--------|
| `00_core_philosophy.md` | Design principles, git versioning, naming, communication style |
| `01_blueprint_patterns.md` | Blueprint YAML structure, inputs, variables, script standards |
| `02_automation_patterns.md` | Error handling, modes, timeouts, triggers, helpers |
| `03_conversation_agents.md` | Agent prompts, separation of concerns, multi-agent coordination |
| `04_esphome_patterns.md` | Device configs, packages, secrets, wake words |
| `05_music_assistant_patterns.md` | MA players, play_media, TTS duck/restore, volume sync |
| `06_anti_patterns_and_workflow.md` | Things to never do, build/review/edit workflows |
| `07_troubleshooting.md` | Traces, Developer Tools, failure modes, log analysis |
| `08_voice_assistant_pattern.md` | End-to-end voice stack architecture (6-layer model) |
| `09_qa_audit_checklist.md` | QA checks, trigger rules, cross-reference index |

## Sources & Acknowledgments

The style guide draws on official [Home Assistant documentation](https://www.home-assistant.io/docs/), [ESPHome documentation](https://esphome.io/), [Music Assistant documentation](https://music-assistant.io/), and the [Extended OpenAI Conversation](https://github.com/jekalmin/extended_openai_conversation) integration. The operational mode system and token budget management are original architectural patterns developed through iterative refinement.

Cultural references throughout the guide are inspired by *Star Trek: Deep Space Nine* (Paramount) — particularly Quark and the Ferengi Rules of Acquisition — and *Rick and Morty* (Adult Swim).

## Tooling & AI Disclosure

This style guide and its documentation were developed collaboratively with **Claude** (Anthropic) via Claude Desktop, using the following MCP tool integrations: Desktop Commander (file operations), Filesystem MCP (precise reads), git MCP (version control), ripgrep (content search), Context7 (documentation lookups), HA MCP (Home Assistant operations), ha-ssh (container access), and Gemini (header image generation).

## Author

**madalone** · [GitHub](https://github.com/mmadalone)

## License

See repository root for license details.
