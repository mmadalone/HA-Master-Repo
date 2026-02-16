# QA Audit Checklist — Checks, Triggers & Cross-References

![QA Audit Checklist header](https://raw.githubusercontent.com/mmadalone/HA-Master-Repo/main/images/style-guide/09_qa_audit_checklist-header.jpeg)

The quality assurance ledger. This file defines every QA check that can be run against the style guide and its governed codebase — what each check examines, when it triggers automatically, how the user can trigger it manually, and which sections of the guide each check validates. It's the self-referential layer: the guide checking itself.

One section — §15 — with four subsections: check definitions, trigger rules, the cross-reference index, and audit tiers.

## What's Inside

**§15.1 — Check Definitions** catalogues every QA check organized into eight categories:

- **SEC** (Security) — secrets exposure, authentication, credential handling
- **VER** (Version/Syntax) — deprecated syntax, version claims, HA compatibility
- **AIR** (Accuracy/Information) — documentation accuracy, example validity, token count correctness
- **CQ** (Code Quality) — YAML validity, modern syntax in examples, formatting consistency
- **ARCH** (Architecture) — internal cross-reference integrity, routing reachability, structural consistency
- **ZONE** (Scope/Boundaries) — file scope compliance, section boundary enforcement
- **INT** (Integration) — integration-specific pattern compliance
- **MAINT** (Maintenance) — staleness detection, changelog consistency, file hygiene

Each check has a unique ID (e.g., SEC-1, VER-3, CQ-6, ARCH-5), a description of what it validates, pass/fail criteria, and the severity level of findings.

**§15.2 — When to Run Checks** defines two trigger mechanisms: automatic triggers (checks that fire when specific actions occur, like YAML generation triggering CQ-5 and CQ-6) and user-triggered commands. The command table documents every command the user can issue: `sanity check` (technical correctness scan), `run audit` (full compliance sweep), `check <ID>` (individual check), `check versions`, `check secrets`, `check vibe readiness`, and `run maintenance`. Each command maps to specific check IDs and requires mandatory log pairs per AP-39.

**§15.3 — Cross-Reference Index** maps each check to the guide sections it validates, creating a bidirectional reference: from check to section and from section to applicable checks.

**§15.4 — Audit Tiers** defines two execution tiers: **quick-pass** (10 high-impact checks in a single turn, ~5–7K token budget) and **deep-pass** (full battery using sectional chunking from §11.15, ~12–15K staged). Quick-pass is the default for routine audits. Deep-pass fires on explicit request or when quick-pass escalates (3+ ERRORs trigger a deep-pass suggestion). Each tier has its own check roster, token budget, and log pair requirements.

## When to Load

Primary file for AUDIT mode. Load when running any QA check command.

| Mode | When to load |
|------|-------------|
| BUILD | Not loaded by default. Referenced if a build triggers automatic checks. |
| TROUBLESHOOT | Not loaded by default |
| AUDIT | Always — paired with §10/§11.2 from Anti-Patterns & Workflow. §15.4 determines quick-pass vs deep-pass tier. |

## Key Concepts

**Sanity check** — the most commonly used command. Runs a focused set of technical correctness checks: SEC-1 (secrets), VER-1 (version claims), VER-3 (deprecated syntax), CQ-5 (YAML validity), CQ-6 (modern syntax), AIR-6 (token counts), ARCH-4 (cross-references), and ARCH-5 (routing reachability). Flags broken things only — no style nits.

**Mandatory log pairs** (AP-39, §11.8.2) — every QA check command requires a progress log and a report log in `_build_logs/` before the first check runs. This is unconditional — even a check that finds zero issues generates its log pair. The progress log tracks which checks are running and their status; the report log captures findings.

**Automatic triggers** — some checks fire without explicit user commands. CQ-5 and CQ-6 trigger on any YAML generation. ARCH-4 and ARCH-5 trigger on section renumbering. SEC-1 triggers on any file write containing potential credentials. These are wired into the BUILD and AUDIT mode workflows.

**Cross-reference integrity** (ARCH-4) — validates that every `§X.Y` reference in the guide points to an actual section that exists. Cross-references are the guide's internal hyperlinks — broken ones mean rules that cite non-existent sections, which erodes trust in the entire system.

**Routing reachability** (ARCH-5) — validates that every style guide file and every operational mode command appears in at least one routing table entry. Unreachable files are dead weight; unreachable commands are features the AI doesn't know how to trigger.

**Audit tiers** (§15.4) — not every audit needs the full battery. Quick-pass runs 10 checks in a single turn for routine reviews. Deep-pass runs everything using sectional chunking (§11.15) to avoid context overload. The tier system is what prevents audits from crashing on the ~110K token guide — the problem that motivated the audit resilience framework.

## Related Files

| File | Relationship |
|------|-------------|
| `06_anti_patterns_and_workflow.md` | §10 anti-patterns and §10.5 security checks are validated by QA checks; §11.8.2 defines log pair requirements; §11.15 provides audit resilience (sectional chunking for deep-pass) |
| `00_core_philosophy.md` | §1.11 (severity taxonomy) governs how QA findings are classified |
| `ha_style_guide_project_instructions.md` | Master index routing table maps `sanity check` and audit commands to this file |
| All style guide files | Every file has `📋 QA Check` callouts linking to relevant checks |

## Sources & Acknowledgments

QA check patterns are original, designed for systematic validation of AI-assisted development style guides. The category system (SEC, VER, AIR, CQ, ARCH, ZONE, INT, MAINT) was developed to cover the full spectrum of documentation quality concerns. The mandatory log pair system draws from standard engineering audit trail practices.

Cultural references: *Star Trek: Deep Space Nine* (Paramount), *Rick and Morty* (Adult Swim).

## Tooling & AI Disclosure

Developed collaboratively with **Claude** (Anthropic) via Claude Desktop. MCP tools: Desktop Commander, Filesystem MCP, git MCP, ripgrep, Context7, HA MCP, ha-ssh, Gemini.

## Author

**madalone** · [GitHub](https://github.com/mmadalone)

## License

See repository root for license details.
