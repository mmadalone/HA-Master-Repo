# Sanity Check & Fix Prompt

Paste this into a fresh conversation with the project instructions loaded.

---

## Prompt

```
Run `sanity check` on the Rules of Acquisition. Follow the QA checklist in 09_qa_audit_checklist.md exactly — no shortcuts.

Before you start:
1. Read 09_qa_audit_checklist.md to get the check definitions for: SEC-1, VER-1, VER-3, CQ-5, CQ-6, AIR-6, ARCH-4, ARCH-5.
2. For each check, follow the **exact procedure** described in the checklist. Specifically:
   - **VER-1**: Web search each version claim against official release notes. Don't just list them — verify them.
   - **CQ-5**: Read every fenced ```yaml block in the guide files. Validate structure and confirm action domains are real HA domains.
   - **ARCH-5**: Collect ALL section headings from ALL files. Cross-check every one against the master index routing tables. Report any orphan sections.
   - **ARCH-4**: Verify every §X.X reference, file reference, and AP-code reference resolves to an actual target.
3. Don't batch or summarize checks you didn't actually run. If a check takes too long for one session, say so and tell me which checks are done and which are deferred.

After the scan, produce:
- A findings report in `[SEVERITY] CHECK-ID | file | description` format.
- For each WARNING or ERROR finding, propose a specific fix (the exact text to change, not just "update this").
- Do NOT apply any fixes yet — report only. I'll approve before you touch anything.

This is AUDIT mode — load §10 scan tables and §11.2 review workflow if you need workflow guidance. No build logs required, no file edits until I say so.
```
