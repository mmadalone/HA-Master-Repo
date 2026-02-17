# Build Log: bedtime_routine_plus.yaml — Quick Wins Audit Fixes

**Date:** 2026-02-17
**File:** `blueprints/automation/madalone/bedtime_routine_plus.yaml`
**Status:** completed
**Type:** Audit remediation — quick wins only

## Scope

Four fixes from audit:
1. §3.2 `collapsed: true` on sections ③–⑩ (8 sections)
2. Missing `source_url` in blueprint metadata
3. `continue_on_error: true` on 4 `kodi.call_method` pre-fetch calls
4. Missing `response_type` guard on conversational goodnight LLM extraction

## Decisions

- No version bump — these are compliance fixes, not feature changes
- Actually, §3.1 says metadata fixes warrant a patch bump → v5.3.1
- Description changelog: add v5.3.1 entry, drop oldest (v5.1.0)

## Files Modified

- `blueprints/automation/madalone/bedtime_routine_plus.yaml`

## Chunks

- [x] Fix 1: `collapsed: true` on ③–⑩
- [x] Fix 2: `source_url` added
- [x] Fix 3: `continue_on_error: true` on kodi.call_method calls
- [x] Fix 4: `response_type` guard on conversational goodnight extraction
- [x] Version bump v5.3.0 → v5.3.1 + changelog update
