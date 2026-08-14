# Runbook - People Can't Login RCA (DWP)

## Purpose
Provide a repeatable DWP runbook to identify root cause, restore access quickly, and prevent recurrence when multiple users cannot log in or experience severe login latency.

## Scope
- Microsoft Entra ID sign-in failures and slow authentication
- Conditional Access and Intune compliance interactions
- MFA and credential-path failures
- Network/proxy or tenant-service-related authentication degradation

## Trigger conditions
Start this runbook when all are true:
- 10 or more users in the same location/time window report failed or very slow login.
- The issue appears correlated by timing/cohort rather than isolated to one endpoint.
- Business operations are materially impacted.

## Severity and ownership
- Default severity: Sev-2
- Upgrade to Sev-1 if major business functions are blocked, impact expands rapidly, or no workaround exists.
- Incident owner: DWP Incident Lead
- Technical owners: IAM/Entra Admin, Intune Admin, Endpoint Engineering, Network Ops

## Inputs required
- First reported timestamp and affected floor/team
- Sample list of affected and unaffected users/devices
- Recent change events (policy changes, rollout assignments, network changes)
- Authentication app/resource context (M365 app, VPN, line-of-business app)

## Authoritative data sources
- Entra sign-in logs
- Conditional Access policy insights and evaluation results
- Intune compliance state and check-in history
- Microsoft service health dashboard
- Local network/proxy telemetry where applicable

## Step 1 - Stabilize and frame (0-15 minutes)
1. Open incident bridge and assign clear ownership.
2. Capture impact snapshot:
   - Count of affected users
   - Primary symptom (fail vs slow)
   - Earliest known timestamp
3. Gather representative sample (6-10 affected users + 2 unaffected controls).
4. Notify service desk to stop generic reboot-only guidance until failure mode is known.

## Step 2 - First diagnostic pass (15-30 minutes)
For each sampled failed attempt, capture:
- UPN
- Device name/ID and join state
- Exact sign-in timestamp
- Entra failure reason and error code
- Correlation ID or Request ID
- Policy name if Conditional Access evaluated

Build an error distribution table and identify dominant class:
- Conditional Access block
- Device compliance failure
- MFA/credential failure
- Timeout/network/service error

## Decision tree
### Decision A: Conditional Access dominant?
- Validate which policy blocked sign-in.
- Compare current vs previous assignment scope.
- Check grant controls and named location logic.
- If confirmed, go to Step 3A.

### Decision B: Device compliance dominant?
- Validate Intune compliance freshness and assignment drift.
- Check device check-in delays and stale compliance state.
- If confirmed, go to Step 3B.

### Decision C: MFA/credential dominant?
- Check MFA service health and method registration status.
- Review account lockout, risky sign-in, and password events.
- If confirmed, go to Step 3C.

### Decision D: Timeout/service/network dominant?
- Check Microsoft advisories and tenant service health.
- Validate proxy/DNS/connectivity dependencies from affected subnet.
- If confirmed, go to Step 3D.

## Step 3A - Corrective actions (Conditional Access)
1. Apply tightly scoped temporary exclusion for confirmed affected cohort only.
2. Keep exception time-bound with approval and expiry.
3. Correct policy scope/logic and retest with pilot users.
4. Remove temporary exclusion once stable.

## Step 3B - Corrective actions (Compliance)
1. Trigger Intune sync/compliance reevaluation for affected devices.
2. Validate policy assignments and recent compliance rule changes.
3. Use temporary grace path only with IAM/Security approval.
4. Confirm restoration and revoke grace path promptly.

## Step 3C - Corrective actions (MFA/Credential)
1. Resolve lockout or credential mismatch conditions.
2. Re-register MFA methods for impacted users as needed.
3. Confirm no broader MFA provider incident before bulk resets.
4. Retest sign-in across impacted cohort.

## Step 3D - Corrective actions (Service/Network)
1. Declare dependency incident if external service is degraded.
2. Apply approved workarounds (alternate auth path/location if available).
3. Coordinate with Network Ops for local dependency bottlenecks.
4. Track service recovery and user restoration trend.

## Step 4 - Blast-radius and trend tracking (30-90 minutes)
- Segment impact by floor, business unit, device type, join state, and assignment group.
- Correlate failures to Friday rollout groups and recent policy changes.
- Update impacted count and success-rate recovery every 15 minutes.

## Step 5 - Verification gates
Do not close incident until all pass:
- Login success rate returns to baseline for impacted cohort.
- No sustained sign-in failure spike for 60 minutes.
- Temporary bypasses are removed or tracked with owner/expiry.
- Service desk confirms ticket inflow normalizing.

## Evidence pack for RCA
Include:
- Timeline of detection, triage, mitigation, and recovery
- Error-code distribution and dominant failure class
- Before/after policy or compliance state snapshots
- Change records linked to incident window
- Validation evidence across pilot and broad cohort

## Preventive controls
- Pre-change simulation for Conditional Access scope updates.
- Compliance-state health checks before broad rollout waves.
- Alerting on sign-in error-rate spikes by site/floor.
- Standardized rollback plan attached to auth-impacting changes.

## Rollback plan
1. Revert latest auth-impacting policy change.
2. Remove temporary broad assignments introduced during mitigation.
3. Revalidate pilot users before wider restore.
4. Confirm metrics stabilize before incident closure.

## Communications template (internal)
- Incident: Multi-user login failure/latency
- Status: Investigating or mitigating
- Dominant cause class: CA or Compliance or MFA or Service/Network
- Impact: <affected>/<population>
- Next update: <timestamp>

## Closure criteria
- Root cause confirmed with evidence.
- Permanent fix deployed and validated.
- Temporary exceptions cleaned up.
- RCA and preventive actions logged with owners/dates.
