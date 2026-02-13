# Draft: §15.2.1 — Audit Execution Protocol

**Target file:** `09_qa_audit_checklist.md`  
**Insert after:** §15.2 user-triggered commands table  
**Cross-references to add:** §11.2 (review workflow) should reference this subsection  
**Date:** 2026-02-13  

---

## Proposed text

### §15.2.1 — Audit execution protocol (MANDATORY)

This protocol applies to `sanity check`, `run audit`, and any scoped audit command. No exceptions — not for "quick checks" and not for single-file scans.

**1. Pre-scan gate — read before you run.**

Before executing ANY check, read the check definition in §15.1. Execute the **exact procedure** described — not a paraphrase, not a shortcut, not what you think the check probably says. If the check says "web search each version claim," you web search each version claim. If it says "read every fenced YAML block," you read every fenced YAML block.

**2. No-batching rule — don't summarize checks you didn't run.**

Every check in the scan list MUST be individually executed and individually reported. Do not:
- Batch multiple checks into a single "looks fine" summary
- Claim a check passed without showing the evidence (grep output, search results, file reads)
- Skip a check silently because it "probably" passes

If a check requires reading files, show which files were read. If it requires web searches, show the queries. The audit trail IS the audit.

**3. Deferral protocol — say what you skipped and why.**

If a check cannot be completed in the current session (token budget, tool limitations, scope too large), explicitly report:

```
[DEFERRED] CHECK-ID | reason | what remains to be done
```

Partial runs are fine. Silent omissions are not. At the end of every audit, state:
- ✅ Checks completed (list)
- ⏸️ Checks deferred (list + reason)
- Total findings: X ERROR, Y WARNING, Z INFO

**4. Concrete fix requirement — propose the scalpel, not the diagnosis.**

For every WARNING or ERROR finding, include:
- The exact file and location (line number or section reference)
- The current text that's wrong
- The proposed replacement text

```
[ERROR] ARCH-4 | 05_music_assistant_patterns.md §7.8 | References §5.11 
  but §5.11 is "Purpose-specific triggers" — should be §5.1 (timeouts)
  Current:  "see §5.11 for timeout patterns"
  Proposed: "see §5.1 for timeout patterns"
```

INFO findings may use a summary description without a proposed fix.

**5. Approval gate — report only, touch nothing.**

Audit mode produces a findings report. It does NOT:
- Edit any style guide file
- Create fix commits
- Modify any YAML

All fixes require explicit user approval. Present the full report, wait for "approved" or cherry-picked items, THEN switch to BUILD mode for the edits.

---

## Also needed

**Cross-reference from §11.2 (review/improve workflow):**

Add after step 3 ("Present findings as a prioritized list"):

> For audit commands (`sanity check`, `run audit`, etc.), follow the execution protocol in §15.2.1 — pre-scan gate, no-batching, deferral tracking, concrete fixes, approval gate.
