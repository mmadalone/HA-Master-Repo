# Home Assistant Style Guide — Anti-Patterns & Workflow

Sections 10 and 11 — Things to never do, and build/review/edit workflows.

---

## 10. ANTI-PATTERNS (NEVER DO THESE)

> **AI self-check:** Before outputting generated code, scan this table. Each row is a rule-ID, a trigger condition (what to look for in your output), and the section with the full explanation. If your output matches any trigger condition, fix it before presenting.

| # | Trigger condition (scan your output for...) | Fix ref |
|---|---|---|
| 1 | LLM system prompt text inside a blueprint YAML | §1.2 |
| 2 | Hardcoded `entity_id:` strings in action/trigger blocks (not from `!input`) | §3.3 |
| 3 | `device_id:` in triggers or actions (non-Zigbee) | §1.5 |
| 4 | `continue_on_timeout:` missing or set to `false` | §5.1 |
| 5 | Removed behavior without user confirmation in conversation | §1.3 |
| 6 | `input_boolean`/`switch` turned on with no cleanup on every exit path | §5.3 |
| 10 | `service:` keyword in new code | §11.3 |
| 11 | Action step missing `alias:` field | §3.5 |
| 12 | File edit without versioning | §2.2 |
| 16 | `states()` or `state_attr()` without `\| default()` | §3.6 |
| 17 | `continue_on_error: true` on critical-path actions | §5.2 |
| 18 | Explicit entity list where area/label target would work | §5.9 |
| 19 | Template sensor when built-in helper exists | §5.10 |
| 20 | `wait_for_trigger` where state might already be true | §5.1 |
| 24 | `entity: domain: conversation` selector | §3.3 |
| 30 | `media_player.play_media` for MA content | §7.2 |
| 32 | Volume restore immediately after `tts.speak` (no delay) | §7.4 |
| 33 | TTS duck/restore without ducking flag | §7.4 |
| 34 | Conditions before input_boolean reset in voice bridges | §7.7 |
| 37 | Single-pass generation over ~150 lines | §11.5 |

*Not all 37 anti-patterns have simple scan triggers — some require architectural judgment. The table above covers the ones an AI can mechanically self-check. For the full list with context, see below.*

### General (1–24)

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
11. **Never output an action without an `alias:` field.** Aliases must describe the what and why — they're your primary documentation, visible in both YAML and traces. YAML comments are optional, reserved for complex reasoning the alias can't convey.
12. **Never edit a file without completing the §2.2 pre-flight checklist first.** This applies to ALL project files — YAML, markdown, docs, prompts, everything. "It's just a small change" and "it's just docs" are not exemptions. See §2.1 for the full scope definition.
13. **Never use free-text inputs when a dropdown or multi-select would work.** Constrain user input whenever possible.
14. **Never assume integration syntax.** Always verify against the official docs for the specific integration.
15. **Never create a blueprint or script without a header image** in its description. Always ask the user — see §11.1 step 4 for default image specs (1K, 16:9, Rick & Morty style, `<blueprint_name>-header.jpeg`).
16. **Never write a template without `| default()` safety.** All `states()` and `state_attr()` calls must have fallback values.
17. **Never blanket-apply `continue_on_error: true`.** Only use it on genuinely non-critical steps — otherwise it masks real bugs.
18. **Never use entity lists when area/label targeting would work.** Area and label targets auto-include new devices; entity lists require manual updates.
19. **Never create a template sensor when a built-in helper does the same job.** Check the helper selection matrix (§5.10) first.
20. **Never substitute `wait_for_trigger` for `wait_template` without checking** whether the state might already be true. They have fundamentally different semantics (see §5.1).
21. **Never put raw API keys or passwords in YAML files.** Use `!secret` references (see §1.6).
22. **Never use Labs/experimental features in shared blueprints** without setting `min_version` and documenting the dependency.
23. **Never assume `restart` mode cleans up after the interrupted run.** Design early steps to be idempotent or add a failsafe.
24. **Never use `entity: domain: conversation` selector for conversation agent inputs.** It only shows built-in HA agents, hiding Extended OpenAI Conversation and other third-party agents. Always use the `conversation_agent:` selector (see §3.3).

### ESPHome (25–29)

25. **Never inline API encryption keys in ESPHome configs.** Use `!secret api_key_<device>` — encryption keys are passwords and get exposed when sharing configs or asking for help on forums (see §6.4).
26. **Never repeat package-provided config in ESPHome device files.** Only extend or override what's different — duplicating the package's defaults causes merge conflicts and maintenance headaches (see §6.3).
27. **Never skip `substitutions` in ESPHome configs.** Even simple devices need `name` and `friendly_name` as substitutions — hardcoding them scatters identity across the file (see §6.2).
28. **Never leave debug/diagnostic sensors enabled in production ESPHome configs** without a comment explaining why they're needed. They consume device resources and clutter HA's entity list (see §6.7).
29. **Never delete old ESPHome configs.** Archive them — pin mappings, calibration values, and custom component configs are a pain to reconstruct from memory (see §6.9).

