# Root Cause Analysis (RCA)
## Legal (Floor 6) — DocManager.exe Crash Wave, Legal-Win11 (45 devices)

**Report Date:** 2026-08-14
**Analyst:** DWP Analyst
**Related document:** [Legal-DocManager-v2.1-Crash-Wave-Analysis-2026-08-14.md](Legal-DocManager-v2.1-Crash-Wave-Analysis-2026-08-14.md)

---

## 1. Incident Summary

| Field | Detail |
|---|---|
| Location / group | Legal, Floor 6 — device group **Legal-Win11** (45 devices) |
| Impact | Fleet-wide DEX score drop (91→55) and app crash rate spike (0.1%→6.8%), with **DocManager.exe** responsible for 74% of crashes in the worst window |
| Trigger event | SCCM deployment of **Legal Document Manager v2.1**, replacing the stable v2.0 build that had run for 6 weeks |
| Root cause | v2.1's new auto-save feature runs an initial index-build process after install; on devices with under 8GB RAM this is a vendor-documented known limitation causing high disk I/O and intermittent crashes for the first few hours post-install — and 40% of the Legal-Win11 fleet (≈18 of 45 devices) runs 4GB RAM, under that threshold |

---

## 2. Supporting Evidence

| Evidence | Source |
|---|---|
| DEX score 91 (08:00) → 90 (09:00) → 58 (10:00) → 55 (11:00) | Nexthink DEX export |
| App crash rate 0.1% (08:00) → 0.2% (09:00) → 6.2% (10:00) → 6.8% (11:00) | Nexthink DEX export |
| Disk I/O: Normal through 09:00, **High** at 10:00 and 11:00 | Nexthink DEX export |
| Top crashing process 10:00–11:00: **DocManager.exe**, 74% of all crashes in that window | Nexthink DEX export |
| Deployment of `Legal Document Manager v2.1` started 09:38:20, completed 09:44:07, 45/45 devices, 0 failures | SCCM deployment log |
| Previous version was v2.0, stable, deployed 6 weeks prior (no prior crash history implied) | SCCM deployment log |
| Vendor release notes: v2.1 adds auto-save; **known limitation** — devices under 8GB RAM see high disk I/O and intermittent crashes for the first few hours post-install while the initial index builds | SCCM deployment log / vendor release notes |
| Fleet hardware: 60% (≈27 devices) at 8GB RAM, **40% (≈18 devices) at 4GB RAM** | SCCM deployment log |

---

## 3. Timeline

| Time (2024-03-25) | Event |
|---|---|
| 08:00 | Baseline healthy: DEX 91, crash rate 0.1%, Disk I/O Normal |
| 09:00 | Still healthy: DEX 90, crash rate 0.2%, Disk I/O Normal |
| 09:38:20 | SCCM begins deploying Document Manager v2.1 to all 45 Legal-Win11 devices |
| 09:44:07 | Deployment completes — 45 of 45 devices, 0 failures reported |
| ~09:44–10:00 | v2.1's auto-save feature begins its initial index-build process on newly upgraded devices (per vendor documentation) |
| 10:00 | DEX drops to 58, crash rate jumps to 6.2%, Disk I/O reported High; DocManager.exe becomes the dominant crashing process (74% share, 10:00–11:00 window) |
| 11:00 | Degradation persists/worsens slightly: DEX 55, crash rate 6.8%, Disk I/O still High |
| Report time | Scope facts captured from both sources; correlation and root cause analysis performed |

---

## 4. 5-Why Analysis

1. **Why did Legal Floor 6 experience a wave of app crashes this morning?**
   Because DocManager.exe began crashing repeatedly starting around 10:00, accounting for 74% of all crashes in the 10:00–11:00 window.

2. **Why did DocManager.exe start crashing at that specific time?**
   Because Legal Document Manager v2.1 had just been deployed fleet-wide via SCCM (install completed 09:44:07), and the new version's auto-save feature kicks off an initial index-build process shortly after installation.

3. **Why does the index-build process cause crashes?**
   Because, per the vendor's own release notes, on devices with under 8GB RAM the auto-save indexing process causes high disk I/O and intermittent crashes during the first few hours after installation while the index builds — and the DEX export independently confirms Disk I/O was High at exactly this time.

4. **Why are enough devices affected to produce a fleet-wide 6–7% crash rate and a visible DEX drop?**
   Because 40% of the Legal-Win11 fleet (≈18 of 45 devices) runs 4GB RAM — under the vendor's documented 8GB threshold — giving a substantial population of devices expected to hit this known limitation simultaneously right after the single fleet-wide deployment window. (Not yet confirmed at per-device level — see Section 6, Gap/Confirmation Check.)

