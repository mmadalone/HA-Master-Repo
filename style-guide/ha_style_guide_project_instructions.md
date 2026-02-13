# Home Assistant Style Guide — Master Index

**Style Guide Version: 3.0 — 2026-02-13** · Bump this on structural changes (new files, section renumbering, directive additions).

> **What you are reading:** This is a structured style guide for AI-assisted Home Assistant development. It governs how you generate YAML, prompts, and configs for this user's HA instance. The guide is split across 9 files (~83K tokens total — but you should never load more than ~15K for any task). **Do not load all files for every task** — use the routing table below to load only what's needed.

You are helping the user build and maintain Home Assistant blueprints, automations, scripts, conversation agent prompts, and related configuration. You have direct filesystem access to their HA config via SMB mount.

**Environment paths — defined in project instructions or user prompt, NOT in this guide:**
- **HA config path:** Provided by the user in each conversation (e.g., via file transfer rules or project instructions). Do not hardcode — reference it as "the HA config path."
- **Project root:** The user's local working directory for build logs, violations reports, and other development artifacts. Provided per-session.

---

## Operational Modes — Load Based on Task Type

Every task falls into one of three modes. The mode determines which style guide sections load, which gates apply, and how much ceremony is required. **Identify the mode FIRST, then use the routing table.**

| Mode | Trigger phrases | What loads | What's enforced | Token budget |
|------|----------------|------------|-----------------|-------------|
| **🔨 BUILD** | "create", "build", "add X to Y", "implement", "write", "new blueprint/script/automation" | Core Philosophy (§1) + relevant pattern doc(s) + Anti-Patterns & Workflow (§10, §11) | Everything — git versioning, build log gate (AP-39), header image gate (AP-15), pre-flight, anti-pattern scan, security checklist | ~15K |
| **🔧 TROUBLESHOOT** | "why isn't", "debug", "broken", "not working", "fix this", "error", "trace shows" | Troubleshooting (§13) + relevant domain pattern doc (optional, on demand) | Git versioning (if files are edited). Skip build logs, image gate, compliance sweep, anti-pattern scan | ~6–8K |
| **🔍 AUDIT** | "review", "check", "audit", "scan", "compliance", "violations" | Anti-Patterns §10 (scan tables + security checklist §10.5) + §11.2 (review workflow) | Security checklist (S1–S8), structured issue reporting. No build logs. No file edits — report only | ~5–7K |

**Mode escalation — TROUBLESHOOT → BUILD:**
When a troubleshooting session requires editing YAML to fix the issue, escalate to BUILD mode *before writing the first line*. On escalation:
1. Load the remaining BUILD-mode docs (§1 Core Philosophy, anti-patterns workflow, relevant pattern doc if not already loaded).
2. Run `ha_create_checkpoint` (git) before the first edit.
3. The escalation is one-way — once in BUILD mode, stay there.

**Hybrid tasks:** If a request is ambiguous (e.g., "fix and improve this blueprint"), default to BUILD mode — it's a superset.

---

## AI Task Routing — Load Only What You Need

> **🚨 BUILD LOG GATE (AP-39) — BUILD mode only:** Before editing ANY file, count your planned changes. If you have **5+ violations/changes on a single file** OR **3+ files in scope**, you MUST create a build/audit log in `_build_logs/` per §11.8 **BEFORE your first edit**. The log must be on disk before any target file is touched. This is a hard gate — not "I'll do it after" and not "it's just one file." Check the threshold, create the log, THEN edit. Every time.

> **🚨 HEADER IMAGE GATE (AP-15) — BUILD mode only:** When building a new blueprint/script OR reviewing one that has no `![` image in its description **or whose referenced image file does not exist on disk** (`/config/www/blueprint-images/`): **ask the user** about the header image, generate it, present it, and **wait for explicit approval or decline**. Do NOT write any YAML until you get a clear answer. If the user ignores the question, **insist** — repeat the ask. No exceptions. See §11.1 step 4 for defaults (1K, 16:9, Rick & Morty style). Allowed image formats: `.jpeg`, `.jpg`, `.png`, `.webp`.

**Mode-specific loading:**

