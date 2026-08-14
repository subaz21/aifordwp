# Escalation Email - L2/L3 Technical Team

Subject: Sev-1 Escalation - Unauthorized Matter Visibility via Existing Permission Path (Copilot Surface)

To: L2 M365 Operations; L3 IAM/Entra Engineering; L3 SharePoint/Document Management Engineering
Cc: DWP Incident Lead; Security Operations; Legal Liaison; Compliance; DPO
Priority: High

Hello L2/L3 Team,

This is a Sev-1 escalation for immediate technical investigation and containment support.

## Executive summary
A paralegal reported seeing content from a client matter she is not authorized to access when using Microsoft 365 Copilot. Current RCA direction indicates this is not a Copilot feature defect; it is most likely an underlying permission-path exposure (direct grant, inherited ACL, or nested group expansion) introduced or widened during the recent rollout window.

## Technical analysis (current)
- Fault domain:
  - Access-control pathing (SharePoint/document-management ACL plus Entra group inheritance), not Copilot entitlement logic.
- Why:
  - Copilot can only surface content available to the signed-in identity.
  - Reported behavior matches unauthorized effective access rather than generation error.
- Leading hypotheses:
  1. Over-broad ACL applied at site/library/folder level.
  2. Nested group membership expansion unintentionally included non-matter users.
  3. Permission template drift during Friday rollout expanded visibility.
  4. Inheritance break/reset changed expected least-privilege boundary.

## Actions already completed
- Incident classified as Sev-1 (security/governance).
- Reporting user's access path was removed to contain immediate exposure.
- Initial evidence preservation initiated:
  - ACL and inheritance snapshots
  - Group membership state capture
  - Audit-log collection for access and permission-change events
- Need-to-know comms controls enforced.

## L2/L3 assistance requested now
1. L2 M365 Operations:
- Pull and share complete effective-permission trace for affected matter scope.
- Confirm all principals with current read access.
- Provide quick delta of ACL state vs last known-good baseline.

2. L3 IAM/Entra Engineering:
- Expand and validate nested group paths granting access.
- Identify recent membership changes in incident window.
- Confirm if affected user cohort extends beyond reporting user.

3. L3 SharePoint/Document Management Engineering:
- Validate inheritance behavior and permission-template integrity post-rollout.
- Identify any rollout job/change that touched affected scope.
- Propose safe corrective model and rollback boundaries.

## Required outputs (time-bound)
- Within 30 minutes:
  - Confirm exact unauthorized access path and whether it is still active for any principal.
- Within 60 minutes:
  - Blast-radius summary (users/groups/matters potentially exposed).
  - Recommended containment change set with risk notes.
- Within 120 minutes:
  - Verified remediation plan and validation checklist for closure gates.

## Evidence package required in updates
- Effective-permission chain from principal to object.
- ACL before/after snapshots and inheritance state.
- Group membership before/after with timestamps.
- Audit events: access, permission change, membership change, rollout actions.

## Risk statement
This is a potential ethical-wall and client-confidentiality exposure. Delayed confirmation or partial containment increases legal, regulatory, and reputational risk.

Please acknowledge receipt, assign technical owners for each stream above, and post first findings to the incident channel immediately.

Regards,
DWP Engineering
Incident Owner: <name>
Incident ID: <id>
