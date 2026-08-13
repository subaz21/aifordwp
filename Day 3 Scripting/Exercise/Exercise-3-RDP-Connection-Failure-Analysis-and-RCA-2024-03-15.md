# Exercise 3 - RDP Connection Failure Analysis and RCA

Date analyzed: 2026-08-07
Exercise source: Day 4 - Analysis, RCA and Git push/Exercise.md
User: FINBRIDGE\\bwalker
Source IP: 10.10.5.44

## Prompt Used
You are a DWP analyst reviewing an RDP access incident. Below are relevant System and Security log entries for a window in which a user failed to connect, was locked out, and later successfully signed in.
Tasks:
1. For each event ID, explain what it records.
2. Reconstruct the sequence of events in plain English.
3. Identify the most likely cause of the incident with evidence from the events.
4. Create a detailed RCA with 5 Why analysis.
5. Provide corrective actions, preventive actions, and validation checks.
6. Treat all event data as given.
7. If uncertain about any interpretation, state uncertainty instead of guessing.
8. Mark anything that should be verified against Microsoft documentation.

## Analysis Output

### Event ID explanations
- 56 (TermDD): RDP transport or security protocol stream issue caused disconnect.
- 140 (RdpCoreTS): Authentication failed due to incorrect username or password.
- 4625 (Security): Failed sign-in attempt, logon type 10 (RemoteInteractive).
- 4740 (Security): Account lockout triggered after failed authentication threshold.
- 131 (RdpCoreTS): New TCP connection accepted by server.
- 4624 (Security): Successful sign-in, logon type 10.

### Reconstructed sequence in plain English
1. Initial RDP session attempts from 10.10.5.44 encountered authentication failure.
2. Security logs captured repeated failed remote-interactive sign-ins for the same user.
3. Immediately after repeated failures, the account was locked out.
4. Later, a fresh TCP connection was accepted from the same source IP.
5. A successful remote-interactive sign-in then occurred, indicating recovery after lockout and credential correction.

### Most likely cause with evidence
Most likely cause:
- Repeated incorrect credentials entered for FINBRIDGE\\bwalker from client 10.10.5.44, triggering lockout policy.

Evidence:
- Multiple 4625 events with bad password reason.
- 4740 lockout follows directly after repeated failures.
- 4624 success later confirms access works once account state and credentials are corrected.

## RCA Output

### Incident summary
- Impact: user could not access RDP during lockout window.
- Scope: single user account from one source IP.
- Recovery: successful login achieved after lockout interval or admin intervention.

### 5 Why analysis
1. Why could the user not connect by RDP?
- Authentication attempts failed repeatedly.

2. Why did authentication fail repeatedly?
- Incorrect credentials were submitted from the client.

3. Why did repeated failures become an outage?
- Account lockout policy threshold was reached.

4. Why was lockout not avoided after initial failures?
- No early correction of username format, password, keyboard layout, or saved credentials.

5. Why did this require incident handling?
- Lockout enforcement blocked access until account status and credentials were restored.

### Root cause
Immediate cause:
- Repeated invalid RDP credentials from 10.10.5.44 led to account lockout.
Contributing cause:
- Lack of early failed-logon intervention and credential hygiene checks on the client.

### Corrective actions
1. Clear saved credentials on source client and re-enter verified credentials.
2. Verify username format and keyboard layout before retries.
3. Unlock account through approved helpdesk workflow when threshold is reached.

### Preventive actions
1. Add alerting for clustered 4625 failures before 4740 lockout.
2. Provide user guidance for RDP credential entry and lockout avoidance.
3. Review lockout threshold settings versus operational needs.

### Validation checks
1. No new 4625 entries for same user and source IP during next attempts.
2. Successful 4624 logon type 10 without preceding failures.
3. No recurring lockout event 4740 for this pattern.

### Items to verify against Microsoft documentation
- Interpretation details for TermDD 56 versus authentication-only failures.
- Recommended thresholds for account lockout policy in enterprise environments.
