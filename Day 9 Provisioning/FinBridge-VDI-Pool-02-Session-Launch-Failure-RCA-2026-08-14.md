# Root Cause Analysis (RCA)
## FinBridge — FinBridge-VDI-Pool-02 Session Launch Failure

**Report Date:** 2026-08-14
**Analyst:** DWP Analyst
**Related documents:**
- [FinBridge-VDI-Pool-02-Session-Launch-Failure-Scope-2026-08-14.md](FinBridge-VDI-Pool-02-Session-Launch-Failure-Scope-2026-08-14.md)
- [FinBridge-VDI-Pool-02-Session-Launch-Failure-Analysis-2026-08-14.md](FinBridge-VDI-Pool-02-Session-Launch-Failure-Analysis-2026-08-14.md)

---

## 1. Incident Summary

| Field | Detail |
|---|---|
| Service affected | FinBridge-VDI-Pool-02 (session launch) |
| Impact | 22 of 30 users unable to launch VDI sessions |
| Unaffected comparison | FinBridge-VDI-Pool-01 (same site, different pool/controller) — normal |
| Detected via | Session launch failures, broker error 1030 "No machines available in the desktop group" |
| Root cause | Citrix Broker Service on Delivery Controller dc-vdi-02 stopped after a Windows Update installed at 00:15 was never completed with a reboot |

---

## 2. Supporting Evidence

| Evidence | Source |
|---|---|
| Broker log: `Timeout waiting for machine registration response (30000ms exceeded)` at 08:58:34 | Broker error log |
| Broker log: `Session launch FAILED: error 1030 'No machines available in the desktop group'` at 08:58:34 | Broker error log |
| Pool-02 registration: 25 provisioned / 3 registered / 22 unregistered / 0 maintenance | Machine catalog registration status |
| Pool-01 registration (control group): 20 provisioned / 19 registered / 1 unregistered | Machine catalog registration status |
| VDI-P02-014: failed registration attempt 06:15:22 — "Unable to contact Delivery Controller", `dc-vdi-02.finbridge.local:80` connection refused | Unregistered machine detail |
| VDI-P02-017: failed registration attempt 06:16:01 — same error/host/port | Unregistered machine detail |
| dc-vdi-02 Broker Service: **STOPPED**; last known running yesterday 23:40; Windows Update installed today 00:15, reboot-required flag set, host not rebooted | Delivery Controller health check |
| dc-vdi-01 (serves Pool-01) Broker Service: **RUNNING**, uptime 14 days | Delivery Controller health check |

---

## 3. Timeline

| Time (2026-08-14 unless noted) | Event |
|---|---|
| Yesterday 23:40 | dc-vdi-02 Broker Service last confirmed running |
| 00:15 | Windows Update installed on dc-vdi-02; reboot-required flag set; **host not rebooted** — Broker Service left stopped/not restarted |
| 06:15:22 | VDI-P02-014 registration attempt fails — connection refused to `dc-vdi-02.finbridge.local:80` |
| 06:16:01 | VDI-P02-017 registration attempt fails — connection refused to `dc-vdi-02.finbridge.local:80` |
| (06:15–08:58, ongoing) | Remaining Pool-02 VDAs progressively fail to register for the same reason (22 of 25 total by time of scoping) |
| 08:58:34 | Broker logs registration timeout and session launch failure (error 1030) for users attempting to launch on Pool-02 |
| 2026-08-14 (report time) | Scope facts captured; analysis performed; root cause confirmed |

---

## 4. 5-Why Analysis

1. **Why did user session launches fail on Pool-02?**
   Because the broker reported error 1030, "No machines available in the desktop group."

2. **Why were no machines available in the desktop group?**
   Because 22 of 25 machines in Pool-02's catalog were unregistered with the Delivery Controller.

3. **Why were those machines unregistered?**
   Because the VDAs could not contact the Delivery Controller — connections to `dc-vdi-02.finbridge.local:80` were refused.

4. **Why were connections to dc-vdi-02 on port 80 refused?**
   Because the Citrix Broker Service on dc-vdi-02 was stopped.

5. **Why was the Broker Service stopped?**
   Because a Windows Update installed on dc-vdi-02 at 00:15 required a reboot to complete/restart the service, and the reboot was never performed — leaving the service down indefinitely with no automated detection or alert.

**Root cause:** Lack of enforced/automated reboot after Windows Update installation on a single-point-of-failure Delivery Controller, combined with no active health monitoring on the Broker Service to catch the resulting outage before it impacted users.

---

## 5. Remediation

### Steps (in order)
1. Open/confirm a P1 change record for the production Delivery Controller outage.
2. On dc-vdi-02, verify the pending-reboot flag and Windows Update install history to confirm the 00:15 update is the cause.
3. Gracefully reboot dc-vdi-02.
4. Verify the Broker Service (and dependent Citrix services) returns to **Running** with startup type **Automatic**.
5. If the service does not auto-start, start it manually and inspect the Citrix Broker Service event log / CDF trace for install-related errors.
6. Confirm Pool-02 machines transition from Unregistered to Registered via Citrix Studio or `Get-BrokerMachine`.
7. For any VDAs still unregistered after ~10 minutes, restart the affected VDA's Citrix services (or the VM) to force re-registration.
8. Perform a test session launch against Pool-02 with a test account.

### Verification Check
- `Get-Service BrokerService` on dc-vdi-02 returns `Running` / `Automatic`.
- `Get-BrokerMachine -DesktopGroupName 'Pool-02'` shows RegistrationState `Registered` for all/expected machines (target 25/25).
- A test session launch against Pool-02 succeeds with no error 1030.
- No repeat "Timeout waiting for machine registration" broker errors over a 30–60 minute monitoring window.

---

## 6. Preventive Actions

1. **Patch/reboot enforcement:** Require Delivery Controllers to auto-reboot (or be forcibly rebooted) within a defined SLA (e.g., 4 hours) after Windows Update installation, via WSUS/SCCM maintenance window policy with compliance reporting — do not leave "reboot required" servers running indefinitely.
2. **Active monitoring:** Add health monitoring/alerting on the Citrix Broker Service (service-state check plus a synthetic registration/heartbeat test) so a stopped broker triggers an immediate alert instead of being discovered through user-facing session failures.
3. **Controller redundancy:** Evaluate adding a second Delivery Controller for Pool-02's site so a single controller outage cannot fully block registration for the pool.
4. **Change visibility:** Ensure patch installation on infrastructure servers (Delivery Controllers) is tracked with a mandatory post-patch verification step (service health check) before the change is considered complete.

---

## 7. Status

- Root cause: **Confirmed** (Broker Service down on dc-vdi-02 due to unrestarted Windows Update).
- Remediation: Documented above — pending execution/confirmation in production.
- Incident closure: To occur after verification checks in Section 5 pass and stability is confirmed.
