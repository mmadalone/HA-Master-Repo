# Alexa ↔ Music Assistant Volume Sync

![Header](https://raw.githubusercontent.com/mmadalone/HA-Master-Repo/main/images/header/alexa_ma_volume_sync_blueprint-header.jpeg)

A blueprint that keeps the volume and mute state of paired Alexa Echo devices and Music Assistant speakers in sync — bidirectionally. Change the volume on either device and its partner follows. Supports multiple device pairs in a single blueprint instance.

## How It Works

The blueprint triggers on `volume_level` and `is_volume_muted` attribute changes on both Alexa and Music Assistant media players. When a change is detected, it identifies which device pair was affected using list-index matching, checks direction permissions and tolerance thresholds, applies a cooldown to absorb rapid changes, then syncs the volume and mute state to the partner device.

The flow is: volume/mute changes on either device → pair index lookup → ducking guard check → direction check → optional playing-state check → tolerance filter → cooldown delay → re-read source volume → sync mute state → sync volume level.

## Key Design Decisions

### Voice PE Ducking Guard

The `ducking_flag` input connects to the same `input_boolean` used by Voice PE duck/restore blueprints. When the flag is ON (meaning a voice pipeline is actively ducking volumes for TTS playback), volume sync is paused entirely. Without this, the ducking action would trigger a sync, the sync would fight the restore, and you'd get a feedback loop that oscillates the volume until one side gives up. The guard breaks the loop at the source.

### Tolerance Threshold

The `volume_tolerance` input (default 3%) prevents unnecessary syncs from rounding differences between Alexa and Music Assistant. The two platforms report volume at slightly different precisions, so a volume of 0.25 on one device might read as 0.24 or 0.26 on the other. Without the tolerance, these rounding artifacts would trigger an infinite sync loop: A→B sync, B reads slightly different, B→A sync, A reads slightly different, repeat.

### Cooldown with Fresh Re-Read

The cooldown delay (default 1 second) absorbs rapid volume changes — the kind you get when holding the volume button. After the delay, the blueprint re-reads the source volume (`fresh_source_vol`) instead of using the stale value from trigger time. This means if you hold the volume button for 3 seconds, only the final volume gets synced to the partner rather than every intermediate step.

### Zero-Volume Mute Detection

The volume sync action includes implicit mute logic: if the re-read source volume is 0, the target is muted; if it's above 0, the target is unmuted. This runs alongside the explicit mute trigger path, ensuring that volume-to-zero always results in a muted partner device regardless of which attribute change fires first.

### Pair Index Matching

Devices are paired by list position: first Alexa player maps to first MA player, second to second. The `pair_index` variable uses Python's `.index()` method within Jinja2 to find the changed entity's position in its source list, with a `-1` fallback if the entity isn't found. The partner entity is then looked up by the same index in the opposite list.

### Queued Mode

The blueprint runs in `mode: queued` with `max: 4`. Volume changes can come in bursts (especially when holding a button), and queued mode ensures each change gets processed in order rather than being dropped or restarted. The `max: 4` cap prevents an unbounded queue from building up during rapid changes, and `max_exceeded: silent` drops excess events quietly.

## Blueprint Inputs

**① Device Pairing** — Select Alexa media players (from `alexa_media` integration) and Music Assistant players in matching order. First Alexa pairs with first MA, second with second.

**② Sync Settings** (collapsed) — Voice PE ducking flag entity, sync direction (both/Alexa→MA/MA→Alexa), volume tolerance percentage, cooldown duration, and optional playing-state requirement.

## Sync Direction Options

**Both ways** (recommended) — Changes on either device sync to the other. Most natural behavior.

**Alexa → MA only** — Only Alexa volume changes update the MA speaker. Useful when MA is the playback device and you want Alexa to act as a remote control without MA changes feeding back.

**MA → Alexa only** — Only MA speaker changes update the Alexa device. The reverse scenario.

## Condition Stack

The automation checks five conditions in sequence before syncing. All must pass:

1. **Valid pair found** — The changed entity was found in its list and a partner entity was resolved. Protects against orphaned entities or list mismatches.

2. **Ducking not active** — The Voice PE ducking flag is OFF. Prevents feedback loops during voice interactions.

3. **Direction allowed** — The sync direction setting permits this particular direction (Alexa→MA or MA→Alexa).

4. **At least one device playing** (optional) — When enabled, skips syncs on idle devices to prevent unexpected volume changes when nothing is playing.

5. **Volume difference exceeds tolerance** (in the action branch) — The percentage-point difference between source and target exceeds the configured threshold. Prevents rounding-triggered infinite loops.

## Trigger Structure

Four triggers cover all sync scenarios, each with a descriptive `id:` for trace readability:

`alexa_vol_changed` / `ma_vol_changed` — Attribute triggers on `volume_level` changes.

`alexa_mute_changed` / `ma_mute_changed` — Attribute triggers on `is_volume_muted` changes.

The `is_volume_trigger` and `is_mute_trigger` variables route the action logic to the appropriate branch (mute sync vs. volume sync) without duplicating the condition stack.

## Template Logic

All pair resolution happens in the `variables:` block. The `is_alexa_source` boolean determines which list to search, `pair_index` finds the position, and `target_entity` resolves the partner. Volume difference is computed on a 0–100 scale (`vol_diff`) for human-readable comparison against the tolerance percentage.

The `| float(0)` guards on volume attributes and `| default(false)` on mute attributes prevent template errors when devices are temporarily unavailable.

## Version History

**v3** — Fixed section naming convention, moved ducking flag into section.

**v2** — Added author, header image, changelog, missing action aliases.

**v1** — Initial version.

## Requirements

- Home Assistant 2024.10.0+
- Alexa Media Player integration (HACS) with Echo devices configured
- Music Assistant integration with speakers configured
- An `input_boolean` for the Voice PE ducking flag (shared with duck/restore blueprints)

## Author

**madalone**

## License

See repository for license details.
