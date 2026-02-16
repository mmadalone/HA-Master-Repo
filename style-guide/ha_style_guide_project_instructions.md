# Home Assistant Style Guide — Master Index

**Style Guide Version: 3.19 — 2026-02-16** · Bump this on structural changes (new files, section renumbering, directive additions).

> **What you are reading:** This is a structured style guide for AI-assisted Home Assistant development. It governs how you generate YAML, prompts, and configs for this user's HA instance. The guide is split across 10 files (~110K tokens total — but you should never load more than ~15K for any task). **Do not load all files for every task** — use the routing table below to load only what's needed.

You are helping the user build and maintain Home Assistant blueprints, automations, scripts, conversation agent prompts, and related configuration. You have direct filesystem access to their HA config via SMB mount.

**Environment paths — defined in project instructions or user prompt, NOT in this guide:**
- **HA config path:** Provided by the user in each conversation (e.g., via file transfer rules or project instructions). Do not hardcode — reference it as "the HA config path."
- **Project root:** The user's local working directory for build logs, violations reports, and other development artifacts. Provided per-session.

---

## Operational Modes — Load Based on Task Type

Every task falls into one of three modes. The mode determines which style guide sections load, which gates apply, and how much ceremony is required. **Identify the mode FIRST, then use the routing table.**

| Mode | Trigger phrases | What loads | What's enforced | Token budget |
|------|----------------|------------|-----------------|-------------|
| **🔨 BUILD** | "create", "build", "add X to Y", "implement", "write", "new blueprint/script/automation" | Core Philosophy (§1) + relevant pattern doc(s) + Anti-Patterns & Workflow (§10, §11) | Everything — git versioning, build log gate (AP-39, every edit), header image gate (AP-15), pre-flight, anti-pattern scan, security checklist | ~15K |
| **🔧 TROUBLESHOOT** | "why isn't", "debug", "broken", "not working", "fix this", "error", "trace shows" | Troubleshooting (§13) + relevant domain pattern doc (optional, on demand) | Git versioning (if files are edited). Skip build logs, image gate, compliance sweep, anti-pattern scan | ~6–8K |
| **🔍 AUDIT** | "review", "check", "audit", "scan", "sanity check", "compliance", "violations" | Anti-Patterns §10 (scan tables + security checklist §10.5) + §11.2 (review workflow) + §15.4 (audit tiers) | Security checklist (S1–S8), structured issue reporting. **Mandatory log pairs** (§11.8.2) for every check command — unconditional, even with zero findings. No file edits — report only. Fixes require BUILD escalation. **Tier selection:** quick-pass (default) or deep-pass (§15.4). Deep-pass uses sectional chunking (§11.15). | ~5–7K (quick) · ~12–15K (deep, staged) |

**Mode escalation — TROUBLESHOOT → BUILD:**
When a troubleshooting session requires editing YAML to fix the issue, escalate to BUILD mode *before writing the first line*. On escalation:
1. Load the remaining BUILD-mode docs (§1 Core Philosophy, anti-patterns workflow, relevant pattern doc if not already loaded).
2. Run `ha_create_checkpoint` (git) before the first edit.
3. The escalation is one-way — once in BUILD mode, stay there.

**Hybrid tasks:** If a request is ambiguous (e.g., "fix and improve this blueprint"), default to BUILD mode — it's a superset.

---

## AI Task Routing — Load Only What You Need

> **🚨 LOG GATES (AP-39):** (a) **BUILD mode:** Every file edit requires a build log in `_build_logs/` **BEFORE the first write**. Compact or full format per §11.8. (b) **AUDIT mode:** Every `sanity check` or audit command (§15.2) requires a log pair (progress + report) per §11.8.2 **BEFORE the first check runs** — unconditional, even with zero findings. (c) **Escalation:** When check findings are approved for fixing, create a build log before the first edit. These are hard gates — not "I'll do it after."

> **🚨 HEADER IMAGE GATE (AP-15) — BUILD mode only:** When building a new blueprint/script OR reviewing one that has no `![` image in its description **or whose referenced image file does not exist on disk** (at `HEADER_IMG` — see Project Instructions for resolved path): **ask the user** about the header image, generate it, present it, and **wait for explicit approval or decline**. Do NOT write any YAML until you get a clear answer. If the user ignores the question, **insist** — repeat the ask. No exceptions. See §11.1 step 4 for defaults (1K, 16:9, premise from `IMG_PREMISES`). Allowed image formats: `.jpeg`, `.jpg`, `.png`, `.webp`.

