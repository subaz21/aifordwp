# 2nd - People Can't Login (Detailed Triage) - FinBridge Floor 6, 2026-08-14

## Incident summary
A dozen or more users on Floor 6 report they cannot sign in, or sign-in is extremely slow, shortly after Friday's document management rollout.

## Why this is urgent
- This is an active availability incident affecting business operations at the start of the workday.
- The impacted count and timing suggest a shared mechanism (policy/state/platform) rather than isolated endpoint issues.
- Delay increases productivity loss and support queue saturation.

## What to check first
- Entra ID sign-in logs for a representative sample of affected users.
- Capture the exact failure reason/error code at the same timestamps users attempted sign-in.
- Focus on code categories: Conditional Access block, device compliance failure, MFA/credential failure, timeout/service degradation.

## Why this check first
- Error codes immediately collapse the hypothesis space and prevent blind troubleshooting.
- This avoids low-value actions (mass reboots, ad hoc reinstalls) that do not address a policy or identity-state root cause.

## Severity and initial classification
- Initial severity: Sev-2 (upgrade to Sev-1 if impact grows, executive-critical users impacted, or no workaround).
- Incident type: authentication and access availability degradation.
- Likely domains: Entra Conditional Access, Intune compliance state, identity token/MFA path, network dependency, or tenant service health.

## Triage objectives (priority order)
1. Identify the dominant failure mode from authoritative sign-in telemetry.
2. Restore access for the largest user cohort first.
3. Isolate whether the trigger is policy, compliance, credential/MFA, or platform health.
4. Preserve evidence for post-incident RCA and change review.

## First 15 minutes (stabilization)
- Open incident channel/bridge with Service Desk, IAM, Intune, and endpoint owner.
- Pull a sample of 6-10 affected users across departments/devices.
- For each sample user, collect:
  - Username/UPN
  - Device ID/hostname
  - Sign-in time (local)
  - Error code/failure reason in Entra logs
  - Correlation ID/Request ID
- Confirm whether unaffected users in same location can sign in normally.

## Decision point A: dominant error class
- If most failures are Conditional Access:
  - Identify the specific policy and grant/control that failed.
  - Check recent policy changes, include/exclude group scope, named locations, and app targeting.
- If most failures are Device Compliance:
  - Validate Intune compliance evaluation latency/state drift after rollout.
  - Confirm device check-in status and compliance policy assignment changes.
- If most failures are MFA/Credential:
  - Check MFA provider status, method registration issues, risk policies, and lockout signals.
- If most failures are timeouts/unknown/network:
  - Check Microsoft 365 and Entra service health plus local network/proxy dependencies.

## Blast-radius mapping (next 30-60 minutes)
- Quantify impact by floor, business unit, device type, and join state (AADJ/Hybrid).
- Compare affected users against rollout assignment groups from Friday.
- Verify whether failures correlate to one app/policy/device cohort.
- Track impacted count trend every 15 minutes.

## Fast containment/remediation by scenario
- Conditional Access scenario:
  - Apply temporary scoped exclusion for confirmed affected cohort only.
  - Keep exclusion time-bound and documented with approver.
- Compliance scenario:
  - Trigger device sync/compliance refresh for affected cohort.
  - Apply temporary grace path only if approved by IAM/Security.
- MFA scenario:
  - Reset/re-register impacted MFA methods where needed.
  - Confirm no broad MFA provider outage before user-level resets.
- Service degradation scenario:
  - Communicate external dependency issue and publish workaround cadence.

## Evidence preservation checklist
- Entra sign-in logs with code, reason, policy, correlation ID, and timestamp.
- Conditional Access evaluation details per failed attempt.
- Intune compliance state snapshots and assignment history.
- Change evidence from Friday rollout (who changed what, when, and scope).
- Timeline of containment actions and approvals.

## Communications plan
- Internal updates every 30 minutes with:
  - Current impacted count
  - Dominant failure mode
  - Mitigation in progress
  - ETA for next checkpoint
- User-facing message:
  - Acknowledge incident
  - Provide temporary workarounds if available
  - Commit to next update time

## Escalation triggers
- Escalate to major incident if:
  - Impact exceeds agreed threshold (for example >40% of floor users), or
  - No validated mitigation within 60 minutes, or
  - Multiple business-critical teams blocked.
- Escalate to Microsoft support when tenant/service behavior is suspected and internal controls are ruled out.

## Exit criteria
- Affected users can authenticate at normal success rate.
- No sustained spike in sign-in failures for at least 60 minutes.
- Temporary bypasses/exclusions are either rolled back or tracked with expiry and owner.
- Incident timeline and evidence package are complete for RCA.

## Common mistakes to avoid
- Troubleshooting endpoints first without reading Entra failure reasons.
- Applying tenant-wide policy relaxations without scoped targeting.
- Treating "slow login" and "cannot login" as separate unrelated incidents before telemetry review.
- Closing incident on first recovery without monitoring for regression.