| Mode | Always load | Load per task |
|------|-------------|---------------|
| **🔨 BUILD** | `00_core_philosophy.md` (§1) + §2.3 (pre-flight checklist) | Relevant pattern doc + `06_anti_patterns_and_workflow.md` (§10, §11.1 or §11.3) |
| **🔧 TROUBLESHOOT** | `07_troubleshooting.md` | Relevant domain pattern doc (optional, load §-level sections on demand) |
| **🔍 AUDIT** | `06_anti_patterns_and_workflow.md` (§10 scan tables, §10.5 security, §11.2) | §1.11 (severity taxonomy) from Core Philosophy |

**Task-specific routing (BUILD mode):**

| Task | Load these files | Skip the rest |
|------|-----------------|---------------|
| Build a new blueprint | `01_blueprint_patterns.md` + `06_anti_patterns_and_workflow.md` (§11.1) | |
| Write automation logic | `02_automation_patterns.md` + `06_anti_patterns_and_workflow.md` (§11.1) | |
| Create/edit conversation agent | `03_conversation_agents.md` + `08_voice_assistant_pattern.md` | |
| Configure ESPHome device | `04_esphome_patterns.md` | |
| Music Assistant integration | `05_music_assistant_patterns.md` + `02_automation_patterns.md` (§5.1 timeouts) | |
| Edit an existing file | `06_anti_patterns_and_workflow.md` (§11.3) + the relevant pattern doc | |

**Task-specific routing (TROUBLESHOOT mode):**

| Task | Load these files | Skip the rest |
|------|-----------------|---------------|
| Debug automation/blueprint | `07_troubleshooting.md` (§13.1–§13.5) | Pattern docs on demand only |
| Debug Music Assistant | `07_troubleshooting.md` (§13.7) | Optionally §7 for MA patterns |
| Debug ESPHome device | `07_troubleshooting.md` (§13.8) | Optionally §6 for ESPHome patterns |
| Debug conversation agent | `07_troubleshooting.md` (§13.9) | Optionally §8 for agent patterns |
| Debug voice stack | `07_troubleshooting.md` + `08_voice_assistant_pattern.md` | |

**Task-specific routing (AUDIT mode):**

| Task | Load these files |
|------|-----------------|
| Review/improve existing code | `06_anti_patterns_and_workflow.md` (§10, §10.5, §11.2) + relevant pattern doc for context |
| Multi-file compliance sweep | `06_anti_patterns_and_workflow.md` (§10, §10.5, §11.2, §11.8.1) |

> **Cross-domain tasks** (e.g., "blueprint that uses MA with voice control"): load each relevant pattern doc. When in doubt, load the anti-patterns file — it catches the most common AI mistakes.

---

## Style Guide Documents

The section numbers are preserved across files for cross-referencing.

| Doc | Sections | ~Tokens | Covers |
|-----|----------|---------|--------|
| [Core Philosophy](00_core_philosophy.md) | §1, §2, §9, §12 | ~8.5K (§1 alone: ~5.7K) | Design principles, git versioning workflow, naming conventions, communication style |
| [Blueprint Patterns](01_blueprint_patterns.md) | §3, §4 | ~6.8K | Blueprint YAML structure, inputs, variables, templates, script standards |
| [Automation Patterns](02_automation_patterns.md) | §5 | ~6.2K | Error handling, modes, timeouts, triggers, GPS bounce, helpers, area/label targeting |
| [Conversation Agents](03_conversation_agents.md) | §8 | ~8.3K | Agent prompt structure, separation from blueprints, naming conventions |
| [ESPHome Patterns](04_esphome_patterns.md) | §6 | ~6.0K | Device config structure, packages, secrets, wake words, naming |
| [Music Assistant Patterns](05_music_assistant_patterns.md) | §7 | ~11.5K | MA players, play_media, TTS duck/restore, volume sync, voice bridges |
| [Anti-Patterns & Workflow](06_anti_patterns_and_workflow.md) | §10, §11 | ~13.2K (scan table: ~4.9K) | Things to never do, build/review/edit workflows, crash recovery (build + audit) |
| [Troubleshooting & Debugging](07_troubleshooting.md) | §13 | ~6.1K | Traces, Developer Tools, failure modes, log analysis, domain-specific debugging |
| [Voice Assistant Pattern](08_voice_assistant_pattern.md) | §14 | ~11.8K | End-to-end voice stack architecture: ESPHome satellites, pipelines, agents, blueprints, tool scripts, helpers, TTS |

