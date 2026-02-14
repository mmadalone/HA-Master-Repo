# 09 — QA Audit Checklist

> **Purpose:** This checklist defines quality gates that AI agents MUST run when generating HA configurations, and that auditors (human or AI) should run periodically against the style guide itself. Every finding has a severity level and a concrete check procedure.
>
> **How to use:** When generating or reviewing HA YAML, run through each applicable section. When auditing the style guide, run ALL sections. Report findings using the severity format: `[ERROR]`, `[WARNING]`, or `[INFO]`.

---

## Severity Levels

| Level | Meaning | Action Required |
|-------|---------|-----------------|
| **ERROR** | Will cause failures, security issues, or incorrect behavior at runtime | Must fix before merge/deploy |
| **WARNING** | May cause confusion, maintenance burden, or subtle bugs; degrades AI-readability | Should fix; document exception if skipped |
| **INFO** | Improvement opportunity; better DX or completeness | Fix when convenient |

---

## 15.1 — Check Definitions

### 1 — Security & Secrets Management

### SEC-1: No Inline Secrets [ERROR]

**Check:** Scan ALL YAML examples (in guide files AND generated output) for hardcoded API keys, tokens, passwords, or credentials.

```
# What to look for:
api_key: "sk-..."
token: "eyJ..."
password: "..."
api_key: !env_var ...   # Also suspicious — prefer !secret
```

**Rule:** Every secret MUST use `!secret` references. No exceptions, not even in "example" blocks — the guide's own examples are copy-pasted by AI agents and humans alike.

**Fix pattern:**
```yaml
# ❌ WRONG — even in examples
api_key: "sk-proj-abc123"

# ✅ CORRECT
api_key: !secret openai_api_key
```

### SEC-2: Safety Carve-outs in Directive Precedence [ERROR]

**Check:** If the guide defines a directive precedence hierarchy (e.g., "user instructions override style preferences"), verify it includes an explicit carve-out:

> Explicit user instructions override style preferences but **NOT** safety-critical rules: error handling, secrets management, cleanup patterns, and input validation.

**Why:** An AI agent told "skip error handling, just make it work" must still include error handling.

---

### 2 — Version Accuracy

### VER-1: All Version Claims Must Be Verified [ERROR]

**Check:** Every statement claiming a feature requires "HA 20XX.X+", "ESPHome 20XX.X+", or "Music Assistant X.X+" MUST be verified against official release notes or changelogs.

**Verification sources (in priority order):**
1. Official release notes: `https://www.home-assistant.io/blog/categories/release-notes/`
2. ESPHome changelog: `https://esphome.io/changelog/`
3. Music Assistant GitHub releases: `https://github.com/music-assistant/server/releases`
4. HA breaking changes: `https://www.home-assistant.io/blog/categories/breaking-changes/`

**Known checks to verify periodically:**

| Claim | File | Verification Source |
|-------|------|---------------------|
| `conversation_agent` selector requires HA 2024.2+ | 01_blueprint_patterns.md | HA release notes |
| `collapsed: true` requires HA 2024.6+ | 01_blueprint_patterns.md | HA release notes |
| Modern blueprint syntax requires HA 2024.10+ | 01_blueprint_patterns.md | HA release notes |
| Dual wake word support requires HA 2025.10+ | 04_esphome_patterns.md | ESPHome changelog |
| Sub-devices require HA 2025.7+ | 04_esphome_patterns.md | ESPHome changelog |
| `ask_question` full capabilities require HA 2025.7+ | 08_voice_assistant_pattern.md | HA release notes |
| TTS streaming requires HA 2025.10+ | 08_voice_assistant_pattern.md | HA release notes |
| MCP servers introduced HA 2025.2+, improved native support 2025.9+ | 03_conversation_agents.md | HA release notes |
| `data_template` deprecation target: 2025.12 | 06_anti_patterns_and_workflow.md | HA release notes |

**Procedure:**
1. Web search: `site:home-assistant.io "<feature_name>" release`
2. If not found in release notes, search GitHub PRs/issues
3. If unverifiable, add caveat: `<!-- UNVERIFIED: version claim needs confirmation -->`

### VER-2: Blueprint Examples Must Include min_version [WARNING]

**Check:** All blueprint examples using modern syntax (actions instead of action, response_variable, conversation_agent selector) MUST include:

```yaml
homeassistant:
  min_version: "2024.10.0"
```

