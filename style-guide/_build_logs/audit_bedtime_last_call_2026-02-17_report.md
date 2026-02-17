# Audit Report — bedtime_last_call.yaml

| Field | Value |
|-------|-------|
| **File** | `blueprints/automation/madalone/bedtime_last_call.yaml` |
| **Blueprint version** | v2.1 |
| **Audit type** | Quick-pass |
| **Date** | 2026-02-17 |
| **Lines** | 464 |
| **Mode** | `single`, `max_exceeded: silent` |

---

## Findings

### 1. ❌ AP-16 — `states()` without `| default()` guard

**Location:** Line 343 (condition: "Not speaking over active media")

**Current code:**
```jinja
{{ states(player_entity) not in ['playing', 'buffering'] }}
```

**Risk:** If `player_entity` resolves to an invalid/unavailable entity, `states()` returns `unknown` or `unavailable` — which isn't in the blocklist, so the condition passes and the automation fires when it shouldn't (TTS over a possibly-errored player). More critically, if the entity is completely missing, `states()` can raise an error in strict template evaluation.

**Fix:**
```jinja
{{ states(player_entity) | default('unknown') not in ['playing', 'buffering'] }}
```

---

### 2. ⚠️ AP-09a — Inputs in collapsed sections missing `default:`

**Location:** Lines 206–212 (`conversation_agent` input in section ⑤, collapsed)

The `conversation_agent` input has no `default:` value. When section ⑤ is collapsed in the UI, this input is hidden — if the user doesn't expand the section and fill it in, the blueprint may fail at runtime when `conversation.process` is called with no agent.

**Mitigation note:** The `conversation_agent:` selector type may not support a meaningful default (agent IDs are instance-specific). This is a known limitation — the practical fix is either: (a) un-collapse section ⑤ since the agent is a required input, or (b) add a runtime guard that checks if the agent ID is valid before calling `conversation.process`.

**Location:** Lines 270–277 (`followup_script` input in section ⑥, collapsed)

Same pattern — `followup_script` has no `default:`. However, this is lower risk because the follow-up script is gated by `enable_followup_script` (default: `false`), so it won't fire unless the user deliberately enables it and presumably also selects a script.

**Recommendation:** The `followup_script` missing default is acceptable given the boolean gate. The `conversation_agent` missing default is the real concern — consider either un-collapsing section ⑤ or adding a runtime condition that checks if the agent is set before calling `conversation.process`.

---

## Passing Checks (notable positives)

- ✅ **AP-15** — Header image exists at `bedtime_last_call-header.jpeg`
- ✅ **AP-10/10a/10b** — No legacy syntax; uses `action:`, `trigger:`, `triggers:`/`conditions:`/`actions:` (plural), `data:`
- ✅ **AP-11** — Every action step has a descriptive `alias:`
- ✅ **AP-17** — `continue_on_error: true` correctly placed on non-critical LLM call with fallback
- ✅ **AP-24** — Uses `conversation_agent:` selector (not `entity: domain: conversation`)
- ✅ **AP-04** — No `wait_for_trigger` or `wait_template` present
- ✅ **AP-21/S1** — No raw secrets in YAML
- ✅ **AP-08** — Action block ~94 lines, nesting depth ≤3
- ✅ **AP-42** — `blueprint:` block uses only valid keys; `min_version` correctly nested under `homeassistant:`
- ✅ **AP-09** — Inputs organized in 6 collapsible sections
- ✅ **S2** — Input selectors properly constrain types
- ✅ **S3** — No template injection vectors (inputs used safely)
- ✅ **S4** — Service calls use explicit targets

---

## Overall Assessment

This is a solid, well-structured blueprint. The code quality is high — modern syntax throughout, excellent alias coverage, proper LLM fallback chain, defensive `continue_on_error` usage, and clean cross-midnight time logic. The one mandatory fix (AP-16 `states()` guard) is a one-line change. The AP-09a warnings are structural decisions worth revisiting but not blocking.

**Verdict:** 1 fix required (AP-16), 1 recommended improvement (AP-09a on conversation_agent).
