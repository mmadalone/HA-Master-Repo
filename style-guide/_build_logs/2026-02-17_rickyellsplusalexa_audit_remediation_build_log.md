# Build Log: rickyellsplusalexa.yaml — Audit Remediation

| Field | Value |
|---|---|
| **File** | `blueprints/script/madalone/rickyellsplusalexa.yaml` |
| **Blueprint** | Rick wake-up helper – TTS + Alexa music |
| **Type** | Script |
| **Status** | 🔨 in-progress |
| **Started** | 2026-02-17 |
| **Version (pre)** | unversioned |
| **Version (target)** | v2.0 |

---

## Audit Summary (14 violations)

| # | Sev | Violation | Status |
|---|-----|-----------|--------|
| 1 | 🔴 CRIT | `service:` → `action:` | ⬜ pending |
| 2 | 🔴 CRIT | No `continue_on_error` on external calls | ⬜ pending |
| 3 | 🔴 CRIT | No action aliases | ⬜ pending |
| 4 | 🟠 HIGH | No collapsible input sections | ⬜ pending |
| 5 | 🟠 HIGH | Missing defaults block collapsibility | ⬜ pending |
| 6 | 🟠 HIGH | No `source_url` | ⬜ pending |
| 7 | 🟠 HIGH | No version/changelog | ⬜ pending |
| 8 | 🟡 MED | No header image | ⬜ pending |
| 9 | 🟡 MED | Bare `device: {}` selector | ⬜ pending |
| 10 | 🟡 MED | Description template non-standard | ⬜ pending |
| 11 | 🟡 MED | Entity inputs lack any default | ⬜ pending |
| 12 | 🟢 LOW | Redundant `#` numbering | ⬜ pending |
| 13 | 🟢 LOW | Verbose delay block | ⬜ pending |
| 14 | 🟢 LOW | No version in name | ⬜ pending |

---

## Staged Remediation Plan

### Stage 1 — Pre-edit snapshot ✅
- Captured full original file (157 lines)
- Build log created

### Stage 2 — Critical fixes (violations 1–3)
- Replace `service:` → `action:` (×4)
- Add `continue_on_error: true` to all external calls
- Add action aliases to all sequence steps

### Stage 3 — High fixes (violations 4–7)
- Restructure inputs into collapsible sections
- Add bare `default:` to entity selectors
- Add `source_url:` to metadata
- Add version + changelog to description

### Stage 4 — Medium fixes (violations 9–11)
- Filter device selector to Alexa integration
- Reformat description to standard template
- Confirm all defaults applied

### Stage 5 — Low fixes (violations 12–14)
- Clean up comments
- Simplify delay block
- Add version to name

### Stage 6 — Header image (violation 8)
- Generate episode premise
- Present for user approval

---

## Edit Log

### PRE-EDIT STATE (original file — 157 lines)

```yaml
blueprint:
  name: Rick wake-up helper – TTS + Alexa music
  description: |
    **Rick wake-up helper – TTS + Alexa music**
    [... full description block ...]
  domain: script
  input:
    tts_engine:        # no default, no section
    tts_output_player: # no default, no section
    tts_message:       # has default
    tts_voice_profile: # has default
    alexa_delay_after_tts: # has default
    alexa_device:      # no default, bare device: {}
    alexa_volume_command:  # has default
    alexa_song_command:    # has default

mode: single
sequence:
  - service: tts.speak         # deprecated, no alias, no continue_on_error
  - delay: {h:0, m:0, s:input} # verbose
  - service: alexa_devices.send_text_command  # deprecated, no alias, no continue_on_error
  - service: alexa_devices.send_text_command  # deprecated, no alias, no continue_on_error
```



---

### STAGE 2 — Critical fixes (+ LOW 12, 13) ✅

**Violations resolved:** 1, 2, 3, 12, 13

**Changes applied:**
- `service:` → `action:` on all 3 service calls (violation 1)
- Added `continue_on_error: true` to TTS + both Alexa calls (violation 2)
- Added aliases: `"Rick TTS speak on media player"`, `"Delay before Alexa commands"`, `"Alexa set volume"`, `"Alexa play wake-up music"` (violation 3)
- Removed redundant `# 1)` style comments — aliases carry the names now (violation 12)
- Simplified delay block: removed `hours: 0, minutes: 0` padding (violation 13)

**Post-edit sequence block:**
```yaml
sequence:
  - alias: "Rick TTS speak on media player"
    action: tts.speak
    continue_on_error: true
  - alias: "Delay before Alexa commands"
    delay:
      seconds: !input alexa_delay_after_tts
  - alias: "Alexa set volume"
    action: alexa_devices.send_text_command
    continue_on_error: true
  - alias: "Alexa play wake-up music"
    action: alexa_devices.send_text_command
    continue_on_error: true
```


### STAGE 3 — High fixes (violations 4–7) ✅

**Violations resolved:** 4, 5, 6, 7

**Changes applied:**
- **Collapsible sections** (violation 4):
  - `tts_settings:` — `name: "🎙️ TTS Configuration"`, `icon: mdi:account-voice`, `collapsed: false`
  - `alexa_settings:` — `name: "📻 Alexa Configuration"`, `icon: mdi:speaker-wireless`, `collapsed: true`
