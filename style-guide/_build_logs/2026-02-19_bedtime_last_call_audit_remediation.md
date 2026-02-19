# Build Log — bedtime_last_call.yaml Audit Remediation

| Field            | Value                                             |
|------------------|---------------------------------------------------|
| **File**         | `blueprints/automation/madalone/bedtime_last_call.yaml` |
| **Version**      | v2.1 → v2.2                                       |
| **Status**       | completed                                          |
| **Started**      | 2026-02-19                                         |
| **Build type**   | Audit remediation                                  |

## Audit Findings (priority order)

| # | Severity | Finding | Status |
|---|----------|---------|--------|
| 1 | 🔴 Critical | Hardcoded "Miquel" in LLM task block — not reusable | ✅ done |
| 2 | 🟡 Medium | Missing `continue_on_error: true` on both TTS actions | ✅ done |
| 3 | 🟡 Medium | Empty `media_player` default → runtime failure if unset | ✅ done |
| 4 | 🟡 Medium | Empty `tts_entity` default → same issue | ✅ done (combined w/3) |
| 5 | 🟡 Medium | Empty `followup_script` + enabled flag → `script.turn_on ""` | ✅ done |
| 6 | 🟢 Minor | `sensor_context` trailing whitespace from Jinja loop | ✅ done |
| 7 | 🟢 Minor | `presence_sensors` default `[]` — no validation note | ✅ done |
| 8 | 🔵 Design | No once-per-window guard — document intentional repeats | ✅ documented |
| ~~9~~ | ~~🟡~~ | ~~No `_versioning/` directory~~ | N/A — git versioning |

## Remediation Plan

1. Add `user_name` input to ① section with default "friend"
2. Replace hardcoded "Miquel" with `{{ user_name }}`
3. Add `continue_on_error: true` to both TTS choose branches
4. Add condition guard: skip TTS entirely if `player` is empty
5. Add condition guard: skip TTS if `tts_entity` is empty
6. Add inner guard on follow-up script: check entity not empty
7. Trim `sensor_context` output
8. Add validation note to `presence_sensors` description
9. Add description note about intentional repeat-trigger behavior
10. Bump version to v2.2, update changelog

## Changes Log

1. Added `user_name` input to ① section (default: "friend"), wired to action variables
2. Replaced hardcoded "Miquel" in LLM task block with `{{ user_name }}`
3. Updated fallback message to use `user_name` + `area_name`
4. Added `continue_on_error: true` to ElevenLabs TTS action
5. Added `continue_on_error: true` to standard TTS action
6. Wrapped entire TTS routing in `if` guard — skips if `tts_entity` or `player` empty
7. Added empty-entity guard to follow-up script condition: `followup_script | default('') != ''`
8. Fixed `sensor_context` Jinja whitespace with `{%-` control tags
9. Added "at least one sensor required" note to `presence_sensors` description
10. Documented intentional repeat-trigger behavior in blueprint description
11. Bumped version to v2.2, updated changelog
