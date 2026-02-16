# Anti-Patterns & Workflow — What Never to Do, and How to Do Everything Else

![Anti-Patterns & Workflow header](https://raw.githubusercontent.com/mmadalone/HA-Master-Repo/main/images/style-guide/06_anti_patterns_and_workflow-header.jpeg)

The biggest file in the guide, and for good reason — this is where the bodies are buried. §10 catalogues 43 anti-patterns across four domains with severity classifications, organized into scan tables that the AI runs against every piece of generated code. §11 defines every workflow: building new things, reviewing existing code, editing files, producing agent prompts, chunked generation, crash recovery, and the build log system that makes it all recoverable.

At ~19.6K tokens, this is never loaded in full. The scan tables (~4.9K) plus the relevant workflow section is the typical load.

## What's Inside

**§10 — Anti-Patterns (Never Do These)** is organized into domain-specific scan tables. Core anti-patterns (AP-01 through AP-24) cover the universal mistakes: hardcoded entity IDs, missing timeouts, forgotten `continue_on_error` guards, unprotected `states()` calls, `device_id` usage, and dozens more. ESPHome anti-patterns (AP-25 through AP-29) target device config mistakes. Music Assistant anti-patterns (AP-30 through AP-35) catch MA-specific errors like using `media_player.play_media` instead of the MA-native service. Development environment anti-patterns (AP-36 through AP-43) enforce the tooling and workflow rules — including AP-39 (zero-threshold build log gate) and AP-43 (Edit Log updates between consecutive edits).

**§10.5 — Security Review Checklist** defines eight security checks (S1–S8) that run after the anti-pattern scan: secrets exposure, API key handling, authentication, network exposure, input validation, privilege escalation, logging of sensitive data, and credential rotation reminders.

**§11 — Workflow** covers every operational procedure. §11.0 is the universal pre-flight that applies to all workflows, including the **log-before-work** and **log-after-work** invariants — mandatory for both BUILD and AUDIT modes, enforcing the sequence: log → work → update log → next work. §11.1 handles building something new (the full ceremony: reason → checkpoint → image gate with dynamic `IMG_PREMISES` premise selection → build → scan → commit). §11.2 handles reviews and audits with structured issue reporting. §11.3 handles editing existing files with the surgical read/edit/verify approach. §11.4 covers conversation agent prompt production. §11.5 mandates chunked generation for files over ~150 lines. §11.6 documents pre-build checkpointing. §11.7 covers prompt decomposition for complex requests. §11.8 is the crash recovery system with the build log schema (one mandatory format — no compact alternative), the `## Edit Log` section for per-edit tracking, and the mandatory audit log pairs (§11.8.2). §11.9 defines convergence criteria for when to stop iterating. §11.10 is the abort protocol. §11.11 provides prompt templates for common tasks. §11.12 covers post-generation validation. §11.13 handles large file editing (1000+ lines). §11.14 defines the README generation workflow — every blueprint and script gets a companion README as a mandatory deliverable. §11.15 defines audit resilience — sectional chunking splits deep-pass audits into four stages with per-stage style guide loading, and audit checkpointing provides crash recovery with `IN_PROGRESS`/`COMPLETE`/`PENDING`/`SKIP` stage markers.

## When to Load

T2 (review/edit). The scan tables load for any BUILD-mode anti-pattern check. Individual §11 workflow sections load based on the task at hand.

| Mode | What to load |
|------|-------------|
| BUILD | §10 scan tables + the relevant §11 workflow (§11.1 for new builds, §11.3 for edits) |
| TROUBLESHOOT | Not loaded by default. §11.8 for crash recovery only. |
| AUDIT | §10 (scan tables + §10.5 security) + §11.2 (review workflow) + §11.8.2 (log pairs) + §11.15 (audit resilience, deep-pass only) |

## Key Concepts

**Anti-pattern scan tables** — structured tables with AP codes, severity (ERROR/WARNING/INFO), trigger text, and fix guidance. The AI scans generated code against these tables before delivery. Each anti-pattern has a unique code (AP-01 through AP-43) for cross-referencing in violation reports.

**AP-39 — the build log gate** — every BUILD-mode file edit requires a build log in `_build_logs/` before the first write. Every AUDIT check command requires a log pair (progress + report). Zero threshold — even a one-line fix gets logged. All build logs use the same full schema; there is no compact alternative. The companion **log-after-work invariant** requires updating the log's `## Edit Log` section after every edit before proceeding. **AP-43** enforces this — flagging build logs not updated between consecutive edits as "stale logs." Together with the log-before-work invariant, the sequence is: log → work → update Edit Log → next work. This is what makes crash recovery possible.

**Security checklist** (§10.5) — eight checks that run after the anti-pattern scan. S1 (secrets exposure) catches raw API keys in YAML. S2 (authentication) checks for unprotected endpoints. The security checklist has higher precedence than any anti-pattern (per §1.12).

**Crash recovery** (§11.8) — when a session crashes mid-build, the build log and git state together provide enough information to reconstruct what was in progress, what decisions were made, and where to resume. The build log captures decisions and progress; git captures the actual file state.

**Chunked generation** (§11.5) — files over ~150 lines are built in logical sections with verification between chunks. This prevents context loss during conversation compression and ensures each section is correct before proceeding to the next.

## Related Files

| File | Relationship |
|------|-------------|
| `00_core_philosophy.md` | §1 principles are what the anti-patterns enforce |
| `09_qa_audit_checklist.md` | QA checks cross-reference specific anti-patterns and security checks |
| All pattern docs | Each domain's anti-patterns (ESPHome, MA) correspond to the domain's pattern doc |
| `ha_style_guide_project_instructions.md` | Master index routes to specific §11 workflows based on task type |

## Sources & Acknowledgments

Anti-patterns were catalogued from real-world debugging of Home Assistant automations, ESPHome devices, and Music Assistant integrations. The workflow system (build, review, edit, crash recovery) was developed through iterative refinement of AI-assisted development practices. Build log patterns follow standard engineering practice adapted for AI conversation sessions.

Cultural references: *Star Trek: Deep Space Nine* (Paramount), *Rick and Morty* (Adult Swim).

## Tooling & AI Disclosure

Developed collaboratively with **Claude** (Anthropic) via Claude Desktop. MCP tools: Desktop Commander, Filesystem MCP, git MCP, ripgrep, Context7, HA MCP, ha-ssh, Gemini.

## Author

**madalone** · [GitHub](https://github.com/mmadalone)

## License

See repository root for license details.