**Why:** Without `min_version`, blueprints silently break on older HA installs with confusing errors. AI agents copy these examples verbatim.

### VER-3: Deprecation Dates Must Be Tracked [WARNING]

**Check:** Any mention of deprecated features (e.g., `data_template`, `service` → `action`) MUST include:
- The version it was deprecated
- The target removal version (if announced)
- The migration path

**Format:**
```markdown
> ⚠️ **Deprecated:** `data_template` was deprecated in HA 2024.x.
> Target removal: HA 2025.12 (verify against release notes).
> Migration: Replace with `data:` under the new `action:` syntax.
```

---

### 3 — AI-Readability & Vibe Coding Readiness

### AIR-1: No "Use Good Judgment" Without Concrete Thresholds [WARNING]

**Check:** Search for vague guidance that assumes human-level inference. An AI agent cannot interpret:
- "use appropriate delays"
- "set a reasonable timeout"
- "keep it short"
- "use common sense"

**Fix pattern:** Replace with concrete numbers, ranges, or decision trees:

```markdown
# ❌ Vague
Use an appropriate delay between retries.

# ✅ Concrete
Use exponential backoff between retries:
- 1st retry: 2 seconds
- 2nd retry: 5 seconds
- 3rd retry: 15 seconds
- Max retries: 3
- Max total wait: 22 seconds
```

### AIR-2: Every Pattern Must Have an Implementation Skeleton [WARNING]

**Check:** If the guide describes a pattern (dispatcher, fallback, duck-and-restore, etc.), it MUST include a copy-pasteable YAML skeleton, not just a prose description.

**What counts as a skeleton:**
- Complete enough that an AI agent can adapt it without inventing structure
- Includes all required keys (even if values are placeholder)
- Has comments explaining what to customize

**What does NOT count:**
- "You could use a choose block for this" (prose only)
- A partial snippet missing required fields
- A reference to another file without inline example

### AIR-3: Decision Logic Must Be Explicit [WARNING]

**Check:** When the guide says "choose between X and Y," it MUST provide selection criteria:

```markdown
# ❌ Unclear
You can use either `conversation.process` or `assist_satellite.start_conversation`.

# ✅ Clear decision tree
## Choosing Between Conversation Actions
- **Need the response text in an automation variable?**
  → Use `conversation.process` — returns `response.speech.plain.speech`
- **Need audio output on a satellite device?**
  → Use `assist_satellite.start_conversation` — does NOT return response text
- **Need both?**
  → Use `conversation.process` first, then pipe result to TTS
```

### AIR-4: Anti-patterns Must Show the Fix Alongside the Bad Example [INFO]

**Check:** Every ❌ example MUST be immediately followed by its ✅ corrected version. An AI agent seeing only the wrong pattern may accidentally learn from it.

### AIR-5: Numerical Thresholds for Subjective Guidance [WARNING]

**Check:** Look for subjective quality guidance and add numbers:

| Subjective | Concrete |
|------------|----------|
| "Don't make automations too complex" | "If a single automation exceeds 200 lines or 5 nested conditions, split it" |
| "Keep descriptions concise" | "Blueprint descriptions: 1-2 sentences, max 160 characters for UI display" |
| "Avoid too many triggers" | "More than 8 triggers in one automation suggests it should be split by domain" |
| "Use reasonable delays" | "TTS duck/restore: 300ms fade, 500ms restore delay (adjust ±200ms per speaker)" |

### AIR-6: Token Count Accuracy [WARNING]

**Check:** Every token estimate in the master index and file headers must be verifiable. Use `1 token ≈ 4 characters` as the baseline conversion.

**Threshold:** Flag when a claim drifts by more than **15%** from the measured value.

**What to verify:**
- Per-file token estimates in the master index routing table
- The total token count claim (e.g., "~86K tokens total")
- Any per-section token budget claims (e.g., "§1 alone: ~5.7K")

**Measurement method:**
```bash
# Approximate tokens for a file (chars / 4)
wc -c <filename> | awk '{printf "%.1fK tokens\n", $1/4/1000}'
```

