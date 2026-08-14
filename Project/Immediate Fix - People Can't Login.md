# Immediate Fix - People Can't Login or Login is Slow (DWP)

## Immediate objective
Identify dominant failure mode from telemetry and restore authentication for the largest affected cohort.

## Severity
- Start at Sev-2.
- Upgrade to Sev-1 if impact expands rapidly or mitigation is not validated within 60 minutes.

## First 0-15 minutes
- Open incident bridge with IAM, Intune, Endpoint, Network, and Service Desk.
- Capture impact snapshot:
  - Affected count
  - Fail vs slow ratio
  - Earliest timestamp
- Gather sample set: 6-10 affected users and 2 unaffected controls.

## First 15-30 minutes
- Pull Entra sign-in logs and extract:
  - Error code/failure reason
  - Correlation ID
  - Policy involved (if any)
- Classify dominant cause:
  - Conditional Access
  - Compliance
  - MFA/Credential
  - Timeout/Service/Network

## Immediate fix by dominant cause
- Conditional Access:
  - Apply tightly scoped, time-bound exception to impacted cohort.
  - Correct scope/logic and retest pilot users.
- Compliance:
  - Trigger Intune sync/compliance reevaluation.
  - Apply temporary grace path only with IAM/Security approval.
- MFA/Credential:
  - Resolve lockout/credential mismatch.
  - Re-register MFA only for impacted users.
- Service/Network:
  - Declare dependency incident and apply approved workaround path.

## Immediate success criteria
- Sign-in success rate trending back toward baseline.
- Ticket inflow stabilizing.
- Temporary exceptions tracked with owner and expiry.

## Escalation trigger
- Escalate to major incident if impact exceeds threshold or no validated mitigation in 60 minutes.

## Handover to RCA
- Continue full investigation in: Runbook - People Can't Login RCA.
- Attach timeline, error-code distribution, and change evidence.
