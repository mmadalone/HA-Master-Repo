# Edit Log — AP-16 fix proactive_llm_sensors
**Date:** 2026-02-14 · **Status:** complete
**File(s):** `/config/blueprints/automation/madalone/proactive_llm_sensors.yaml`
**Changes:** Add `| default('idle')` to unguarded `states()` call in "Not speaking over active media" condition (AP-16 ❌ ERROR from audit report 2026-02-14_proactive_llm_sensors_audit_report.log)
**Git:** checkpoint created before edit: yes (checkpoint_20250214_132048)
