# L2 Copilot Paralegal issue

## Audience
L2 technical engineer handling repeat incidents where Copilot surfaces client-matter content to an unauthorized user.

## Incident type
- Sev-1 security/governance incident
- Potential ethical-wall and confidentiality exposure
- Primary fault domain: access control path (ACL/group inheritance), not Copilot entitlement

## When to use this article
Use this article when a user reports Copilot showing matter content they should not access, especially after permission/template rollout changes.

## Immediate goals
1. Contain potential exposure.
2. Confirm unauthorized access path technically.
3. Determine blast radius.
4. Preserve evidence for Legal/Compliance and RCA.
5. Hand off validated findings to L3 for permanent model correction if needed.

## Inputs to collect at intake
- Reporting user UPN and department
- Timestamp of occurrence
- Matter/site/library/folder/document identifiers
- Prompt context and screenshot
- Device/session context
- Recent rollout/change window reference

## Prerequisites
1. Incident bridge active: DWP lead, M365 Platform, IAM, Document Management owner.
2. Legal/Compliance/DPO notified and in loop.
3. Emergency change approval path open.
4. Access to:
- SharePoint permissions
- Entra group membership and nested group views
- Audit logs (access, permission change, membership change)
5. Two test accounts:
- Authorized matter-team account
- Unauthorized control account

## Procedure (with expected result after each step)
1. Contain reporter path immediately by removing their effective access route to affected matter scope.
Expected result: Reporter can no longer retrieve matter content.

2. Capture pre-change evidence (ACL, inheritance, group membership snapshots, relevant audit events).
Expected result: Forensic baseline preserved before broad remediation.

3. Build access matrix for affected scope (all principals with access).
Expected result: Full principal inventory for site/library/folder/document.

4. Expand nested groups and indirect memberships in matrix.
Expected result: Effective user exposure is fully visible, no unresolved inheritance paths.

5. Identify exact unauthorized path (direct ACL, inherited ACL, group assignment, nested group link).
Expected result: One or more explicit technical paths mapped from principal to object.

6. Classify principals as Authorized, Unauthorized, or Review Needed with matter owner/legal delegate.
Expected result: Governance-approved classification list.

7. Apply scoped emergency reduction (remove/narrow offending ACL/group links).
Expected result: Unauthorized users lose read path while legitimate matter team remains functional.

8. Validate with control testing:
- Authorized account should still access matter
- Unauthorized control account must be denied
Expected result: Correct least-privilege state validated.

9. Extend blast-radius checks to adjacent sensitive matters using same template/policy.
Expected result: Confirmation that equivalent over-broad paths are either absent or remediated.

10. Capture post-change evidence and publish containment update.
Expected result: Before/after traceability and documented containment status.

## Technical checks by layer
### SharePoint and content layer
- Unique permissions vs inherited permissions on target scope
- Broken inheritance points introduced in rollout window
- ACL deltas compared to last known-good state

### Identity layer (Entra)
- Group membership changes during incident window
- Nested group expansion and unintended inclusions
- Privileged or broad security groups mapped to sensitive scopes

### Change layer
- Permission template revisions
- Rollout jobs/scripts touching ACLs or group mapping
- CAB/change record timeline alignment with first incident timestamp

## Verification gates
All must pass before de-escalation:
1. Reporter and exposed cohorts have no unauthorized path.
2. Authorized matter-team access is preserved.
3. No new unauthorized access events detected in monitoring window.
4. Legal/Compliance/DPO acknowledge containment status.

## Rollback (if legitimate users lose access)
1. Pause additional permission changes.
2. Restore last known-good ACL template for impacted scope.
3. Reapply approved least-privilege mapping from pre-approved matrix.
4. Retest authorized and unauthorized control accounts.
5. Re-approve adjusted change set before resuming rollout.

Expected rollback outcome: Legitimate access restored with unauthorized exposure still blocked.

## Escalate to L3 when
- Unauthorized path cannot be isolated at L2.
- Blast radius spans multiple matters/groups.
- Template-level or systemic permission-model correction is required.
- Conflicting controls create trade-off between containment and business continuity.

## Evidence package for closure/RCA
- Incident timeline (detect, contain, remediate, verify)
- Pre/post ACL and inheritance snapshots
- Pre/post group membership snapshots
- Audit extracts (access, permission-change, membership-change)
- Test-account validation outcomes
- Governance approvals and communication milestones

## Common L2 errors to avoid
- Treating issue as Copilot feature defect before permission analysis
- Bulk permission edits without pre-change evidence capture
- Breaking legitimate matter-team access during emergency scope reduction
- Delaying legal/compliance updates pending perfect technical certainty
