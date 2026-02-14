# Music Assistant Patterns — Players, TTS Duck/Restore & Voice Bridges

![Music Assistant Patterns header](https://raw.githubusercontent.com/mmadalone/HA-Master-Repo/main/images/style-guide/05_music_assistant_patterns-header.jpeg)

The sound system manual. Music Assistant is one of the most complex integrations in this project — it manages multi-room audio, handles the delicate dance between music playback and TTS announcements, syncs volume with Alexa, and bridges voice commands to media control. This file documents every pattern needed to make it all work without speakers cutting out, volumes going haywire, or TTS talking over music at full blast.

One section — §7 — but at ~11.5K tokens it's the second largest pattern doc in the guide. Eleven subsections covering the full spectrum of Music Assistant integration.

## What's Inside

**§7 — Music Assistant Patterns** starts with the critical distinction between MA players and generic media_players (§7.1) — they look similar but behave differently. The `music_assistant.play_media` service (§7.2) versus `media_player.play_media` — always use the MA-native call. Stop vs Pause semantics (§7.3) explains when each is appropriate and why the wrong choice causes silent failures.

The TTS duck/restore pattern (§7.4) is the crown jewel — the choreography of lowering music volume, playing a TTS announcement, waiting for it to finish, and restoring volume. This involves timing guards, state snapshots, and fallback paths for when the restore fails. Volume sync between Alexa and MA (§7.5) handles the bidirectional volume matching that keeps physical device controls and HA-controlled volume in agreement.

Presence-aware player selection (§7.6) picks the right speaker based on room occupancy. Voice command → MA playback bridges (§7.7) use the input_boolean pattern to translate Alexa voice commands into HA automations that control MA. Voice playback initiation (§7.8) documents the LLM script-as-tool pattern where a conversation agent triggers media playback through exposed scripts. The search → select → play disambiguation pattern (§7.8.1) handles ambiguous voice requests. Voice media control via thin wrappers (§7.9) provides volume, skip, pause, and stop through agent-callable scripts. TTS coexistence on Voice PE speakers (§7.10) solves the conflict when the same speaker handles both music and voice assistant audio. Extra zone mappings (§7.11) handles shared speakers that appear in multiple MA zones.

## When to Load

T1 (task-specific). The largest pattern doc — load selectively. §7.2 (play_media) and §7.4 (duck/restore) are the most frequently needed sections. Load the voice bridge sections (§7.7–§7.9) only when working on voice-controlled media.

| Mode | When to load |
|------|-------------|
| BUILD | Any Music Assistant integration task. Pair with §5.1 (timeouts) from Automation Patterns. |
| TROUBLESHOOT | On demand — paired with §13.7 (debugging MA issues) |
| AUDIT | When reviewing MA integration compliance (AP-30 through AP-35) |

## Key Concepts

**MA players ≠ media_players** (§7.1) — Music Assistant creates its own player entities that wrap underlying media_players. Always target MA player entities for MA operations. Targeting the underlying media_player directly bypasses MA's queue management and state tracking.

**TTS duck/restore** (§7.4) — the most complex single pattern in the guide. Before a TTS announcement: snapshot current volume and playback state, lower volume to a duck level, wait for the volume change to propagate, play TTS, wait for TTS to finish (with timeout!), restore volume, restore playback if it was paused. Every step needs a timeout and a fallback path. Getting this wrong means music blasting back at full volume mid-announcement or never resuming after TTS.

**Voice command bridges** (§7.7) — Alexa can't call MA services directly. The bridge pattern uses an `input_boolean` that Alexa toggles, which triggers an automation that calls the actual MA service. The automation resets the boolean after execution, making it ready for the next command.

**Script-as-tool for agents** (§7.8) — conversation agents don't call `music_assistant.play_media` directly. They call exposed HA scripts that wrap the service call with proper error handling, volume management, and player selection. The script is the tool; the agent is the user of the tool.

**Presence-aware selection** (§7.6) — instead of hardcoding which speaker plays music, the system checks occupancy sensors to determine which room the user is in and routes playback accordingly. Combined with MA's group player capabilities, this enables follow-me audio.

## Related Files

| File | Relationship |
|------|-------------|
| `02_automation_patterns.md` | §5.1 (timeouts) is critical for duck/restore timing |
| `03_conversation_agents.md` | §8.3.2 (tool exposure) for wiring MA scripts as agent tools |
| `08_voice_assistant_pattern.md` | §14.5–§14.7 detail how voice commands flow to MA playback |
| `07_troubleshooting.md` | §13.7 covers MA-specific debugging |
| `06_anti_patterns_and_workflow.md` | AP-30 through AP-35 target MA-specific anti-patterns |

## Sources & Acknowledgments

Music Assistant patterns draw from official [Music Assistant documentation](https://music-assistant.io/) and the MA integration's service call reference. Volume sync and Alexa bridge patterns were developed through real-world multi-room audio testing. The TTS duck/restore choreography was refined through extensive debugging of timing edge cases across different speaker hardware.

Cultural references: *Star Trek: Deep Space Nine* (Paramount), *Rick and Morty* (Adult Swim).

## Tooling & AI Disclosure

Developed collaboratively with **Claude** (Anthropic) via Claude Desktop. MCP tools: Desktop Commander, Filesystem MCP, git MCP, ripgrep, Context7, HA MCP, ha-ssh, Gemini.

## Author

**madalone** · [GitHub](https://github.com/mmadalone)

## License

See repository root for license details.
