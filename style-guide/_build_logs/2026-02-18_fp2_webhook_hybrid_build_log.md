# Build Log: FP2 Webhook Hybrid — Option A

| Field | Value |
|---|---|
| **Date** | 2026-02-18 |
| **Target** | `custom_components/ha_aqara_devices/` |
| **Operation** | Add Aqara Open API webhook receiver for FP2 push-based presence updates |
| **Status** | in-progress |
| **Operational Mode** | BUILD |

---

## Context

The FP2 presence sensors suffer from unacceptable latency when using the Aqara cloud
polling path (mobile API). The current integration polls every 2 seconds but the cloud
itself only updates every 10–30s, meaning the light goes off while the user is still
in the room. Switching from HomeKit (local push) to cloud (poll) caused the regression.

### Root Cause Analysis

1. **Current data path:** FP2 sensor → Aqara cloud → mobile API poll (2s) → HA coordinator
2. **HomeKit data path was:** FP2 sensor → Bluetooth/Thread → HA (instant push)
3. **Cloud-side staleness:** The Aqara cloud API serves cached state, not real-time.
   Polling faster doesn't help — you're just re-reading stale data.
4. **The `fp2_presence_state` entity** uses the history endpoint (`res/history/log`),
   which is even slower than the status query endpoint.

### Solution: Hybrid Webhook + Poll (Option A)

Add Aqara Open API webhook support so the cloud PUSHES state changes to HA instantly,
while keeping the existing poll as a fallback safety net at a much lower frequency.

---

## Implementation Plan

### Phase 1: Webhook receiver module (`webhook.py`)
- Register HA webhook endpoint at integration setup
- Validate incoming Aqara push signatures
- Parse `resource_report` messages
- Map `subjectId` → FP2 device → coordinator
- On valid data: inject into coordinator cache, fire `async_set_updated_data()`

### Phase 2: Open API client (`open_api.py`)
- OAuth2 token management (accessToken + refreshToken in config entry)
- Auto-refresh before expiry
- `config.resource.subscribe` at startup for FP2 detection zone resource IDs
- `config.resource.unsubscribe` on unload

### Phase 3: Reduce polling cadence
- `FP2_FAST_INTERVAL`: 2s → 30s (webhook handles real-time; poll is fallback)
- Keep `FP2_SLOW_INTERVAL` at 5 min for settings
- API call volume drops from ~120 calls/min → ~4 calls/min

### Phase 4: Config flow additions
- Open API credentials (App ID, Key ID, App Key)
- OAuth2 tokens (accessToken, refreshToken) 
- Webhook ID stored in config entry
- "Use webhook push" toggle for fallback to pure polling

---

## Prerequisites (from user)

- [x] Aqara Open API App ID — received (stored in secrets, not logged here)
- [x] Aqara Open API Key ID — received (stored in secrets, not logged here)
- [x] Aqara Open API App Key — received (stored in secrets, not logged here)
- [x] Region: EU (domain: `open-ger.aqara.com`)
- [x] OAuth2 accessToken + refreshToken — received (stored in secrets, not logged here)
- [x] HA external URL: `https://4ucqce6q1amnlevf2rbv6lnbractgnkx.ui.nabu.casa/` → webhook target: `https://4ucqce6q1amnlevf2rbv6lnbractgnkx.ui.nabu.casa/api/webhook/aqara_fp2_push`
- [ ] Aqara dev console: Message Push configured as HTTP Push, user-defined subscription mode — STILL NEEDED
- [ ] FP2 device IDs confirmed (same `did` as mobile API?) — TO VERIFY IN CODE

---

## Files to Modify/Create

| File | Action | Backup Required |
|---|---|---|
| `__init__.py` | Modify — reduce FP2_FAST_INTERVAL, register webhook | YES |
| `webhook.py` | **Create** — webhook receiver + signature validation | n/a (new) |
| `open_api.py` | **Create** — Open API OAuth2 client + subscription mgmt | n/a (new) |
| `const.py` | Modify — add Open API constants, EU domain, resource ID map | YES |
| `config_flow.py` | Modify — add Open API credential fields | YES |
| `manifest.json` | Modify — bump version | YES |
| `translations/en.json` | Modify — add config flow strings | YES |