**Why:** Stale token estimates cause the AI to either overload context (loads too many files) or underload it (skips a file thinking it won't fit). Both degrade output quality.

📋 QA Check: Re-measure after any structural change to a style guide file.

---

### 4 — Code Quality & Patterns

### CQ-1: Action Aliases Are Strongly Recommended [WARNING]

**Check:** All `action:` blocks in examples SHOULD include `alias:` fields.

**Why:** When debugging in HA's trace viewer, unnamed actions show as "Action 1", "Action 2" — useless. Aliases show "Turn on living room lights", "Set TTS volume" — dramatically easier to debug.

**Note:** This is "strongly recommended," not mandatory. But if an example omits aliases, it should have a comment explaining this is for brevity.

### CQ-2: Error Handling Must Not Be Optional [ERROR]

**Check:** Any example involving:
- API calls (REST, conversation agents, TTS)
- Network-dependent actions
- Multi-step sequences where failure mid-way leaves bad state

MUST include error handling (try/catch via `choose` with `continue_on_error`, or explicit state checks).

### CQ-3: Cleanup Patterns for Stateful Operations [WARNING]

**Check:** If an automation sets a temporary state (e.g., volume duck, temporary mode change, helper toggle), it MUST include a cleanup/restore mechanism, even on failure paths.

```yaml
# Pattern: always-restore
sequence:
  - alias: "Save current volume"
    action: scene.create
    data:
      scene_id: tts_volume_restore
      snapshot_entities:
        - media_player.living_room
  - alias: "Duck volume"
    action: media_player.volume_set
    # ... TTS actions ...
  - alias: "Restore volume (runs even if TTS fails)"
    action: scene.turn_on
    target:
      entity_id: scene.tts_volume_restore
    continue_on_error: true
```

### CQ-4: Return Values Must Be Documented [ERROR]

**Check:** Any action described in the guide that has a return value MUST document:
- What the return variable contains
- The exact access path (e.g., `response.speech.plain.speech`)
- Whether the action returns anything at all (some don't!)

Known return value documentation required:

| Action | Returns | Access Path |
|--------|---------|-------------|
| `conversation.process` | Yes | `response.speech.plain.speech` |
| `assist_satellite.start_conversation` | No | N/A — does not return response text |

### CQ-5: YAML Example Validity [ERROR]

**Check:** Every fenced YAML block (```` ```yaml ````) in the style guide must:
1. Parse without syntax errors (valid YAML structure)
2. Use real HA action/service domain names (not invented ones)
3. Use real entity domain prefixes (e.g., `light.`, `climate.`, not `thing.`)

**Known valid action domains:** `homeassistant`, `light`, `switch`, `climate`, `media_player`, `music_assistant`, `cover`, `fan`, `scene`, `script`, `automation`, `input_boolean`, `input_number`, `input_select`, `input_text`, `input_datetime`, `input_button`, `timer`, `counter`, `number`, `select`, `button`, `notify`, `tts`, `conversation`, `assist_satellite`, `rest_command`, `shell_command`, `logbook`, `persistent_notification`. This is not exhaustive — verify against HA docs if unsure.

**Exceptions:** Blocks explicitly marked as pseudocode, illustrative fragments, or `# (not real YAML)` are exempt.

📋 QA Check: Run on every YAML example added or modified in the guide.

### CQ-6: Modern Syntax in Examples [WARNING]

**Check:** All YAML examples must use HA 2024.10+ syntax. Flag these violations:

| Legacy (pre-2024.10) | Modern (2024.10+) | Ties to |
|---|---|---|
| `service:` | `action:` | AP-08 |
| `service_data:` | `data:` (under `action:`) | AP-08 |
| `trigger:` (singular, inside automation) | `triggers:` (plural) | §3.8 |
| `condition:` (singular, inside automation) | `conditions:` (plural) | §3.8 |
| `action:` (singular, inside automation) | `actions:` (plural) | §3.8 |

**Note:** Top-level `automation:` and `script:` keys in `configuration.yaml`, packages, and `scripts.yaml` are correctly singular — do NOT flag these.

**Exceptions:** Blocks that explicitly demonstrate the migration (showing old → new) or that document legacy behavior are exempt if clearly labeled.

📋 QA Check: Run on every YAML example added or modified in the guide.

---

### 5 — Architecture & Structure

### ARCH-1: Layer Boundary Enforcement [WARNING]

**Check:** If the guide defines a layered architecture (e.g., the 6-layer voice assistant pattern), each layer MUST include explicit "MUST NOT" boundary rules.

**Format:**
```markdown
### Layer 1 — Hardware / ESPHome
- **MUST:** Define wake words, audio pipeline, LED patterns
- **MUST NOT:** Contain conversation logic, TTS selection, or intent routing
```

**Why:** Without negative boundaries, AI agents stuff logic into whatever layer they encounter first.

### ARCH-2: Naming Conventions Must Include Rationale [WARNING]

**Check:** If the guide recommends a naming convention (e.g., persona-based agents vs. scenario-based agents), it MUST explain WHY with a concrete comparison:

```markdown
# Why persona-based naming
- Persona-based: 2 agents (Rick, Quark) × unlimited intents = 2 agents
- Scenario-based: 1 agent per intent × 50 intents = 50 agents
Persona-based avoids agent explosion. Each persona is a reusable router.
```

### ARCH-3: File Location References Must Be Concrete [INFO]

**Check:** If the guide references where files should live, include:
- Exact paths (not "in the ESPHome config directory")
- A directory tree view for complex structures
- Which files are optional vs. required

### ARCH-4: Internal Cross-Reference Integrity [ERROR]

**Check:** Every internal reference must resolve:

1. **Section references** (`§X.X`) — must match an actual heading in the target file. Verify the number AND the heading text.
2. **File references** (e.g., `06_anti_patterns_and_workflow.md`) — the file must exist in `PROJECT_DIR`.
3. **AP-code references** (e.g., `AP-15`, `AP-39`) — must exist in the §10 scan tables.
4. **Check-ID references** (e.g., `SEC-1`, `CQ-3`) — must exist in this QA checklist.

**How to scan:**
```bash
# Find all §X.X references
grep -oE '§[0-9]+\.[0-9]+(\.[0-9]+)?' *.md | sort -u

# Find all file references
grep -oE '[0-9]{2}_[a-z_]+\.md' *.md | sort -u

# Find all AP-code references
grep -oE 'AP-[0-9]+' *.md | sort -u
```

Then verify each one resolves to an actual target. Dangling references are ERROR severity — they send the AI on a wild goose chase through files that don't exist.

📋 QA Check: Run after any section renumbering, file rename, or AP-code addition/removal.

### ARCH-5: Routing Reachability [WARNING]

**Check:** Every section in every style guide file must be reachable from at least one entry in the master index routing tables (operational mode tables, task-specific routing, or quick reference).

**How to verify:**
1. Collect all section numbers from all files: `grep -oE '^#{1,3} [0-9]+\.' *.md`
2. Collect all section numbers referenced in the master index routing tables
3. Flag any section that appears in (1) but not in (2)

**Orphan sections** — sections with no routing path — will never be loaded by the AI unless it happens to read the entire file. This defeats the token budget system (§1.9).

**Fix:** Either add the orphan section to a routing table entry, or move its content into a section that IS routed.

📋 QA Check: Run after adding new sections or modifying routing tables.

### ARCH-6: README Existence and Currency [WARNING]

**Check:** Every blueprint and script in the project must have a companion README file in the appropriate `readme/` subdirectory (see §11.14).

**Verification procedure:**
1. List all blueprint YAML files in `HA_CONFIG/blueprints/automation/madalone/` and `HA_CONFIG/blueprints/script/madalone/`.
2. For each YAML file, check that a corresponding `<stem>-readme.md` exists in `README_AUTO_DIR` or `README_SCRI_DIR`.
3. For each existing README, verify the header image URL matches the blueprint's `description:` field (both should use `HEADER_IMG_RAW` + filename).
4. Flag READMEs whose feature lists, input tables, or changelogs are visibly stale (e.g., README lists fewer inputs than the blueprint, changelog is behind the YAML description's "Recent changes").

**Naming convention check:**
- README filename must be `<blueprint_stem>-readme.md` — flag files using other patterns (e.g., missing `-readme` suffix, wrong stem).
- Agent prompt files (`*_agent_prompt_*.md`) in the readme directory are separate deliverables, not READMEs — don't flag them as naming violations.

**When to run:**
- During full audits (`run audit`)
- After any BUILD that creates a new blueprint/script
- After any EDIT that materially changes a blueprint's inputs or features

---

### 6 — Integration-Specific Checks

### INT-1: Conversation Agent Completeness [WARNING]

**Checks for 03_conversation_agents.md:**
- [ ] Dispatcher pattern has implementation skeleton
- [ ] MCP servers documented as tool source (HA 2025.2+, improved 2025.9+)
- [ ] Confirm-then-execute pattern included (using `ask_question` or `conversation_id`)
- [ ] Agent naming rationale explains persona vs. scenario trade-off
- [ ] Max token budget guidance for `extra_system_prompt`
- [ ] Multi-agent coordination pattern documented

### INT-2: ESPHome Pattern Completeness [WARNING]

**Checks for 04_esphome_patterns.md:**
- [ ] `web_server` → `ota: platform:` dependency explained (web_server uses OTA platform for firmware upload endpoint)
- [ ] Packages merge/replace/`!extend`/`!remove` behaviors shown with examples
- [ ] Config archiving method recommended (git as primary)
- [ ] Debug sensor toggle via packages substitution documented
- [ ] Sub-devices version verified

### INT-3: Music Assistant Pattern Completeness [WARNING]

**Checks for 05_music_assistant_patterns.md:**
- [ ] `media_type` "no auto value" claim verified against current MA docs
- [ ] Enqueue mode list verified: `play`, `replace`, `next`, `add`, `replace_next`
- [ ] TTS duck/restore race condition addressed (polling `media_player.is_playing` OR note that `play_announcement` handles ducking natively)
- [ ] Alexa ↔ MA volume sync stability caveat included
- [ ] Search → select → play disambiguation pattern included
- [ ] MA + TTS coexistence on Voice PE guidance expanded
- [ ] Extra zone mapping implementation example included

### INT-4: Voice Assistant Pattern Completeness [WARNING]

**Checks for 08_voice_assistant_pattern.md:**
- [ ] 6-layer architecture has MUST NOT boundary rules per layer
- [ ] TTS streaming (HA 2025.10+) configuration or "documentation pending" note
- [ ] ElevenLabs fallback pattern: try ElevenLabs → fallback to HA Cloud TTS or Piper
- [ ] One-agent-per-persona clarified: doesn't mean one tool source per agent; MCP multi-tool is fine
- [ ] Mermaid data flow diagrams for interactive + one-shot flows
- [ ] Directory tree view in file locations reference
- [ ] All examples use `!secret` for API keys

---

### 7 — Zone & Presence Checks

### ZONE-1: GPS Bounce Protection Guidance [WARNING]

**Check:** If the guide includes zone-based automations or presence detection:
- Note whether HA 2024.x+ zone radius improvements reduce the need for manual GPS bounce protection
- If manual protection is still recommended, include the specific pattern (e.g., `for:` duration on zone triggers)
- Include concrete radius recommendations

### ZONE-2: Purpose-Specific Triggers [WARNING]

**Check:** If the guide documents `purpose`-specific triggers (e.g., `purpose: zone.enter`), include:
- Version requirement
- Stability status (stable, beta, experimental)
- Which trigger types support `purpose`

---

### 8 — Periodic Maintenance Checks

These checks should be run on a schedule (e.g., after every major HA release):

### MAINT-1: Version Claim Sweep

Re-verify ALL version claims in the guide against the latest release notes. Use the table in VER-1.

### MAINT-2: Deprecated Feature Sweep

Search the guide for any features that have been deprecated or removed in the latest HA release. Update migration paths.

### MAINT-3: New Feature Coverage

Check if the latest HA/ESPHome/MA releases introduced features that should be documented in the guide. Common areas:
- New conversation agent capabilities
- New voice assistant features
- New Music Assistant integration options
- New ESPHome components
- New automation trigger types or conditions

### MAINT-4: Link Rot Check

Verify all external links in the guide still resolve. Replace broken links with current equivalents.

---

## 15.2 — When to Run Checks

### Automatic (AI suggests when relevant)

| Trigger | Checks to suggest |
|---------|-------------------|
| Generating or reviewing any YAML output | SEC-1, CQ-1, CQ-2, CQ-3, CQ-4, CQ-5, CQ-6, VER-2 |
| Editing a style guide `.md` file | AIR-1, AIR-2, AIR-3, AIR-4, AIR-6 for that file, plus its INT-x checklist if it has one |
| User mentions upgrading HA, ESPHome, or MA | MAINT-1 (version sweep), MAINT-2 (deprecation sweep), MAINT-3 (new feature coverage) |
| Adding or changing a version claim in the guide | VER-1 for that claim — verify before committing |
| Adding a new pattern or architecture section | AIR-2 (needs skeleton), ARCH-1 (needs boundary rules), ARCH-2 (needs rationale), ARCH-5 (must be routable) |
| User shares a changelog, release notes URL, or mentions a new release | MAINT-1, MAINT-2, MAINT-3 against that release |
| Renaming, renumbering, or moving sections between files | ARCH-4 (cross-ref integrity), ARCH-5 (routing reachability) |
| Building a new blueprint/script or materially editing one | ARCH-6 (README exists and reflects current state — §11.14) |
| First conversation in a new session involving the style guide | Mention that `run audit` is available if it's been a while |

**For YAML generation checks:** run silently, fix violations before presenting output. Don't ask — just fix.

**For style guide edit checks:** mention which checks apply and offer to run them. Don't force it.

### User-triggered commands

The user can say any of these at any time:

| Command | What it does |
|---------|--------------|
| `run audit` | Full checklist against all style guide files. Report findings in `[SEVERITY] CHECK-ID \| file \| description` format. |
| `run audit on <filename>` | Full checklist scoped to one file. |
| `check secrets` | SEC-1 scan across all files — grep for inline keys/tokens. |
| `check versions` | VER-1 sweep — verify all version claims against current release notes via web search. |
| `check vibe readiness` | AIR-1 through AIR-6 — find vague guidance, missing skeletons, unclear decision logic, stale token counts. |
| `run maintenance` | MAINT-1 through MAINT-4 — version sweep, deprecation sweep, new features, link rot. |
| `check <CHECK-ID>` | Run a single specific check (e.g., `check CQ-3`). |
| `sanity check` | Technical correctness scan: SEC-1 + VER-1 + VER-3 + CQ-5 + CQ-6 + AIR-6 + ARCH-4 + ARCH-5. Only flags broken things — no style nits. |

> **Execution standard (applies to ALL commands above):** Every check runs to its full procedure as defined in §15.1. Spot-checking, eyeballing, sampling, or "structural scans" do not satisfy a check. If a procedure says "verify all 9 claims," verify all 9. If it says "parse every YAML block," parse every YAML block. If it says "compute the set difference," compute it — don't declare PASS on vibes. A check is either fully executed or reported as `[SKIP]` with a reason.

> **📋 Log pair requirement (§11.8.2):** Every command in the table above requires a mandatory log pair (progress + report) in `_build_logs/` before the first check runs. This is unconditional — a clean scan with zero findings still gets both logs. See §11.8.2 for naming conventions and format. Skipping the log pair is an AP-39 violation.

### Progress tracking

When fixing findings from any audit run, maintain a progress log:

```
fix_progress.log format:
[DONE] CHECK-ID | filename | one-line summary of change
[SKIP] CHECK-ID | filename | reason for skipping
```

If a fix session crashes or is resumed, read `fix_progress.log` FIRST and skip anything marked `[DONE]`.

---

## 15.3 — Quick Grep Patterns

Useful searches to catch common violations in YAML files:

```bash
# SEC-1: Find potential inline secrets
grep -rn 'api_key:\s*"' *.md *.yaml
grep -rn 'token:\s*"' *.md *.yaml
grep -rn 'password:\s*"' *.md *.yaml
grep -rn 'sk-' *.md *.yaml

# AIR-1: Find vague guidance
grep -rn 'appropriate\|reasonable\|common sense\|as needed\|good judgment' *.md

# VER-1: Find version claims to verify
grep -rn 'HA 20[0-9][0-9]\.[0-9]' *.md
grep -rn 'requires.*20[0-9][0-9]' *.md
grep -rn 'min_version' *.md

# CQ-1: Find action blocks without aliases
# (Requires YAML-aware parsing — use as rough indicator)
grep -rn 'action:' *.md | grep -v 'alias:'

# ARCH-1: Find layers without boundaries
grep -rn 'Layer [0-9]' *.md | grep -v 'MUST NOT'

# CQ-5: Find YAML blocks to validate
grep -n '```yaml' *.md

# CQ-6: Find legacy syntax in examples (should be action:, not service:)
# Run inside YAML fenced blocks only — manual review needed
grep -n 'service:' *.md | grep -v '#\|service_data\|service call\|service name'

# AIR-6: Measure actual token counts per file
for f in 0*.md; do printf "%-40s %sK tokens\n" "$f" "$(wc -c < "$f" | awk '{printf "%.1f", $1/4/1000}')"; done

# ARCH-4: Find all internal cross-references to verify
grep -oE '§[0-9]+\.[0-9]+(\.[0-9]+)?' *.md | sort | uniq -c | sort -rn
grep -oE '[0-9]{2}_[a-z_]+\.md' *.md | sort -u
grep -oE 'AP-[0-9]+' *.md | sort -u

# ARCH-5: Find all section headings (candidates for routing check)
grep -n '^#{1,3} [0-9]' *.md
```
