# Audit Log: voice_active_media_controls.yaml

**Date:** 2026-02-11
**Auditor:** Claude (Quark persona)
**File:** `blueprints/automation/madalone/voice_active_media_controls.yaml`
**Style Guide Version:** Current (§1–§12, AP-01–AP-39, S1–S8)
**Status:** ✅ DEPLOYED — v2 live, all 12 findings resolved
**Draft:** `_versioning/automations/voice_active_media_controls_v2_DRAFT.yaml`

---

## Summary

| Severity | Count |
|----------|-------|
| CRITICAL | 1     |
| ERROR    | 4     |
| WARNING  | 5     |
| INFO     | 2     |
| **Total** | **12** |

---

## Findings

### CRITICAL

#### C-1: Dead code — `choose` branch 1 has `conditions: []`, making branches 2–4 unreachable

**Ref:** AP-23 (structural anti-pattern), §3.5 (action flow clarity)
**Impact:** The ENTIRE command dispatch logic (pause_active, stop_radio, shut_up) is dead code and never executes.

**Explanation:**
In HA's `choose` action, the first branch whose conditions evaluate to `true` is executed, and the rest are skipped. Branch 1 has `conditions: []` (empty list), which HA evaluates as "all conditions pass" = **always true**.

This means:
- Branch 1 (requirement checks) ALWAYS matches
- Branch 2 (pause_active), Branch 3 (stop_radio), Branch 4 (shut_up) are NEVER reached
- When requirements ARE met, branch 1's sequence completes without dispatching ANY command
- The `stop:` action only fires when requirements are NOT met
- **Result: the automation does nothing when properly configured**

**Fix:** Restructure to run requirement checks BEFORE the choose, then use choose exclusively for command routing. Or integrate requirement checks INTO each command branch.

---

### ERROR

#### E-1: AP-10 — Legacy `service:` syntax (8 instances)

All service calls use deprecated `service:` key. Must be `action:` (HA 2024.10+).

Locations:
1. Requirement check notification (`persistent_notification.create`)
2. pause_active media pause (`media_player.media_pause`)
3. pause_active no-player notification
4. stop_radio media pause
5. stop_radio no-players notification
6. shut_up media pause
7. shut_up no-players notification
8. Unknown command notification (default branch)

#### E-2: AP-10a — Legacy `platform:` trigger syntax (1 instance)

```yaml
- platform: event          # ← should be: trigger: event
  event_type: automation_reloaded
```

#### E-3: AP-11 — Missing `alias:` on ALL action steps (~26 locations)

Zero action steps have aliases. Every `choose` branch, every `if:`, every `service:`/`action:` call, every `variables:` block, and every `stop:` action needs an alias for trace readability.

#### E-4: AP-15 — Missing header image in description

No `![header](...)` image link in blueprint description. No matching image found in `/config/www/blueprint-images/`. This is a §3.1 blocking gate.

---

### WARNING

#### W-1: AP-09 — No collapsible input sections

Inputs lack `<details><summary>` collapsible sections with circled Unicode number prefixes per §3.2.

#### W-2: §7.9 — Mode `parallel` inappropriate for voice media controls

Blueprint uses `mode: parallel`. Per §7.9 (thin-wrapper architecture), voice media control automations should use `single` or `restart` because parallel control commands create race conditions (e.g., two "pause" commands hitting the same player simultaneously).

#### W-3: No `continue_on_error: true` on external service calls

Three `media_player.media_pause` calls and five `persistent_notification.create` calls lack `continue_on_error: true`. If a media player becomes unavailable mid-execution, the automation crashes instead of degrading gracefully.

#### W-4: No `min_version` declaration

Blueprint uses patterns that imply HA 2024.10+ (should declare `homeassistant: min_version: "2024.10.0"` once migrated to `action:` syntax).

#### W-5: No version tracking in blueprint metadata

No `version:` field in blueprint metadata. Per §2, all blueprints should track version for changelog and rollback purposes.

---

### INFO

#### I-1: No "Recent changes" section in description

Per §3.1, blueprint descriptions should include last 3 version changes for user visibility.

#### I-2: Placeholder `source_url`

`source_url: https://example.com/madalone/voice_active_media_controls.yaml` is a placeholder. Should point to actual repository or be removed.

---

## Recommended Fix Order

1. **C-1 (CRITICAL):** Restructure choose architecture — this must be fixed first as it renders the entire automation non-functional for its intended purpose.
2. **E-3 (AP-11):** Add aliases to all action steps during restructure.
3. **E-1 (AP-10):** Migrate `service:` → `action:` during restructure.
4. **E-2 (AP-10a):** Migrate `platform:` → `trigger:` during restructure.
5. **W-2:** Change mode from `parallel` to `restart`.
6. **W-3:** Add `continue_on_error: true` to external calls.
7. **E-4 + W-1 + W-4 + W-5 + I-1 + I-2:** Metadata and description updates (can be batched).

---

## Architecture Recommendation for C-1 Fix

```yaml
action:
  # Phase 1: Requirement validation (runs unconditionally)
  - alias: "Validate requirements for command"
    variables:
      missing_candidates: "{{ not has_candidates }}"
      missing_radio: "{{ command == 'stop_radio' and not has_radio_players }}"
  
  - alias: "Notify on misconfiguration"
    if:
      - condition: template
        value_template: "{{ enable_notifications and (missing_candidates or missing_radio) }}"
    then:
      - action: persistent_notification.create
        # ... notification data ...

  - alias: "Stop if requirements not met"
    if:
      - condition: template
        value_template: >-
          {{ (command in ['pause_active', 'shut_up'] and not has_candidates)
             or (command == 'stop_radio' and not has_radio_players) }}
    then:
      - stop: "Requirements not met for {{ command }}"
        error: false

  # Phase 2: Command dispatch (choose only for routing)
  - alias: "Dispatch command"
    choose:
      - alias: "Command: pause_active"
        conditions:
          - condition: template
            value_template: "{{ command == 'pause_active' }}"
        sequence: ...
      - alias: "Command: stop_radio"
        conditions:
          - condition: template
            value_template: "{{ command == 'stop_radio' }}"
        sequence: ...
      - alias: "Command: shut_up"
        conditions:
          - condition: template
            value_template: "{{ command == 'shut_up' }}"
        sequence: ...
    default:
      - alias: "Handle unknown command"
        # ... unknown command notification ...
```

This separates requirement validation (sequential, always runs) from command dispatch (choose, only one branch matches).
