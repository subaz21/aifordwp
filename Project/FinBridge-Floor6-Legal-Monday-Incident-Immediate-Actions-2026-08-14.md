# Immediate Actions - FinBridge Floor 6 (Legal) Monday Incident

Date: 2026-08-14
Owner: DWP Engineer / IT Ops
Related: [FinBridge-Floor6-Legal-Monday-Incident-Analysis-2026-08-14.md](FinBridge-Floor6-Legal-Monday-Incident-Analysis-2026-08-14.md)

Priority order below is by risk, not by ticket volume. Do these in order.

## Priority 1 - Contain the data/confidentiality exposure (Copilot client-matter access)

This is treated as a potential conflicts-of-interest / ethical-wall breach, not a routine Copilot ticket. Do not wait for full root cause before containing it.

1. Before changing anything, export the audit trail for the specific matter library/site: who has access today, and any permission/group changes since Friday. This preserves evidence of the exposure window.
2. Identify and remove the paralegal's access path to that matter (direct grant or group membership) immediately.
3. Check for blast radius: identify anyone else who was added to the same group/permission during Friday's rollout, and review whether they can see matters they should not. Lock down proactively rather than waiting for more reports.
4. Do not disable or restrict Copilot tenant-wide or for the floor as a first response - Copilot only reflects existing permissions, so the fix is the permission, not the AI tool. Removing Copilot access alone leaves the underlying over-permissioning in place.
5. Escalate to Legal/Compliance and the Data Protection Officer now, today, before lunch - a client-matter access breach at a law firm may carry professional-conduct and regulatory reporting obligations that IT cannot decide alone.
6. Ask the paralegal directly (once) whether she opened or acted on the matter content, and record the answer - this materially changes the severity assessment Legal/Compliance will need to make.
7. Do not tell the wider floor "the Copilot bug is fixed" - it is not confirmed to be a Copilot fault. Keep the message limited to "the access has been corrected" until permissions review is complete.

## Priority 2 - Restore sign-in for blocked/slow users

1. Pull the list of affected users and their sign-in error codes/timestamps (see Analysis document, Evidence Collection Plan item 1) before applying a fix - do not guess.
2. If the pattern points to Intune compliance/Conditional Access (most likely per current hypotheses), check whether affected devices flipped to Not Compliant since Friday and, for devices confirmed clean, apply a short manual compliance exception while the underlying policy/deployment interaction is fixed - do not disable the compliance policy fleet-wide.
3. Give affected users a single documented workaround to try once (sign out fully, wait, sign back in; restart if that fails) and ask them to stop repeating sign-in attempts and log a ticket instead if it fails twice - repeated retries can worsen lockouts.
4. Assign an engineer to correlate the login failures against the exact Friday deployment window and the Intune compliance report.

## Priority 3 - Missing desktop shortcuts

1. Treat as friction, not blocking - no emergency fix required this morning.
2. Point affected users to self-service guidance (recreate shortcuts / pin apps) while the deployment script is reviewed for the actual cause.
3. Fix at the source (correct the app's install/config script) rather than asking every user to manually recreate shortcuts long-term.

## Cross-cutting actions

1. Freeze further rollout of the new document management app to any other floor until the permission and profile/login mechanisms are understood.
2. Stand up a short incident bridge for Floor 6 given three concurrent symptom clusters and partner-facing sensitivity.
3. Prepare the partner/executive update (see Comms document) before lunch, and do not wait for full RCA to send it - use current-known-facts framing and update again once confirmed.
