# Home Assistant Style Guide — Anti-Patterns & Workflow

Sections 10 and 11 — Things to never do, and build/review/edit workflows.

---

## 10. ANTI-PATTERNS (NEVER DO THESE)

### General (1–23)

1. **Never bake large LLM system prompts into blueprints.** Use a dedicated conversation agent.
2. **Never hardcode entity IDs in blueprint actions or prompts.** Use inputs with defaults, or variables derived from inputs.
3. **Never use `device_id` in triggers or actions** unless it's a Zigbee button/remote (use `entity_id` instead — `device_id` breaks on re-pair).
4. **Never use `continue_on_timeout: false`** (or omit it, since false is the default). Always handle timeouts explicitly.
5. **Never remove features or behavior without asking the user first.** If something looks unnecessary, ask.
6. **Never leave temporary state (switches, booleans, locks) without a cleanup path** on every exit route.
7. **Never assume the HA API is reachable** from the development environment. Always be prepared to work via filesystem.
8. **Never create a monolithic blueprint** when the complexity could be split into composable pieces. When in doubt, ask.
9. **Never skip input sections.** Even small blueprints benefit from organized, collapsible input groups.
10. **Never use deprecated syntax** (`service:` instead of `action:`) in new code without matching the existing file's style.
11. **Never output an action without both a numbered comment AND an `alias:` field.** Comments explain reasoning; aliases make traces readable.
12. **Never edit a file without completing the §2.2 pre-flight checklist first.** This applies to ALL project files — YAML, markdown, docs, prompts, everything. "It's just a small change" and "it's just docs" are not exemptions. See §2.1 for the full scope definition.
13. **Never use free-text inputs when a dropdown or multi-select would work.** Constrain user input whenever possible.
14. **Never assume integration syntax.** Always verify against the official docs for the specific integration.
15. **Never create a blueprint or script without an image** in its description. Ask the user for one or find one.
16. **Never write a template without `| default()` safety.** All `states()` and `state_attr()` calls must have fallback values.
17. **Never blanket-apply `continue_on_error: true`.** Only use it on genuinely non-critical steps — otherwise it masks real bugs.
18. **Never use entity lists when area/label targeting would work.** Area and label targets auto-include new devices; entity lists require manual updates.
19. **Never create a template sensor when a built-in helper does the same job.** Check the helper selection matrix (§5.10) first.
20. **Never substitute `wait_for_trigger` for `wait_template` without checking** whether the state might already be true. They have fundamentally different semantics (see §5.1).
21. **Never put raw API keys or passwords in YAML files.** Use `!secret` references (see §1.6).
22. **Never use Labs/experimental features in shared blueprints** without setting `min_version` and documenting the dependency.
23. **Never assume `restart` mode cleans up after the interrupted run.** Design early steps to be idempotent or add a failsafe.

### ESPHome (24–28)

24. **Never inline API encryption keys in ESPHome configs.** Use `!secret api_key_<device>` — encryption keys are passwords and get exposed when sharing configs or asking for help on forums (see §6.4).
25. **Never repeat package-provided config in ESPHome device files.** Only extend or override what's different — duplicating the package's defaults causes merge conflicts and maintenance headaches (see §6.3).
26. **Never skip `substitutions` in ESPHome configs.** Even simple devices need `name` and `friendly_name` as substitutions — hardcoding them scatters identity across the file (see §6.2).
27. **Never leave debug/diagnostic sensors enabled in production ESPHome configs** without a comment explaining why they're needed. They consume device resources and clutter HA's entity list (see §6.7).
28. **Never delete old ESPHome configs.** Archive them — pin mappings, calibration values, and custom component configs are a pain to reconstruct from memory (see §6.9).

### Music Assistant (29–34)

29. **Never use `media_player.play_media` for Music Assistant playback.** Always use `music_assistant.play_media` — the generic action lacks MA queue features and may fail to resolve media (see §7.2).
30. **Never hardcode `radio_mode` or `enqueue` in MA blueprints.** Expose them as user-configurable inputs with sensible defaults (see §7.2).
31. **Never restore volume immediately after `tts.speak`.** ElevenLabs and other streaming TTS engines return before audio finishes — always include a configurable post-TTS delay (see §7.4).
32. **Never skip the ducking flag when building TTS-over-music flows.** Without the coordination flag, volume sync automations will fight the duck/restore cycle and create feedback loops (see §7.4).
33. **Never place conditions before the input_boolean auto-reset in voice command → MA bridges.** If a condition aborts the run, the boolean stays ON and the next voice command can't re-trigger it (see §7.7).
34. **Never use `media_player.media_stop` when you might want to resume.** Stop destroys the queue. Use `media_player.media_pause` for anything that could be temporary (see §7.3).