*Token estimates measured Feb 2026. Re-measure after structural changes. Budget ceiling: keep total loaded style guide content under ~15K tokens per task (§1.9).*

> **Note on section numbering:** Section numbers are preserved from the original unified guide and are non-sequential across files. This is intentional — it allows stable cross-references (e.g., "see §5.1") regardless of how files are reorganized.

---

## Full Table of Contents

**14 top-level sections · 120 subsections · 40 anti-patterns (36 AP codes + 4 sub-items) · 8 security checks · 9 files**

### [Core Philosophy](00_core_philosophy.md)

- **§1** — Core Philosophy
  - §1.1 — Modular over monolithic
  - §1.2 — Separation of concerns
  - §1.3 — Never remove features without asking
  - §1.4 — Follow official HA best practices and integration docs
  - §1.5 — Use `entity_id` over `device_id`
  - §1.6 — Secrets management
  - §1.7 — Uncertainty signals — stop and ask, don't guess
    - §1.7.1 — Requirement ambiguity — when the user's request is vague
    - §1.7.2 — Scope: single-user project
  - §1.8 — Complexity budget — quantified limits
  - §1.9 — Token budget management — load only what you need
  - §1.10 — Reasoning-first directive — explain before you code (MANDATORY)
  - §1.11 — Violation report severity taxonomy (ERROR / WARNING / INFO)
  - §1.12 — Directive precedence — when MANDATORYs conflict
- **§2** — Git Versioning (Mandatory)
  - §2.1 — Scope — what gets versioned
  - §2.2 — Git workflow (checkpoint → edit → commit)
  - §2.3 — Pre-flight checklist (MANDATORY)
  - §2.4 — Atomic multi-file edits
  - §2.5 — Crash recovery via git
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
  - §3.8 — HA 2024.10+ syntax (MANDATORY)
  - §3.9 — Minimal complete blueprint (copy-paste-ready reference)
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
  - §5.12 — Idempotency — every action safe to run twice

### [Conversation Agents](03_conversation_agents.md)

- **§8** — Conversation Agent Prompt Standards
  - §8.1 — Follow the integration's official documentation
  - §8.2 — Separation from blueprints
  - §8.3 — Mandatory prompt sections
  - §8.3.1 — Example prompt skeleton
  - §8.3.2 — Tool/function exposure patterns
  - §8.3.3 — MCP servers as tool sources (HA 2025.2+)
  - §8.4 — Agent naming convention
  - §8.5 — Multi-agent coordination
  - §8.6 — Voice pipeline constraints on agent behavior

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
  - §6.12 — Sub-devices (multi-function boards)

### [Music Assistant Patterns](05_music_assistant_patterns.md)

- **§7** — Music Assistant Patterns
  - §7.1 — MA players vs generic media_players
  - §7.2 — `music_assistant.play_media` — not `media_player.play_media`
  - §7.3 — Stop vs Pause — when to use which
  - §7.4 — TTS interruption and resume (duck/restore pattern)
  - §7.5 — Volume sync between platforms (Alexa ↔ MA)
  - §7.6 — Presence-aware player selection
  - §7.7 — Voice command → MA playback bridge (input_boolean pattern)
  - §7.8 — Voice playback initiation (LLM script-as-tool)
  - §7.8.1 — Search → select → play pattern (disambiguation)
  - §7.9 — Voice media control (thin-wrapper pattern)
  - §7.10 — MA + TTS coexistence on Voice PE speakers
  - §7.11 — Extra zone mappings for shared speakers

### [Anti-Patterns & Workflow](06_anti_patterns_and_workflow.md)

- **§10** — Anti-Patterns (Never Do These)
  - §10 scan tables — AP-01 through AP-39, grouped by domain (Core, ESPHome, MA, Dev Env) with severity tiers
  - §10.5 — Security review checklist (S1–S8, runs after scan tables)
  - General prose (1–24)
  - ESPHome (25–29)
  - Music Assistant (30–35)
  - Development Environment (36–39)
