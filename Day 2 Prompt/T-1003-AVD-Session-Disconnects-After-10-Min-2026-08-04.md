# Ticket T-1003 - AVD Session Disconnects After About 10 Minutes

## Summary (one line)
AVD session disconnects after roughly 10 minutes and reconnects, suggesting a potential network path, session policy, or client stability condition (to-verify).

## Impact (who/how many/business urgency)
- Who: User(s) relying on AVD for primary desktop access (to-verify).
- How many: At least one reported user; possible wider impact if linked to host pool, policy, or site network conditions (to-verify).
- Business urgency: Medium to high due to interruption of active work sessions and productivity loss.

## Known Facts
- Ticket reference: T-1003.
- Reported behavior: Session disconnects around 10 minutes, then reconnects.
- Service context: Azure Virtual Desktop.
- No confirmed error code or disconnect reason provided.

## Missing Information to Gather
- Whether disconnect timing is consistent or variable.
- Whether issue affects one user, one site, or multiple users.
- Whether issue occurs across different networks or devices.
- AVD client type and version in use (to-verify).
- Whether reconnect resumes same session state or starts a new session (to-verify).
- Whether there were recent changes to session timeout or conditional access policies (to-verify).

## Likely Catagory
AVD / Session Stability / Connectivity (to-verify).

## First Diagnostic Step
Check approved AVD monitoring and session diagnostics for the affected user timeframe to identify whether disconnects originate from client/network interruption or host/session policy enforcement (to-verify).