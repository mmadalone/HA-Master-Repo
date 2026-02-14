# Build Log — Style Guide README Generation

| Field | Value |
|---|---|
| **Date** | 2026-02-14 |
| **Task** | Generate 11 READMEs + 11 header images for all style guide files |
| **Mode** | BUILD |
| **Status** | completed |
| **Output Dir (READMEs)** | `GIT_REPO/readme/style-guide/` |
| **Output Dir (Images)** | `GIT_REPO/images/style-guide/` |
| **Image URLs** | `https://raw.githubusercontent.com/mmadalone/HA-Master-Repo/main/images/style-guide/<n>-header.jpeg` |

## Scope

11 style guide files → 11 READMEs + 11 header images:

| # | Source File | README | Image | Image Status |
|---|---|---|---|---|
| 1 | `ha_style_guide_project_instructions.md` | `ha_style_guide_project_instructions-readme.md` | `ha_style_guide_project_instructions-header.jpeg` (774KB) | ✅ approved — Rick & Quark at desk, holographic TOC, latinum, bar through window |
| 2 | `00_core_philosophy.md` | `00_core_philosophy-readme.md` | `00_core_philosophy-header.jpeg` (389KB, compressed) | ✅ approved — Rick & Quark crossover, workbench flowchart board, lab gear + latinum |
| 3 | `01_blueprint_patterns.md` | `01_blueprint_patterns-readme.md` | `01_blueprint_patterns-header.jpeg` (762KB) | ✅ approved — Red alert corridor, Rick pointing at blueprints Quark holds, sparks + smoke |
| 4 | `02_automation_patterns.md` | `02_automation_patterns-readme.md` | `02_automation_patterns-header.jpeg` (844KB) | ✅ approved — user-selected image-1771079075424.jpeg (glitching transporter, routing panel, bounce dot) |
| 5 | `03_conversation_agents.md` | `03_conversation_agents-readme.md` | `03_conversation_agents-header.jpeg` (419KB, compressed) | ✅ approved — user-selected image-1771079390576.jpeg (multi-agent bar chaos) |
| 6 | `04_esphome_patterns.md` | `04_esphome_patterns-readme.md` | `04_esphome_patterns-header.jpeg` (709KB) | ✅ approved — over-shoulder shot, Rick soldering circuit board, Quark with magnifying glass, firmware display |
| 7 | `05_music_assistant_patterns.md` | `05_music_assistant_patterns-readme.md` | `05_music_assistant_patterns-header.jpeg` | ✅ approved — user handled final selection independently |
| 8 | `06_anti_patterns_and_workflow.md` | `06_anti_patterns_and_workflow-readme.md` | `06_anti_patterns_and_workflow-header.jpeg` (777KB) | ✅ approved — duct-tape shuttle falling apart, Quark gripping seat, Rick grabbing at panels |
| 9 | `07_troubleshooting.md` | `07_troubleshooting-readme.md` | `07_troubleshooting-header.jpeg` (697KB) | ✅ approved — dark diagnostic room, Quark pointing at ERROR, Rick pointing at trace panel, holographic logs |
| 10 | `08_voice_assistant_pattern.md` | `08_voice_assistant_pattern-readme.md` | `08_voice_assistant_pattern-header.jpeg` (365KB, compressed) | ✅ approved — user-selected image-1771082657633.jpeg (Quark clone flood, Rick portal gun, low angle bar) |
| 11 | `09_qa_audit_checklist.md` | `09_qa_audit_checklist-readme.md` | `09_qa_audit_checklist-header.jpeg` (805KB) | ✅ approved — user-selected image-1771083385534.jpeg (QA audit dimension, Quark PASS, Rick swarmed by ERROR stamps) |

## Decisions

- **Image size:** 1K resolution (Gemini minimum), 16:9 aspect ratio, must be under 900KB — compress with `sips -s formatOptions 80` if over
- **Image style:** Rick & Quark crossover episode — Lower Decks meets Rick & Morty animation. Each image is a scene from a fictional crossover episode themed by the README's content
- **Image approval gate:** User approves each image individually before renaming/moving. Show image first, wait for approval, THEN move to final location
- **Quark rules:** Quark wears brown-gold civilian bartender clothes ONLY — never a Starfleet uniform. Normal adult height, not a dwarf. He works at his bar, not for the Federation
- **Camera variety:** Vary shot angles (low, high, over-shoulder, wide, close-up) and character positioning (don't always put Rick left, Quark right)
- **Source attribution:** Each README includes a Sources & Acknowledgments section citing HA docs, ESPHome docs, MA docs, Extended OpenAI Conversation, DS9, Rick & Morty as appropriate per file
- **Tooling disclosure:** Each README includes Claude Desktop MCP tooling used (Desktop Commander, Filesystem MCP, git MCP, ripgrep, Context7, HA MCP, ha-ssh, Gemini)
- **AI collaboration disclosure:** Each README acknowledges AI-assisted creation with Claude (Anthropic) via Claude Desktop
- **Cultural references:** DS9/Ferengi/Quark/Rick & Morty peppered in but not heavy-handed

## Workflow

1. ✅ Read all 11 source files for content and plagiarism analysis
2. ✅ Plan README structure and image themes — user approved
3. ✅ Create output directories (readme/style-guide, images/style-guide)
4. ✅ Generate images one at a time with user approval gate per image — **11 of 11 approved**
5. ✅ Write READMEs — **11 of 11 written**
6. ✅ Final review — all 11 read back, user approved
7. ✅ Commit via Post-Edit Publish Workflow — **user handled commit + push independently**

## Notes

- Gemini frequently generates images over 1MB requiring prompt simplification (fewer characters, simpler backgrounds)
- Gemini has a bias toward making Quark very short/dwarf-like — explicit "normal adult height" prompt language helps
- Gemini tends to put Quark in Starfleet uniforms — must explicitly say "civilian bartender clothes" and "NOT wearing Starfleet uniform"
- User selects from Gemini output directory when multiple candidates exist (images land in `images/header/` before being moved)
- Stray images accumulate in `images/header/` — cleanup needed at end of session
- Session 2 (2026-02-14 ~15:00 UTC): completed images #10 and #11. User strongly prefers Rick & Morty episode premises over static scenes — think actual R&M cold opens with weird sci-fi concepts gone wrong, not just "two guys standing in a room." Dynamic camera angles are mandatory — no straight-on medium shots
- For image #10 (voice assistant), user selected from Gemini candidates independently (image-1771082657633.jpeg) — compressed to 365KB
- For image #11 (QA audit), user selected image-1771083385534.jpeg (805KB, no compression needed)
- Session 3 (2026-02-14 ~16:00 UTC): Wrote all 11 READMEs. Template structure: title + header image → overview (2-3 paragraphs) → What's Inside (section breakdown) → When to Load (mode table) → Key Concepts (3-5 takeaways) → Related Files (cross-references) → Sources & Acknowledgments → Tooling & AI Disclosure → Author/License. Consistent across all 11 files, adapted per file's content domain. All written directly to `GIT_REPO/readme/style-guide/`. Full review completed — all 11 read back to user. User committed and pushed independently.
- Stray images in `images/header/` still need cleanup (leftover Gemini candidates from sessions 1–2)
- **BUILD COMPLETE** — 11 images + 11 READMEs delivered, committed, pushed. Total span: 3 sessions across 2026-02-14.