**Mode-specific loading:**

| Mode | Always load | Load per task |
|------|-------------|---------------|
| **🔨 BUILD** | `00_core_philosophy.md` (§1) + §2.3 (pre-flight checklist) | Relevant pattern doc + `06_anti_patterns_and_workflow.md` (§10, §11.1 or §11.3) |
| **🔧 TROUBLESHOOT** | `07_troubleshooting.md` | Relevant domain pattern doc (optional, load §-level sections on demand) |
| **🔍 AUDIT** | `06_anti_patterns_and_workflow.md` (§10 scan tables, §10.5 security, §11.2, §11.15) | §1.11 (severity taxonomy) from Core Philosophy, §15.4 (audit tiers) from QA Checklist |

**Task-specific routing (BUILD mode):**

| Task | Load these files | Skip the rest |
|------|-----------------|---------------|
| Build a new blueprint | `01_blueprint_patterns.md` + `06_anti_patterns_and_workflow.md` (§11.1) | |
| Write automation logic | `02_automation_patterns.md` + `06_anti_patterns_and_workflow.md` (§11.1) | |
| Create/edit conversation agent | `03_conversation_agents.md` + `08_voice_assistant_pattern.md` | |
| Configure ESPHome device | `04_esphome_patterns.md` | |
| Music Assistant integration | `05_music_assistant_patterns.md` + `02_automation_patterns.md` (§5.1 timeouts) | |
| Edit an existing file | `06_anti_patterns_and_workflow.md` (§11.3) + the relevant pattern doc | |
| Generate/update a README | `06_anti_patterns_and_workflow.md` (§11.14) + the relevant pattern doc for context | |

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
| QA check commands (`sanity check`, `run audit`, `check <ID>`, `check versions`, etc.) | `09_qa_audit_checklist.md` (§15) + `06_anti_patterns_and_workflow.md` (§11.8.2 log pairs) |
| Deep-pass audit (full battery, staged) | `09_qa_audit_checklist.md` (§15.4 tier selection) + `06_anti_patterns_and_workflow.md` (§11.15 chunking + checkpointing) — then load per-stage sections per §11.15.1 |

> **Cross-domain tasks** (e.g., "blueprint that uses MA with voice control"): load each relevant pattern doc. When in doubt, load the anti-patterns file — it catches the most common AI mistakes.

---

## Style Guide Documents

The section numbers are preserved across files for cross-referencing.

| Doc | Sections | ~Tokens | Covers |
|-----|----------|---------|--------|
| [Core Philosophy](00_core_philosophy.md) | §1, §2, §9, §12 | ~12.0K (§1 alone: ~8.8K) | Design principles, git versioning workflow, naming conventions, communication style |
| [Blueprint Patterns](01_blueprint_patterns.md) | §3, §4 | ~7.2K | Blueprint YAML structure, inputs, variables, templates, script standards |
| [Automation Patterns](02_automation_patterns.md) | §5 | ~6.2K | Error handling, modes, timeouts, triggers, GPS bounce, helpers, area/label targeting |
| [Conversation Agents](03_conversation_agents.md) | §8 | ~8.0K | Agent prompt structure, separation from blueprints, naming conventions |
| [ESPHome Patterns](04_esphome_patterns.md) | §6 | ~6.1K | Device config structure, packages, secrets, wake words, naming |
| [Music Assistant Patterns](05_music_assistant_patterns.md) | §7 | ~11.1K | MA players, play_media, TTS duck/restore, volume sync, voice bridges |
| [Anti-Patterns & Workflow](06_anti_patterns_and_workflow.md) | §10, §11 | ~19.6K (scan table: ~4.9K) | Things to never do, build/review/edit workflows, README generation (§11.14), audit resilience (§11.15), crash recovery |
| [Troubleshooting & Debugging](07_troubleshooting.md) | §13 | ~6.9K | Traces, Developer Tools, failure modes, log analysis, domain-specific debugging |
| [Voice Assistant Pattern](08_voice_assistant_pattern.md) | §14 | ~11.8K | End-to-end voice stack architecture: ESPHome satellites, pipelines, agents, blueprints, tool scripts, helpers, TTS |
| [QA Audit Checklist](09_qa_audit_checklist.md) | §15 | ~12.7K | QA audit checks, trigger rules, cross-reference index, audit tiers (§15.4), and user commands for guide maintenance |

