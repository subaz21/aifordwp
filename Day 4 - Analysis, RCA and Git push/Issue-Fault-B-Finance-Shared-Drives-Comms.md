# FAULT-B Finance Shared Drive Access Incident: Audience Communications

## Audience 1 - Non-technical executive
Service has been restored and data remained safe. On 2024-03-15, Finance users could not access shared drives because a recent automation change ran drive mapping under the wrong execution context at startup. We corrected the mapping method, validated shared drive access, and confirmed normal operation for affected users. No data loss occurred.

## Audience 2 - Affected end-user team (non-technical)
Your shared drive access is restored and data is safe. The issue was caused by a startup automation change that tried to map drives before the right user context was available. We corrected the mapping process and confirmed access is working again. If you see this again, sign out and sign back in once, then contact Service Desk.

## Audience 3 - Engineer-to-engineer internal note
Incident: INC-FIN-DRIVE-MAP-20240315-01, Finance shared-drive mapping failure, 2024-03-15 morning startup window.

Root cause:
- Drive mapping moved from GPO user logon script to Intune script executed as SYSTEM.
- Script attempted UNC mapping without user context and before startup dependency readiness.
- No retry logic was configured, so initial failure persisted.

Exact action taken:
- Correlated ScriptRunner context and failure events with System timeline.
- Reverted mapping execution path to user context.
- Added service/readiness checks and bounded retry behavior.
- Validated mapping and share access across Finance device sample.

Config and event details:
- 08:00:02 Script context SYSTEM.
- 08:00:03 UNC access failure and script exit code 1.
- 08:00:05 Workstation service entered running state after script failure.
- 08:00:06 Event 1500 confirms Group Policy success.
- 08:00:07 Event 98 confirms S: assignment failure.

Verification:
- Post-fix, mapped drive assignment succeeded and Finance share became accessible.
- No repeat script-run failures observed in validation window.
- User representatives confirmed normal shared-drive access.

Preventive action required:
- Enforce context validation for all endpoint script migrations (USER vs SYSTEM).
- Require startup dependency checks and retry logic for network-mapping scripts.
- Require canary rollout and monitored success criteria before full assignment.
