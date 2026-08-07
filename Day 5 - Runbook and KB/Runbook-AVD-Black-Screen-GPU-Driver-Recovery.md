# Runbook: AVD Black Screen Recovery (GPU Driver Regression)

Title: Runbook-AVD-Black-Screen-GPU-Driver-Recovery
Version: 1.0
Date: 07/08/2026
Author: Sathishbabu
Reviewed: self
Status: draft
Change: initial version from RCA

Incident pattern covered:
- Users log in to AVD and see black screen or get disconnected.
- Typical event signature: Event 1000 (dwm.exe faulting in igdumd64.dll), followed by Event 9009.

Use this runbook for incidents matching the RCA in Issue-AVD-Black-Screen-RCA.md.

---

## 1. Prerequisites

Complete this checklist before remediation.

### A) Access Checklist
- [ ] [ELEVATED] Confirm you can open Azure portal path: Azure Virtual Desktop -> Host pools -> <AffectedHostPool>.
- [ ] [ELEVATED] Confirm you can modify host pool session settings (drain mode/new session control).
- [ ] [ELEVATED] Confirm you can assign/update image version in your image system (Azure Compute Gallery or image pipeline used by your team).
- [ ] [ELEVATED] Confirm you can restart AVD session hosts from Azure portal path: Azure Virtual Desktop -> Host pools -> <AffectedHostPool> -> Session hosts.
- [ ] [ELEVATED] Confirm local admin access to at least 1 affected host and 1 unaffected host.
- [ ] [ELEVATED] Confirm permission to read Windows logs on session hosts.

### B) Tools Checklist
- [ ] Open Event Viewer on admin workstation or via remote session.
- [ ] Confirm PowerShell 5.1+ is available on admin workstation.
- [ ] Confirm remote desktop access method to session hosts is working.
- [ ] Confirm location of known-good driver baseline artifact (image tag/version from unaffected baseline).

### C) Mandatory End-User Input Checklist
- [ ] Primary symptom in user words (black screen, disconnect, delay, or all three).
- [ ] First observed time (HH:MM and timezone).
- [ ] Affected user count estimate and business impact.
- [ ] At least 2 affected usernames and their session host names.
- [ ] One unaffected user/session host pair in same business window (if available).
- [ ] Screenshot or exact error text shown to user (if any).
- [ ] Confirmation whether issue occurs on first login only or on reconnect too.

### D) Incident Context Checklist
- [ ] Affected host pool name and region.
- [ ] Incident time window (start and latest occurrence).
- [ ] Last change before incident (image version, driver package, deployment time).
- [ ] Candidate canary host names selected (2 hosts).

---

## 2. Procedure

Follow steps in order. Each step has one action and an expected result.

1. Open Azure portal and navigate to Azure Virtual Desktop -> Host pools -> <AffectedHostPool>.
Expected result: Host pool overview page is visible.

2. Open Session hosts tab under the affected host pool.
Expected result: Full list of session hosts and status is visible.

3. Select one affected host from the list and copy its hostname into incident notes.
Expected result: One confirmed affected hostname is documented.

4. Start an RDP admin session to the affected host.
Expected result: You are logged into the affected host desktop.

5. Open Event Viewer on the affected host at Windows Logs -> Application.
Expected result: Application log events are visible.

6. Apply a filter on Application log for Event ID 1000.
Expected result: Event 1000 entries are listed.

7. Open one Event 1000 entry and confirm Faulting module is igdumd64.dll.
Expected result: At least one event confirms dwm.exe faulting in igdumd64.dll.

8. Open Event Viewer path Windows Logs -> System on the same host.
Expected result: System log events are visible.

9. Apply a filter on System log for Event ID 9009.
Expected result: Event 9009 entries are listed in incident window.

10. Record one timestamp pair where Event 1000 is followed by Event 9009.
Expected result: One evidence chain (1000 -> 9009) is documented.

11. Start an RDP admin session to one unaffected comparison host.
Expected result: You are logged into unaffected host desktop.

12. Open Event Viewer on comparison host at Windows Logs -> Application.
Expected result: Comparison Application log is visible.

13. Filter comparison Application log for Event ID 1000 and search for igdumd64.dll.
Expected result: No matching igdumd64.dll crash pattern is found.

14. Open comparison host Event Viewer path Applications and Services Logs -> Microsoft -> Windows -> Desktop Window Manager -> Operational.
Expected result: DWM operational events are visible.

15. Filter DWM operational log for Event ID 9011.
Expected result: Successful DWM startup events are present.

16. On affected host open File Explorer and navigate to C:\Windows\System32.
Expected result: System32 folder is open.

17. Open properties for igdumd64.dll and record file version.
Expected result: Affected driver version is documented.

18. Repeat igdumd64.dll version check on unaffected host.
Expected result: Baseline stable driver version is documented.

19. [ELEVATED] In Azure portal set the affected session hosts to drain mode from Azure Virtual Desktop -> Host pools -> <AffectedHostPool> -> Session hosts.
Expected result: New user sessions stop landing on affected hosts.

20. [ELEVATED] In image management console create a new image version with known-good GPU driver baseline.
Expected result: Corrected image version is created and available.

21. [ELEVATED] Assign corrected image to two designated canary hosts in the affected host pool.
Expected result: Canary host image assignment is updated.

22. [ELEVATED] Restart canary host #1 from Azure portal Session hosts tab.
Expected result: Canary host #1 returns to Available state.

23. [ELEVATED] Restart canary host #2 from Azure portal Session hosts tab.
Expected result: Canary host #2 returns to Available state.

24. Execute one interactive user logon test on canary host #1.
Expected result: Desktop loads with no black screen or disconnect.

25. Execute one interactive user logon test on canary host #2.
Expected result: Desktop loads with no black screen or disconnect.