*Token estimates measured Feb 2026. Re-measure after structural changes. Budget ceiling: keep total loaded style guide content under ~15K tokens per task (§1.9). Total across all files: ~110K.*

> **Note on section numbering:** Section numbers are preserved from the original unified guide and are non-sequential across files. This is intentional — it allows stable cross-references (e.g., "see §5.1") regardless of how files are reorganized.

---

## Full Table of Contents

**15 top-level sections · 132 subsections · 43 anti-patterns (39 AP codes + 4 sub-items) · 8 security checks · 10 files**

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
  - §1.13 — Available tools and when to use them (MANDATORY) — §1.13.1 file ops, §1.13.2 HA ops, §1.13.3 known quirks, §1.13.4 decision rules
  - §1.14 — Session discipline and context hygiene
- **§2** — Git Versioning (Mandatory)
  - §2.1 — Scope — what gets versioned
  - §2.2 — Git workflow (checkpoint → edit → commit)
  - §2.3 — Pre-flight checklist (MANDATORY)
  - §2.4 — Atomic multi-file edits
  - §2.5 — Crash recovery via git
  - §2.6 — Git scope boundaries — don't overthink it
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
    - §11.8.2 — Sanity check and audit check log pairs (MANDATORY)
  - §11.9 — Convergence criteria — when to stop iterating
  - §11.10 — Abort protocol — when the user says stop
  - §11.11 — Prompt templates — starter prompts for common tasks
  - §11.12 — Post-generation validation — trust but verify
  - §11.13 — Large file editing (1000+ lines) — surgical read/edit/verify workflow (AP-40)
  - §11.14 — README generation workflow (MANDATORY for blueprints and scripts)
  - §11.15 — Audit resilience — sectional chunking & checkpointing (§11.15.1 four stages, §11.15.2 audit checkpointing)

### [Troubleshooting & Debugging](07_troubleshooting.md)
  - §13.1 — Automation traces — your first stop
  - §13.2 — Quick tests from the automation editor
  - §13.3 — Developer Tools patterns
  - §13.4 — The "why didn't my automation trigger?" flowchart
  - §13.5 — Common failure modes and symptoms
  - §13.6 — Log analysis
    - §13.6.1 — AI log file access protocol (MANDATORY)
    - §13.6.2 — Live troubleshooting protocol — long-running automations (MANDATORY)
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

### [QA Audit Checklist](09_qa_audit_checklist.md)

- **§15** — QA Audit Checklist
  - §15.1 — Check definitions (SEC, VER, AIR, CQ, ARCH, ZONE, INT, MAINT categories)
  - §15.2 — When to run checks (automatic triggers + user-triggered commands including `sanity check`)
  - §15.3 — Cross-reference index (which checks apply to which guide sections)
  - §15.4 — Audit tiers (quick-pass / deep-pass, tier selection rules, escalation)

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
- **Running a QA audit?** → 🔍 AUDIT: QA Audit Checklist (check definitions + trigger rules)

---

## Changelog

### v3.19 — 2026-02-16
- **§11.0 — Log invariants broadened and renamed** — Log-before-edit → **log-before-work**, log-after-edit → **log-after-work**. Both now MANDATORY for BUILD and AUDIT modes (previously BUILD-only). Before-work covers build logs, AUDIT log pairs (§11.8.2), and deep-pass checkpoint files (§11.15.2). After-work requires updating the relevant log after every file write (BUILD) or check/stage completion (AUDIT) before proceeding. Sequence: log → work → update log → next work. Closes the gap where the after-invariant was only implied across scattered subsections and audits had no explicit update-after-each-step rule.
- Build log: `_build_logs/2026-02-16_log_after_edit_invariant_build_log.md`

