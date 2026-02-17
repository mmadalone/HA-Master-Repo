# Build Log: escalating_wakeup_guard.yaml — v7 → v8 Audit Remediation

| Field             | Value |
|-------------------|-------|
| **File**          | `blueprints/automation/madalone/escalating_wakeup_guard.yaml` |
| **Source**        | HA_CONFIG (SMB mount) |
| **Version**       | v7 → v8 |
| **Status**        | `completed` |
| **Started**       | 2026-02-17 |
| **Build Type**    | Audit remediation — compliance fixes only, no feature changes |

---

## Planned Stages

| Stage | ID   | Severity | Description |
|-------|------|----------|-------------|
| 1     | C-1  | 🔴 Critical | Singular → plural top-level keys (`triggers:`, `conditions:`, `actions:`) |
| 2     | M-5  | 🟡 Medium   | Add `collapsed:` key to sections 1–4 (§1 false, §2–4 true) |
| 3     | M-1  | 🟡 Medium   | Add `version:` key to blueprint metadata |
| 4     | M-2  | 🟡 Medium   | Add DRY comments on duplicated cleanup sequence |
| 5     | M-3  | 🟡 Medium   | Add comment on `replace()` chain fragility |
| 6     | M-4  | 🟡 Medium   | Add `id:` to weekday condition |
| 7     | —    | 📝 Admin   | Bump changelog in description to v8 |

---

## Stage Log

### Stage 1 — C-1: Singular → plural top-level keys
- **Pre-edit:** `trigger:`, `condition:`, `action:` at top level (singular, deprecated)
- **Target:** Rename to `triggers:`, `conditions:`, `actions:`
- **Status:** ✅ complete — `trigger:` → `triggers:`, `condition:` → `conditions:`, `action:` → `actions:`

### Stage 2 — M-5: Add `collapsed:` to sections 1–4
- **Pre-edit:** Sections 1–4 missing `collapsed:` key entirely; sections 5–8 already have `collapsed: true`
- **Target:** §1 gets `collapsed: false`, §2–4 get `collapsed: true`
- **Status:** ✅ complete — §1 `collapsed: false`, §2–4 `collapsed: true`

### Stage 3 — M-1: Add `version:` key to blueprint metadata
- **Pre-edit:** No machine-readable version field; changelog in description tracks v7
- **Target:** Add `version: 8` to blueprint block
- **Status:** ✅ complete — `version: 8` added after `domain: automation`

### Stage 4 — M-2: DRY comments on duplicated cleanup sequence
- **Pre-edit:** Cleanup block (volume restore → toggle reset → cleanup script) appears in two places without duplication note
- **Target:** Add `# NOTE: duplicated...` comment on both cleanup instances
- **Status:** ✅ complete — DRY `# NOTE:` added on both cleanup triads (in-loop + post-loop)

### Stage 5 — M-3: Comment on `replace()` chain fragility
- **Pre-edit:** `static_message` uses chained `| replace()` for pseudo-Jinja without explanation
- **Target:** Add explanatory comment
- **Status:** ✅ complete — `# NOTE:` added above `static_message` variable

### Stage 6 — M-4: Add `id:` to weekday condition
- **Pre-edit:** Top-level condition has alias but no `id:` for trace debugging
- **Target:** Add `id: weekday_check`
- **Status:** ✅ complete — `id: weekday_check` added

### Stage 7 — Admin: Bump changelog to v8
- **Pre-edit:** Description changelog starts at v7
- **Target:** Add v8 entry, update all prior changes
- **Status:** ✅ complete — v8 changelog entry added to description

---

## Verification

- ✅ All 8 sections have `collapsed:` key (§1 false, §2–8 true)
- ✅ Plural top-level keys only (`triggers:`, `conditions:`, `actions:`)
- ✅ `version: 8` present in blueprint metadata
- ✅ DRY comments on both cleanup triads (lines 659, 856)
- ✅ Comment on `replace()` chain workaround
- ✅ `id: weekday_check` on condition
- ✅ Changelog updated to v8
- ✅ File tail intact — no truncation

## Final State

| Field      | Value |
|------------|-------|
| **Status** | `completed` |
| **Lines**  | 880 (was 864) |
| **Edits**  | 11 edit_block calls across 7 stages + 1 rollback |

## Post-Completion Rollback

- **M-1 REVERTED:** `version:` is not a valid key in the HA blueprint schema — causes
  `extra keys not allowed @ data['blueprint']['version']`. Removed `version: 8` line.
  Blueprint versioning is tracked in the description changelog only (no machine-readable
  field exists in the HA blueprint spec).

## Post-Completion Fix: Missing Defaults on Required Inputs

Sections 2, 3, and 8 couldn't collapse because inputs lacked defaults — HA treats
defaultless inputs as required and forces the section open regardless of `collapsed:`.

| Input | Section | Default Added |
|-------|---------|---------------|
| `guard_time` | §1 | `default: "07:15:00"` |
| `activity_sensors` | §2 | `default: []` |
| `tts_entity` | §3 | `default: ""` |
| `tts_output_player` | §3 | `default: ""` |
| `stop_toggle` | §8 | `default: ""` |

All sections now fully defaulted → `collapsed:` key respected by HA UI.

## Post-Completion Rollback 2

- **M-4 REVERTED:** `id:` is not a valid key on conditions — only on triggers.
  Removed `id: weekday_check` from the weekday condition. The alias alone
  provides trace identification for conditions.

