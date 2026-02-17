# Build Log — coming_home.yaml Audit Remediation

| Field              | Value                                                |
|--------------------|------------------------------------------------------|
| **File**           | `blueprints/automation/madalone/coming_home.yaml`    |
| **Version**        | v3 → v4                                              |
| **Status**         | ✅ `completed`                                       |
| **Started**        | 2026-02-17                                           |
| **Build mode**     | staged remediation (edit → log → next)               |

---

## Audit Findings

| #  | Severity | Finding                                                        | Status      |
|----|----------|----------------------------------------------------------------|-------------|
| F1 | 🔴 HIGH   | Person ID bug — greeting names all configured persons          | ✅ `fixed`  |
| F2 | 🟡 MED    | Template safety gap — LLM `.plain.speech` access chain         | ✅ `fixed`  |
| F3 | 🟡 MED    | Optional-but-required trigger source (`person_entities`)       | ✅ `fixed`  |
| F4 | 🟡 MED    | Sections ②③④ missing `collapsed: true`                        | ✅ `fixed`  |
| F5 | 🟡 MED    | Entity selectors missing explicit `default:` (bare null)       | ✅ `fixed`  |
| F6 | 🟢 LOW    | Missing `continue_on_error` on reset switch actions            | ✅ `fixed`  |
| F7 | 🟢 LOW    | `mode: restart` cleanup gap (document or mitigate)             | ✅ `fixed`  |

---

## Stage Log

### Stage 1 — F1: Person identification bug (HIGH)
- **Scope:** `variables.person_name` template (~line 197)
- **Fix:** Resolve arriving person from `trigger.entity_id`, not full list iteration
- **Status:** ✅ `fixed` — resolved from `trigger.entity_id` instead of full list iteration

### Stage 2 — F2: LLM response template safety (MED)
- **Scope:** `variables.welcome_line` template (~line 307)
- **Fix:** Replaced nested `if/elif` with chained `.get()` calls + `| default(fallback, true)`
- **Status:** ✅ `fixed`

### Stage 3 — F3: Optional trigger source guard (MED)
- **Scope:** `person_entities` input definition (~line 28)
- **Fix:** Removed `default: []` (now required), removed "(optional)" from name, updated description. Removed dead `person_entities_list` variable.
- **Status:** ✅ `fixed`

### Stage 4 — F4+F5: Collapsible sections + bare null defaults (MED)
- **Scope:** Sections ②③④ input groups; `arrival_switches` selector
- **F4 fix:** Added `collapsed: true` to sections ②③④
- **F5 fix:** Converted `arrival_switches` from bare-null target selector to entity selector with `default: []` and `multiple: true`. Added choose guards on all 3 action references (turn_on, abort cleanup, final cleanup). `entrance_sensor`, `conversation_agent`, `assist_satellites` remain without defaults — intentionally required inputs per HA blueprint semantics.
- **Status:** ✅ `fixed`

### Stage 5 — F6: Reset switch continue_on_error (LOW)
- **Scope:** Reset switch turn_off/turn_on actions
- **Fix:** Added `continue_on_error: true` to both power-cycle actions
- **Status:** ✅ `fixed`

### Stage 6 — F7: mode: restart cleanup documentation (LOW)
- **Scope:** Blueprint description block
- **Fix:** Added note documenting restart-mode behavior and temporary switch cleanup gap
- **Status:** ✅ `fixed`

### Stage 7 — Version bump + changelog
- **Scope:** Description block
- **Fix:** Bumped to v4, added changelog summarizing all audit remediation fixes
- **Status:** ✅ `fixed`
