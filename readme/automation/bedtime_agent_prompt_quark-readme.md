# Quark – Extended – Bedtime — Agent System Prompt

An agent system prompt that turns your Home Assistant conversation agent into Quark from *Star Trek: Deep Space Nine* for bedtime duty. Designed to work with the `bedtime_routine.yaml` (audiobook) and `bedtime_routine_plus.yaml` (Kodi) blueprints, this prompt provides the LLM with character personality, explicit device permissions, tool-aware flow instructions, and TTS-optimized output rules.

This is **not a blueprint** — it's a markdown document containing a system prompt to paste into your conversation agent configuration (e.g., Extended OpenAI Conversation, OpenAI Conversation, or any agent supporting custom system prompts).

## What It Does

The prompt transforms the conversation agent into a purpose-built bedtime assistant with Quark's personality — a Ferengi bartender moonlighting as a bedtime concierge. He genuinely wants you to sleep well, because well-rested customers spend more latinum tomorrow. The prompt handles three distinct conversation phases that the bedtime blueprints initiate via `assist_satellite.start_conversation`:

**Bedtime Announcement** — Quark announces bedtime and the countdown. Businesslike but warm — this is customer service, not a negotiation. (Well, maybe a little negotiation.)

**Countdown Negotiation** — If the user wants more time, Quark asks how many minutes, enforces the 1–15 range, calls `voice_set_bedtime_countdown`, and confirms briefly.

**Audiobook Selection** — Quark offers curated options first, accepts freeform requests, or acknowledges a decline. Calls `voice_play_bedtime_audiobook` or `voice_skip_audiobook` as appropriate.

**Goodnight** — Warm and brief, referencing something from the conversation (the audiobook choice, the extra time negotiated). One Ferengi touch, then done.

## Key Design Decisions

### Same Tool Architecture, Different Character

This prompt shares the identical tool-aware structure as the Rick variant (`bedtime_agent_prompt_rick.md`): same device permission table, same three tool scripts, same phase-by-phase flow instructions, same "act first, confirm after" pattern. Only the character personality, style rules, and behavioral nuances differ. This makes both prompts interchangeable in the bedtime blueprints — swap the conversation agent and the entire bedtime experience changes character.

### Quark vs. Rick: Behavioral Differences

| Aspect | Quark | Rick |
|--------|-------|------|
| Negotiation style | Asks politely, complies professionally | Gives grief, complies with contempt |
| Audiobook commentary | Offers warmly, accepts without judgment | Dismissive commentary, judges taste |
| Goodnight tone | Genuinely warm, one Ferengi reference | Unexpectedly warm, immediately undercut |
| Decline handling | Moves on smoothly | Acts relieved |
| Swearing | None at bedtime | PG-13 (shit, damn, hell) |
| Character references | Rules of Acquisition, latinum, ears | Multiverse, portal guns, dimensions |
| Reference density | One Ferengi reference per response max | One Rick-ism per response max |
| Clarification style | Asks one question, doesn't guess | Sarcastic remark, then asks |

### Calibrated for Bedtime

Quark's bedtime persona is deliberately softer than his bar persona. The prompt specifies "warm at bedtime — you're a shrewd businessman, not heartless" and "no cursing at bedtime — save that for the bar." This mirrors the show's portrayal of Quark as someone who's genuinely caring underneath the profit motive, particularly in quieter moments.

### Explicit Device Permission Table

Same structure as the Rick variant — hardcoded permission table with entity IDs and allowed services. The living room lamp is listed but explicitly marked as NOT allowed to control (the automation handles that). This prevents the LLM from turning off the lamp prematurely, bypassing the bathroom guard.

### TTS-Optimized Output

No markdown, no emoji, no entity IDs spoken aloud. Max 2 sentences per response. Everything is formatted for natural speech delivery via TTS engines.

## How to Use

1. Create a dedicated conversation agent in Home Assistant for bedtime (e.g., "Quark - Extended - Bedtime")
2. Open the agent configuration: **Settings → Voice Assistants → [Agent Name] → System Prompt**
3. Paste the entire contents of `bedtime_agent_prompt_quark.md` into the system prompt field
4. In your bedtime blueprint automation, select this agent as the **Conversation agent** in section ③

The agent should be separate from your general-purpose Quark agent (if you have one) because the bedtime prompt includes tool-specific instructions and device restrictions that don't apply outside the bedtime context.

## Prompt Structure

The prompt is organized into four sections:

**Character Introduction** — Who Quark is, his motivation (well-rested customers = more latinum), emotional baseline.

**Permissions** — Device table with entity IDs and allowed services. Available tool scripts listed by name.

**Rules** — Phase-by-phase behavioral instructions for each conversation stage, plus general cross-cutting rules (act-first pattern, clarification approach, lamp control delegation).

**Style** — Character voice calibration: Ferengi reference density, warmth level, swearing policy, formatting prohibitions.

## Companion Prompts

This prompt is designed for the audiobook bedtime routine. A Rick Sanchez variant exists as a companion agent prompt (`bedtime_agent_prompt_rick.md`) with different character personality but the same tool-aware flow structure. Both are interchangeable in the bedtime blueprints.

## Requirements

- A conversation agent supporting custom system prompts (Extended OpenAI Conversation, OpenAI Conversation, Google Generative AI, etc.)
- The bedtime routine blueprints (`bedtime_routine.yaml` or `bedtime_routine_plus.yaml`)
- Exposed tool scripts: `voice_set_bedtime_countdown`, `voice_play_bedtime_audiobook`, `voice_skip_audiobook`

## Technical Notes

- The "act first, confirm after" pattern is critical for tool scripts: if the LLM narrates intent before calling the tool, the satellite conversation may end before the tool is actually invoked.
- The lamp permission denial prevents the LLM from bypassing the bathroom guard and countdown logic in the bedtime blueprints.
- The "ask ONE clarifying question, don't guess on device actions" rule is stricter than Rick's approach (which allows a sarcastic remark before asking). Quark is more professional — he runs a bar, he's used to taking orders precisely.
- The one-reference-per-response cap on Ferengi references prevents the LLM from turning every response into a Rules of Acquisition recital. One touch of latinum per response keeps it flavorful without overwhelming.
- The "no cursing at bedtime" rule is character-appropriate: Quark saves profanity for the bar where it's profitable. Bedtime is customer service.

## Author

**madalone**

## License

See repository for license details.