### Music Assistant (30–35)

30. **Never use `media_player.play_media` for Music Assistant playback.** Always use `music_assistant.play_media` — the generic action lacks MA queue features and may fail to resolve media (see §7.2).
31. **Never hardcode `radio_mode` or `enqueue` in MA blueprints.** Expose them as user-configurable inputs with sensible defaults (see §7.2).
32. **Never restore volume immediately after `tts.speak`.** ElevenLabs and other streaming TTS engines return before audio finishes — always include a configurable post-TTS delay (see §7.4).
33. **Never skip the ducking flag when building TTS-over-music flows.** Without the coordination flag, volume sync automations will fight the duck/restore cycle and create feedback loops (see §7.4).
34. **Never place conditions before the input_boolean auto-reset in voice command → MA bridges.** If a condition aborts the run, the boolean stays ON and the next voice command can't re-trigger it (see §7.7).
35. **Never use `media_player.media_stop` when you might want to resume.** Stop destroys the queue. Use `media_player.media_pause` for anything that could be temporary (see §7.3).

### Development Environment (36–37)

36. **Never use container/sandbox tools (`bash_tool`, `view`, `create_file`) for HA config or project file operations.** All filesystem access goes through Desktop Commander or Filesystem MCP tools targeting the user's actual filesystem. The container environment is for Claude's internal scratch work only — the user's files don't live there. Using the wrong toolset creates delays, generates errors, and wastes everyone's time.
37. **Never generate a file over ~150 lines in a single uninterrupted pass.** Context compression during long outputs causes dropped sections, forgotten decisions, and inconsistent logic. Use the chunked generation workflow (§11.5) instead.

---

## 11. WORKFLOW

### 11.0 Universal pre-flight (applies to ALL workflows below)

**Before ANY file edit in ANY workflow, complete the §2.2 pre-flight checklist.** This is not optional, not "I'll do it after," and not "this file is too small to matter." The checklist takes 30 seconds. Recovering from an unversioned destructive edit takes much longer.

If a task involves editing multiple files, complete the pre-flight for EACH file individually before editing that file. Do not batch-version everything upfront and then edit — version each file at the point you're about to touch it.

### 11.1 When the user asks to build something new
1. **Clarify scope** — ask about complexity and whether this should be one blueprint, multiple, with helper scripts, etc.
2. **Check existing patterns** — look at what's already in the blueprints folder. Reuse patterns and stay consistent.
3. **Draft the structure** — present the input sections and action flow outline before writing full YAML.
4. **Header image (Mandatory)** — If no header image exists or has been provided, **always ask the user** before generating one. Use these defaults unless the user specifies otherwise:
   - **Resolution:** 1K
   - **Aspect ratio:** 16:9
   - **Style:** Rick & Morty (Adult Swim cartoon)
   - **Filename:** `<blueprint_name>-header.jpeg` (e.g., `bedtime_routine-header.jpeg`)
   - **Save location:** `/config/www/blueprint-images/`
   - **Blueprint URL:** `/local/blueprint-images/<blueprint_name>-header.jpeg`
   - After generating, rename the output file from its auto-generated name to the proper `<blueprint_name>-header.jpeg` convention.
5. **Edit directly** — write to the SMB mount. Don't ask "should I write this?" — just do it.
6. **Verify output (MANDATORY)** — after writing the file:
   - **Self-check against §10 scan table** — run through the machine-scannable anti-pattern triggers. Fix violations before telling the user the file is ready.
   - **Tell the user to validate** — include this in your response: *"File written. Next steps: (1) Reload automations in Developer Tools → YAML, (2) Open the automation/blueprint in the UI and check for schema errors, (3) Run it once manually and check the trace for unexpected behavior."*
   - **For blueprints:** Remind the user to create an instance from the blueprint and verify all `!input` references resolve (missing inputs show as errors in the UI editor).
   - **For templates:** Suggest testing complex templates in Developer Tools → Template before relying on them in automation.
7. **If a conversation agent prompt is involved**, consult the integration's official docs, then produce the prompt as a separate deliverable (file for copy-paste into the UI).

### 11.2 When the user asks to review/improve something
1. Read the file from the SMB mount.
2. Identify issues against this style guide.
3. Present findings as a prioritized list.
4. **Ask before making changes** — especially removals or architectural changes.
5. Follow the versioning workflow (§2) when editing.