26. Check canary host Application log for new Event 1000 entries with igdumd64.dll after tests.
Expected result: Zero new matching crash entries.

27. Check canary host System log for new Event 9009 entries after tests.
Expected result: Zero new DWM exit entries tied to incident pattern.

28. Check canary DWM Operational log for Event 9011 entries after tests.
Expected result: Event 9011 appears for test logons.

29. [ELEVATED] Assign corrected image to remaining affected hosts.
Expected result: Full remediation rollout assignment is in place.

30. [ELEVATED] Restart remaining affected hosts in small batches (for example 2 to 3 hosts per batch).
Expected result: Hosts return online without mass reconnect storm.

31. [ELEVATED] Disable drain mode on remediated hosts from Session hosts tab.
Expected result: Hosts accept new user sessions again.

32. Monitor first 100 post-remediation logons using Azure portal session metrics and help desk queue.
Expected result: No repeat black-screen trend appears.

---

## 3. Verification

Complete all checks before closure:

1. Open Azure portal path Azure Virtual Desktop -> Host pools -> <AffectedHostPool> -> Session hosts.
Expected result: Session hosts list shows all remediated hosts in Available state.

2. Open one remediated host by selecting host name in Session hosts list.
Expected result: Host details page opens.

3. Open the Sessions tab on that host details page.
Expected result: Active sessions are visible and not rapidly disconnecting.

4. Start remote admin session to this host from your approved admin access method.
Expected result: You reach the host desktop successfully.

5. Open Event Viewer path Windows Logs -> Application.
Expected result: Application log is visible.

6. Apply Filter Current Log with Event IDs set to 1000 and Logged set to Last 1 hour.
Expected result: Event 1000 list for the post-fix window is shown.

7. Search filtered Event 1000 results for text igdumd64.dll.
Expected result: Zero matching events are found.

8. Open Event Viewer path Windows Logs -> System.
Expected result: System log is visible.

9. Apply Filter Current Log with Event ID 9009 and Logged set to Last 1 hour.
Expected result: Zero new DWM exit events tied to incident timeframe are found.

10. Open Event Viewer path Applications and Services Logs -> Microsoft -> Windows -> Desktop Window Manager -> Operational.
Expected result: DWM Operational log is visible.

11. Apply Filter Current Log with Event ID 9011 and Logged set to Last 1 hour.
Expected result: Event 9011 entries are present for recent user logons.

12. Repeat steps 2 through 11 for two additional remediated hosts.
Expected result: Three-host sample confirms same healthy pattern.

13. Open Azure portal path Azure Virtual Desktop -> Host pools -> <AffectedHostPool> -> Insights (or Workbook/Monitoring view used by your team).
Expected result: Session trend shows no new spike in disconnect or failed logons.

14. Validate five real-user logons by checking host Sessions list and confirming users reached desktop.
Expected result: Five successful logons are confirmed with no black-screen reports.

15. Check Service Desk queue filter for keywords black screen and disconnect for this host pool for last 60 minutes.
Expected result: No new matching incident tickets are present.

16. Record verification evidence in closure note including hostnames, event IDs checked, and time window.
Expected result: Closure record is complete and auditable.

---

## 4. Rollback

Use this section immediately if symptoms worsen after deployment.

Goal:
- Complete emergency containment and rollback start in under 3 minutes.

1. [ELEVATED] Open Azure portal path Azure Virtual Desktop -> Host pools -> <AffectedHostPool> -> Session hosts.
Expected result: You are on the host list page for immediate actions.

2. [ELEVATED] Select all affected hosts and set Drain mode to On.
Expected result: New user sessions are blocked from affected hosts.

3. [ELEVATED] Open your image assignment console and select last known-good image version tag.
Expected result: Known-good image version is selected for rollback.

4. [ELEVATED] Apply known-good image version to the affected host pool.
Expected result: Host pool now targets rollback image version.

5. [ELEVATED] Return to Azure Virtual Desktop -> Host pools -> <AffectedHostPool> -> Session hosts and restart two canary hosts first.
Expected result: Two rollback canary hosts begin reboot and return online.

6. Start one interactive test logon on each rollback canary host.
Expected result: Both test logons reach desktop with no black screen.

7. On one rollback canary host open Event Viewer path Windows Logs -> Application and filter Event ID 1000 for Last 15 minutes.
Expected result: No new Event 1000 entries with igdumd64.dll appear.

8. On same host open Event Viewer path Windows Logs -> System and filter Event ID 9009 for Last 15 minutes.
Expected result: No new Event 9009 entries tied to incident pattern appear.

9. [ELEVATED] Restart remaining hosts in batches from Session hosts tab.
Expected result: Remaining hosts come online on known-good image.

10. [ELEVATED] Set Drain mode to Off only after canary and sample log checks pass.
Expected result: Users are routed back to stable hosts.

11. Open incident timeline notes and log rollback start time, image tag, canary hosts, and verification results.
Expected result: Rollback execution is fully documented for audit.

---

## 5. Notes

Edge cases
- If only one host shows the pattern, isolate and remediate that host first before full pool action.
- If Event 1000 exists without igdumd64.dll, do not use this runbook; branch to generic DWM crash triage.
- If canary passes but production fails, compare hardware SKU mix between canary and failing hosts.

Warnings
- Do not perform full redeployment before canary logons are validated.
- Do not mix driver rollback with unrelated patch changes in same deployment wave.
- Do not re-enable session placement until verification checks complete.

Related incidents
- Issue-AVD-Black-Screen-Analysis.md
- Issue-AVD-Black-Screen-RCA.md
- Issue-AVD-Black-Screen-KEDB.md
- Issue-AVD-Black-Screen-Closure-Note.md
