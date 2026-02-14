# Core Philosophy — Design Principles, Versioning & Naming

![Core Philosophy header](https://raw.githubusercontent.com/mmadalone/HA-Master-Repo/main/images/style-guide/00_core_philosophy-header.jpeg)

The foundation everything else builds on. This file contains the non-negotiable rules that apply to every task, every file, and every mode of operation — the principles that don't change whether you're building a new blueprint, debugging a broken automation, or auditing existing code for compliance.

Four sections live here: §1 (Core Philosophy) establishes the design principles and mandatory directives. §2 (Git Versioning) defines the checkpoint-edit-commit workflow. §9 (Naming Conventions) standardizes how files, entities, and helpers are named. §12 (Communication Style) sets the tone — yes, the Quark voice is codified in the style guide.

## What's Inside

**§1 — Core Philosophy** is the beating heart of the guide. Thirteen subsections covering modular design (§1.1), separation of concerns (§1.2), the "never remove features" rule (§1.3), HA best practices with a native conditions substitution table (§1.4), entity_id-over-device_id (§1.5), secrets management (§1.6), uncertainty signals (§1.7), complexity budgets with quantified limits (§1.8), token budget management with per-file costs and drop rules (§1.9), the reasoning-first directive (§1.10), violation severity taxonomy (§1.11), directive precedence when MANDATORYs conflict (§1.12), MCP tool routing tables organized by operation type (§1.13), and session discipline rules (§1.14).

**§2 — Git Versioning** defines the mandatory pre-flight checklist, the checkpoint → edit → commit workflow, atomic multi-file edit rules, crash recovery via git, and scope boundaries between HA config git and the style guide repo.

**§9 — Naming Conventions** covers blueprints (snake_case filenames, Title Case names), scripts (descriptive IDs with required alias/description/icon), helpers (persona-prefixed naming), automations (human-readable aliases), categories and labels (HA 2024.4+), and the packages pattern for feature-based config organization.

**§12 — Communication Style** codifies the Quark voice with anti-examples, the "explain as you go" narration principle, and the balance between personality and technical precision.

## When to Load

§1 (Core Philosophy) loads for every BUILD-mode task — it's the T0 (always-load) tier. The pre-flight checklist from §2.3 loads before any file edit. The remaining sections (§2 details, §9, §12) are reference material loaded on demand.

| Mode | What to load |
|------|-------------|
| BUILD | §1 always. §2.3 (pre-flight) before edits. §9 and §12 on demand. |
| TROUBLESHOOT | Not loaded by default. §1.7 (uncertainty signals) if needed. |
| AUDIT | §1.11 (severity taxonomy) for structured reporting. |

## Key Concepts

**Modular over monolithic** (§1.1) — prefer small, composable pieces. If a blueprint exceeds ~200 lines of action logic, extract into scripts or helper automations. Always discuss decomposition with the user before deciding.

**Complexity budget** (§1.8) — hard ceilings on nesting depth (4 levels), choose branches (5 max), variables per block (15 max), and action lines (~200). These aren't arbitrary — they mark where HA traces become unreadable.

**Reasoning-first** (§1.10) — explain the approach before generating any code. Non-negotiable. The reasoning step catches hallucinations before they ship.

**Directive precedence** (§1.12) — when mandatory rules conflict, security wins, then git versioning, then template safety, then timeouts, then reasoning-first. The user can override style preferences but not safety guardrails.

**Operation-based tool routing** (§1.13) — tools are assigned by what you're doing (search, read, edit, write), not by which MCP server to reach for. ripgrep for search, Desktop Commander for writes, Filesystem MCP for precise line-range reads.

## Related Files

| File | Relationship |
|------|-------------|
| `ha_style_guide_project_instructions.md` | Master index — routes to this file for BUILD mode |
| `06_anti_patterns_and_workflow.md` | §10 anti-patterns enforce the principles defined here; §11 workflows implement §2's versioning |
| `09_qa_audit_checklist.md` | QA checks (SEC, VER, CQ) validate compliance with §1's rules |
| All pattern docs | Every pattern doc assumes §1's principles as baseline |

## Sources & Acknowledgments

Design principles draw from official [Home Assistant documentation](https://www.home-assistant.io/docs/) best practices, particularly the native conditions preference table and 2024.10+ syntax migration. Git versioning patterns follow standard checkpoint-commit workflows adapted for AI-assisted development. The MCP tool routing system was developed through iterative refinement across Desktop Commander, Filesystem MCP, ripgrep, git MCP, and Context7 integrations.

Cultural references: *Star Trek: Deep Space Nine* (Paramount) — Quark's communication style. *Rick and Morty* (Adult Swim) — collaborative imagery.

## Tooling & AI Disclosure

Developed collaboratively with **Claude** (Anthropic) via Claude Desktop. MCP tools: Desktop Commander, Filesystem MCP, git MCP, ripgrep, Context7, HA MCP, ha-ssh, Gemini.

## Author

**madalone** · [GitHub](https://github.com/mmadalone)

## License

See repository root for license details.
