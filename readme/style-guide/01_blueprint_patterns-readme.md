# Blueprint Patterns — Structure, Inputs & Script Standards

![Blueprint Patterns header](https://raw.githubusercontent.com/mmadalone/HA-Master-Repo/main/images/style-guide/01_blueprint_patterns-header.jpeg)

The construction manual for Home Assistant blueprints. This file defines how every blueprint should be structured — from the YAML header and description image down to individual input definitions, variable blocks, and action labels. If Core Philosophy tells you *what* to build, Blueprint Patterns tells you *how* to build it.

Two sections: §3 covers blueprint YAML structure and formatting rules. §4 covers script standards — because scripts are the extracted building blocks that keep blueprints under the complexity budget.

## What's Inside

**§3 — Blueprint Structure & YAML Formatting** starts with header and description image requirements (§3.1, with image premise selection driven by `IMG_PREMISES` in project instructions), then moves to collapsible input sections with Unicode numbering (§3.2) — a mandatory pattern that keeps 15+ inputs navigable. Input definitions (§3.3) cover typing, defaults, selectors, and the entity/device filter patterns. The variables block (§3.4) documents the centralized extraction pattern where all `!input` references live in one place. Action labels (§3.5) are mandatory for trace readability. Template safety (§3.6) codifies the `| default()` guard requirement on all `states()` calls and `is_defined` checks on trigger attributes. YAML formatting (§3.7) covers quoting, multiline strings, and comment conventions. HA 2024.10+ syntax (§3.8) mandates plural top-level keys and the `trigger:` keyword. A minimal complete blueprint (§3.9) provides a copy-paste-ready reference skeleton.

**§4 — Script Standards** defines required fields (§4.1) — every script needs `alias`, `description`, `icon`, and `mode`. Inline explanations (§4.2) and changelog-in-description (§4.3) round out the documentation requirements.

## When to Load

This is a T1 (task-specific) file. Load it when building or editing blueprints or scripts.

| Mode | When to load |
|------|-------------|
| BUILD | Any blueprint or script creation/editing task |
| TROUBLESHOOT | On demand — if debugging a blueprint structural issue |
| AUDIT | When reviewing blueprint compliance (paired with §10 anti-patterns) |

## Key Concepts

**Collapsible input sections** (§3.2) — mandatory for any blueprint with more than a handful of inputs. Unicode-numbered section headers (① ② ③) group related inputs and collapse in the HA UI, keeping the configuration page navigable.

**Variables block centralization** (§3.4) — all `!input` references are extracted into a single `variables:` block at the top of the action sequence. Actions reference the variable names, never `!input` directly. This prevents scattered input references and makes the data flow visible at a glance.

**Template safety** (§3.6) — every `states()` call gets a `| default()` guard. Every trigger attribute access gets an `is defined` check. Silent failures from missing defaults are the #1 cause of automation breakdowns that are nearly impossible to debug from traces alone.

**Action labels** (§3.5) — every action step, choose branch, and conditional block gets an `alias:` that describes what it does. These show up in automation traces and turn an opaque execution log into a readable narrative.

**Minimal complete blueprint** (§3.9) — a copy-paste skeleton that demonstrates every required element in the correct order: metadata, inputs with collapsible sections, variables block, triggers, conditions, and labeled actions.

## Related Files

| File | Relationship |
|------|-------------|
| `00_core_philosophy.md` | §1.1 (modular design) and §1.8 (complexity budget) set the limits this file implements |
| `02_automation_patterns.md` | §5 covers the automation logic that goes inside blueprint actions |
| `06_anti_patterns_and_workflow.md` | §10 scan tables catch blueprint anti-patterns; §11.1 defines the build workflow |
| `09_qa_audit_checklist.md` | CQ-1 through CQ-6 validate blueprint code quality |

## Sources & Acknowledgments

Blueprint structure patterns follow official [Home Assistant Blueprint documentation](https://www.home-assistant.io/docs/blueprint/). The collapsible input section pattern and Unicode numbering convention are original patterns developed for managing complex multi-section blueprints. Template safety rules draw from HA's Jinja2 templating documentation and hard-won debugging experience.

Cultural references: *Star Trek: Deep Space Nine* (Paramount), *Rick and Morty* (Adult Swim).

## Tooling & AI Disclosure

Developed collaboratively with **Claude** (Anthropic) via Claude Desktop. MCP tools: Desktop Commander, Filesystem MCP, git MCP, ripgrep, Context7, HA MCP, ha-ssh, Gemini.

## Author

**madalone** · [GitHub](https://github.com/mmadalone)

## License

See repository root for license details.
