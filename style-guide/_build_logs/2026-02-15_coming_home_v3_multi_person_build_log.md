# Build Log — coming_home v3

**Date:** 2026-02-15  
**Blueprint:** `coming_home.yaml`  
**Mode:** BUILD  
**Status:** completed

## Scope

1. `person_entity` → `person_entities` (multi-select, optional, `default: []`) + `person_names` (multiline text, `default: ""`)
2. `reset_switches` → optional (`entity` selector with `multiple: true`, `default: []`), wrapped in choose block
3. Variables, triggers, and action blocks updated for multi-person and optional reset
4. README updated to match

## Decisions

- Person entities remain the trigger mechanism — empty list means automation won't fire (acceptable for "optional")
- Custom names field overrides entity friendly_names when provided (one name per line, joined with "and")
- Reset switches changed from `target:` selector to `entity:` selector for clean optional default
- Reset actions wrapped in choose block that checks list length > 0
- Arrival switches left as-is (user didn't request changes)