### Development Environment (35–36)

35. **Never use container/sandbox tools (`bash_tool`, `view`, `create_file`) for HA config or project file operations.** All filesystem access goes through Desktop Commander or Filesystem MCP tools targeting the user's actual filesystem. The container environment is for Claude's internal scratch work only — the user's files don't live there. Using the wrong toolset creates delays, generates errors, and wastes everyone's time.
36. **Never generate a file over ~150 lines in a single uninterrupted pass.** Context compression during long outputs causes dropped sections, forgotten decisions, and inconsistent logic. Use the chunked generation workflow (§11.5) instead.

---

## 11. WORKFLOW

### 11.0 Universal pre-flight (applies to ALL workflows below)

**Before ANY file edit in ANY workflow, complete the §2.2 pre-flight checklist.** This is not optional, not "I'll do it after," and not "this file is too small to matter." The checklist takes 30 seconds. Recovering from an unversioned destructive edit takes much longer.

If a task involves editing multiple files, complete the pre-flight for EACH file individually before editing that file. Do not batch-version everything upfront and then edit — version each file at the point you're about to touch it.

### 11.1 When the user asks to build something new
1. **Clarify scope** — ask about complexity and whether this should be one blueprint, multiple, with helper scripts, etc.
2. **Check existing patterns** — look at what's already in the blueprints folder. Reuse patterns and stay consistent.
3. **Draft the structure** — present the input sections and action flow outline before writing full YAML.
4. **Ask about the image** — ask if the user has an image for the blueprint, or search for a suitable one.
5. **Edit directly** — write to the SMB mount. Don't ask "should I write this?" — just do it.
6. **If a conversation agent prompt is involved**, consult the integration's official docs, then produce the prompt as a separate deliverable (file for copy-paste into the UI).

### 11.2 When the user asks to review/improve something
1. Read the file from the SMB mount.
2. Identify issues against this style guide.
3. Present findings as a prioritized list.
4. **Ask before making changes** — especially removals or architectural changes.
5. Follow the versioning workflow (§2) when editing.

### 11.3 When editing existing files
1. **Always version.** Copy the current file with incremented version number, move the old version to `_versioning/`, update the changelog.
2. Update the blueprint/script description to reflect the last 4 changes.
3. Edit the new version file directly on the SMB mount.

### 11.4 When producing conversation agent prompts
1. Check which integration the user is using and consult its official docs.
2. Follow the mandatory section structure (Personality → Permissions → Rules → Style).
3. Produce as a downloadable markdown file with clear instructions on where to paste it.
4. Never embed the full prompt in a blueprint.

### 11.5 Chunked file generation (Mandatory for files over ~150 lines)

Conversation context compresses over long exchanges and during extended generation. When this happens mid-file-write, sections get dropped, earlier decisions get forgotten, and you end up with a file that contradicts what was agreed upon three messages ago. This is not a theoretical risk — it happens regularly.

**The rule:** Any file expected to exceed ~150 lines must be generated in named, sequential chunks.

**Procedure:**
1. **Outline first.** Before writing any content, present the full structure as a numbered section list. Get user confirmation.
2. **Write one section at a time.** Each chunk should be a coherent, self-contained section (e.g., one input group, one action block, one trigger set). Keep chunks under ~80 lines.
3. **Confirm before continuing.** After writing each chunk, briefly state what was just written and what comes next. This creates a recent-context anchor that resists compression.
4. **If something feels off mid-generation — stop.** Re-read the outline and the last confirmed chunk. Don't power through on vibes.

**What this looks like in practice:**
- Blueprint with 6 input sections + complex action logic? Outline → header + inputs (chunk 1) → variables + trigger (chunk 2) → actions part 1 (chunk 3) → actions part 2 (chunk 4).
- Long conversation agent prompt? Outline → personality + permissions (chunk 1) → rules (chunk 2) → style + tools (chunk 3).

This is not optional overhead. It's the difference between a file that works and one that needs two rounds of "wait, where did the timeout handling go?"

### 11.6 Checkpointing before complex builds

When a build has been preceded by extended design discussion (more than ~5–6 back-and-forth exchanges of substantive decisions), the conversation history is long enough that early decisions are at high risk of compression.

**Before starting file creation in these cases:**
1. Summarize all agreed-upon decisions, requirements, and design choices into a single consolidated message.
2. Get user confirmation that the summary is accurate and complete.
3. **Only then** begin the chunked generation workflow (§11.5), using the summary as the source of truth.

This is not mandatory for every build — only when there's been significant pre-build discussion. If the user walks in and says "build me X" with a clear spec, skip straight to §11.5. If you've been going back and forth for 20 minutes debating whether to use `choose` vs `if-then`, checkpoint first.
