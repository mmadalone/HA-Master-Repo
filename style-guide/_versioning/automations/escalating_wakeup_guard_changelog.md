# escalating_wakeup_guard — Changelog

## v7 — 2026-02-09

### Feature fix
- Wired `v_llm_context_entities` into `conversation.process` `text:` field
  — sensor readings (friendly_name + state) now appended to the LLM prompt
  when context entities are configured. Previously the input was declared
  and resolved to a variable but never referenced in any action.
- Updated alias on `conversation.process` call to reflect context injection

## v6 — 2026-02-09

### Moderate fixes
- Replaced template weekday condition with native `condition: time` + `weekday:` (§1.4)
  — validated at load time instead of silently failing at runtime
- Removed orphaned `v_active_days` variable (no longer referenced after native condition switch)

### Minor fixes
- Removed decorative `═══` cleanup banner from action section (§3.5 — aliases are the docs)
- Added `continue_on_error: true` on both flash cycle light actions (§5.2 — rapid-fire
  calls to flaky bulbs shouldn't abort the final-stage flash loop)

Net: 858 lines (−4 from v5 — native condition is more compact than template)

## v5 — 2026-02-09

### Style guide compliance fixes
- Added missing aliases on 3 inner service calls inside if/then blocks:
  - `light.turn_on` inside brightness ramp → "Turn on lights at interpolated brightness"
  - `script.turn_on` inside interrupted cleanup → "Execute cleanup script"
  - `script.turn_on` inside post-escalation cleanup → "Execute cleanup script"
- Removed 8 decorative `═══` banner comments from input sections (redundant with
  collapsible section name/icon/description metadata). Kept action-section separator.
- Added `| default([])` guard on `v_active_days` in weekday condition template (§3.6)
- Updated blueprint description to reflect v5 changes

## v4 — 2026-02-09

### Moderate fixes
- Added `continue_on_error: true` on music script call (non-critical, optional feature)
- Added `continue_on_error: true` on mobile notification call (non-critical, optional feature)
- Added aliases on both flash delay steps (`"Flash off hold"`, `"Flash on hold"`)

### Low-priority fixes
- Added `continue_on_error: true` on light brightness ramp (user decision: survive silent)
- Added `continue_on_error: true` on both cleanup volume_set calls (prevents toggle reset
  and cleanup script from being skipped as collateral damage)
- Added `# NOTE: duplicated` comments on both activity-sensor template blocks
  (no extraction path in HA — pragmatic duplication)

Net: 890 lines (+11 from v3 — all error guards and documentation)

## v3 — 2026-02-09

### Critical fixes
- **Fix #1 — Merged duplicate cleanup blocks** (3→2): Combined the two in-loop exit
  checks (cancel signal + activity re-check) into a single `condition: or` block with
  one shared cleanup sequence. Post-loop cleanup remains separate (HA has no `break` in
  repeat loops, so `stop:` inside the loop can't flow to shared code after it).
- **Fix #2 — Guarded cleanup script calls**: Added `continue_on_error: true` to both
  `script.turn_on` calls for the optional cleanup script. It's a non-critical optional
  step — shouldn't kill the automation if the script entity is unavailable.
- **Fix #3 — DRYed LLM resolution + type-safe parsing**: Replaced 3-branch `choose`
  block (first/final/middle) with a single variable-selection step + one LLM call path.
  Added `is mapping` guard on `llm_response` to prevent Jinja2 crash if `continue_on_error`
  swallows an exception and the response isn't a dict. Net: 1 conversation.process call
  instead of 3, 1 response parser instead of 3.

### Moderate fixes
- Removed decorative `═══` banners around trigger/condition/variables/action keys (§3.5)
- Added HA limitation note to `notify_service` description (Anti-pattern #13)
- Marked `stop_toggle` as REQUIRED in its description (§3.3)
- Added `id: guard_time` to trigger (§5.6)
- Added no-space `{{stage}}`/`{{total}}`/`{{stage_delay}}` fallback replace variants for
  placeholder robustness (§3.4)
- Added `trace: stored_traces: 15` for complex automation debugging (§5.8)
- Style guide §3.2 updated to accept circled number emoji (`①②③`) as alternative to
  `"Stage N —"` section naming — existing pattern kept as-is

### Low-priority fixes
- Renamed `active_days` → `v_active_days` for naming convention consistency; added
  comment documenting the `v_` prefix convention at top of variables block
- #12 (music_script default `""`) reviewed and cleared — `default: ""` + runtime guard
  is the canonical HA pattern for optional entity selector inputs
- #13 (inconsistent collapsed) reviewed and cleared — sections 1–4 expanded (core config),
  5–8 collapsed (advanced/optional) is intentional progressive disclosure

- Net: 878 lines (−84 from v2)

## v2 — 2026-02-09
- Switched TTS delivery from raw tts.speak via helper script to conversation agent pipeline
- Removed inputs: tts_engine, voice_profile, tts_speak_script
- Added input: conversation_agent (conversation_agent selector)
- Replaced script.turn_on action with conversation.process (continue_on_error: true)
- Kept tts_output_player — still needed for volume control during escalation
- Removed variables: v_tts_engine, v_voice_profile, v_tts_speak_script
- Added variable: v_conversation_agent
- Net: 947 lines (−19), 49 !input refs (−3)

## v_initial — 2026-02-09
- Initial generation: 966 lines, 52 !input references, valid YAML
- 8 collapsible input sections (Schedule, Activity Sensors, TTS & Voice, Escalation, Messages, LLM Config, Optional Features, Cleanup)
- Inverted presence logic with configurable activity_lookback window
- Interpolation engine for volume and brightness across num_stages (1-6)
- 3-tier hybrid LLM messages (first/middle/final) with use_llm toggles, prompts, static fallbacks
- Optional lights with start/end brightness and flash_final_stage
- Optional music via script call at configurable stage threshold
- Mobile notification with STOP action button (first stage only)
- Cancellation via wait_for_trigger (mobile action + stop_toggle + activity_sensors)
- Cleanup on all exit paths: volume restore, toggle reset, optional cleanup script
- Bug fix during generation: music_started scoping — changed >= to == for single-fire without persistent flag
- Bug fix during generation: optional entity selector defaults changed from [] to "" to match llm_alarm pattern
