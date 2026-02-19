# Build Log — coming_home.yaml v4.5 AP-20 Fix

**Date:** 2026-02-19
**File(s):** `blueprints/automation/madalone/coming_home.yaml`
**Trigger:** Audit finding AP-20 — second `wait_for_trigger` (entrance clear) missing pre-check for already-off state
**Status:** completed

---

## Scope

| # | File | Section | Change |
|---|------|---------|--------|
| 1 | `coming_home.yaml` | Actions — entrance clear wait (~L307) | Wrap with `if` pre-check mirroring the first entrance wait pattern |
| 2 | `coming_home.yaml` | Description changelog | Add v4.5 entry |

---

## Decisions

- Mirror the existing `if/then/else` pattern from the first entrance wait (L253) — proven pattern, already in this file
- Move the timeout abort handler inside the `else` block so `wait.completed` is scoped correctly

---

## Edit Log

| # | Edit description | File | Status | Timestamp |
|---|-----------------|------|--------|-----------|
| 1 | Wrapped second entrance wait with `if` pre-check for already-off state | coming_home.yaml | ✅ DONE | 2026-02-19 |
| 2 | Added v4.5 changelog entry | coming_home.yaml | ✅ DONE | 2026-02-19 |
