# Root Cause Analysis Report
## Finance Shared Drive Access Failure (FAULT-B)

Report Date: 2026-08-07
Incident Date: 2024-03-15
Incident ID: INC-FIN-DRIVE-MAP-20240315-01
Severity: High (45-user business-team impact)
Status: Resolved
Resolution Time: Approximately 1 hour from detection to stable access restoration

---

## Executive Summary

Finance users (about 45) could not access shared drives after a script migration change. The drive-mapping script was moved from GPO user logon execution to Intune PowerShell execution under SYSTEM context without adapting for user credential context and startup network dependency timing. The script failed before the Workstation service was fully ready and had no retry logic, resulting in failed S: mapping across Finance endpoints.

Service was restored by moving mapping back to user-context execution path and adding readiness/retry safeguards. Validation confirmed shared drive access recovered.

---

## Scope and Impact

- Affected user/group: Finance users on DESKTOP-FB* devices (approximately 45 users)
- Affected systems: Drive mapping process for \\finbridge-fs01\Finance
- Business impact: Finance users unable to access shared drive resources required for daily operations

---

## Supporting Evidence

1. 08:00:01 - ScriptRunner Info - Executing Map-FinBridgeDrives.ps1
2. 08:00:02 - ScriptRunner Info - Script context: SYSTEM account
3. 08:00:03 - ScriptRunner Warning - UNC path not accessible from SYSTEM context
4. 08:00:03 - ScriptRunner Error - Exit code 1, network name cannot be found
5. 08:00:04 - ScriptRunner Info - No retry configured
6. 08:00:05 - Event 7036 - Workstation service entered running state
7. 08:00:06 - Event 1500 - Group Policy processed successfully (not a GPO failure)
8. 08:00:07 - Event 98 - S: drive letter not assigned
9. 2024-03-14 23:30 - Change note - migration from GPO user script to Intune SYSTEM script without context adaptation

Interpretation:
- Primary failure is execution-context design mismatch introduced by change, with startup timing and missing retries making failure deterministic at login.

---

## Incident Timeline
| Time | Event | Evidence | Meaning |
|---|---|---|---|
| 2024-03-14 23:30 | Script migration change applied | Change note | Mapping moved from USER to SYSTEM context |
| 08:00:01 | Script starts | ScriptRunner Info | New mapping path invoked |
| 08:00:02 | SYSTEM context confirmed | ScriptRunner Info | User credential context unavailable |
| 08:00:03 | UNC access fails | ScriptRunner Warning/Error | Mapping target unreachable in current context/time |
| 08:00:04 | No retry path | ScriptRunner Info | Single failure becomes user-visible outage |
| 08:00:05 | Workstation service starts | Event 7036 | Network stack became ready after failure point |
| 08:00:06 | Group Policy success | Event 1500 | Confirms issue is not Group Policy |
| 08:00:07 | S: mapping missing | Event 98 | Drive assignment failed |
| Post-fix | Mapping restored via user-context path | Remediation change | Shared drive access recovered |

---

## Root Cause Statement

The Finance shared-drive outage was caused by migrating drive mapping from user-context GPO execution to SYSTEM-context Intune execution without script redesign for user-token UNC access and startup readiness, causing mapping to fail consistently before dependencies were available.

---

## 5 Whys Analysis
Why 1: Why could Finance users not access shared drives?
- Because the S: drive mapping failed during startup/logon.
- Evidence: Event 98 at 08:00:07; script failure at 08:00:03.

Why 2: Why did drive mapping fail?
- Because the mapping script could not access \\finbridge-fs01\Finance.
- Evidence: ScriptRunner warning and error at 08:00:03.

Why 3: Why could the script not access UNC path?
- Because script was executed under SYSTEM context, not user context.
- Evidence: ScriptRunner context line at 08:00:02.

Why 4: Why was SYSTEM context used?
- Because mapping process was migrated from GPO user logon script to Intune PowerShell script.
- Evidence: Change note from 2024-03-14 23:30.

Why 5: Why did migration cause outage?
- Because script and deployment design lacked context-aware logic, readiness checks, and retry behavior before production rollout.
- Evidence: No retry configured at 08:00:04 and dependency timing mismatch with Workstation service at 08:00:05.

Systemic cause:
- Change governance gap: insufficient pre-production validation of execution context and startup dependencies for endpoint automation.

---

## Resolution Actions Performed
1. Confirmed failure pattern across Finance endpoints and ruled out Group Policy as root issue.
2. Reviewed script execution context and correlated failures with SYSTEM runtime.
3. Restored drive mapping to user-context execution path.
4. Added dependency checks and retry behavior in mapping flow.
5. Validated successful mapping and access across representative Finance devices.

---

## Preventive Actions
### Immediate (0-7 days)
1. Block production use of SYSTEM-context drive mapping scripts unless exception-approved.
- Owner: EUC Engineering
- Success metric: 100% of drive mapping scripts run in approved user context.

2. Add mandatory readiness checks to mapping scripts.
- Owner: Endpoint Engineering
- Success metric: Scripts verify Workstation service and UNC reachability before map.

### Near Term (7-30 days)
1. Introduce canary validation for Intune script migrations.
- Owner: Device Management Team
- Success metric: All script changes pass pilot ring before broad assignment.

2. Add script execution telemetry dashboard with failure-rate thresholds.
- Owner: Monitoring Team
- Success metric: Alert within 10 minutes if failure rate exceeds 5% in target cohort.

### Long Term (30-90 days)
1. Create standard migration pattern for GPO to Intune scripts with context decision matrix.
- Owner: Platform Standards
- Success metric: All migrations use approved pattern and checklist.

2. Add formal rollback gate in change template.
- Owner: Change Management
- Success metric: Every endpoint script change includes tested rollback plan.

---

## Closure and Verification
- Shared drive mapping restored for Finance users after user-context mapping rollout.
- Validation confirmed access to \\finbridge-fs01\Finance and successful S: assignment on sampled endpoints.
- User representatives confirmed normal operation.

---

## Lessons Learned

| Lesson | Impact | Action |
|---|---|---|
| USER vs SYSTEM execution context is a critical design dependency for drive mapping | High | Add mandatory context validation for endpoint script migrations |
| Startup dependency timing can break otherwise valid scripts | High | Require Workstation/UNC readiness checks before mapping logic |
| Missing retry logic converts transient startup issues into full user outage | Medium | Implement bounded retry/backoff in all network-mapping scripts |
| GPO success events can quickly exclude policy as primary root cause | Medium | Include exclusion checks in triage templates to reduce investigation time |
