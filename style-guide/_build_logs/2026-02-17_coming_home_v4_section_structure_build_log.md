# Build Log — coming_home.yaml Section Structure Fixes

| Field              | Value                                                |
|--------------------|------------------------------------------------------|
| **File**           | `blueprints/automation/madalone/coming_home.yaml`    |
| **Version**        | v4 → v4.2                                            |
| **Status**         | `completed`                                          |
| **Started**        | 2026-02-17                                           |
| **Build mode**     | staged remediation                                   |
| **Prior build**    | `2026-02-17_coming_home_audit_remediation_build_log.md` (completed, v3→v4) |

---

## Audit Findings (new — missed by v4 remediation)

| #  | Severity | Finding                                                        | Status      |
|----|----------|----------------------------------------------------------------|-------------|
| F8 | 🟡 MED   | Section ① missing explicit `collapsed: false` (AP-44)          | `fixed`     |
| F9 | 🟡 MED   | `person_entities` and `person_names` float outside any section — should be in ① (AP-09) | `fixed` |

---

## Planned Work

- [x] F9: Move `person_entities` and `person_names` inputs into the `detection:` section (Section ①), before `entrance_sensor`
- [x] F8: Add `collapsed: false` to the `detection:` section header
- [x] Version bump v4 → v4.1, update changelog
- [x] Verify file after edits

## Decisions

- `person_entities` has no `default:` — intentionally required. This is fine because Section ① uses `collapsed: false`, so its inputs are exempt from the mandatory-default rule per §3.2 AP-44 last bullet.
- `person_names` already has `default: ""` — no change needed.
- No action-block changes — only input structure and section header.

## Notes

- The v4 remediation (prior build log) is fully landed and verified via git diff. All 7 original findings (F1–F7) are confirmed fixed on disk but uncommitted.
- This build adds two structural fixes missed by that pass.
- After this build completes, all pending HA config changes (coming_home.yaml, bedtime_routine_plus.yaml, scripts.yaml) should be committed together.
- **v4.2 addendum:** HA requires ALL inputs in a section to have defaults for collapsible rendering. Added `default: []` to person_entities, `default: ""` to entrance_sensor and conversation_agent, `default: {}` to assist_satellites. AP-44 exemption was style-guide-level only — HA's UI engine doesn't honor it.
