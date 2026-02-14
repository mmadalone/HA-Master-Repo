# Automation Patterns — Error Handling, Modes & Triggers

![Automation Patterns header](https://raw.githubusercontent.com/mmadalone/HA-Master-Repo/main/images/style-guide/02_automation_patterns-header.jpeg)

The runtime reliability playbook. While Blueprint Patterns tells you how to structure YAML, Automation Patterns tells you how to make that YAML survive contact with the real world — where sensors go unavailable, services time out, GPS bounces trigger false arrivals, and overlapping runs corrupt shared state.

One section — §5 — but it's dense. Twelve subsections covering every pattern that separates a robust automation from one that works on a good day and fails silently on a bad one.

## What's Inside

**§5 — Automation Patterns** opens with timeout handling (§5.1) — the mandatory `wait_for_trigger` pattern with `continue_on_timeout: true` and cleanup actions. Non-critical action failures (§5.2) get `continue_on_error: true` guards. Cleanup on failure (§5.3) ensures temporary state is always reset even when automations abort. Mode selection (§5.4) provides a deep dive into `single`, `restart`, `queued`, and `parallel` with concrete guidance on when each is appropriate. GPS bounce protection (§5.5) covers re-trigger guards for presence-based automations. Trigger ID + Choose (§5.6) documents the multi-trigger dispatch pattern. Order of operations (§5.7) covers action sequencing for predictable execution. Stored traces (§5.8) sets `stored_traces: 15` as baseline. Area, floor, and label targeting (§5.9) documents the HA 2024.4+ targeting system. Helper selection (§5.10) provides a decision matrix for choosing between input_boolean, input_select, input_number, input_text, input_datetime, and input_button. Purpose-specific triggers (§5.11) covers the HA 2025.12+ Labs feature. Idempotency (§5.12) establishes the principle that every action should be safe to run twice.

## When to Load

T1 (task-specific). Load when building automations or working with automation logic inside blueprints. §5.1 (timeouts) and §5.4 (modes) are the most frequently needed subsections.

| Mode | When to load |
|------|-------------|
| BUILD | Any automation or blueprint-with-complex-logic task. §5.1 for Music Assistant integrations. |
| TROUBLESHOOT | On demand — §5.4 (modes) and §5.5 (GPS bounce) are common debugging references |
| AUDIT | When reviewing automation reliability patterns |

## Key Concepts

**Timeout handling** (§5.1) — every `wait_for_trigger` must have a timeout and `continue_on_timeout: true`. The cleanup path after a timeout must reset all temporary state. This is the #1 HA reliability killer when missing — an automation that hangs indefinitely with no cleanup blocks all subsequent runs.

**Mode selection** (§5.4) — `single` for most automations (prevents overlapping runs), `restart` for presence-based (new trigger cancels stale run), `queued` for sequential processing (rare), `parallel` almost never (race conditions on shared state). The choice matters more than most people think.

**GPS bounce protection** (§5.5) — presence automations need re-trigger guards because phone GPS fluctuates at zone boundaries. Without protection, a "coming home" automation fires repeatedly as the phone bounces in and out of the home zone.

**Helper selection matrix** (§5.10) — a decision table mapping common state-tracking needs to the right helper type. Stops the "just use an input_boolean for everything" anti-pattern.

**Idempotency** (§5.12) — every action should produce the same result whether it runs once or twice. This means using `turn_on` instead of `toggle`, checking state before acting, and designing for the reality that HA may re-execute actions on restart.

## Related Files

| File | Relationship |
|------|-------------|
| `00_core_philosophy.md` | §1.8 (complexity budget) limits nesting and branch counts in automations |
| `01_blueprint_patterns.md` | §3 defines the structure that contains §5's automation logic |
| `05_music_assistant_patterns.md` | §7.4 (TTS duck/restore) relies heavily on §5.1 timeout patterns |
| `06_anti_patterns_and_workflow.md` | Multiple anti-patterns (AP-05, AP-06, AP-07) target automation mistakes |
| `07_troubleshooting.md` | §13.4 ("why didn't my automation trigger?") debugs §5's patterns |

## Sources & Acknowledgments

Automation patterns draw from official [Home Assistant Automation documentation](https://www.home-assistant.io/docs/automation/), particularly the modes system and wait_for_trigger behavior. GPS bounce protection patterns were developed through real-world testing with phone-based presence detection. The helper selection matrix synthesizes HA's input helper documentation into a decision framework.

Cultural references: *Star Trek: Deep Space Nine* (Paramount), *Rick and Morty* (Adult Swim).

## Tooling & AI Disclosure

Developed collaboratively with **Claude** (Anthropic) via Claude Desktop. MCP tools: Desktop Commander, Filesystem MCP, git MCP, ripgrep, Context7, HA MCP, ha-ssh, Gemini.

## Author

**madalone** · [GitHub](https://github.com/mmadalone)

## License

See repository root for license details.