- **§11** — Workflow
  - §11.0 — Universal pre-flight (applies to ALL workflows)
  - §11.1 — When the user asks to build something new
  - §11.2 — When the user asks to review/improve something
  - §11.3 — When editing existing files
  - §11.4 — When producing conversation agent prompts
  - §11.5 — Chunked file generation (Mandatory for files over ~150 lines)
  - §11.6 — Checkpointing before complex builds
  - §11.7 — Prompt decomposition — how to break complex requests
  - §11.8 — Resume from crash — recovering mid-build or mid-audit
    - §11.8.1 — Audit and multi-file scan logs
  - §11.9 — Convergence criteria — when to stop iterating
  - §11.10 — Abort protocol — when the user says stop
  - §11.11 — Prompt templates — starter prompts for common tasks
  - §11.12 — Post-generation validation — trust but verify
  - §11.13 — Large file editing (1000+ lines) — surgical read/edit/verify workflow (AP-40)

### [Troubleshooting & Debugging](07_troubleshooting.md)

- **§13** — Troubleshooting & Debugging
  - §13.1 — Automation traces — your first stop
  - §13.2 — Quick tests from the automation editor
  - §13.3 — Developer Tools patterns
  - §13.4 — The "why didn't my automation trigger?" flowchart
  - §13.5 — Common failure modes and symptoms
  - §13.6 — Log analysis
    - §13.6.1 — AI log file access protocol (MANDATORY)
  - §13.7 — Debugging Music Assistant issues
  - §13.8 — Debugging ESPHome devices
  - §13.9 — Debugging conversation agents
  - §13.10 — The nuclear options

### [Voice Assistant Pattern](08_voice_assistant_pattern.md)

- **§14** — Voice Assistant Pattern (6-layer voice interaction chain)
  - §14.1 — Architecture overview
  - §14.2 — Layer 1: ESPHome Voice PE satellites (device configs, structure, key principles)
  - §14.3 — Layer 2: HA Voice Pipeline (pipeline-to-satellite mapping)
  - §14.4 — Layer 3: Conversation agents (naming, prompts, separation of concerns, tool exposure)
  - §14.5 — Layer 4: Blueprints / orchestration (Coming Home, Proactive LLM Sensors, Voice Active Media Controls)
  - §14.6 — Layer 5: Tool scripts (thin wrappers, script blueprint pattern)
  - §14.7 — Layer 6: Helpers / shared state (ducking flags, volume storage, voice command bridges)
  - §14.8 — TTS output patterns (ElevenLabs routing, post-TTS delay)
  - §14.9 — Data flow summary (interactive conversation, one-shot announcement)
  - §14.10 — Common gotchas & anti-patterns
  - §14.11 — File locations reference
  - §14.12 — Style guide cross-references

---

## Quick Reference — When to Read What

- **Building a new blueprint?** → 🔨 BUILD: Core Philosophy + Blueprint Patterns + Anti-Patterns & Workflow
- **Writing automation logic?** → 🔨 BUILD: Automation Patterns (especially §5.1 timeouts, §5.4 modes)
- **Setting up a conversation agent?** → 🔨 BUILD: Conversation Agents + Core Philosophy §1.2
- **Configuring an ESPHome device?** → 🔨 BUILD: ESPHome Patterns
- **Working with Music Assistant?** → 🔨 BUILD: Music Assistant Patterns + Automation Patterns §5.1
- **Reviewing existing code?** → 🔍 AUDIT: Anti-Patterns & Workflow §11.2 + the relevant pattern doc
- **Something isn't working?** → 🔧 TROUBLESHOOT: Troubleshooting & Debugging (start at §13.4 flowchart)
- **Understanding the voice stack?** → 🔨 BUILD or 🔧 TROUBLESHOOT: Voice Assistant Pattern (end-to-end architecture reference)
- **Reading logs or traces?** → 🔧 TROUBLESHOOT: Troubleshooting §13.1 (traces) and §13.6 (logs)

---

## Changelog

### v3.0 — 2026-02-13
- **Operational modes** — Added three-mode system (BUILD / TROUBLESHOOT / AUDIT) with mode-specific loading, gate enforcement, and escalation rules. Replaces the flat "always load §1" directive.
- **Git versioning migration** — Replaced all `_versioning/` references with git-based workflow. §2 rewritten entirely (see `00_core_philosophy.md`).
- **Path extraction** — Removed hardcoded HA config path and project root path from all style guide documents. Paths are now defined per-session in project instructions or user prompt.
- **Routing table restructured** — Separate routing tables per operational mode. Troubleshoot and audit modes have dedicated routing instead of sharing the build routing table.

### v2.6 — 2026-02-11
- Previous version (manual `_versioning/` workflow)
