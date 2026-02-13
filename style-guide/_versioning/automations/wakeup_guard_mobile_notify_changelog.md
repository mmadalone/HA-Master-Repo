# Wake-up Guard – Mobile Snooze/Stop Handler — Changelog

## v3 — Style-guide compliance pass #2 (structural + refactor)
- **AP-09**: Added `icon:` and `description:` to both input sections (§3.2)
- **AP-09**: Removed redundant `collapsed: true` (HA default)
- **AP-09**: Added `===` box-style section divider comments (§3.2)
- **AP-11**: Added `alias:` to routing `variables:` step in actions
- **AP-13**: Switched action ID selectors from `text: {}` to `select:` with `custom_value: true`
- **§3.7**: Rewrote description from `|` block scalar to single-quoted string
- **§5.2**: Added `continue_on_error: true` on both `media_player.media_stop` calls
- **§5.4**: Added explicit `mode: restart` (was implicit `single`)
- **§3.4**: Added `variables:` block resolving all `!input` refs
- **§1.1**: Refactored duplicate snooze/stop `choose` branches into single variable-driven path
  - Replaced 2-branch `choose:` with a template variable resolving target toggle
  - Shared stop sequence runs once regardless of trigger
  - Cuts action block from ~40 lines to ~20, eliminates duplication

## v2 — Style-guide compliance pass
- **AP-10**: Migrated all `service:` → `action:` (2024.10+ syntax)
- **AP-10a**: Migrated all `platform: event/state` → `trigger: event/state`
- **AP-10**: Top-level `trigger:/condition:/action:` → plural `triggers:/conditions:/actions:`
- **§3.1**: Added `author: madalone`
- **§3.1**: Added `homeassistant: min_version: "2024.10.0"`
- **§3.1**: Added `### Recent changes` section to description
- **AP-09**: Organized inputs into collapsible sections (① Toggles & entities, ② Notification action IDs)
- **AP-11**: Added `alias:` to all 6 service/action calls
- **AP-11**: Added `alias:` to all 4 triggers
- **AP-35**: Confirmed `media_player.media_stop` on music_players is intentional (wake-up alarm context; queue destruction desired)

### Not addressed (INFO-level)
- **AP-15**: Header image — ✅ added (Rick disintegrating alarm with remote)
- **AP-13**: `text:` selector on action IDs — kept as-is (custom values needed)
- Variables block omitted (no templates in this blueprint)
- Duplicate snooze/stop branches kept for trace clarity

## v1 — Initial version
- Original file as received.