### v3.18 — 2026-02-16
- **§15.4 added** — Audit tiers: quick-pass (10 high-impact checks, single-turn) and deep-pass (full battery, sectional chunking). Tier selection rules, escalation from quick to deep on 3+ ERRORs, log pair requirements per tier.
- **§11.15 added** — Audit resilience: sectional chunking & checkpointing. Four-stage deep-pass execution (Security & Versions → Code Quality & Performance → AI-Readability & Architecture → Integration, Zones & Maintenance). Per-stage style guide loading, `[STAGE]` checkpoint markers with `IN_PROGRESS`/`COMPLETE`/`PENDING`/`SKIP` states, crash recovery protocol.
- **AUDIT mode row updated** — Token budget split: ~5–7K (quick-pass) / ~12–15K (deep-pass, staged). References §15.4 for tier selection and §11.15 for chunking.
- **Doc table updated** — Token estimates refreshed: `06_anti_patterns_and_workflow.md` ~16.0K → ~19.6K, `09_qa_audit_checklist.md` ~6K → ~12.7K. Total ~101K → ~110K.
- **TOC updated** — Added §11.15 (with subsections §11.15.1, §11.15.2) and §15.4 entries.
- Build log: `_build_logs/2026-02-16_audit_resilience_recovery_build_log.md` (recovery of crashed session `2026-02-16_audit_resilience_framework_build_log.md`)

### v3.17 — 2026-02-16
- **§3.2 hardened** — Collapsible input sections: removed "optional for 3-4 inputs" exception. All blueprints use collapsible sections, no exceptions. Added MANDATORY `collapsed: true` rule for section ③ and beyond (①–② remain expanded). YAML example updated with `collapsed: true` on ③ and ④. Cross-referenced `min_version: 2024.6.0` requirement.
- Build log: `_build_logs/2026-02-16_s3.2_collapsible_sections_hardening_build_log.md`

### v3.16 — 2026-02-15
- **§11.1 step 4 updated** — Replaced hardcoded "Rick & Morty (Adult Swim cartoon)" image style with dynamic `IMG_PREMISES` selection. AI reads a semicolon-delimited list of episode premise descriptions from Project Instructions, presents numbered options, and waits for user pick before generating. Falls back to generic prompt if `IMG_PREMISES` is missing/empty. Single-entry lists still require confirmation.
- **Parenthetical references updated** — All "(1K, 16:9, Rick & Morty style)" parentheticals replaced with "(1K, 16:9, premise from `IMG_PREMISES`)" in: master index HEADER IMAGE GATE callout, AP-15 rule #15 prose (§10), and §3.1 blueprint header.
- Build log: `_build_logs/2026-02-15_img_premises_dynamic_selection_build_log.md`

### v3.15 — 2026-02-15
- **AP-42 added** — Blueprint schema key whitelist. Catches `min_version:` or `icon:` placed directly under `blueprint:` instead of nested correctly (under `homeassistant:` for `min_version`, not valid at all for `icon`). Severity: ❌ ERROR. Triggered by an actual AI-generated bug where bare `min_version: 2024.10.0` under `blueprint:` caused `extra keys not allowed` at import.
- **§3.1 updated** — Added explicit valid `blueprint:` top-level key whitelist: `name`, `author`, `description`, `domain`, `source_url`, `homeassistant`, `input`. Documents common mistakes and correct nesting for `min_version` and `icon`.
- AP count: 42 → 43 (39 AP codes + 4 sub-items).
- Build log: `_build_logs/2026-02-15_ap42_blueprint_schema_keys_build_log.md`

### v3.14 — 2026-02-14
- **§11.8.2 added** — Mandatory log pairs for sanity checks and audit commands. Every `sanity check`, `run audit`, `check <ID>`, `check versions`, `check secrets`, `check vibe readiness`, and `run maintenance` now requires a progress + report log pair in `_build_logs/` BEFORE the first check runs. Unconditional — zero findings still gets logged.
- **AP-39 updated** — Three explicit gates: (a) BUILD-mode build log before first write, (b) AUDIT-mode log pair before first check, (c) BUILD escalation log before first fix. Scan table row and rule #39 prose rewritten.
- **AUDIT mode row updated** — Now requires mandatory log pairs (§11.8.2) unconditionally. "No build logs" guidance removed and replaced with log pair requirement.
- **LOG GATES callout updated** — Replaces "BUILD LOG GATE" — now covers BUILD, AUDIT, and escalation gates.
- **Sanity check prompt retired** — `_build_logs/sanity_check_prompt.md` deleted. Redundant — §15.2 execution standard and check definitions in §15.1 already cover the same ground. "Run a sanity check" is all that's needed.
- **QA checklist updated** — §15.2 command table now includes log pair requirement callout with AP-39 cross-reference.
- Build log: `_build_logs/2026-02-14_sanity_audit_log_pairs_build_log.md`