---

## Backup Checklist

- [ ] `__init__.py` backed up before first edit
- [ ] `const.py` backed up before first edit
- [ ] `config_flow.py` backed up before first edit
- [ ] `manifest.json` backed up before first edit
- [ ] `translations/en.json` backed up before first edit

---

## Open Questions

1. **FP2 Open API resource IDs:** The mobile API uses attribute names (`detection_area1`).
   The Open API uses numeric resource IDs (`3.51.85`). Need to map zone detection
   attributes to Open API resource IDs. May require subscribing to "all" initially
   and logging what arrives, or checking Aqara resource definition docs.
2. **Webhook verification:** Aqara periodically pings the webhook to verify it's alive.
   Need to handle the verification handshake in the receiver.
3. **Rate limiting:** Open API has separate rate limits from the mobile API. Need to
   confirm subscription doesn't count against query quotas.
4. **Token refresh:** accessToken expires (default 24h, configurable). Need reliable
   background refresh via refreshToken.

---

## Progress Log

| Step | Description | File(s) | Status |
|---|---|---|---|
| 0 | Build log created | _build_logs/ | ✅ done |
| 1 | Backup existing files | ha_aqara_devices/ | ⚠️ skipped by prior session — no backups exist, git diff is the baseline |
| 2 | Add Open API constants to const.py | const.py | ✅ done (prior session — hardcoded, TODO for config entry migration) |
| 3 | Create open_api.py (OAuth2 client) | open_api.py | ✅ done — 382 lines. OAuth2 token mgmt, auto-refresh (23h loop), resource subscribe/unsubscribe, graceful degradation to poll on failure. |
| 4 | Create webhook.py (receiver) | webhook.py | ✅ done (prior session) |
| 4a | Fix resource map collision bug | webhook.py | ✅ done — removed speculative zone comprehension that overwrote 3.51.85/3.52.85 global presence with zone 1/2. Now ships confirmed IDs only; unmapped resources logged for discovery. |
| 5 | Wire webhook + open_api into __init__.py | __init__.py | ✅ done — import added, async_setup_open_api() in setup_entry, async_teardown_open_api() in unload_entry |
| 6 | Reduce FP2_FAST_INTERVAL | __init__.py | pending (still 2s — intentionally deferred until webhook proven) |
| 7 | Update config_flow.py | config_flow.py | pending |
| 8 | Update manifest.json version | manifest.json | ✅ done (prior session — 0.4.0-beta, iot_class→cloud_push, webhook dep) |
| 9 | Update translations | translations/en.json | pending |
| 10 | Test webhook registration | HA restart | pending |
| 11 | Verify end-to-end push flow | Aqara console | pending |

### Phase 1 Verification (2026-02-18, session 3)

All phase 1 deliverables verified on disk:

- **webhook.py** (178 lines) — collision fix applied, debug logging for unmapped resources, signature verification, coordinator injection via `async_set_updated_data()`
- **const.py** lines 137–145 — Open API constants hardcoded (App ID, Key ID, App Key, tokens, EU server, webhook ID). TODO: migrate to config entry.
- **manifest.json** — v0.4.0-beta, `iot_class: "cloud_push"`, `dependencies: ["webhook"]`
- **__init__.py** — webhook registered in `async_setup()`, unregistered in `async_unload_entry()` when last entry removed
- **FP2_FAST_INTERVAL** — still 2s (correct — step 6 deferred until webhook proven working)

### Phase 2 Verification (2026-02-18, session 4)

- **open_api.py** (382 lines) — `AqaraOpenApiClient` class with MD5 signature generation, intent-based API calls, OAuth2 token refresh (23h background loop with 5min retry on failure), resource subscribe/unsubscribe via `config.resource.subscribe`/`unsubscribe`, graceful degradation (all failures non-fatal, polling continues). Module-level helpers: `async_setup_open_api()` and `async_teardown_open_api()`.
- **__init__.py** — import added (line 27), `async_setup_open_api()` called after platform forward at end of `async_setup_entry()`, `async_teardown_open_api()` called in `async_unload_entry()` before entry data pop and webhook unregister.
