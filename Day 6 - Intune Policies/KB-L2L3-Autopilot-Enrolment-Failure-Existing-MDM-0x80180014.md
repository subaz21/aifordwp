Title: KB-L2L3-Autopilot-Enrolment-Failure-Existing-MDM-0x80180014
Version Header: v 1.0, 11/08/2026, status : Draft
Audience: DWP L2/L3 Engineers
Scope: Diagnose and resolve Autopilot enrolment failure caused by existing legacy MDM enrolment conflict

## Background

Autopilot expects to establish the active MDM management path during provisioning. If a device already has legacy/manual MDM enrolment state, Autopilot can fail before policy and compliance are fully evaluated.

Confirmed code meanings used in this KB:
- `0x80180014`: Device already enrolled in MDM
- `0x80070005`: Access denied

## Symptom

Engineer sees:
- Autopilot flow fails during enrolment.
- Policy application stalls (`ProfilesApplied: 0 of 4`).
- Compliance state cannot evaluate due to incomplete enrolment.

Typical export signature:
- EnrollmentState: Failed
- ErrorCode: 0x80180014
- ErrorDescription: The device is already enrolled in MDM
- MDMEnrolled: Yes (previous enrolment)
- EnrolmentSource: Legacy manual MDM enrolment

## Root Cause

Existing legacy MDM enrolment remained present and conflicted with Autopilot enrolment ownership.

## Detection

Complete all checks before remediation.

### Step 1: Confirm failure signature from export or portal

- Confirm `0x80180014` with description "already enrolled in MDM".
- Confirm `ProfilesApplied: 0 of 4` and compliance not complete.

### Step 2: Validate non-causal controls (rule-out)

- AzureADJoined = Yes
- Intune and Autopilot licenses = Yes
- Enrolment endpoints reachable, no proxy problem

### Step 3: Confirm stale enrolment context in Intune

Portal path:
- Intune admin center -> Devices -> All devices -> [affected device]

Check for:
- old/manual management history
- duplicate managed records for same device identity pattern

### Step 4: Confirm local stale binding on device

Device path:
- Settings -> Accounts -> Access work or school

Check for:
- old work/school MDM connection tied to legacy enrolment

## Resolution

Execute in exact order.

### Phase A: Admin center cleanup

1. Open Devices -> All devices -> [affected device].
2. Retire stale active managed record.
3. Remove stale duplicate Intune device objects for same physical device.
4. Confirm Autopilot device object still exists and is profile-assigned:
   - Devices -> Windows -> Windows enrollment -> Devices
5. Confirm user licensing and MDM scope are correct.

### Phase B: Device-side cleanup

1. On device, open Settings -> Accounts -> Access work or school.
2. Disconnect legacy MDM connection.
3. Reboot device.
4. Start clean provisioning path (Autopilot Reset or Wipe preferred).
5. Rerun Autopilot OOBE enrolment.

## Verification

Success criteria:
1. Enrolment no longer fails with `0x80180014`.
2. Device appears as fresh current managed instance in Intune.
3. Profile application progresses beyond `0 of 4`.
4. Compliance engine evaluates (not blocked by incomplete enrolment).
5. Device shows only intended current work/school connection.

## Rollback / Containment

If enrolment still fails after cleanup:
1. Pause onboarding for similar legacy-enrolled devices.
2. Re-check for remaining duplicate cloud records.
3. Re-run clean wipe/reset and repeat enrolment.
4. Escalate with fresh diagnostic export and exact timestamps.

## Preventive Action

1. Add mandatory pre-Autopilot legacy-enrolment hygiene gate.
2. Retire/remove stale manual enrolment records before wave assignment.
3. Require reset/wipe for devices with prior manual enrolment history.
4. Pilot each migration wave and monitor recurrence of `0x80180014` before scale-out.

## Quick Engineer Checklist

- [ ] Confirm 0x80180014 signature
- [ ] Confirm legacy MDM enrolment evidence
- [ ] Retire/remove stale Intune records
- [ ] Remove local old work/school binding
- [ ] Reboot and run clean Autopilot flow
- [ ] Validate profile and compliance progression