### v3.12 — 2026-02-14
- **AP-39 — all thresholds eliminated** — Every BUILD-mode file edit now requires a log in `_build_logs/` before the first write, regardless of change count or file count. Every AUDIT with findings requires an audit log, regardless of finding count or file count. Compact log format introduced for simple BUILD edits; full build log schema unchanged for multi-chunk builds and complex scopes.
  - AP-39 scan table trigger text rewritten for zero-threshold enforcement across both BUILD and AUDIT modes.
  - §11.0 log-before-edit invariant reworded — unconditional, no minimum change count.
  - §11.8 "When to create" rewritten with universal requirement + two-tier format table (compact vs full). Explicit TROUBLESHOOT→BUILD and AUDIT→BUILD escalation rules added. "When NOT to bother" section removed.
  - §11.2 step 0 rewritten — audit log now mandatory for any review with findings, not just 3+ files or 5+ findings. AUDIT→BUILD cross-reference added.
  - Master index BUILD LOG GATE callout and operational modes table updated.
- Build log: `_build_logs/2026-02-14_ap39_zero_threshold_build_log.md`

### v3.11 — 2026-02-14
- **§1.13 updated** — Added git MCP and Context7 to routing tables:
  - §1.13.1: git operations row (status, diff, log, add, commit) → git MCP for `GIT_REPO`. References Post-Edit Publish Workflow in project instructions.
  - §1.13.2: Context7 documentation lookups row (HA Jinja2, ESPHome, Music Assistant, integration docs). Two-step resolve → query pattern with web search fallback.
  - §1.13.3: Four new quirk entries — git MCP `repo_path` requirement, Context7 coverage gaps, Context7 multi-match disambiguation.
  - §1.13.4: Decision rules #9 (git on GIT_REPO → git MCP + publish workflow) and #10 (integration docs → Context7 → web search fallback).
  - Cross-references updated to include Post-Edit Publish Workflow.
- **§2.6 updated** — Replaced `sync-to-repo.sh` reference with Post-Edit Publish Workflow (Claude-native rsync + git MCP commit chain). Decision table updated for both `PROJECT_DIR` and mixed-scope edits.
- Build log: `_build_logs/2026-02-14_new_tool_integration_build_log.md`

### v3.10 — 2026-02-14
- **§1.13 rewritten** — Replaced tool-identity routing with operation-based routing. Tools assigned by what you're doing (search, read, edit, write), not which MCP server to reach for. Key changes:
  - **ripgrep** added as primary search tool — single-call context lines, line numbers, multi-match detail. DC `start_search` demoted to fallback.
  - **Filesystem MCP** blanket prohibition lifted — now authorized for reads and precise line-range targeting. Write prohibition remains.
  - **Known quirks table** (§1.13.3) added — documents DC `read_file` range unreliability, DC `start_search` context gaps, `edit_block` uniqueness requirements.
  - Section expanded from flat table to four subsections: §1.13.1 (file ops), §1.13.2 (HA ops), §1.13.3 (quirks), §1.13.4 (decision rules).
- Master index TOC updated with subsection references.

### v3.7 — 2026-02-14
- **Sanity check fixes** — All findings from the v3.6 sanity check resolved (1 ERROR, 2 WARNING, 2 INFO → 0).
- **§15 renumbered** — `09_qa_audit_checklist.md` now uses `## 15.1 — Check Definitions`, `## 15.2 — When to Run Checks`, `## 15.3 — Quick Grep Patterns`. Categories 1–8 demoted to `###` under 15.1. Master index TOC §15.x references now resolve.
- **Token estimates updated** — `00_core_philosophy.md`: ~8.5K → ~11.0K; §1 alone: ~5.7K → ~7.9K; `07_troubleshooting.md`: ~6.1K → ~6.9K. Added missing `09_qa_audit_checklist.md` row. Total: ~90K → ~92K.
- **VER-3 compliance** — `data_template` deprecation info added to AP-10b scan table and §11.3 migration table (deprecated ~HA 0.115/2020, no removal date announced).
- **VER-1 correction** — Two unverifiable MCP "2025.9+" claims in `03_conversation_agents.md` corrected to "2025.2+" (verified introduction date).
- **CQ-6 definition corrected** — Replaced incorrect `automation:` → `automations:` / `script:` → `scripts:` rows with the actual 2024.10 changes (`trigger:` → `triggers:`, `condition:` → `conditions:`, `action:` → `actions:` inside automations). Added note that top-level singular keys are valid.

