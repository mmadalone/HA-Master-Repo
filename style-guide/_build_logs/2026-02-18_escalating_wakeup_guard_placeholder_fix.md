# Build Log — Escalating Wake-Up Guard: Template Placeholder Fix

| Field             | Value |
|-------------------|-------|
| **Date**          | 2026-02-18 |
| **Blueprint**     | `escalating_wakeup_guard.yaml` |
| **Version**       | v8 → v9 |
| **Status**        | completed |
| **Triggered by**  | Trace analysis — Jinja placeholders in input defaults evaluated at variable-resolution time, resolving to empty strings before repeat loop assigns stage/total/stage_delay |

## Problem

All `{{ stage }}`, `{{ total }}`, `{{ stage_delay }}` placeholders in input
default strings are eaten by HA's Jinja engine during the top-level `variables:`
block evaluation. The `replace()` chains in the action sequence find nothing
to replace because the tokens are already gone.

**Impact:** LLM prompts arrive with missing numbers → conversation agent
returns confused meta-responses → those get spoken as TTS wake-up messages.
Static fallback messages also broken (same placeholder issue).

## Fix

Replace Jinja-style `{{ var }}` placeholders with non-Jinja `{VAR}` format
in all input defaults. Update all `replace()` chains to match.

### Affected inputs (defaults)
- `llm_prompt_first_stage`: `{{ stage_delay }}` → `{STAGE_DELAY}`
- `middle_stage_message`: `{{ stage }}`, `{{ total }}` → `{STAGE}`, `{TOTAL}`
- `llm_prompt_middle_stage`: `{{ stage }}`, `{{ total }}`, `{{ stage_delay }}`
- `final_stage_message`: `{{ stage }}`, `{{ total }}`
- `llm_prompt_final_stage`: `{{ stage }}`, `{{ total }}`, `{{ stage_delay }}`

### Affected replace() chains
- `static_message` variable (lines ~550-560 approx)
- `llm_prompt_raw` → conversation.process text (lines ~570-580 approx)

## Files Modified
- `HA_CONFIG/blueprints/automation/madalone/escalating_wakeup_guard.yaml`

## Changelog
- Replaced `{{ stage }}` / `{{ total }}` / `{{ stage_delay }}` with `{STAGE}` / `{TOTAL}` / `{STAGE_DELAY}` in 6 input defaults
- Updated 6 input descriptions to document new placeholder format
- Rewrote `static_message` replace() chain (removed spacing-variant pairs, now single replace per token)
- Rewrote `conversation.process` text replace() chain (same simplification)
- Updated comment block explaining the workaround
- Added `{STAGE}/{TOTAL}` to `llm_prompt_final_stage` default (was missing stage info entirely)
- Bumped blueprint version v8 → v9 with changelog
- Reloaded automations
