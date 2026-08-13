# Runbook: Finance Shared Drive Access Recovery (FAULT-B)

Title: Runbook-Fault-B-Finance-Shared-Drives-Recovery
Version: 1.0
Date: 07/08/2026
Author: Sathishbabu
Reviewed: self
Status: draft
Change: initial version from RCA

Incident pattern covered:
- Finance users cannot access shared drive resources.
- Drive mapping fails during startup with missing drive letter.
- Endpoint script runs in SYSTEM context and fails UNC access.

Use this runbook for incidents matching the RCA in Issue-Fault-B-Finance-Shared-Drives-RCA.md.

---

## 1. Prerequisites

Complete this checklist before remediation.

### A) Access Checklist
- [ ] [ELEVATED] Confirm you can open Microsoft Intune admin center.
- [ ] [ELEVATED] Confirm you can edit or reassign endpoint scripts in Intune.
- [ ] [ELEVATED] Confirm you can open Azure AD/Entra device records for affected endpoints.
- [ ] [ELEVATED] Confirm local admin access on at least 2 affected Finance devices.
- [ ] [ELEVATED] Confirm access to Event Viewer and Intune Management Extension logs.

### B) Tools Checklist
- [ ] Intune admin center access (https://intune.microsoft.com).
- [ ] Remote support tool or RDP/Quick Assist to affected endpoints.
- [ ] Event Viewer on endpoint.
- [ ] Text editor for script review.
- [ ] PowerShell 5.1+ on admin workstation.

### C) Mandatory End-User Input Checklist
- [ ] First observed time (HH:MM and timezone).
- [ ] Affected user count and business impact.
- [ ] At least 2 affected usernames and device names.
- [ ] Confirmation whether issue occurs every login or intermittently.
- [ ] Screenshot/photo of missing drive or access message.

### D) Incident Context Checklist
- [ ] Script name in scope: Map-FinBridgeDrives.ps1.
- [ ] Change reference: migration from user logon script to SYSTEM-context script.
- [ ] Target user/device group name in Intune.
- [ ] Known-good fallback method (user-context mapping path).

---

## 2. Procedure

Follow steps in order. Each step has one action and an expected result.

1. Open Intune admin center path Devices -> Scripts and remediations -> Platform scripts.
Expected result: Script list is visible.

2. Select script Map-FinBridgeDrives.ps1.
Expected result: Script details page opens.

3. Open Properties on the script details page.
Expected result: Script configuration settings are visible.

4. Verify script execution context setting.
Expected result: Context is confirmed as SYSTEM (matches incident pattern).

5. Open Assignments tab for the script.
Expected result: Targeted device/user groups are visible.

6. Record affected Finance assignment group names in incident notes.
Expected result: Assignment scope is documented.

7. Open one affected endpoint and start remote admin session.
Expected result: You are logged into affected device desktop.

8. Open log file path C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\IntuneManagementExtension.log.
Expected result: Intune log file opens.

9. Search Intune log for text Map-FinBridgeDrives.ps1.
Expected result: Script execution entries are visible.

10. Search same log for text SYSTEM account.
Expected result: SYSTEM context execution evidence is found.

11. Search same log for text Network name cannot be found.
Expected result: Script failure text is found with exit code.

12. Open Event Viewer path Windows Logs -> System.
Expected result: System log is visible.

13. Filter System log for Event ID 7036 in incident window.
Expected result: Workstation service start timing is visible.

14. Filter System log for Event ID 98 in incident window.
Expected result: Drive letter mapping failure events are visible.

15. Open Event Viewer path Applications and Services Logs -> Microsoft -> Windows -> GroupPolicy -> Operational.
Expected result: Group Policy operational log is visible.

16. Confirm Group Policy success entries in incident window.
Expected result: Policy layer is confirmed healthy (issue is mapping path).

17. [ELEVATED] Disable current SYSTEM-context mapping assignment in Intune (remove assignment or set script to not assigned).
Expected result: Problem script no longer targets affected Finance devices.

18. [ELEVATED] Assign approved user-context mapping method (user-context script or previous logon mapping method) to Finance group.
Expected result: Recovery mapping method is assigned.

19. [ELEVATED] Trigger Intune device sync from Intune path Devices -> All devices -> <DeviceName> -> Sync.
Expected result: Sync command is accepted.

20. On affected endpoint, sign out and sign in once with test user.
Expected result: User session starts normally.

21. Open File Explorer -> This PC and check S: drive.
Expected result: S: drive is present.

22. Open S: drive and access Finance folder contents.
Expected result: Finance shared content opens successfully.

23. Repeat steps 19 through 22 on at least two additional affected devices.
Expected result: Recovery is confirmed across sample devices.

24. Monitor Intune script status for Finance assignment for failures.
Expected result: Failure count drops and success state stabilizes.

---

## 3. Verification

Complete all checks before closure.

1. Open Intune admin center path Devices -> Scripts and remediations -> Platform scripts -> <RecoveryScript> -> Device status.
Expected result: Affected devices show Success or Remediated state.

2. Open Intune admin center path Devices -> Scripts and remediations -> Platform scripts -> Map-FinBridgeDrives.ps1 -> Device status.
Expected result: Failing SYSTEM-context deployment is removed or no longer active on Finance devices.

3. On one remediated endpoint open log path C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\IntuneManagementExtension.log.
Expected result: Latest script run shows successful completion for mapping workflow.

4. On same endpoint open Event Viewer -> Windows Logs -> System and filter Event ID 98 for Last 1 hour.
Expected result: No new drive-letter mapping failure events appear.

5. On same endpoint open File Explorer -> This PC and open S: drive.
Expected result: S: is present and readable.

6. Repeat steps 3 through 5 on two more remediated endpoints.
Expected result: Three-device sample passes.

7. Validate with at least 5 Finance users that shared drive opens after sign-in.
Expected result: Users confirm normal access.

8. Check Service Desk queue for new Finance shared-drive tickets in last 60 minutes.
Expected result: No new incident spike appears.

9. Record closure evidence including device names, user confirmations, and verification times.
Expected result: Closure record is complete and auditable.

---

## 4. Rollback

Use this section immediately if symptoms worsen after change.

Goal:
- Start containment and rollback in under 3 minutes.

1. [ELEVATED] Open Intune admin center path Devices -> Scripts and remediations -> Platform scripts -> <RecoveryScript>.
Expected result: Recovery script details are visible.

2. [ELEVATED] Remove Finance group assignment from the new recovery script.
Expected result: New change stops targeting devices.

3. [ELEVATED] Re-assign last known-good mapping method in Intune to Finance group.
Expected result: Known-good mapping path is active.

4. [ELEVATED] Open Intune path Devices -> All devices -> select 3 canary Finance devices -> Sync.
Expected result: Sync is triggered for canary devices.

5. On canary device sign out and sign in with test user.
Expected result: Session starts and S: drive appears.

6. On canary device open Event Viewer -> Windows Logs -> System and filter Event ID 98 for Last 15 minutes.
Expected result: No new Event 98 failures after rollback.

7. [ELEVATED] Trigger sync for remaining Finance devices in batches.
Expected result: Rollback propagates across remaining devices.

8. Confirm from Service Desk and user sample that shared-drive access is restored.
Expected result: Incident impact is contained and stable.

9. Document rollback start time, reverted assignment, canary devices, and outcomes.
Expected result: Rollback execution evidence is complete.

---

## 5. Notes

Edge cases
- Device can show stale mapping until user signs out and signs in.
- Endpoint offline during rollout may apply change later at next sync.
- Cached credentials can delay access recovery on first attempt.

Warnings
- Do not run drive mapping in SYSTEM context for user-dependent shares.
- Do not remove known-good assignment before recovery method is validated on canary devices.
- Do not close incident without user confirmation from Finance sample.

Related incidents
- Issue-Fault-B-Finance-Shared-Drives-Analysis.md
- Issue-Fault-B-Finance-Shared-Drives-RCA.md
- Issue-Fault-B-Finance-Shared-Drives-KEDB.md
- Issue-Fault-B-Finance-Shared-Drives-Closure-Note.md