- **Bare defaults for collapsibility** (violation 5):
  - `tts_engine:` → added `default:`
  - `tts_output_player:` → added `default:`
  - `alexa_device:` → added `default:`
- **source_url** (violation 6):
  - Added `source_url: https://github.com/mmadalone/HA-Master-Repo/blob/main/script/rickyellsplusalexa.yaml`
- **Version/changelog** (violation 7):
  - Added `### Version / Changelog` block with v2.0 and v1.0 entries
  - Description reformatted to standard template (violation 10)

---

### STAGE 4 — Medium fixes (violations 9–11) ✅

**Violations resolved:** 9, 10, 11

**Changes applied:**
- **Device selector filter** (violation 9):
  - `device: {}` → `device: { integration: alexa_devices }`
- **Description template** (violation 10): Reformatted with header image ref,
  clean markdown, requirements section, changelog — all in Stage 3 edit.
- **Entity defaults** (violation 11): Covered by Stage 3 bare `default:` additions.

---

### STAGE 5 — Low fixes (violations 12–14) ✅

**Violations resolved:** 12, 13, 14

**Changes applied:**
- **Comment cleanup** (violation 12): Done in Stage 2 — aliases replaced numbered comments.
- **Delay simplification** (violation 13): Done in Stage 2 — removed `hours: 0, minutes: 0`.
- **Version in name** (violation 14): Name now reads `Rick wake-up helper – TTS + Alexa music (v2.0)`.

---

## Updated Audit Tracker

| # | Sev | Violation | Status |
|---|-----|-----------|--------|
| 1 | 🔴 CRIT | `service:` → `action:` | ✅ Stage 2 |
| 2 | 🔴 CRIT | No `continue_on_error` on external calls | ✅ Stage 2 |
| 3 | 🔴 CRIT | No action aliases | ✅ Stage 2 |
| 4 | 🟠 HIGH | No collapsible input sections | ✅ Stage 3 |
| 5 | 🟠 HIGH | Missing defaults block collapsibility | ✅ Stage 3 |
| 6 | 🟠 HIGH | No `source_url` | ✅ Stage 3 |
| 7 | 🟠 HIGH | No version/changelog | ✅ Stage 3 |
| 8 | 🟡 MED | No header image | ⏳ Stage 6 — awaiting user approval |
| 9 | 🟡 MED | Bare `device: {}` selector | ✅ Stage 4 |
| 10 | 🟡 MED | Description template non-standard | ✅ Stage 4 |
| 11 | 🟡 MED | Entity inputs lack any default | ✅ Stage 4 |
| 12 | 🟢 LOW | Redundant `#` numbering | ✅ Stage 2 |
| 13 | 🟢 LOW | Verbose delay block | ✅ Stage 2 |
| 14 | 🟢 LOW | No version in name | ✅ Stage 5 |

**Score: 13/14 resolved. 1 pending (header image — user approval required).**


### STAGE 6 — Header image (violation 8) ✅

**Violation resolved:** 8

**Changes applied:**
- Renamed `image-1771365817398.jpeg` → `rickyellsplusalexa-header.jpeg` in `HEADER_IMG`
- Updated blueprint description image URL:
  `https://raw.githubusercontent.com/mmadalone/HA-Master-Repo/main/images/header/rickyellsplusalexa-header.jpeg`
- Episode premise: "The Wake-Up Profit" (Rick & Quark series)

---

## Final Audit Tracker

| # | Sev | Violation | Status |
|---|-----|-----------|--------|
| 1 | 🔴 CRIT | `service:` → `action:` | ✅ Stage 2 |
| 2 | 🔴 CRIT | No `continue_on_error` on external calls | ✅ Stage 2 |
| 3 | 🔴 CRIT | No action aliases | ✅ Stage 2 |
| 4 | 🟠 HIGH | No collapsible input sections | ✅ Stage 3 |
| 5 | 🟠 HIGH | Missing defaults block collapsibility | ✅ Stage 3 |
| 6 | 🟠 HIGH | No `source_url` | ✅ Stage 3 |
| 7 | 🟠 HIGH | No version/changelog | ✅ Stage 3 |
| 8 | 🟡 MED | No header image | ✅ Stage 6 |
| 9 | 🟡 MED | Bare `device: {}` selector | ✅ Stage 4 |
| 10 | 🟡 MED | Description template non-standard | ✅ Stage 4 |
| 11 | 🟡 MED | Entity inputs lack any default | ✅ Stage 4 |
| 12 | 🟢 LOW | Redundant `#` numbering | ✅ Stage 2 |
| 13 | 🟢 LOW | Verbose delay block | ✅ Stage 2 |
| 14 | 🟢 LOW | No version in name | ✅ Stage 5 |

**Score: 14/14 ✅ — ALL VIOLATIONS RESOLVED**

---

| Field | Value |
|---|---|
| **Status** | ✅ completed |
| **Version (final)** | v2.0 |
| **Lines (pre)** | 157 |
| **Lines (post)** | 155 |

