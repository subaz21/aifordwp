# FinBridge Floor 6 (Legal) Monday Incident: Audience Communications

Date: 2026-08-14
Related: [FinBridge-Floor6-Legal-Monday-Incident-Analysis-2026-08-14.md](FinBridge-Floor6-Legal-Monday-Incident-Analysis-2026-08-14.md), [FinBridge-Floor6-Legal-Monday-Incident-Immediate-Actions-2026-08-14.md](FinBridge-Floor6-Legal-Monday-Incident-Immediate-Actions-2026-08-14.md)

## Audience 1 - Partners / Executive update (send before lunch)
This morning some Floor 6 staff had trouble logging in or logging in quickly, following Friday's rollout of the new document management system. IT identified and corrected the likely cause and is restoring access now. Separately, one paralegal briefly saw a client matter she should not have had access to. We treated this as a priority: her access to that matter has already been removed, we have preserved a full record of who had access and when, and Legal/Compliance has been engaged to assess any impact. We are checking whether anyone else was similarly affected. No client data is known to have left the firm. We will confirm the full picture and next steps by end of day.

## Audience 2 - Floor 6 (Legal) team update
Some of you had trouble logging in this morning, and a few of you lost desktop shortcuts - both are linked to Friday's new document system rollout, and IT is fixing them now. If you still can't log in, try signing out, waiting a minute, and signing back in once; if that doesn't work, log a ticket rather than retrying repeatedly. Missing shortcuts are cosmetic and will be restored - you can recreate them yourself in the meantime if you need to. Important: if you ever see a document or matter in Copilot or elsewhere that you don't think you should have access to, stop, don't open it, and report it to IT or Compliance straight away. Contact the service desk with any questions.

## Audience 3 - Engineer-to-engineer internal note
Incident: FinBridge Floor 6 (Legal), 45 users, 2026-08-14 09:14 report, three concurrent symptom clusters following Friday PM deployment of a new document management app to the Legal-Win11 device group.

Root cause: Not yet confirmed - see Analysis doc for the 5 ranked hypotheses. Working theory is weekend profile re-provisioning (login + shortcuts) and a Friday permission/group change tied to the app rollout (Copilot exposure), pending evidence.

Exact action taken:
- Pulled/preserving audit trail on the client matter library before any permission change.
- Removed the paralegal's access path to the out-of-scope matter; reviewing group membership for blast radius.
- Not disabling Copilot as a fix - permission is the fault, Copilot only surfaced it (consistent with prior FinBridge ticket-triage case #6 pattern).
- Change freeze on further DMS rollout to other floors pending root cause.

Config and event details to pull (not yet collected):
- Entra sign-in logs + error codes for affected users.
- Intune compliance report for Legal-Win11 device group, Friday-to-Monday state changes.
- Win32 app deployment/detection script for the DMS app (desktop/Start layout writes, profile impact).
- SharePoint/Entra audit log for group or permission changes in the Friday deployment window.
- Local profile folder comparison on a sample of affected devices.

Verification (pending):
- Sign-in success restored and error codes clear for affected users.
- Confirmed no other users hold the same excess access.
- Legal/Compliance sign-off on the exposure assessment.

Preventive action required:
- Add a permissions/access-scope review gate to the DMS deployment/change process before any future floor rollout, consistent with the existing Copilot oversharing risk plan (Phase 0 control hardening pattern).
- Add a post-deployment health/permissions check window (first few hours) for app rollouts to this fleet, not just installer success/failure.
- Confirm profile-handling behavior of Intune-deployed apps before fleet-wide push, given this is now a repeat theme (slow login/missing shortcuts already flagged fleet-wide from the Win11 migration).