5. **Why wasn't this caught or mitigated before the fleet-wide rollout?**
   Because the deployment was pushed to the entire Legal-Win11 collection in one pass (45 of 45 devices, single 6-minute window) without cross-checking the vendor's documented RAM-based known limitation against the fleet's hardware inventory, and without a staged/pilot ring or a RAM-based device exclusion to shield the ≈18 lower-RAM devices from a known, vendor-documented risk.

**Root cause:** Fleet-wide, non-staged deployment of Document Manager v2.1 to a device population where 40% of hardware falls under the vendor's documented 8GB RAM threshold, triggering the vendor's known post-install indexing/disk I/O/crash behavior simultaneously across a large share of the fleet.

---

## 5. Remediation

### Steps (in order)
1. Pull a per-device crash/DEX breakdown for Legal-Win11 segmented by RAM tier (4GB vs 8GB) to confirm whether crashes are concentrated on the lower-RAM devices as hypothesized — this is the fastest check and should gate the rest of remediation scope.
2. If confirmed as RAM-correlated and vendor states this is a transient first-few-hours condition: monitor DEX score, crash rate, and Disk I/O hourly on the affected devices to see if they self-resolve as the initial index build completes.
3. If the condition has not begun improving within the vendor's stated "first few hours" window, escalate to the vendor for a hotfix or an indexing-throttle setting, and consider rolling back the affected/lower-RAM devices to the previously stable v2.0 build via SCCM.
4. For any devices still crashing after rollback consideration, prioritize the ≈18 devices with 4GB RAM for either a temporary RAM increase, a deferred v2.1 rollout, or a vendor-recommended configuration change (if one exists) before re-attempting the upgrade.
5. Communicate status to Legal (Floor 6) with an expected resolution window based on the vendor's "first few hours" guidance, and revise if the self-resolution does not occur.

### Order of Operations
Confirm RAM-tier correlation → monitor for self-resolution during the vendor's stated window → escalate/rollback if not resolved in that window → remediate the lower-RAM subset specifically → communicate status throughout.

### Verification Check
- DEX score returns to the ~90–91 baseline range.
- App crash rate returns to ~0.1–0.2%.
- Disk I/O returns to **Normal**.
- DocManager.exe drops out of the top-crashing-process list.
- If rollback was performed: confirm affected devices report v2.0 via SCCM and no recurrence of the crash pattern.

---

## 6. Gap / Confirmation Check Needed

The current evidence supports the hypothesis strongly on **timing** (crash spike within ~15 minutes of install, sustained for the vendor's stated "first few hours" window) and on **content** (top crashing process is the just-deployed app, and Disk I/O status matches the vendor's documented mechanism). It does **not** yet include a per-device crash breakdown, so the RAM-tier population fit (40% of fleet under 8GB) is a strong supporting data point but not a fully confirmed causal proof. Treat Section 5, Step 1 as mandatory before closing this incident.

---

## 7. Preventive Actions

1. **Pre-deployment hardware eligibility check:** Before deploying applications with vendor-documented hardware-dependent known limitations, query the target SCCM collection's hardware inventory (RAM, disk, CPU) against the vendor's minimum/recommended spec and exclude non-meeting devices or flag them for a separate deployment ring.
2. **Staged rollout for disk/indexing-intensive updates:** Require a pilot ring (e.g., 10% of a collection) for any application update that touches document indexing, database rebuilds, or similar disk-intensive first-run behavior, with a monitoring window before fleet-wide push — rather than a single all-at-once deployment.
3. **Release-notes review gate:** Add a step to the change process requiring vendor release notes (including "known limitations") to be reviewed against the target fleet's hardware profile as part of deployment approval, not just installer success/failure criteria.
4. **Post-deployment health correlation:** Pair every SCCM deployment completion with a short automated DEX/endpoint health check window (e.g., first 2 hours post-install) so a "0 failures" install result is not treated as the end of verification.

---

## 8. Status

- Root cause: **Primary hypothesis confirmed by timing and process/mechanism correlation; RAM-tier population fit pending per-device confirmation** (Section 6).
- Remediation: Documented above — pending execution and per-device confirmation.
- Incident closure: To occur after verification checks in Section 5 pass and the per-device RAM correlation is confirmed or the condition self-resolves within the vendor's stated window.
