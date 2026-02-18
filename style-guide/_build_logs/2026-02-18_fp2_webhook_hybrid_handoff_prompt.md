# FP2 Webhook Hybrid Build — Phase 2 Handoff Prompt

Paste everything below the line into a new conversation.

---

## Resume: FP2 Webhook Hybrid Build (Option A) — Phase 2

**Build log:** `_build_logs/2026-02-18_fp2_webhook_hybrid_build_log.md` in `PROJECT_DIR`
**Status:** in-progress. Phase 1 verified complete. Phase 2 (`open_api.py`) is next.

### What we're doing

The FP2 presence sensors have unacceptable latency via cloud polling (lights go off mid-use). The current `ha_aqara_devices` custom component at:
```
/Users/madalone/Library/Containers/nz.co.pixeleyes.AutoMounter/Data/Mounts/Home Assistant/SMB/config/custom_components/ha_aqara_devices/
```
uses the Aqara **mobile API** (poll-only, `FP2_FAST_INTERVAL = 2s`). The cloud itself only updates every 10–30s, so faster polling just re-reads stale data.

**Solution:** Add Aqara **Open API** webhook support (HTTP push from Aqara cloud → HA webhook endpoint) so presence changes arrive instantly. Keep the existing poll as a safety-net fallback at reduced frequency (2s → 30s).

### Phase 1 — COMPLETE (verified 2026-02-18)

All four deliverables verified on disk:

| File | Status | Key details |
|---|---|---|
| `webhook.py` (178 lines) | ✅ | Receiver with signature verification, `resource_report` parsing, coordinator injection via `async_set_updated_data()`. Debug logging for unmapped resource IDs. Collision fix applied (zone comprehension removed). |
| `const.py` L137–145 | ✅ | Open API constants hardcoded (App ID, Key ID, App Key, tokens, EU server `open-ger.aqara.com`, webhook ID `aqara_fp2_push`). TODO: migrate to config entry. |
| `manifest.json` | ✅ | v0.4.0-beta, `iot_class: "cloud_push"`, `dependencies: ["webhook"]` |
| `__init__.py` | ✅ | Webhook registered in `async_setup()`, unregistered in `async_unload_entry()` when last entry removed. `FP2_FAST_INTERVAL` still 2s (deferred to step 6). |

### Phase 2 — BUILD `open_api.py` (OAuth2 client + subscription management)

Create `open_api.py` in the same directory. Responsibilities:

1. **OAuth2 token management**
   - Store `accessToken` + `refreshToken` (currently hardcoded in `const.py`, eventually from config entry)
   - Auto-refresh before expiry (default 24h token lifetime)
   - Background refresh task started at integration setup, cancelled on unload
   - On refresh failure: log error, fall back to polling-only mode (don't crash the integration)

2. **Resource subscription** (`config.resource.subscribe`)
   - At startup: call Aqara Open API to subscribe FP2 device resource IDs for push delivery
   - The push URL is: `https://4ucqce6q1amnlevf2rbv6lnbractgnkx.ui.nabu.casa/api/webhook/aqara_fp2_push`
   - Subscribe to ALL FP2 resources initially (presence, zones, illuminance, people count) — we need to discover the zone resource IDs from live push data
   - On unload: `config.resource.unsubscribe`

3. **API call pattern**
   - Base URL: `https://open-ger.aqara.com` (EU region)
   - Auth header: `Appid`, `Keyid`, `Token` (accessToken), `Nonce`, `Time`, `Sign`
   - Signature: MD5 of sorted lowercase params + appKey
   - Content-Type: `application/json`
   - Intent-based: `{"intent": "config.resource.subscribe", "data": {...}}`

4. **Wire into `__init__.py`**
   - Import and call `async_setup_open_api(hass, entry)` during `async_setup_entry()`
   - Call `async_teardown_open_api(hass, entry)` during `async_unload_entry()`

### Remaining steps after phase 2

| Step | Description | File(s) | Status |
|---|---|---|---|
| 6 | Reduce FP2_FAST_INTERVAL 2s → 30s | __init__.py | pending (after webhook proven) |
| 7 | Update config_flow.py (Open API credential fields) | config_flow.py | pending |
| 9 | Update translations | translations/en.json | pending |
| 10 | Test webhook registration | HA restart | pending |
| 11 | Verify end-to-end push flow | Aqara console | pending |

### Credentials (DO NOT log — use secrets)

- **App ID:** `14730853351807918085c3e5`
- **Key ID:** `K.1473085335222734848`
- **App Key:** `0c9ay5kt8lsn7cb8lsz1357te90i03cc`
- **Region:** EU → domain `open-ger.aqara.com`
- **accessToken:** `ca03d8ed6d81a45f070546797c9e8744`
- **refreshToken:** `b54659e676c5c0c8eb0404bddb706da0`

These are currently hardcoded in `const.py`. Will migrate to config entry in step 7.

### Prerequisites status

- [x] Aqara Open API credentials — received, hardcoded in const.py
- [x] HA external URL: `https://4ucqce6q1amnlevf2rbv6lnbractgnkx.ui.nabu.casa/`
- [ ] Aqara dev console: Message Push configured — STILL NEEDED (after code deployed + HA restarted)
- [ ] FP2 zone detection resource IDs — unknown, will discover from push logs

### Key technical details for phase 2

- `__init__.py` dual coordinator pattern: `fp2_coordinators` (fast, 2s) and `fp2_settings_coordinators` (slow, 5min)
- `const.py`: `FP2_ZONE_COUNT = 30`, `FP2_PRESENCE_RESOURCES = ["3.51.85", "3.52.85"]`
- Open API docs: intent-based JSON API. Subscribe via `config.resource.subscribe`. Token refresh via `config.auth.refreshToken`.
- Open API auth signature: `MD5(f"accesstoken={token}&appid={appid}&keyid={keyid}&nonce={nonce}&time={time}{appkey}".lower())`
- Aqara Open API docs: https://opendoc.aqara.com (may need web search for specific endpoint specs)

### Rules

- Read the build log first
- Back up every file before first edit (backup checklist in build log)
- All edits via Desktop Commander to SMB mount path
- Verify files after writing
- This is a custom Python component, NOT a blueprint — style guide anti-patterns don't apply, but backup/build-log discipline does
