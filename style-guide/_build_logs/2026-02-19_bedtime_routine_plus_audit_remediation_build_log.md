# Build Log — Bedtime Routine Plus Audit Remediation

## Session
- **Date started:** 2026-02-19
- **Status:** completed
- **Mode:** BUILD (escalated from AUDIT)
- **Target file(s):** `/config/blueprints/automation/madalone/bedtime_routine_plus.yaml`
- **Style guide version:** 3.25
- **Predecessor:** audit conversation same session
- **Checkpoint:** checkpoint_20260219_103123 (0f00a790)

## Task
Fix 9 issues found during quick-pass audit of bedtime_routine_plus.yaml (v5.3.3).
Skipping M-2 (DRY/code duplication) per user instruction — architectural trade-off, not broken.

### Fixes planned
1. **C-1:** TV sleep timer CEC branch targets `kodi_entity` → should be `tv_entity`
2. **C-2:** `state_attr(sensor, 'last_changed')` → `states[sensor].last_changed` (presence duration gate non-functional)
3. **H-1:** Add `continue_on_error: true` to 8 non-critical service calls
4. **H-2:** Add comment documenting empty-entity trigger limitation on manual_trigger input
5. **M-1:** §① `collapsed: false` → `collapsed: true` (matches changelog claim)
6. **M-3:** Add `max_exceeded: silent` to mode declaration
7. **L-1:** Add `blueprint_version: "5.4.0"` variable
8. **L-2:** Add comment explaining noon threshold in effective_day_key
9. **L-3:** Fix settling-in empty fallbacks from whitespace to explicit `{{ '' }}`

### Version bump
5.3.3 → 5.4.0 (two critical fixes + resilience improvements = minor version)

## Decisions
- M-2 skipped: duplication is a known trade-off, not a bug
- Version bump to 5.4.0 (not patch) due to C-1 behavioral change and C-2 feature fix
- C-2 fix also wraps `changed` in `as_datetime()` for safety belt on string→datetime coercion

## Edit Log
1. ✅ C-1: L2254 `{{ kodi_entity }}` → `{{ tv_entity }}` in TV sleep timer CEC branch
2. ✅ C-2: L935 `state_attr(sensor, 'last_changed')` → `states[sensor].last_changed | default(none)` + `as_datetime(changed)`
3. ✅ H-1: Added `continue_on_error: true` to 8 service calls (countdown init, temp switches on, Kodi volume, lights off, lamp on, lamp off tail, cleanup tail, countdown reset tail) — total now 25
4. ✅ H-2: L82–86 added empty-entity trigger limitation note to manual_trigger description
5. ✅ M-1: §① `collapsed: false` → `collapsed: true`
6. ✅ M-3: L2271 `max_exceeded: silent` added after `mode: single`
7. ✅ L-1: L911 `blueprint_version: "5.4.0"` variable added
8. ✅ L-2: L972–974 Jinja comment explaining noon cutoff assumption in effective_day_key
9. ✅ L-3: L1453 + L1993 settling-in fallback whitespace → `{{ '' }}`
10. ✅ Changelog: v5.4.0 entry added to description

## Verification
- `state_attr.*last_changed` — zero code matches (changelog only) ✅
- `states[sensor].last_changed` — L935 confirmed ✅
- TV sleep timer CEC target — `{{ tv_entity }}` at L2254 ✅
- `collapsed: false` — only in changelog text, not in any input section ✅
- `max_exceeded: silent` — L2271 confirmed ✅
- `blueprint_version: "5.4.0"` — L911 confirmed ✅
- Noon threshold comment — L974 confirmed ✅
- Explicit `{{ '' }}` fallbacks — L1453 + L1993 confirmed ✅
- `continue_on_error: true` — 25 total instances confirmed ✅
- Empty-entity trigger note — L86 confirmed ✅
