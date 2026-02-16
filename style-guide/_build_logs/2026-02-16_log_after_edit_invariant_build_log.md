# Edit Log — Log-after-edit invariant
**Date:** 2026-02-16 · **Status:** completed
**Style guide version:** 3.18 → 3.19
**File(s):** `06_anti_patterns_and_workflow.md`, `ha_style_guide_project_instructions.md`
**Changes:** Add MANDATORY log-after-edit invariant to §11.0 as companion to existing log-before-edit invariant. Version bump + changelog entry.
**Git:** checkpoint not required (surgical text addition, no structural change)
**Edit 1:** §11.0 log-after-edit invariant added to `06_anti_patterns_and_workflow.md` (L232, between log-before-edit and _build_logs location)
**Edit 2:** Version bump 3.18→3.19 + changelog entry in `ha_style_guide_project_instructions.md`
**Edit 3:** Both invariants broadened from BUILD-only to BUILD+AUDIT. Renamed log-before-edit → log-before-work, log-after-edit → log-after-work. Before-work now covers AUDIT log pairs (§11.8.2) and deep-pass checkpoints (§11.15.2). After-work now covers progress log updates per check and stage marker transitions.
**Edit 4:** Changelog entry in master index updated to reflect broader scope (BUILD+AUDIT, rename).
