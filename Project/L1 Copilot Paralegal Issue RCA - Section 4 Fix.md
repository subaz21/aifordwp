# Runbook - Copilot Paralegal Issue RCA - Section 4 Fix

## Purpose
Execute a controlled fix for the Section 4 blast-radius findings by removing unauthorized access paths and validating least-privilege access on matter content.

## Prerequisites
1. Sev-1 incident bridge is active with DWP, M365 Platform, IAM, and Document Management owner.
2. Legal/Compliance/DPO are informed and available for governance decisions.
3. Affected matter identifiers are confirmed (site/library/folder/document).
4. Evidence baseline captured before change:
   - ACL and inheritance snapshots
   - Group membership snapshots (including nested groups)
   - Relevant audit log extracts
5. Change approval is granted for emergency access corrections.
6. Two test accounts are available:
   - One authorized matter-team account
   - One unauthorized control account

## Numbered procedure (with expected result)
1. Create the blast-radius access matrix.
Expected result: Complete list of principals (users/groups/service identities) with current access to affected scope.

2. Expand all nested groups in the matrix.
Expected result: No unresolved indirect memberships; every effective user exposure is visible.

3. Classify principals as Authorized, Unauthorized, or Review Needed.
Expected result: Governance-aligned classification list signed off by matter owner or legal delegate.

4. Isolate offending permission paths (ACL entries, inheritance points, or group links).
Expected result: One or more explicit technical paths identified for removal or narrowing.

5. Apply emergency scope reduction.
Expected result: Unauthorized principals no longer inherit or hold read access to matter content.

6. Preserve post-change snapshots immediately.
Expected result: Before/after evidence set captured for audit and RCA traceability.

7. Validate access with control tests.
Expected result: Authorized test account can access expected content; unauthorized control account is denied.

8. Check adjacent sensitive matters that share the same template/policy.
Expected result: No equivalent over-broad access paths remain in related scopes.

9. Communicate interim technical status to incident bridge.
Expected result: Confirmed containment statement with impact count and next verification time.

10. Implement permanent least-privilege correction.
Expected result: Access model is corrected at template/group design level, not only by one-off removals.

## Verification
1. Recompute effective permissions for reporting user and exposed cohorts.
Expected result: No unauthorized path remains.

2. Re-run audit query for new unauthorized access events after remediation.
Expected result: No fresh unauthorized accesses detected in monitoring window.

3. Confirm legal/compliance containment acknowledgement.
Expected result: Governance sign-off recorded in incident timeline.

4. Validate business continuity for legitimate matter team.
Expected result: No collateral denial for authorized users.

## Rollback
Use only if fix causes unintended denial to legitimate users.

1. Pause further permission changes.
2. Restore last known-good ACL template for impacted matter scope.
3. Reapply approved least-privilege mappings from pre-approved matrix.
4. Re-test authorized and unauthorized control accounts.
5. Re-open emergency bridge review and approve adjusted change set.

Expected rollback outcome: Legitimate access restored while maintaining unauthorized access blocks.

## Exit criteria
- Unauthorized exposure path removed and independently verified.
- Related scopes checked for template-linked overexposure.
- Legal/Compliance/DPO acknowledgement documented.
- RCA evidence package complete with before/after artifacts.
