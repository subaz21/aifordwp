# The Copilot Incident

## What it actually is
It is not a Copilot support ticket. Copilot only surfaces content the signed-in account already has permission to see - it does not create access, so if the paralegal saw a client matter she shouldn't have, that access already existed somewhere (a direct grant or, more likely, a group membership left too broad after Friday's rollout). What she experienced is the visible symptom of a real, underlying access-control failure. At a law firm, an unauthorized cross-matter view is a potential ethical-wall breach and client confidentiality exposure - a data-governance/security incident with possible professional-conduct and regulatory implications, not an application defect.

## What you would NOT do
- Close it as "AI weirdness" or a Copilot bug. That treats the symptom as the problem and leaves the real over-permission in place for the next person to trip over.
- Tell the paralegal to "just ignore it" without also removing the access. The exposure stays live until the permission itself is fixed.
- Disable or restrict Copilot for the floor as the fix. That hides the symptom but does nothing about the underlying group/permission fault, and it removes the signal that would show whether the fix worked.
- Sit on it waiting for full root cause analysis before telling anyone. This needs to move to Legal/Compliance/the Data Protection Officer today, in parallel with the technical investigation, not after it.
- Discuss the specific matter name or details in a wide/general channel - that risks spreading the same confidential information further while trying to report it.

## Escalation (two sentences)
A paralegal on Floor 6 was shown content from a client matter in Microsoft 365 Copilot that she should not have access to, most likely due to a permission or group scope left too broad after Friday's document management system rollout; IT has already removed her access path and preserved the audit trail pending review. Given the potential conflicts-of-interest and client confidentiality implications, we need Legal, Compliance, and the Data Protection Officer to assess impact and confirm any required next steps today.

## Escalation Email (next-level team)

Subject: Urgent Escalation - Potential Unauthorized Cross-Matter Access via Existing Permissions (Floor 6)

To: Legal Operations; Information Security; Compliance; Data Protection Officer
Cc: IT Service Desk Lead; M365 Platform Team; Document Management Owner

Hello team,

I am escalating a potential confidentiality incident for immediate review.

Incident summary:
- A paralegal on Floor 6 was shown content from a client matter in Microsoft 365 Copilot that she is not authorized to access.
- Current technical assessment is that Copilot exposed content already reachable through existing permissions (likely over-broad group scope after Friday's rollout), rather than creating new access.

Actions already completed by IT:
- Removed the user's access path to the affected matter.
- Preserved relevant audit logs and timestamps for investigation.
- Opened a technical incident record and started group/ACL validation.

Requested next-level support (today):
- Legal/Compliance: assess ethical wall and confidentiality exposure.
- DPO/Privacy: confirm whether this meets internal or regulatory notification thresholds.
- Security/M365: validate whether other users have equivalent unintended access paths.
- Document Management Owner: verify rollout scope changes and identify rollback/remediation options.

Current risk:
- Potential unauthorized cross-matter visibility with legal, client confidentiality, and regulatory implications if additional over-permissions exist.

Please confirm receipt and assign an incident lead for coordinated response. IT can provide timeline, audit extracts, and affected object IDs immediately.

Regards,
[Your Name]
[Role / Team]
[Contact]
