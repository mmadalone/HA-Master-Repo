# Edit Log — AP-16 template safety fixes (goodnight_negotiator_hybrid)
**Date:** 2026-02-15 · **Status:** complete
**File(s):** `HA_CONFIG/blueprints/script/madalone/goodnight_negotiator_hybrid.yaml`
**Changes:** Fixed 4 AP-16 ERROR violations (5 edits total). Escalated from audit `2026-02-15_goodnight_negotiator_audit_report.log`.
- L870: `states(first_playing_entity)` → added `| default('unknown')` guard
- L915: `states(h_last_run_epoch) | float(0)` → added `| default('0')` before float
- L916: `states(h_debounce_seconds) | float(run_debounce)` → added `| default('0')` before float
- L2085: `s3_best_by_query` — `| list | first` → added `| default(none)`
- L2086: `s3_best_by_raw` — `| list | first` → added `| default(none)`
**Git:** checkpoint `checkpoint_20250215_034142` (hash `35c43a48`) created before edits
