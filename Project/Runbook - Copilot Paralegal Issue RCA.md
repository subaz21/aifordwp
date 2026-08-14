# Runbook - Copilot Paralegal Issue RCA (DWP)

## Purpose
Provide a repeatable DWP runbook to investigate and remediate incidents where Microsoft 365 Copilot reveals client matter content to a user who should not have access, and to document root cause with legal/compliance readiness.

## Scope
- Potential unauthorized access to matter content surfaced through Copilot
- SharePoint/OneDrive/document-management permission inheritance issues
- Group membership and access-path drift after rollout/change
- Confidentiality, ethical-wall, and regulatory-risk handling

## Trigger conditions
Start this runbook when any are true:
- User reports seeing matter content they are not authorized to view.
- Access appears outside expected matter team boundaries.
- Timing correlates with recent rollout affecting permissions/group scope.

## Severity and ownership
- Default severity: Sev-1 security/governance incident
- Incident owner: DWP Incident Lead
- Technical owners: M365 Platform, IAM, Document Management Owner
- Governance owners: Legal, Compliance, DPO

## Critical principle
Copilot does not grant new access; it surfaces content available to the signed-in identity. The primary fault domain is permissioning/access path, not Copilot feature enablement.

## Inputs required
- Reporting user and timestamp
- Matter/site/library/object identifiers
- Prompt context and screenshot/evidence
- Recent change records (rollout, permission template, group assignments)

## Data sources
- Effective permissions at site/library/folder/document level
- Group membership and nested group expansion
- SharePoint and Entra audit logs
- Deployment/change logs from the Friday rollout

## Step 1 - Immediate containment (0-15 minutes)
1. Open security incident bridge with Legal/Compliance participation.
2. Remove reporting user's effective access path to affected matter scope.
3. Preserve snapshots before broad cleanup:
   - ACLs
   - Inheritance state
   - Group memberships
4. Restrict incident discussion to need-to-know channels only.

## Step 2 - Validate unauthorized access path (15-45 minutes)
1. Compute reporting user's effective permissions end-to-end:
   - Direct grants
   - Group-based grants
   - Nested group inheritance
2. Identify exactly which principal/path conferred access.
3. Verify whether that path was introduced/expanded in rollout window.

## Decision tree
### Decision A: Unauthorized permission path confirmed?
- If Yes:
  - Maintain Sev-1 and proceed to Step 3A.
- If No:
  - Test alternate explanation (metadata/search context mismatch) but keep high priority until independently validated.

### Decision B: Is scope broader than one user?
- If Yes:
  - Trigger major-incident workflow and executive/legal notification.
  - Proceed to Step 3B blast-radius containment.
- If No:
  - Proceed with targeted remediation and controlled validation.

## Step 3A - Corrective actions (single-path exposure)
1. Remove or narrow offending ACL/group assignment.
2. Validate access removal using independent test account.
3. Reconfirm least-privilege mapping for matter team roles.
4. Document exact change set and approval trail.

## Step 3B - Corrective actions (broad exposure)
1. Identify all principals sharing the same over-broad path.
2. Apply emergency scope reduction to exposed groups.
3. Validate no collateral denial to legitimate matter team members.
4. Stage permanent permission model correction with controlled rollout.

## Step 4 - Blast-radius analysis (45-120 minutes)
- Enumerate all users/groups/service identities with access to affected matter scope.
- Expand high-risk cohorts (paralegals outside matter, contractors, interns).
- Sample-test access across at least three unrelated users.
- Check similar permission template usage on other sensitive matters changed in same window.

## Step 5 - Evidence preservation for RCA/legal
Capture and store:
- ACL and inheritance snapshots (before and after)
- Group membership states with timestamps
- Access, permission-change, and membership-change audit events
- Incident timeline of actions and decision approvals
- Communications record with Legal/Compliance milestones

## Step 6 - Verification gates
Do not close until all pass:
- Unauthorized access path removed for reporting user and exposed cohorts.
- No equivalent over-broad access paths remain on affected matter scope.
- Legal/Compliance/DPO acknowledge containment state.
- Monitoring window completes with no repeat reports.

## Preventive controls
- Introduce pre-deploy permission-impact diff checks for matter libraries.
- Require nested-group expansion review for ethical-wall-sensitive scopes.
- Add automated alerting for sudden access expansion on confidential matter sites.
- Add post-rollout sampling test: unauthorized-role access verification.

## Rollback plan
1. Freeze further permission-template deployments.
2. Revert to last known-good ACL template where safe.
3. Reapply approved least-privilege model by matter role.
4. Validate with legal-approved test matrix before reopening rollout.

## Communications template (internal)
- Incident: Potential unauthorized matter visibility surfaced via Copilot
- Status: Contained or investigating blast radius
- Confirmed fault domain: Permission path or group scope
- Impact: <users/matters potentially exposed>
- Next update: <timestamp>

## Closure criteria
- Root cause confirmed and documented with evidence.
- Permanent fix implemented and validated.
- Preventive controls added to deployment/change process.
- RCA published with legal/compliance sign-off.
