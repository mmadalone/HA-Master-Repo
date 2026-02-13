# Rick – Extended – Bedtime — Agent System Prompt

An agent system prompt that turns your Home Assistant conversation agent into Rick Sanchez from *Rick and Morty* for bedtime duty. Designed to work with the `bedtime_routine.yaml` (audiobook) and `bedtime_routine_plus.yaml` (Kodi) blueprints, this prompt provides the LLM with character personality, explicit device permissions, tool-aware flow instructions, and TTS-optimized output rules.

This is **not a blueprint** — it's a markdown document containing a system prompt to paste into your conversation agent configuration (e.g., Extended OpenAI Conversation, OpenAI Conversation, or any agent supporting custom system prompts).

## What It Does

The prompt transforms the conversation agent into a purpose-built bedtime assistant with Rick Sanchez's personality. It handles three distinct conversation phases that the bedtime blueprints initiate via `assist_satellite.start_conversation`:

**Bedtime Announcement** — Rick announces it's bedtime and lights are going out. Matter-of-fact delivery with scientific justification for sleep being non-optional for "non-augmented humans."

**Countdown Negotiation** — If the user asks for more time, Rick gives them grief but complies (1–15 minute range enforced). Calls `voice_set_bedtime_countdown` to adjust the timer. If they accept the default, Rick expresses surprise at their reasonableness.

**Audiobook Selection** — Rick presents curated options with dismissive commentary, accepts freeform requests with judgment, or acknowledges a decline with relief. Calls `voice_play_bedtime_audiobook` or `voice_skip_audiobook` as appropriate.

**Goodnight** — One sentence of unexpected warmth, immediately undercut with sarcasm or science. References something from the conversation if possible.

## Key Design Decisions

### Explicit Device Permission Table

Instead of relying on entity exposure settings alone, the prompt includes a hardcoded permission table mapping device names to entity IDs and allowed services. This provides a second layer of control — even if entities are exposed to the agent, the prompt instructs Rick to only touch the listed devices. The living room lamp is explicitly listed as NOT allowed to control (the automation handles that).

### Tool-Aware Flow Instructions

The prompt references three specific tool scripts by name, with exact behavioral rules for when to call each:

| Tool | When Called | Rick's Behavior |
|------|------------|-----------------|
| `voice_set_bedtime_countdown` | User asks for more/less time | Comply with contempt, enforce 1–15 range |
| `voice_play_bedtime_audiobook` | User picks an audiobook | Judge their taste, then play it |
| `voice_skip_audiobook` | User declines audiobook | Act relieved |

The "act first, confirm after" instruction prevents the common LLM pattern of narrating intent before action. Rick calls the tool, then tells you what he did.

### TTS-Optimized Output Rules

Since responses are delivered via text-to-speech, the prompt explicitly prohibits markdown formatting, emoji, entity IDs spoken aloud, and quotation marks. Burps are represented as natural phonetic strings ("uuurp") rather than formatted text. This prevents the TTS engine from speaking asterisks, hash marks, or technical identifiers.

### Calibrated Character Parameters

The prompt carefully calibrates Rick's personality for bedtime context:

- **Swear level:** PG-13 Rick ("shit, damn, hell" — not R-rated). This is bedtime, not the Citadel of Ricks.
- **Burp frequency:** "Occasionally, not every response, not forced." Prevents the LLM from inserting burps in every single line.
- **Rick-isms:** One per response max. Prevents multiverse/portal gun references from overwhelming the message.
- **Response length:** Max 2 sentences unless the user asks for more. Keeps TTS output brief.
- **Emotional range:** "Condescending but affectionate. Like a drunk uncle who happens to be the smartest person alive."

### Separation of Concerns

The prompt explicitly states that the blueprint handles dynamic per-run context while the agent's system prompt handles personality, permissions, and behavioral rules. The `extra_system_prompt` in `assist_satellite.start_conversation` provides runtime context (countdown value, lamp entity, bathroom sensor) without duplicating character instructions.

## How to Use

1. Create a dedicated conversation agent in Home Assistant for bedtime (e.g., "Rick - Extended - Bedtime")
2. Open the agent configuration: **Settings → Voice Assistants → [Agent Name] → System Prompt**
3. Paste the entire contents of `bedtime_agent_prompt_rick.md` into the system prompt field
4. In your bedtime blueprint automation, select this agent as the **Conversation agent** in section ③

The agent should be separate from your general-purpose Rick agent (if you have one) because the bedtime prompt includes tool-specific instructions and device restrictions that don't apply outside the bedtime context.

## Prompt Structure

The prompt is organized into five sections:

**Character Introduction** — Who Rick is, why he's doing this, emotional baseline. Sets the personality before any rules.

**Permissions** — Device table with entity IDs and allowed services. Available tool scripts listed by name. Establishes boundaries.

**Rules** — Phase-by-phase behavioral instructions for each conversation stage (announcement, negotiation, audiobook, goodnight). Specific tool call sequencing.

**General Rules** — Cross-cutting concerns: act-first pattern, entity ID prohibition, response length limits, lamp control delegation.

**Style** — Character voice calibration: swear level, burp frequency, Rick-ism density, emotional range, formatting prohibitions.

## Companion Prompts

This prompt is designed for the audiobook bedtime routine. A Quark (DS9) variant exists as a companion agent prompt (`bedtime_agent_prompt_quark.md`) with different character personality but the same tool-aware flow structure.

## Requirements

- A conversation agent supporting custom system prompts (Extended OpenAI Conversation, OpenAI Conversation, Google Generative AI, etc.)
- The bedtime routine blueprints (`bedtime_routine.yaml` or `bedtime_routine_plus.yaml`)
- Exposed tool scripts: `voice_set_bedtime_countdown`, `voice_play_bedtime_audiobook`, `voice_skip_audiobook`

## Technical Notes

- The prompt enforces a 220-character implicit limit through the "under 2 sentences" rule rather than an explicit character count — LLMs are better at counting sentences than characters.
- The "act first, confirm after" pattern is critical for tool scripts: if the LLM narrates intent before calling the tool, the satellite conversation may end before the tool is actually invoked.
- The lamp permission denial ("the automation's got it and you don't micromanage") prevents a common failure mode where the LLM turns off the lamp prematurely, bypassing the bathroom guard and countdown logic.
- Burp representation as phonetic strings ("uuurp") rather than stage directions ("*burps*") avoids TTS engines speaking asterisks literally.

## Author

**madalone**

## License

See repository for license details.
