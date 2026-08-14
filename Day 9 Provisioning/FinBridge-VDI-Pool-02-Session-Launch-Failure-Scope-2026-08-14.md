# VDI Session Launch Failure — Scope Facts
## FinBridge — FinBridge-VDI-Pool-02

**Report Date:** 2026-08-14
**Analyst:** DWP Analyst
**Status:** SCOPE ONLY — root cause not yet determined

---

## Affected Scope

- **Pool affected:** FinBridge-VDI-Pool-02
- **Users affected:** 22 of 30
- **Unaffected pool:** FinBridge-VDI-Pool-01 (same site, different pool)

---

## Broker Error

- `[08:58:34] Broker: Timeout waiting for machine registration response (30000ms exceeded)`
- `[08:58:34] Session launch FAILED: error 1030 'No machines available in the desktop group'`

---

## Machine Catalog Registration Status

| Catalog | Provisioned | Registered | Unregistered | Maintenance mode |
|---|---|---|---|---|
| Pool-02 | 25 | 3 | 22 | 0 |
| Pool-01 | 20 | 19 | 1 | — |

### Unregistered machine detail (sample, Pool-02)

- **VDI-P02-014** — last registration attempt 06:15:22, failed. Error: "Unable to contact Delivery Controller" — `dc-vdi-02.finbridge.local:80` connection refused.
- **VDI-P02-017** — last registration attempt 06:16:01, failed. Error: "Unable to contact Delivery Controller" — `dc-vdi-02.finbridge.local:80` connection refused.

---

## Delivery Controller Health Check

| Controller | Serves | Broker Service | Detail |
|---|---|---|---|
| dc-vdi-02 | Pool-02 | STOPPED | Last known running yesterday 23:40; Windows Update installed today 00:15 (reboot required flag set, host not rebooted) |
| dc-vdi-01 | Pool-01 | RUNNING | Uptime 14 days |

---

*No root cause conclusion is drawn in this document — scope facts only.*
