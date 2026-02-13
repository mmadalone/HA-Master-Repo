# DRAFT — §1.14 Session discipline and context hygiene

> **Status:** DRAFT for review. Not yet integrated into `00_core_philosophy.md`.
> **Placement:** After §1.13 (Available tools), before §2 (Git Versioning).
> **Cross-references to update if approved:** §1.9 (turn threshold adjustment), §11.6 (post-build checkpoint addition), master index TOC.

---

### 1.14 Session discipline and context hygiene

AI conversations are expensive real estate. Every token spent repeating yourself, holding finished YAML in chat, or running tools you don't need is a token stolen from the actual work. This section governs how to keep sessions lean, recoverable, and productive.

**1. Ship it or lose it — write to disk immediately.**
When a file is finalized (user approved or explicitly requested), write it to disk in the same turn. Don't hold finished YAML in conversation for a "final review pass" unless the user asks for one. Conversation history is volatile — finished work belongs on the filesystem, not in a chat bubble that's one browser crash away from oblivion. This applies to configs, build logs, violation reports, and documentation alike.

**2. Post-task state checkpoint.**
After completing any significant deliverable (new blueprint, multi-file edit, audit sweep), produce a brief state summary:

- **Decisions made** — what was agreed, what trade-offs were accepted.
- **Current state** — what exists on disk now, what's been committed to git.
- **Outstanding items** — anything deferred, blocked, or flagged for next session.

This is the *output* counterpart to §11.6's *input* checkpoint. §11.6 says "summarize before you build." This says "summarize after you ship." Together they bookend the work. For multi-step builds with build logs (§11.8), update the log's `Current State` section instead of producing a separate summary.

**3. Reference, don't repeat.**
Once a code block, config snippet, or design decision has been established in the conversation, refer to it by name or location — don't paste it again. Examples:

- ✅ *"Using the trigger block from chunk 1 above..."*
- ✅ *"Same duck/restore pattern as `bedtime.yaml` lines 87–102."*
- ❌ Pasting the same 30-line action sequence a second time to "remind" anyone.

This extends §1.9's "never echo back file contents" from tool outputs to all conversation content. If the user needs to see something again, they can scroll up or you can re-read the file. Don't burn 500 tokens on a courtesy repost.

**4. Artifact-first — files over explanation.**
When the deliverable is code, write the file. Don't narrate 50 lines of YAML across three conversational messages when a single file write does the job in one turn. The reasoning-first directive (§1.10) still applies — explain your approach *before* generating — but once the plan is agreed, go straight to the artifact. Save conversational explanation for things that went wrong, surprising decisions mid-generation, or post-delivery context the user needs.

| Situation | Do this | Not this |
|-----------|---------|----------|
| Delivering a new blueprint | Write the file, summarize what it does in 2–3 sentences | Walk through every section conversationally before writing |
| Applying 5 fixes to an existing file | Make the edits, list what changed | Explain each fix in a paragraph, then make the edits, then summarize again |
| User asks "what did you change?" | Reference the git diff or list changes concisely | Paste the before and after side by side |

**5. Trim your toolkit.**
Not every session needs every tool. If you're doing pure YAML config work, web search and image generation are dead weight in the context window. Mentally scope your active tools at session start:

| Task type | Active tools | Idle tools |
|-----------|-------------|------------|
| Blueprint/automation build | Desktop Commander, HA MCP, ha-ssh (for verification) | Web search, Gemini (unless header image needed) |
| Troubleshooting | Desktop Commander, HA MCP, ha-ssh | Web search (unless investigating unknown integration behavior), Gemini |
| Conversation agent prompt | Desktop Commander, HA MCP | ha-ssh, Gemini, web search |
| Research / unknown integration | Web search, Desktop Commander | Gemini, ha-ssh |

This isn't about disabling anything — it's about not reaching for tools that add latency and context overhead when they're irrelevant to the task. If a YAML session suddenly needs web search (e.g., verifying an integration's API), use it. But don't proactively search for things you already know.

**6. Session scoping — one major deliverable at a time.**
Complex builds (new blueprints, multi-file refactors, full audits) should be one-per-session. Don't start a second blueprint in the same conversation where you just finished a 200-line bedtime automation — the context is already loaded with decisions, partial reads, and tool outputs from the first build. Start a fresh session. Quick follow-ups ("fix this one line," "rename that helper") are fine to chain.

**The turn threshold:**
If a session exceeds ~15 substantive exchanges on a single task without shipping a deliverable, something's wrong. Either the scope needs decomposition (§11.7), the requirements are ambiguous (§1.7.1), or you're over-iterating (§11.9). Pause, summarize progress, and ask the user whether to continue, decompose, or ship what exists.

> **Note:** §1.9 sets a similar threshold at ~30 turns. The difference: §1.9's 30-turn rule triggers a *proactive summary*. This 15-turn rule triggers a *scope check*. At 15 turns, ask "are we still on track?" At 30 turns, summarize regardless.

---

**Cross-references:**
- §1.9 — Token budget management (context conservation rules this section extends)
- §1.10 — Reasoning-first directive (explain before code — §1.14.4 clarifies the boundary)
- §11.5 — Chunked file generation (the mechanism §1.14.1 relies on for large files)
- §11.6 — Checkpointing before complex builds (§1.14.2 is the post-build counterpart)
- §11.8 — Crash recovery (build logs absorb §1.14.2's state checkpoint for multi-step builds)
- §11.9 — Convergence criteria (§1.14.6's turn threshold complements the "when to stop" rules)
