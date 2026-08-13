# Root Cause Analysis (RCA): Autopilot Enrolment Failure 0x80180014

**Author:** DWP Analyst  
**Date:** 2026-08-11  
**Incident Date (from export):** 2024-03-15  
**Affected Device:** DESKTOP-FB099  
**Affected User:** FINBRIDGE\\rthomas  
**Status:** Root cause confirmed, remediation runbook defined

---

## 1. Incident Summary

A Windows Autopilot enrolment attempt failed. The primary failure signal is error code `0x80180014` with explicit description indicating the device was already enrolled in MDM. This prevented enrolment completion, policy application, and compliance evaluation.

---

## 2. Scope and Impact

### 2.1 In-scope impact

- Autopilot enrolment did not complete for the target device.
- Device policies were not applied (`0 of 4`).
- Compliance engine could not evaluate due to incomplete enrolment.

### 2.2 Out-of-scope indicators (validated healthy)

- Licensing was present and valid for M365, Intune P1, and Autopilot.
- Required Microsoft enrolment endpoints were reachable.
- No proxy issue was detected.

---

## 3. Supporting Evidence Matrix

| Evidence Source | Evidence | Operational Meaning | Confidence |
|---|---|---|---|
| EnrollmentStatus | `EnrollmentState: Failed` | Enrolment workflow did not complete | High |
| EnrollmentStatus | `ErrorCode: 0x80180014` | Failure reason tied to existing MDM enrolment conflict | High |
| EnrollmentStatus | `ErrorDescription: The device is already enrolled in MDM.` | Explicit conflict statement from export | High |
| DeviceInfo | `MDMEnrolled: Yes (previous enrolment)` | Confirms existing enrolment state on device | High |
| DeviceInfo | `EnrolmentSource: Legacy (manual MDM enrolment, 2023-11-04)` | Identifies stale/legacy enrolment origin and age | High |
| PolicyManager | `ProfilesAttempted: 4, ProfilesApplied: 0` | No policy payload successfully landed | High |
| PolicyManager | `LastError: 0x80070005 (Access denied)` | Downstream policy application failure while enrolment context is broken | High |
| ComplianceEngine | `Could not evaluate` / `Enrolment not complete` | Compliance blocked by enrolment failure precondition | High |
| DeviceInfo | `AzureADJoined: Yes` | Azure AD join not the blocker | High |
| Licensing | `M365LicenseFound: Yes`, `IntuneP1License: Yes`, `AutopilotLicense: Yes` | Licensing not root cause | High |
| NetworkCheck | Enrolment endpoints OK, no proxy | Network path not root cause | High |

---

## 4. Timeline (UTC offset not provided in export)

### 4.1 Historical context

- **2023-11-04:** Legacy manual MDM enrolment established on device.

### 4.2 Incident sequence on 2024-03-15

- **09:18:44** - EnrollmentStatus records Autopilot enrolment failure: `0x80180014` and description "device is already enrolled in MDM".
- **09:19:01** - PolicyManager reports `ProfilesApplied: 0 of 4`; `LastError: 0x80070005 (Access denied)`.
- **09:19:45** - ComplianceEngine reports `Could not evaluate` with reason `Enrolment not complete`.
- **09:22:00** - Diagnostic export captured with consolidated failure state.

### 4.3 Causal chain from timeline

Legacy manual enrolment existed before Autopilot attempt. Autopilot enrolment failed first, policy application failed next, and compliance evaluation failed last. This order supports enrolment conflict as the initiating condition.

---

## 5. 5-Why Analysis

### Problem statement

Autopilot enrolment failed and device did not receive policy or compliance state.

1. **Why did Autopilot enrolment fail?**  
   Because enrolment returned `0x80180014` with message that the device was already enrolled in MDM.

2. **Why was the device already enrolled in MDM?**  
   Because an existing legacy manual MDM enrolment from 2023-11-04 was still present.

3. **Why was the legacy enrolment still present at Autopilot time?**  
   Because stale enrolment records and local MDM binding were not removed before initiating Autopilot.

4. **Why were stale bindings not removed beforehand?**  
   Because pre-Autopilot readiness checks did not enforce a legacy-enrolment cleanup gate.

5. **Why was there no enforced cleanup gate?**  
   Because migration process controls focused on profile assignment/licensing/network readiness but lacked mandatory historical-enrolment hygiene controls.

### Root cause

Missing operational control for legacy MDM cleanup before Autopilot enrolment allowed a pre-existing manual enrolment to conflict with modern Autopilot MDM takeover.

---

## 6. Corrective Actions (for this incident)

### 6.1 Intune admin center actions

1. Open **Devices > All devices** and locate the affected device record.
2. Confirm legacy/manual enrolment context in the device history.
3. Issue **Retire** for stale managed record(s).
4. Remove stale duplicate Intune device objects for the same hardware identity.
5. Validate Autopilot device identity/profile assignment under **Devices > Windows > Windows enrollment > Devices**.

### 6.2 Device-side actions

1. On device, open **Settings > Accounts > Access work or school**.
2. Disconnect legacy MDM work/school connection.
3. Reboot device.
4. Execute clean re-provisioning path (Autopilot Reset or Wipe preferred), then rerun Autopilot OOBE enrolment.

---

## 7. Verification Plan (post-remediation)

Autopilot remediation is successful when all conditions are true:

1. Enrolment no longer fails with `0x80180014`.
2. Device appears as current managed instance (without stale legacy enrolment context).
3. Policy application progresses beyond `0 of 4`.
4. Compliance engine evaluates normally (no `Enrolment not complete` blocker).
5. Device shows only intended current work/school management connection.

---

## 8. Preventive Actions (to prevent recurrence)

### 8.1 Process controls

1. Add a mandatory pre-Autopilot checklist item: detect and clear legacy/manual MDM enrolments before wave assignment.
2. Add a migration gate: no device enters Autopilot wave unless stale Intune objects are retired/removed.
3. Require reset/wipe path for devices with historical manual enrolment unless exception is approved.

### 8.2 Operational monitoring

1. During pilot and early production waves, monitor for `0x80180014` as a leading indicator.
2. Add daily exception report for devices marked as already enrolled prior to Autopilot flow.
3. Stop wave expansion if repeated stale-enrolment collisions exceed threshold.

### 8.3 Governance updates

1. Update enrolment runbook to include legacy-enrolment hygiene and ownership.
2. Assign accountability for pre-flight validation to migration operations team.
3. Include rollback/hold criteria in change records when enrolment conflicts are detected.

---

## 9. Final RCA Conclusion

The confirmed root cause of this Autopilot failure is a pre-existing legacy manual MDM enrolment conflict. Evidence consistency across enrolment, policy, compliance, licensing, and network sections supports this conclusion with high confidence. Implementing mandatory legacy-enrolment cleanup controls before Autopilot assignment is the key preventive measure to avoid recurrence at fleet scale.
