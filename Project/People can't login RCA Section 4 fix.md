# People can't login RCA Section 4 fix

## Purpose
Provide an execution runbook for Section 4 blast-radius and trend-tracking outcomes, then drive immediate corrective actions to restore login success.

## Prerequisites
1. Incident bridge active with DWP Incident Lead, IAM/Entra Admin, Intune Admin, Endpoint Engineering, and Network Ops.
2. Dominant failure class identified from sign-in telemetry:
- Conditional Access
- Device compliance
- MFA/credential
- Service/network
3. Sample evidence set prepared:
- 6-10 affected users and 2 unaffected controls
- Error code, correlation ID, policy detail, timestamp
4. Emergency change approval available for temporary mitigations.
5. Pilot cohort selected for controlled validation.

## Numbered procedure (expected result after each step)
1. Segment impacted users by floor, business unit, device type, join state, and assignment group.
Expected result: Clear blast-radius map with highest-impact cohort identified.

2. Correlate affected cohort with recent policy or rollout changes.
Expected result: One or more likely change links documented.

3. Conditional Access path: apply tightly scoped, time-bound exclusion for confirmed affected cohort.
Expected result: Immediate login recovery starts for excluded pilot users.

4. Compliance path: trigger Intune sync/compliance reevaluation and validate assignment drift.
Expected result: Previously blocked compliant devices begin passing sign-in checks.

5. MFA/credential path: resolve lockout or method issues and re-register impacted users where needed.
Expected result: MFA failures decline and successful sign-ins increase.

6. Service/network path: validate dependency health, declare dependency incident if needed, and apply approved workaround.
Expected result: Timeout/network class errors reduce measurably.

7. Retest sign-in with pilot users after each change.
Expected result: Pilot success rate improves with no new side effects.

8. Expand mitigation in controlled waves.
Expected result: Broader cohort recovery while preserving change control.

9. Track success/failure trend every 15 minutes.
Expected result: Evidence of sustained recovery or clear trigger for escalation.

10. Remove temporary mitigations once permanent correction is validated.
Expected result: Stable baseline restored without lingering risk exceptions.

## Verification
1. Login success rate returns to baseline for impacted cohort.
Expected result: Authentication KPI normalizes.

2. No sustained sign-in failure spike for at least 60 minutes.
Expected result: Recovery is stable, not transient.

3. Service desk confirms ticket volume normalization.
Expected result: User impact materially resolved.

4. Evidence package updated with before/after states.
Expected result: RCA record is complete and audit-ready.

## Rollback
Use rollback if mitigation causes broad impact or fails to improve outcomes.

1. Revert latest auth-impacting policy change.
2. Remove temporary broad assignments or exclusions.
3. Revalidate pilot users against last known-good configuration.
4. Reassess dominant failure class and re-enter controlled mitigation.

Expected rollback outcome: Environment returns to known stable state while investigation continues.
