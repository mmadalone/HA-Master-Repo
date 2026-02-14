# Build Log — Mandatory Log Pairs for Sanity Checks and Audits (§11.8.2)

## Meta
- **Date started:** 2026-02-14
- **Status:** completed
- **Last updated chunk:** 6 of 6 (all chunks complete)
- **Target file(s):**
  - `06_anti_patterns_and_workflow.md` (new §11.8.2, AP-39 update, rule #39 prose)
  - `ha_style_guide_project_instructions.md` (AUDIT mode row, BUILD LOG GATE callout)
  - `_build_logs/sanity_check_prompt.md` (remove "No build logs required")
  - `09_qa_audit_checklist.md` (add log pair requirement to §15.2)
- **Style guide sections loaded:** §10 (AP-39), §11.0 (pre-flight), §11.2 (review workflow), §11.8 (build logs), §11.8.1 (audit logs), §15.1–15.2 (QA checklist + commands)
- **Version:** v3.13 → v3.14

## Problem Statement

The style guide has no logging requirement for `sanity check` or scoped audit commands (`check versions`, `check vibe readiness`, etc.). AP-39 only mandates logs for "BUILD-mode file edits" and "AUDIT with findings." The AUDIT mode row in the master index explicitly says "No build logs." This creates two loopholes:

1. Sanity checks produce findings with no on-disk paper trail — crash recovery forces a full re-scan.
2. When findings are fixed, the fixer can classify the work as "TROUBLESHOOT mode" (not BUILD) to dodge the build log gate, since no prior log anchors the escalation chain.

**Root cause:** Logging is gated on mode classification, not on what actually happens. The fix: every check command gets mandatory log pairs (progress + report) unconditionally, regardless of mode or finding count.

## Decisions

- Log pairs are UNCONDITIONAL — zero findings still gets logged (a clean scan is still a scan worth documenting)
- Two files per check: `_progress.log` (crash recovery, real-time) + `_report.log` (final record)
- Naming: `YYYY-MM-DD_<scope>_sanity_progress.log` / `YYYY-MM-DD_<scope>_sanity_report.log` (and `audit_` variants)
- Save location: `PROJECT_DIR/_build_logs/` (same as build logs)
- Progress log uses status markers: PASS, FAIL, IN_PROGRESS, SKIP, PENDING
- Report log uses `[FINDING]` tag (distinct from `[ISSUE]` in §11.8.1 anti-pattern scans)
- Escalation chain: progress → report → build log → git commit (complete paper trail)
- Sanity check vs audit distinction is by PURPOSE not by MODE — both run under AUDIT mode, naming differentiates them in `_build_logs/`
- Sanity check = technical correctness ("is it correct?"); Audit = full compliance ("does it follow the rules?")
- §11.8.1 structured markdown audit logs remain valid for multi-file blueprint/script sweeps; log pairs cover §15 QA commands
- Version bump: v3.13 → v3.14

## Planned Chunks

- [x] Chunk 1: New §11.8.2 in `06_anti_patterns_and_workflow.md` — insert after §11.8.1, before §11.9
- [x] Chunk 2: Update AP-39 scan table row (line ~69 of `06_anti_patterns_and_workflow.md`)
- [x] Chunk 3: Update rule #39 prose (line ~183 of `06_anti_patterns_and_workflow.md`)
- [x] Chunk 4: Update AUDIT mode row + BUILD LOG GATE callout in `ha_style_guide_project_instructions.md` (lines ~23 and ~37)
- [x] Chunk 5: Update `_build_logs/sanity_check_prompt.md` (line 26) + `09_qa_audit_checklist.md` §15.2 command table
- [x] Chunk 6: Changelog + version bump (v3.13 → v3.14) in `ha_style_guide_project_instructions.md`, TOC update for §11.8.2, token estimate bump for `06_anti_patterns_and_workflow.md`

## Exact Content for Each Chunk

### Chunk 1 — New §11.8.2

Insert after the last line of §11.8.1 (after the "write the checkpoint before touching the file, update it after completing the file" paragraph), before §11.9.

```markdown
#### 11.8.2 Sanity check and audit check log pairs (MANDATORY)

Every `sanity check` and every audit command (`run audit`, `run audit on <file>`, `check <CHECK-ID>`, `check versions`, `check secrets`, `check vibe readiness`, `run maintenance`) produces **two log files unconditionally** — regardless of whether findings exist. A clean scan is still a scan worth documenting. The progress log is the crash recovery artifact; the report log is the permanent record.

**When to create:**
- `sanity check` command → sanity log pair (always)
- `run audit` / `run audit on <file>` / `check <CHECK-ID>` → audit log pair (always)
- `check versions` / `check secrets` / `check vibe readiness` / `run maintenance` → audit log pair (always — these are scoped audits)

**Naming convention:**

| Check type | Progress log | Report log |
|------------|-------------|------------|
| Sanity check | `YYYY-MM-DD_<scope>_sanity_progress.log` | `YYYY-MM-DD_<scope>_sanity_report.log` |
| Audit | `YYYY-MM-DD_<scope>_audit_progress.log` | `YYYY-MM-DD_<scope>_audit_report.log` |

**Save location:** `PROJECT_DIR/_build_logs/` (same as build logs).

**Progress log** — created BEFORE the first check runs. Updated in real time as each check or file completes. This is what a crash-recovery session reads first.

```
[SESSION] YYYY-MM-DD | type: sanity | scope: style guide v3.14
[CHECK] SEC-1 | PASS | 0 findings
[CHECK] VER-1 | FAIL | 2 findings
[CHECK] VER-3 | IN_PROGRESS
```

Status markers:
- `PASS` — check fully executed, no findings
- `FAIL` — check fully executed, findings logged in report
- `IN_PROGRESS` — check started but not completed (crash point)
- `SKIP` — intentionally skipped, with reason
- `PENDING` — not yet started

**Report log** — created at completion (or at crash, with partial results). Contains all findings in structured format, plus a summary.

```
[SESSION] YYYY-MM-DD | type: sanity | scope: style guide v3.14 | status: complete
[FINDING] VER-1 | ⚠️ WARNING | 04_esphome_patterns.md | Dual wake word version claim unverified
[FINDING] ARCH-4 | ⚠️ WARNING | master index | Section count stale (14→15)
[SUMMARY] 8 checks executed | 6 PASS | 2 FAIL (4 findings) | 0 SKIP
[ACTION] Findings ready for user review. Fixes require BUILD-mode escalation with build log.
```

Finding format: `[FINDING] CHECK-ID | severity | file | description`
- Uses `[FINDING]` to distinguish QA check results from anti-pattern scan `[ISSUE]` entries (§11.8.1).

**The escalation chain:**
When check findings are approved for fixing, that's a BUILD-mode escalation. The escalation creates a build log (compact or full per §11.8) BEFORE the first edit. The build log's `Decisions` section references the report log by filename. This creates a complete paper trail: progress → report → build log → git commit.

**Relationship to §11.8.1 audit logs:**
The structured markdown audit log format in §11.8.1 remains valid for multi-file blueprint/script compliance sweeps (e.g., "scan all 18 blueprints against §10"). The log pairs defined here cover style guide QA checks (§15 commands). Use whichever format fits the task:
- Scanning blueprints against anti-pattern tables → §11.8.1 audit log (markdown)
- Running `sanity check` or `run audit` on the style guide → §11.8.2 log pairs
- If in doubt, log pairs are simpler and always sufficient.
```

### Chunk 2 — AP-39 scan table row update

**Location:** line ~69 of `06_anti_patterns_and_workflow.md`

**Old text:**
```
| AP-39 | ⚠️ | Any BUILD-mode file edit — regardless of size — with no build log created in `_build_logs/` before the first write. One-line fix or twenty-chunk blueprint: log comes first. Use compact format (§11.8) for simple edits, full build log for multi-chunk builds, crash recovery, or multi-file scopes. Any AUDIT with findings also requires an audit log (§11.8.1) regardless of file count or finding count. | §11.8, §11.8.1 |
```

**New text:**
```
| AP-39 | ⚠️ | (a) Any BUILD-mode file edit — regardless of size — with no build log in `_build_logs/` before the first write. Compact or full format per §11.8. (b) Any `sanity check` or audit command (§15.2) executed without creating the mandatory log pair (progress + report) per §11.8.2. Logs are unconditional — zero findings still gets logged. (c) Any check findings approved for fixing without a BUILD-mode escalation and build log before the first edit. | §11.8, §11.8.1, §11.8.2 |
```

### Chunk 3 — Rule #39 prose update

**Location:** line ~183 of `06_anti_patterns_and_workflow.md`

**Old text:**
```
39. **Never edit a file in BUILD mode without a build log on disk first. Never report audit findings without an audit log on disk first.** Every BUILD-mode file edit gets a log (compact or full per §11.8) before the first write. Every AUDIT with findings gets an audit log (§11.8.1) before reporting. No threshold — one fix, one finding, doesn't matter. Create the log before starting work, update it after each milestone, and log every finding in `[ISSUE]` format with AP-ID and line number. Without the log, crash recovery forces a full re-scan, and there's no paper trail linking findings to fixes. The "it's just one file" rationalization is exactly how audit trails disappear.
```

**New text:**
```
39. **Never edit a file in BUILD mode without a build log on disk first. Never run a sanity check or audit command without creating the mandatory log pair first.** Three gates, no exceptions: (a) Every BUILD-mode file edit gets a build log (compact or full per §11.8) before the first write. (b) Every `sanity check` or audit command (§15.2) gets a log pair — progress + report per §11.8.2 — before the first check runs. Logs are unconditional: zero findings still gets logged. (c) When check findings are approved for fixing, that's a BUILD-mode escalation — build log before the first edit, referencing the report log. Without the log pair, crash recovery forces a full re-scan, and there's no paper trail linking findings to fixes. The "it found nothing, why log it?" rationalization is exactly how audit trails disappear.
```

### Chunk 4 — Master index updates (`ha_style_guide_project_instructions.md`)

**4a: AUDIT mode row (line ~23)**

**Old text:**
```
| **🔍 AUDIT** | "review", "check", "audit", "scan", "compliance", "violations" | Anti-Patterns §10 (scan tables + security checklist §10.5) + §11.2 (review workflow) | Security checklist (S1–S8), structured issue reporting. No build logs. No file edits — report only | ~5–7K |
```

**New text:**
```
| **🔍 AUDIT** | "review", "check", "audit", "scan", "sanity check", "compliance", "violations" | Anti-Patterns §10 (scan tables + security checklist §10.5) + §11.2 (review workflow) | Security checklist (S1–S8), structured issue reporting. **Mandatory log pairs** (§11.8.2) for every check command — unconditional, even with zero findings. No file edits — report only. Fixes require BUILD escalation. | ~5–7K |
```

**4b: BUILD LOG GATE callout (line ~37)**

**Old text:**
```
> **🚨 BUILD LOG GATE (AP-39) — BUILD mode only:** Every BUILD-mode file edit requires a log in `_build_logs/` **BEFORE the first write**. No threshold — one fix or a twenty-chunk build, the log comes first. Simple edits use the compact log format; multi-chunk builds and complex scopes use the full build log schema. See §11.8 for both formats. This is a hard gate — not "I'll do it after" and not "it's just one line."
```

**New text:**
```
> **🚨 LOG GATES (AP-39):** (a) **BUILD mode:** Every file edit requires a build log in `_build_logs/` **BEFORE the first write**. Compact or full format per §11.8. (b) **AUDIT mode:** Every `sanity check` or audit command (§15.2) requires a log pair (progress + report) per §11.8.2 **BEFORE the first check runs** — unconditional, even with zero findings. (c) **Escalation:** When check findings are approved for fixing, create a build log before the first edit. These are hard gates — not "I'll do it after."
```

### Chunk 5 — Sanity check prompt + QA checklist

**5a: `_build_logs/sanity_check_prompt.md` (line 26)**

**Old text:**
```
This is AUDIT mode — load §10 scan tables and §11.2 review workflow if you need workflow guidance. No build logs required, no file edits until I say so.
```

**New text:**
```
This is AUDIT mode — load §10 scan tables and §11.2 review workflow if you need workflow guidance. Create the mandatory sanity check log pair (§11.8.2) — `sanity_progress.log` and `sanity_report.log` — before running the first check. No file edits until I say so.
```

**5b: `09_qa_audit_checklist.md` — add log pair note to §15.2 command table**

After the command table (the one with `run audit`, `sanity check`, etc.) and after the execution standard paragraph, add:

```markdown
> **📋 Log pair requirement (§11.8.2):** Every command in the table above requires a mandatory log pair (progress + report) in `_build_logs/` before the first check runs. This is unconditional — a clean scan with zero findings still gets both logs. See §11.8.2 for naming conventions and format. Skipping the log pair is an AP-39 violation.
```

### Chunk 6 — Changelog + version bump

**In `06_anti_patterns_and_workflow.md` changelog (if one exists at top/bottom):** Add entry for v3.14.

**In `ha_style_guide_project_instructions.md`:**
- Bump version from v3.13 to v3.14
- Add changelog entry: `v3.14 — §11.8.2: Mandatory log pairs for sanity checks and audit commands. AP-39 updated with three explicit gates (build log, log pair, escalation). AUDIT mode row updated to require log pairs unconditionally. Sanity check prompt updated.`

Update anti-pattern count in master index header if AP count changes (it shouldn't — AP-39 is updated, not added).

Update token estimate for `06_anti_patterns_and_workflow.md` after measuring the new file size.

## Files Modified
- `06_anti_patterns_and_workflow.md` — §11.8.2 added, AP-39 scan row updated, rule #39 prose updated (Chunks 1-3, previous session)
- `ha_style_guide_project_instructions.md` — AUDIT mode row, LOG GATES callout, version bump to v3.14, TOC §11.8.2 added, changelog v3.14 written, token estimate bumped (Chunks 4+6, split across sessions)
- `_build_logs/sanity_check_prompt.md` — log pair instruction added (Chunk 5a, previous session)
- `09_qa_audit_checklist.md` — §15.2 log pair requirement callout added (Chunk 5b, previous session)

## Current State

All 6 chunks complete. v3.14 is fully landed across all target files. Build recovered from a crashed session — Chunks 1–5 were written by the previous session, Chunk 6 (changelog, TOC, token estimate) completed in the recovery session.

## Recovery (for cold-start sessions)
- **Resume from:** N/A — build complete
- **Next action:** Commit + publish via the 3-phase workflow (rsync → git add/commit → push gate)
- **Decisions still open:** None
- **Blockers:** None
- **Context recovery:** N/A — build complete
