# Vibe Coding Violations Sweep — Changelog

## Date: 2026-02-10
## Scope: 10 violations across 7 files

---

### ha_style_guide_project_instructions.md (v1 → v2)
- **#1 Token routing:** Replaced "Read ALL of them" with AI task routing table
- **#6 Self-describing:** Added meta-block explaining what the guide is and how to consume it
- Updated ToC for new sections: §1.7, §1.8, §5.12, §11.7, §11.8

### 00_core_philosophy.md (v1 → v2)
- **#7 Uncertainty signals:** Added §1.7 — stop-and-ask rule for unknown APIs/syntax
- **#8 Complexity budget:** Added §1.8 — quantified limits table (nesting, choose branches, variables, action lines, wait blocks)

### 01_blueprint_patterns.md (v1 → v2)
- **#2 Negative examples (templates):** Expanded §3.6 with three concrete broken-at-runtime examples: chained math without defaults, list index on empty list, stale variable in repeat loop
- Added two new rules: list operation guards, repeat loop re-read requirement

### 02_automation_patterns.md (v1 → v2)
- **#2 Negative examples (wait semantics):** Added concrete broken refactoring example to §5.1 showing wait_for_trigger hanging when state is already true
- **#9 Idempotency:** Added §5.12 — safe-to-repeat principle with idempotent vs non-idempotent action lists, toggle prohibition, guard pattern for notifications

### 03_conversation_agents.md (v1 → v2)
- **#2 Negative examples (prompts):** Added badly-structured prompt example after §8.3.1 with 5-point failure analysis (no sections, scattered permissions, repeated instructions, no denial clause, no device table)

### 05_music_assistant_patterns.md (v1 → v2)
- **#2 Negative examples (duck/restore):** Added three-mistake broken example to §7.4: saving volume after ducking, no ducking flag, immediate restore without delay

### 06_anti_patterns_and_workflow.md (v1 → v2)
- **#10 Machine-scannable:** Added AI self-check scan table at top of §10 with 20 trigger conditions mapped to fix references
- **#3 Validation:** Added step 6 to §11.1 — mandatory self-check + user validation instructions
- **#4 Prompt decomposition:** Added §11.7 — signs of complexity, decomposition pattern, how to propose to user
- **#5 Resume from crash:** Added §11.8 — decision log format, save location, recovery workflow
