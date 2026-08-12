# Issue Analysis: Autopilot Enrolment Failure (0x80180014)

**Author:** DWP Analyst  
**Date:** 2026-08-11  
**Folder:** Day 6 - Intune Policies  
**Status:** Root cause confirmed and remediation finalized

---

## 1. Executive Summary

Autopilot enrolment failed because the device already had an existing legacy MDM enrolment record. The diagnostic export confirms:

- **EnrollmentState:** Failed
- **ErrorCode:** `0x80180014`
- **ErrorDescription:** The device is already enrolled in MDM
- **MDMEnrolled:** Yes (previous enrolment from 2023-11-04)
- **EnrolmentSource:** Legacy manual MDM enrolment

This conflict blocks Autopilot enrolment from completing until the stale/legacy enrolment is removed and the device is re-enrolled cleanly.

---

## 2. Scope Facts (from collected evidence)

- Enrolment failed with `0x80180014`.
- Device is Azure AD joined.
- Existing MDM enrolment is present (legacy, manual, 2023-11-04).
- Policy application failed (`ProfilesApplied: 0 of 4`, last error `0x80070005 Access denied`).
- Licensing is correct (M365, Intune P1, Autopilot present).
- Network checks are healthy (required endpoints reachable, no proxy).

---

## 3. Confirmed Root Cause

A **conflicting existing legacy MDM enrolment** remained on the device and/or associated cloud records, preventing Autopilot MDM enrolment from taking ownership.

---

## 4. Exact Remediation Steps

### 4.1 Intune admin center actions

1. **[Admin center only]** Open **Devices > All devices** and search for the affected device (for example, `DESKTOP-FB099`).
2. **[Admin center only]** Open the device record and review management timeline to confirm old/manual enrolment history.
3. **[Admin center only]** Run **Retire** on the stale managed record (if still active) and wait for command acceptance.
4. **[Admin center only]** After retire state is processed, remove stale duplicate Intune device records for the same physical device (same device name/serial/hardware identity pattern), keeping only the target current identity path for re-enrolment.
5. **[Admin center only]** Open **Devices > Windows > Windows enrollment > Devices** (Autopilot devices) and confirm the Autopilot device entry still exists and is assigned the intended profile.
6. **[Admin center only]** Confirm the user has valid Intune and Autopilot licensing and is in scope for automatic MDM enrolment.

### 4.2 Device-side actions

1. **[Device access required: physical or remote session]** On the endpoint, open **Settings > Accounts > Access work or school**.
2. **[Device access required]** Identify the existing legacy work/school MDM connection.
3. **[Device access required]** Select the legacy connection and choose **Disconnect**.
4. **[Device access required]** Reboot the device.
5. **[Device access required]** Start a clean provisioning path:
   - Preferred for Autopilot reliability: **Autopilot Reset** or **Wipe** from Intune, then rerun OOBE Autopilot flow.
   - If reset/wipe is not possible immediately, ensure all old MDM bindings are removed and then retry enrolment flow.

---

## 5. Correct Order of Operations

Execute in this exact sequence to avoid re-binding to stale records:

1. **[Admin center only]** Validate root cause on device record and confirm stale legacy enrolment context.
2. **[Admin center only]** Retire and clean stale Intune device objects.
3. **[Admin center only]** Confirm Autopilot device record/profile assignment remains correct.
4. **[Device access required]** Disconnect legacy MDM account from **Access work or school**.
5. **[Device access required]** Reboot device.
6. **[Device access required]** Trigger clean Autopilot path (Reset/Wipe preferred) and rerun Autopilot enrolment.
7. **[Admin center only]** Validate successful new enrolment and policy/application status.

---

## 6. Verification Checks After Remediation

Autopilot is considered successfully remediated only when all checks below are true:

1. **[Admin center only]** In Intune, device shows as newly enrolled under the expected user and current timestamp (not legacy 2023 enrolment context).
2. **[Admin center only]** Enrolment status no longer shows `0x80180014`.
3. **[Admin center only]** Device receives targeted profiles (for this case, profile application is no longer `0 of 4`).
4. **[Admin center only]** Compliance evaluation starts and returns a valid state (not "Could not evaluate: Enrolment not complete").
5. **[Device access required]** `Access work or school` shows only the current intended management connection.

Optional fast confirmation:

- Trigger a manual sync from device and from Intune device action, then refresh **Device status** and **Configuration profiles** result views.

---

## 7. Preventive Action for Fleet Recurrence

Implement a pre-Autopilot hygiene control for devices with historical manual/legacy MDM enrolments:

1. **[Admin center only]** Build a pre-staging checklist that includes stale enrolment detection (legacy enrolment date/source, duplicate managed records).
2. **[Admin center only]** Before assigning Autopilot profile at scale, retire/remove old manual enrolment records for candidate devices.
3. **[Admin center only]** Enforce process policy: devices with prior manual MDM enrolment must go through reset/wipe and enrolment cleanup gate before Autopilot wave assignment.
4. **[Admin center only]** Pilot every migration wave with a small batch and monitor for recurrence of `0x80180014` before expanding.

---

## 8. Final Resolution Statement

The failure was caused by an existing legacy MDM enrolment conflict. The remediation is to remove stale Intune and local enrolment bindings in the defined sequence, then rerun a clean Autopilot enrolment flow. Verification must confirm successful fresh enrolment, profile application, and compliance evaluation before closing the incident.
