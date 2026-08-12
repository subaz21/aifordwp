Symptom     : Autopilot enrolment fails during Windows provisioning. The device does not complete MDM enrolment, configuration profiles do not apply, and compliance cannot be evaluated.

Cause       : Existing legacy manual MDM enrolment remains on the device and/or stale managed record exists in Intune. Autopilot enrolment fails with error 0x80180014 because the device is already enrolled in MDM.

Scope       : Devices targeted for Autopilot that were previously manually enrolled to MDM and did not complete full de-enrolment cleanup before migration.

Workaround  : Temporarily pause rollout for impacted devices. Keep user productive on current setup where possible while stale enrolment cleanup is performed.

Permanent fix: Remove stale Intune managed records and local legacy MDM binding, then execute a clean Autopilot path (Autopilot Reset or Wipe preferred) and re-enrol.

How to spot it:
- EnrollmentState: Failed
- ErrorCode: 0x80180014
- ErrorDescription: The device is already enrolled in MDM
- MDMEnrolled: Yes (previous enrolment)
- EnrolmentSource: Legacy manual MDM enrolment
- ProfilesApplied: 0 of 4
- ComplianceEngine: Could not evaluate (Enrolment not complete)

Fast confirmation checks:
- Intune admin center: Devices > All devices > [Device] shows legacy/stale management context.
- Device: Settings > Accounts > Access work or school shows existing old work/school MDM connection.
- Health controls: licensing and network are healthy (rules out license/network as primary cause).