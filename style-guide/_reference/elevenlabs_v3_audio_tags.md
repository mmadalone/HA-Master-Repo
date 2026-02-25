# ElevenLabs v3 Audio Tags — Reference Guide

**Created:** 2025-02-25
**Purpose:** Cross-blueprint reference for TTS dramatization capabilities.
All blueprints that produce LLM → TTS output can leverage this.

---

## Overview

ElevenLabs Eleven v3 supports inline **audio tags** — square-bracketed stage
directions the model interprets as performance cues rather than text to speak.
These are v3-exclusive; older models (Flash v2.5, Turbo v2.5, Multilingual v2)
do NOT support them and will read the brackets literally.

Older ElevenLabs models interpret emotion from **textual context** instead —
phrases like "she said excitedly" or exclamation marks influence delivery.

---

## Audio Tag Categories

### Voice / Emotional Delivery
```
[laughs]  [laughs harder]  [starts laughing]  [wheezing]
[whispers]  [shouts]
[sighs]  [exhales]
[sarcastic]  [curious]  [excited]  [crying]  [snorts]  [mischievously]
[cheerfully]  [flatly]  [deadpan]  [playfully]
[tired]  [nervous]  [angry]  [happy]  [sorrowful]
```

### Cognitive / Pacing Beats
```
[pauses]  [short pause]  [long pause]
[hesitates]  [stammers]  [resigned tone]
```

### Non-Verbal Reactions
```
[clears throat]  [gulps]  [gasps]  [snorts]
```

### Sound Effects (Experimental)
```
[gunshot]  [applause]  [clapping]  [explosion]
[door slam]  [knocking]  [thunder]  [door creaks]
```

### Unique / Experimental
```
[sings]  [woo]  [fart]
[strong X accent]  (replace X with desired accent)
[rhythmically]  [singsong]
```

## Combinability

Tags can be stacked for layered effects:
```
[nervously][whispers] I... I'm not sure this is going to work.
[happily][shouts] We did it! [laughs] I can't believe we actually won!
```

## Punctuation Effects (v3)

- **Ellipses (…)** → natural pauses, hesitation
- **CAPITALS** → emphasis and stress
- **Exclamation marks** → energy and urgency
- **Question marks** → natural upward inflection
- **Dashes (— or -)** → short pauses

Example: `Wait... what are you DOING?` sounds dramatically different from
`Wait what are you doing` in v3.

---

## Settings That Affect Tag Behavior

### Stability Slider
- **Low (Creative):** Most emotional, more expressive, prone to hallucinations.
  Best for dramatic content, character acting.
- **Mid (Natural):** Balanced, closest to original voice. Good general purpose.
- **High (Robust):** Stable, consistent, less responsive to audio tags.

### Voice Selection
Tag effectiveness depends on the voice's training data. A whispering voice
won't respond well to `[shouts]`. Match voice character to intended use.

---

## Important Caveats

1. **v3 Alpha status** — model is still being developed, may be inconsistent.
2. **Tags may be spoken aloud** instead of interpreted, especially with
   incompatible voices or if v3 isn't selected.
3. **Short prompts (<250 chars)** produce more variable results.
4. **PVCs not fully optimized** for v3 yet — IVCs recommended.
5. **Not for real-time** — v3 is not designed for ultra-low-latency use.
   Flash v2.5 (~75ms) or Turbo v2.5 (~250ms) are better for live agents.
6. **SSML break tags NOT supported** in v3 — use `[pause]` tags instead.

---

## Older Model Alternatives

For non-v3 ElevenLabs models and other TTS engines:
- Emotion comes from **text context** ("he said angrily", exclamation marks)
- Descriptive text WILL be spoken — must be trimmed if undesired
- SSML `<break>` tags work on Flash v2, Turbo v2, Multilingual v2
- SSML phoneme tags work on Flash v2, Turbo v2, English v1 only

---

## Blueprint Integration Pattern

When a blueprint produces LLM → TTS output:

1. **Blueprint input** `tts_engine_type` selector controls TTS-awareness
2. **LLM prompt** includes conditional block based on engine type:
   - `basic`: plain spoken text only
   - `elevenlabs_v3`: may include `[audio tags]`
3. **Expressive text reference table** is always included (LLM-agnostic)
4. **Cultural laughter/expression patterns** are configurable via input

See: `notification_follow_me_design_backlog.md` Issue 3 for the full
design abstraction applied to notification_follow_me.yaml.

---

## Sources

- https://elevenlabs.io/docs/overview/capabilities/text-to-speech/best-practices
- https://elevenlabs.io/blog/v3-audiotags
- https://elevenlabs.io/blog/eleven-v3
- https://help.elevenlabs.io/hc/en-us/articles/35869142561297