### v3.6 — 2026-02-13
- **§11.8 updated** — Added build log boundary rule: build logs track decision metadata, not deliverable content. Codifies the correct approval-to-execution sequence: propose in conversation → user approves → create build log (metadata only) → write to target file. No re-presenting approved content, no intermediate draft files.

### v3.5 — 2026-02-13
- **§1.14 added** — Session discipline and context hygiene. Six rules: write-to-disk-immediately, post-task state checkpoints, reference-don't-repeat, artifact-first workflow, toolkit trimming per task type, and one-major-deliverable-per-session scoping. Introduces ~15-turn scope check threshold complementing §1.9's existing ~30-turn summary threshold.
- §1.9 updated with cross-reference to §1.14.6 dual-threshold system.
- Master index TOC updated.

### v3.4 — 2026-02-13
- **5 new QA checks added** — CQ-5 (YAML example validity), CQ-6 (modern syntax in examples), AIR-6 (token count accuracy), ARCH-4 (internal cross-reference integrity), ARCH-5 (routing reachability).
- **`sanity check` command added** — Technical correctness scan running SEC-1 + VER-1 + VER-3 + CQ-5 + CQ-6 + AIR-6 + ARCH-4 + ARCH-5. Flags broken things only, no style nits.
- `check vibe readiness` scope expanded to include AIR-6.
- Automatic trigger table updated: CQ-5/CQ-6 fire on YAML generation, ARCH-4/ARCH-5 fire on section renumbering.
- New grep patterns added to appendix for CQ-5, CQ-6, AIR-6, ARCH-4, ARCH-5.
- QA checklist token estimate updated: ~3K → ~6K. Total guide token estimate updated: ~86K → ~90K.

### v3.3 — 2026-02-13
- **`09_qa_audit_checklist.md` added** — QA audit checks (§15) with check definitions, automatic trigger rules, and cross-reference index. One-line `📋 QA Check` callouts wired into all 8 guide files (SEC-1, VER-3, AIR-4, CQ-1/3/4, ARCH-1, ZONE-1, INT-1 through INT-4). File count: 9 → 10.

### v3.2 — 2026-02-13
- **§1.13 added** — Available tools and when to use them (MANDATORY). Canonical routing table: Desktop Commander for all file I/O, HA MCP for service calls and automation CRUD, ha-ssh for container shell access and logs, Gemini for blueprint images only. Explicitly deprecates Filesystem MCP and documents that automation traces require the HA UI.
- Cross-references added to §2.6, §13.6.1, and §13.1.

### v3.1 — 2026-02-13
- **§13.6.2 added** — Live troubleshooting protocol for long-running automations (MANDATORY). Round-based workflow: baseline → trigger → wait for user → read. Prevents AI log polling and stale reads during multi-minute automation runs.
- Cross-reference added to §13.6.1 pointing to §13.6.2.

### v3.0 — 2026-02-13
- **Operational modes** — Added three-mode system (BUILD / TROUBLESHOOT / AUDIT) with mode-specific loading, gate enforcement, and escalation rules. Replaces the flat "always load §1" directive.
- **Git versioning migration** — Replaced all `_versioning/` references with git-based workflow. §2 rewritten entirely (see `00_core_philosophy.md`).
- **Path extraction** — Removed hardcoded HA config path and project root path from all style guide documents. Paths are now defined per-session in project instructions or user prompt.
- **Routing table restructured** — Separate routing tables per operational mode. Troubleshoot and audit modes have dedicated routing instead of sharing the build routing table.

### v2.6 — 2026-02-11
- Previous version (manual `_versioning/` workflow)
