# Build Log — coming_home.yaml audit remediation

## Session
- **Date:** 2026-02-19
- **Status:** completed
- **Blueprint:** coming_home.yaml
- **Version:** v4.5 → v4.6
- **Conversation:** Audit escalation from 2026-02-19_coming_home_audit_log.md
- **Style guide version:** 3.25
- **Mode:** BUILD (escalated from AUDIT)
- **Git checkpoint:** d627a9f8 (checkpoint_20260219_142609)

## Decisions
- Fix AP-22: bump min_version from 2024.10.0 to 2025.4.0 (assist_satellite.start_conversation requires ≥2025.4)
- Add source_url for GitHub "Check for updates" feature
- Add v4.6 changelog entry

## Target Files
- `HA_CONFIG/blueprints/automation/madalone/coming_home.yaml`

## Edit Log
| # | Time | Action | Lines | Status |
|---|------|--------|-------|--------|
| 1 | 14:26 | Changed min_version "2024.10.0" → "2025.4.0" | L53 | ✅ verified |
| 2 | 14:26 | Added source_url under domain: automation | L52 | ✅ verified |
| 3 | 14:26 | Added v4.6 changelog entry at top of Recent changes | L21-24 | ✅ verified |
