# Immediate Fix - Copilot Paralegal Access Exposure (DWP)

## Immediate objective
Stop any unauthorized matter visibility now and preserve evidence.

## Severity
- Treat as Sev-1 security/governance incident.

## First 0-15 minutes
- Open Sev-1 bridge with DWP, M365 Platform, IAM, Legal, Compliance, and DPO.
- Remove reporting user's effective access path to affected matter scope.
- Freeze non-essential permission-template deployments/changes for related scope.
- Capture evidence before bulk edits:
  - ACL and inheritance snapshot
  - Group membership snapshot (including nested groups)
  - Access and permission-change audit events

## First 15-45 minutes
- Compute full effective permissions for reporting user.
- Identify exact principal/path granting unauthorized access.
- Expand blast radius:
  - List all users/groups with same path
  - Prioritize high-risk roles outside matter team
- Apply emergency scope reduction to over-broad groups/ACLs.

## Immediate success criteria
- Unauthorized path removed for reporting user and equivalent cohorts.
- Legal/Compliance notified with containment status.
- Evidence package preserved for RCA and governance review.

## Escalation trigger
- Escalate major-incident response immediately if additional matter exposure is confirmed.

## Handover to RCA
- Continue full investigation in: Runbook - Copilot Paralegal Issue RCA.
- Attach timeline, evidence snapshots, and approvals to incident record.
