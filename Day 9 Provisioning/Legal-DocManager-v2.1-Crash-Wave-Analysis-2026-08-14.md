# App Crash Wave — Analysis
## Legal (Floor 6) — Legal-Win11 Device Group (45 devices)

**Report Date:** 2026-08-14
**Analyst:** DWP Analyst
**Status:** ANALYSIS COMPLETE — root cause hypothesis identified, confirmation checks pending
**Data sources:** Nexthink DEX export (Legal-Win11), SCCM deployment log

---

## 1. Problem Statement

Legal (Floor 6, 45 devices) reported a wave of application crashes on the morning of 2024-03-25. Two independent monitoring sources exist for this window — a Nexthink DEX export and an SCCM deployment log — and neither alone explains the full picture. This analysis correlates both by timing and content.

---

## 2. Scope Facts — Source 1: Nexthink DEX Export

| Date | Time | DEX Score | App crash rate | Disk I/O |
|---|---|---|---|---|
| 2024-03-25 | 08:00 | 91 | 0.1% | Normal |
| 2024-03-25 | 09:00 | 90 | 0.2% | Normal |
| 2024-03-25 | 10:00 | 58 | 6.2% | High |
| 2024-03-25 | 11:00 | 55 | 6.8% | High |

- Device group: **Legal-Win11** (45 devices)
- Top crashing process, 10:00–11:00 window: **DocManager.exe** — 74% of all crashes in that window
- DEX score and crash rate are stable and healthy through 09:00, then degrade sharply starting at the 10:00 sample.

---

## 3. Scope Facts — Source 2: SCCM Deployment Log

| Field | Detail |
|---|---|
| Deployment start | 09:38:20 — `Legal Document Manager v2.1` to collection **Legal-Win11** (45 devices) |
| Install completion | 09:44:07 — **45 of 45 devices**, Success, **0 failures** |
| Previous version | Document Manager v2.0 — stable, deployed 6 weeks ago |
| New version | Document Manager v2.1 |
| Vendor release notes | New auto-save feature. **Known limitation:** on devices with under 8GB RAM, the auto-save indexing process can cause high disk I/O and intermittent crashes during the first few hours after installation while the initial index builds. |
| Legal-Win11 fleet hardware | 60% (≈27 devices) at 8GB RAM; **40% (≈18 devices) at 4GB RAM** |

---

## 4. Correlating the Two Sources (Timing + Content)

Read separately, each source is incomplete:
- The DEX export shows *when* things broke and *which process* is crashing, but not *why*.
- The SCCM log shows a *successful* deployment with *zero failures*, which on its own looks like a non-event — nothing in the SCCM log alone signals a problem.

Correlated together:

| Time | SCCM event | DEX observation |
|---|---|---|
| 08:00–09:00 | (pre-deployment) | DEX 91→90, crash rate 0.1%→0.2%, Disk I/O Normal — healthy baseline |
| 09:38:20 | Deployment of v2.1 starts | — |
| 09:44:07 | Deployment completes, 45/45 success, 0 failures | — |
| 10:00 | (~16 min post-install) | DEX drops to 58, crash rate jumps to 6.2%, Disk I/O High |
| 11:00 | (~76 min post-install) | DEX 55, crash rate 6.8%, Disk I/O still High |

Three points of alignment confirm the link, not just a coincidence in timing:

1. **Timing fit:** The crash spike begins within roughly 15 minutes of install completion and is still active an hour later — this matches the vendor's own stated window ("high disk I/O and intermittent crashes during the **first few hours** after installation while the initial index builds"), not a vague "sometime that morning."
2. **Process fit:** The top crashing process (74% of crashes, 10:00–11:00) is **DocManager.exe** — the exact application that was just upgraded. This is not an unrelated app or a system-wide fault; it is the newly deployed component itself.
3. **Mechanism fit:** The vendor explicitly documents high disk I/O as part of the new auto-save indexing behavior in v2.1 — and the DEX export independently reports **Disk I/O: High** at the same 10:00–11:00 timestamps. Two independent telemetry sources (vendor documentation and endpoint monitoring) agree on the same symptom (disk I/O) at the same time.
4. **Population fit (partial):** 40% of the fleet (≈18 of 45 devices) runs 4GB RAM — under the vendor's stated 8GB threshold for this known limitation — giving a plausible population of devices that would trigger the documented behavior. This is consistent with, but does not on its own prove, the magnitude of the observed 6–7% crash rate, since we do not have a per-device breakdown of which machines are crashing.

**A deployment log showing "0 failures" does not mean "no impact."** SCCM install success only measures whether the installer completed — it does not measure downstream application behavior after install. This is the key reason neither source alone tells the full story: SCCM says the change was applied cleanly, DEX says the fleet degraded shortly after — the vendor's release notes are what connects "clean install" to "post-install degradation" as an expected (if undesirable) behavior for a known subset of hardware.

---

## 5. Hypothesis

**Primary hypothesis (supported):** The Document Manager v2.1 deployment (completed 09:44:07) triggered its new auto-save indexing process across the Legal-Win11 fleet. On the ≈18 devices with 4GB RAM (under the vendor's documented 8GB threshold), this indexing process caused high disk I/O and intermittent crashes, consistent with the vendor's stated known limitation. This is directly reflected in the DEX export as a Disk I/O and crash-rate spike beginning at 10:00, with DocManager.exe as the dominant crashing process.

**Gap requiring confirmation:** The current data does not include a per-device crash breakdown by RAM tier. It is not yet confirmed whether crashes are concentrated on the 4GB-RAM subset specifically, or whether the disk I/O contention is also degrading the 8GB-RAM devices (e.g., through shared storage, network share contention, or general system slowdown). This should be checked before finalizing remediation scope.

---

## 6. Recommended Next Step

Proceed to RCA for the confirmed/primary hypothesis, including a fastest-check plan to confirm the RAM-tier correlation, remediation options (rollback vs. wait-out-the-indexing-window vs. vendor hotfix), and preventive actions for future SCCM deployments of this class.
