# L2 People can't login issue

## Audience
L2 engineer handling repeat multi-user login failure/latency incidents on Floor 6.

## Incident profile
- Default severity: Sev-2
- Upgrade to Sev-1 if impact expands rapidly, critical users are blocked, or no validated workaround exists
- Typical domains:
  - Conditional Access scope or control mismatch
  - Intune compliance-state drift
  - MFA or credential-path failure
  - Service/network dependency degradation

## Trigger criteria
Use this article when:
- 10+ users in a shared window/location report failed or very slow login
- Symptoms appear cohort-based, not isolated to a single endpoint

## Technical objective
1. Identify dominant failure mode from authoritative telemetry.
2. Restore access for the largest impacted cohort first.
3. Apply scoped mitigation with minimal risk.
4. Preserve evidence for RCA and governance review.

## Required intake data
- First incident timestamp
- Affected floor/team and impacted count
- Sample users/devices (affected and unaffected)
- Recent changes (CA policy, Intune compliance policy, rollout assignments, network changes)
- Target app/resource path (M365, VPN, LoB app)

## Prerequisites
1. Incident bridge active with DWP Lead, IAM/Entra Admin, Intune Admin, Endpoint Engineering, and Network Ops.
2. Service desk informed to stop generic reboot-only guidance.
3. Access to Entra sign-in logs and Conditional Access evaluation details.
4. Access to Intune compliance history and assignment state.
5. Access to service health and local network/proxy telemetry.

## Procedure (expected result after each step)
1. Capture incident impact snapshot (fail vs slow ratio, earliest timestamp, affected count).
Expected result: Initial scope and urgency confirmed.

2. Build representative sample (6-10 affected users and 2 unaffected controls).
Expected result: Reliable comparison set for diagnostics.

3. For each failed sample, collect UPN, device ID/join state, timestamp, error code, correlation ID, evaluated policy.
Expected result: Structured diagnostic dataset with traceable identifiers.

4. Build error distribution table and classify dominant failure class:
- Conditional Access
- Compliance
- MFA/Credential
- Timeout/Service/Network
Expected result: Primary remediation path selected with evidence.

5. Conditional Access path: apply tightly scoped, time-bound exclusion for confirmed affected cohort only.
Expected result: Immediate login recovery for pilot users without broad policy weakening.

6. Compliance path: trigger Intune sync/compliance reevaluation and check assignment drift.
Expected result: Compliance-based sign-in blocks reduce for affected cohort.

7. MFA/Credential path: resolve lockout/method issues and re-register MFA for impacted users as required.
Expected result: MFA/credential failures drop and login success increases.

8. Service/Network path: validate service advisories and dependency health; apply approved workaround.
Expected result: Timeout/network class failures trend downward.

9. Retest with pilot users after each change.
Expected result: Measurable improvement confirmed before wider mitigation.

10. Expand mitigation in controlled waves and track recovery every 15 minutes.
Expected result: Broad cohort recovery without destabilizing unaffected users.

## Verification gates
1. Login success rate returns to baseline for impacted cohort.
Expected result: Authentication KPI normalized.

2. No sustained sign-in failure spike for at least 60 minutes.
Expected result: Recovery is stable, not temporary.

3. Service desk confirms ticket inflow normalizing.
Expected result: User impact substantially reduced.

4. Temporary exceptions are removed or tracked with owner and expiry.
Expected result: No unmanaged security debt remains.

## Rollback
Use rollback if mitigation introduces wider risk or no recovery trend.

1. Revert latest auth-impacting policy change.
2. Remove temporary broad assignments/exclusions.
3. Revalidate pilot users against last known-good state.
4. Reassess dominant failure class and re-enter controlled fix path.

Expected rollback outcome: Return to stable baseline while preserving incident control.

## Escalate to L3 when
- Dominant class cannot be determined from telemetry
- Multiple failure classes persist without clear primary cause
- Tenant-level behavior suggests deeper platform defect
- Security trade-offs exceed L2 approval authority

## Evidence package for closure
- Timeline: detection, triage, mitigation, validation
- Error-code distribution with dominant class rationale
- Before/after policy/compliance states
- Correlation to recent changes
- Pilot and wave recovery metrics
- Approvals and exception records

## Common L2 mistakes to avoid
- Jumping to endpoint reboots before reading sign-in error codes
- Applying tenant-wide relaxations instead of scoped mitigations
- Treating slow-login and failed-login as separate incidents before telemetry review
- Closing incident immediately after first recovery without stability watch
