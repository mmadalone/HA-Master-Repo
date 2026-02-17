# Audit Report — voice_pe_resume_media.yaml

**Date:** 2026-02-17
**File:** `blueprints/automation/madalone/voice_pe_resume_media.yaml`
**Lines:** 146
**Tier:** Quick-pass
**Progress log:** `audit_voice_pe_resume_media_2026-02-17_progress.log`

---

## Summary

10 violations found, 2 informational notes. This blueprint is functionally correct but predates the style guide — essentially a v1 that needs a full compliance pass. The logic (resume players whose helper is ON, then clear helpers) is sound, but the packaging is bare.

---

## Findings — Critical (❌ ERROR)

### 1. ❌ AP-10 — `service:` keyword (2 instances)

**Lines:** ~120 (`media_player.media_play`), ~141 (`input_boolean.turn_off`)

Both action calls use deprecated `service:` syntax. Must be `action:`.

**Fix:** `service:` → `action:` on both calls.

---

### 2. ❌ AP-10a — Singular top-level keys

**Lines:** ~97 (`trigger:`), ~105 (`condition:`), ~107 (`action:`)

All three top-level keys are singular. Modern blueprints require `triggers:`, `conditions:`, `actions:`.

**Fix:** Rename all three to plural form.

---

## Findings — High (⚠️ WARNING)

### 3. ⚠️ AP-09 — No collapsible input sections

**Lines:** ~62–94 (flat `input:` block)

Both inputs (`satellites`, `media_players`) sit directly under `input:` with no section wrappers. Per §3.2, ALL blueprints must use collapsible sections regardless of input count.

**Fix:** Wrap in at least one section. Recommended structure:
- **① Satellites & media players** — `collapsed: false`, both inputs inside
- (Only one section needed for a 2-input blueprint, but it still gets the wrapper)

---

### 4. ⚠️ AP-09a / AP-44 — Missing `default:` on all inputs

**Lines:** ~63 (`satellites`), ~78 (`media_players`)

Neither input has a `default:` value. HA will refuse to render the collapsible chevron without defaults on every input in the section.

**Fix:**
- `satellites` → `default: []` (entity selector, multiple)
- `media_players` → `default: []` (entity selector, multiple)
- Note in description that at least one of each is functionally required.

---

### 5. ⚠️ AP-11 — Missing `alias:` on all action steps

**Lines:** ~109–145 (entire action block)

Zero `alias:` fields on any action step. The two `repeat:` blocks, the `variables:` assignments, the `choose:` block, and both service calls all lack aliases.

**Fix:** Add descriptive `alias:` to every action step. Examples:
- `alias: "Resume players whose helper is ON"`
- `alias: "Build helper entity_id from player name"`
- `alias: "Resume playback if helper is ON"`
- `alias: "Clear all was_playing helpers"`

---

### 6. ⚠️ AP-15 — No header image

No `![` reference in description, no image file found at `HEADER_IMG` path matching `voice_pe_resume*`.

**Fix:** Generate header image per §11.1 step 4 (requires BUILD escalation + user approval).

---

### 7. ⚠️ AP-42 — Missing blueprint metadata

Missing from `blueprint:` block:
- `homeassistant:` / `min_version:` — needs at least `2024.6.0` for collapsible sections (or `2024.10.0` for plural top-level keys)
- `source_url:` — should point to `GIT_REPO_URL`
- No machine-readable `version:` key

**Fix:** Add metadata block after `author:`:
```yaml
  source_url: https://github.com/mmadalone/HA-Master-Repo/
  homeassistant:
    min_version: "2024.10.0"
```

---

### 8. ⚠️ AP-17 — No `continue_on_error:` on external service calls

**Line:** ~120 (`media_player.media_play`)

If a media player is unavailable or throws an error, the entire repeat loop aborts. The second loop (helper cleanup) might never run, leaving stale helper states.

**Fix:** Add `continue_on_error: true` to the `media_player.media_play` call. Optionally also to the `input_boolean.turn_off` call.

---

### 9. ⚠️ No version changelog in description

The description is comprehensive documentation but has no version history. Per §3.1, the last 3 version changes should be in the description.

**Fix:** Add changelog block at the end of the description. Current state becomes v1; fixes become v2.

---

## Findings — Informational (ℹ️)

### 10. ℹ️ Empty `condition: []`

**Line:** ~105

Bare empty condition list serves no purpose. Remove it or convert to `conditions: []` if keeping as placeholder.

**Fix:** Remove the line entirely (preferred) or rename to `conditions:` with an empty list.

---

### 11. ℹ️ Code deduplication opportunity — merge two repeat loops

**Lines:** ~109–127 (resume loop), ~131–145 (cleanup loop)

Both loops iterate over `media_players_list` and build the same `helper` variable. They could be merged into a single `repeat: for_each` that: (a) checks+resumes if helper is ON, then (b) turns the helper OFF — all in one pass.

**Benefit:** Fewer iterations, guaranteed cleanup runs even if resume fails (with `continue_on_error`), and ~15 fewer lines.

---

## Passed Checks

- ✅ **S1** — No raw secrets
- ✅ **S2** — Entity selectors properly constrained by domain
- ✅ **S3** — No template injection vectors
- ✅ **S4** — Service calls use explicit targets
- ✅ **AP-02** — No hardcoded entity IDs

---

## Remediation Priority

| # | Severity | Fix | Effort |
|---|----------|-----|--------|
| 1 | ❌ Critical | `service:` → `action:` (2×) | Trivial |
| 2 | ❌ Critical | Singular → plural top-level keys (3×) | Trivial |
| 3 | ⚠️ High | Wrap inputs in collapsible section | Small |
| 4 | ⚠️ High | Add `default: []` to both inputs | Trivial |
| 5 | ⚠️ High | Add `alias:` to all action steps | Medium |
| 6 | ⚠️ High | Generate header image | Requires user approval |
| 7 | ⚠️ High | Add metadata (min_version, source_url) | Trivial |
| 8 | ⚠️ High | Add `continue_on_error: true` | Trivial |
| 9 | ⚠️ High | Add version changelog to description | Small |
| 10 | ℹ️ Info | Remove empty condition | Trivial |
| 11 | ℹ️ Info | Merge two repeat loops | Medium |