### 11.3 When editing existing files
1. **Always version.** Copy the current file with incremented version number, move the old version to `_versioning/`, update the changelog.
2. Update the blueprint/script description to reflect the last 3 changes.
3. Edit the new version file directly on the SMB mount.

**MANDATORY — Modern syntax enforcement:** All generated code MUST use current HA syntax. Old syntax still works in HA but MUST NOT be generated. This ensures consistency with HA UI editor output and future-proofs all code.

| Old (DO NOT generate) | New (ALWAYS use) | Context |
|---|---|---|
| `service:` | `action:` | Action calls |
| `platform: state` | `trigger: state` | Trigger type prefix |
| `trigger:` (singular, top-level) | `triggers:` | Automation top-level key |
| `condition:` (singular, top-level) | `conditions:` | Automation top-level key |
| `action:` (singular, top-level) | `actions:` | Automation top-level key |

When **editing existing files** that use old syntax: migrate to new syntax in the sections you touch. Don't rewrite untouched sections just for syntax — but anything you add or modify uses the new forms.

**UI auto-migration note:** Automations managed through HA's automation editor will automatically migrate to the new plural syntax when re-saved via the UI. YAML-only automations are never auto-migrated. A mix of old and new syntax on the same instance is normal and expected — but all new code we produce uses new syntax exclusively.

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

### 11.7 Prompt decomposition — how to break complex requests

LLMs produce better output from focused, single-concern prompts than from sprawling multi-feature requests. When the user asks for something complex, **help them decompose it before you start building.**

**Signs a request needs decomposition:**
- More than 2 integrations involved (e.g., MA + conversation agent + presence detection)
- More than 3 distinct behaviors described in one sentence
- Words like "and also" or "plus it should" appearing multiple times
- The mental model requires understanding multiple docs from this style guide

**Decomposition pattern:**

User says: *"Build me a bedtime negotiator with MA integration, Alexa volume sync, Rick persona, snooze support, and it should detect which room I'm in."*

Instead of attempting this as one build, propose:
1. **Presence detection logic** (§7.6 pattern) — standalone, testable.
2. **Bedtime automation skeleton** — triggers, conditions, flow control, timeout handling.
3. **Rick conversation agent prompt** (§8.3 structure) — separate deliverable.
4. **MA duck/restore integration** (§7.4 pattern) — wired into the skeleton.
5. **Alexa volume sync** (§7.5 pattern) — separate automation with ducking flag coordination.
6. **Snooze mechanism** — helper + notification actions + re-trigger logic.

Each piece is buildable, testable, and debuggable independently. Wire them together last.

**How to propose this to the user:**
> *"That's 5-6 moving parts. I can build it all, but if I do it as one monolith, debugging will be hell. Let me break it down into pieces we can test individually. Here's what I'd build in order: [list]. Sound good, or do you want to shuffle the priority?"*

### 11.8 Resume from crash — recovering mid-build

Conversations die. Browser crashes, token limits hit, Claude goes sideways, or the user just needs to sleep. When a build was in progress, the new conversation has zero context about what was decided and what was already written.

**Prevention — the decision log:**

During any multi-step build, maintain a running decision log as a file. After each significant decision or completed chunk, append to it:

```markdown
# Build Log — <project_name>

## Decisions
- Presence detection: priority-ordered FP2 sensors, fallback to workshop
- Mode: restart (new trigger replaces in-progress)
- TTS engine: ElevenLabs via tts.speak, post-TTS delay 5s
- Agent: Rick - Extended - Bedtime (separate prompt file)

## Completed chunks
- [x] Blueprint header + inputs (written to /config/blueprints/automation/madalone/bedtime.yaml)
- [x] Variables + trigger block
- [ ] Actions part 1 (detection + preparation)
- [ ] Actions part 2 (conversation + cleanup)
- [ ] Agent prompt (separate file)

## Current state
File is partially written through the trigger block. Next: actions part 1.
```

**Save location:** `/Users/madalone/_Claude Projects/HA Master/_build_logs/<project>_build_log.md`

**Recovery — when starting a new conversation after a crash:**

The user pastes or points to the build log. The AI reads it, reads the partially-written file, and picks up from the last completed chunk. No re-debating decisions, no re-reading the entire style guide (use the routing table in the index).

**When to create a build log:**
- Any build expected to take more than 3 chunks (§11.5)
- Any build preceded by significant design discussion (§11.6)
- Any build the user says "this is going to be a big one"

**When NOT to bother:**
- Quick single-file edits
- Simple scripts under 50 lines
- Review/audit tasks (no state to lose)
