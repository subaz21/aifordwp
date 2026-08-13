# Autopilot Enrolment Failure 0x80180014: Audience Communications

## Audience 1 - Non-technical executive
Device onboarding was delayed for a subset of migration devices because some had an older management record still attached from a previous process. Security and licensing were functioning as expected, and there was no network outage. The team has a confirmed fix path: remove stale legacy management bindings, run a clean Autopilot reset flow, and validate policy/compliance completion before returning devices to users.

## Audience 2 - Affected end-user team (non-technical)
Your device setup may fail with an enrolment message while IT is moving it to the new setup process. This happens when an older management connection is still present on the device. IT will remove the old connection and rerun setup. You might be asked to reboot or hand over the device briefly for a clean reset. Your account licensing and network access are fine, and this is a fixable setup-state issue.

## Audience 3 - Engineer-to-engineer internal note
Incident: Autopilot enrolment failure, code 0x80180014.

Confirmed evidence:
- EnrollmentState: Failed
- ErrorCode: 0x80180014
- ErrorDescription: device already enrolled in MDM
- MDMEnrolled: Yes (legacy manual enrolment, 2023-11-04)
- AzureADJoined: Yes
- Licensing: M365/Intune P1/Autopilot all present
- Network checks: required endpoints reachable, no proxy
- ProfilesApplied: 0 of 4
- ComplianceEngine: could not evaluate because enrolment not complete

Action being executed:
1. Retire/remove stale Intune objects for impacted devices.
2. Remove local legacy MDM work/school binding on device.
3. Reboot and run clean Autopilot path (reset/wipe preferred).
4. Validate successful fresh enrolment and profile application.

Risk control:
- Do not expand migration wave for legacy-enrolled devices until pre-flight cleanup gate is passed.
- Track repeat 0x80180014 occurrences as rollout stop criterion.