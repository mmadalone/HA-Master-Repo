# Build Log: bedtime_routine_plus.yaml → v5.4.5

| Field            | Value                                                    |
|------------------|----------------------------------------------------------|
| **Blueprint**    | `bedtime_routine_plus.yaml`                              |
| **Version**      | 5.4.4 → 5.4.5                                           |
| **Status**       | completed                                                |
| **Started**      | 2026-02-19                                               |
| **Trigger**      | Audit remediation                                        |
| **Session**      | Claude Opus 4.6 — single-file execution                 |

## Scope

Audit findings from v5.4.4 review. Fixes:

- **M-1:** Bathroom guard missing config check (×2 — preset + conversational)
- **L-1:** Missing `| default()` on `states()` in countdown variables (×2)
- **L-2:** Inconsistent `trigger.id` default in presence gate — add clarifying comment
- **L-3:** TTS voice profile duplication — add intentional-design comment (no code change)

## Edits

1. [x] L-1: `countdown_minutes` variable — add `| default('')`
2. [x] L-1: `final_countdown` variable — add `| default('')`
3. [x] L-2: presence gate `trigger.id | default('scheduled')` — add comment
4. [x] L-3: first TTS voice profile branch — add intentional-design comment
5. [x] M-1: preset bathroom guard — wrap in config check
6. [x] M-1: conversational bathroom guard — wrap in config check
7. [x] Bump `blueprint_version` to 5.4.5
8. [x] Update changelog in description
