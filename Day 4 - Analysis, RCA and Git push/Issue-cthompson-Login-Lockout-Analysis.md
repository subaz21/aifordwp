# Login Failure Hypothesis Analysis - cthompson

Date: 2026-08-07  
Analyst: DWP Engineer

## Scope Facts Used
- Symptom: user cthompson not able to login
- Who: cthompson only (single affected user)
- Since: approximately 08:40 this morning
- Change: nil reported

## Ranked Most Likely Causes (Most Probable First)

## 1) Account lockout due to bad password attempts
Why this fits the scope facts:
- Only one user is affected, which strongly points to an account-specific issue rather than platform-wide failure.
- Sudden start time (~08:40) is consistent with lockout threshold being reached after repeated attempts (user typo, stale saved credential, or background device/service retry).
- "No change" aligns with this, because lockouts often happen without any planned change.

Single fastest check:
- Check the identity platform (AD/Azure AD/Entra) for cthompson lockout status and latest sign-in failure reason around 08:40.

## 2) Password expired or account set to require password reset
Why this fits the scope facts:
- Isolated to one user, consistent with user lifecycle/password policy state.
- Can begin suddenly at a specific time if expiry threshold is reached overnight/morning.
- No environmental change is needed for this to occur.

Single fastest check:
- Inspect cthompson account attributes for password expiry/"must change at next logon" and recent failed sign-ins indicating credential state failure.

## 3) User account disabled, restricted, or expired (administrative/account lifecycle action)
Why this fits the scope facts:
- Single-user impact strongly fits account-state problems.
- Onset at a clear time can match scheduled deprovisioning, HR-linked lifecycle action, or accidental admin action.
- "No change" from user perspective can still be true if the change was administrative and not communicated.

Single fastest check:
- Verify current account enabled/disabled/expiry state and audit trail for account-property changes near 08:40.

## 4) MFA or Conditional Access challenge failure affecting only this identity
Why this fits the scope facts:
- Per-user policy evaluation, risk flag, device-compliance requirement, or MFA registration issue can block one user while others continue normally.
- Abrupt onset with no local endpoint change is common when policy/risk state changes in the identity service.
- Scope does not indicate broad impact, so user-targeted access control remains plausible.

Single fastest check:
- Review Entra sign-in logs for cthompson at failure time and read the Conditional Access/MFA result (blocked control vs failed challenge).

## 5) Cached/stored stale credentials from one endpoint causing repeated failed auth
Why this fits the scope facts:
- Single-user failures often come from one endpoint or one profile using outdated saved credentials.
- Can start at a specific time when a service/app resumes retries (for example after network reconnection or startup).
- Fits "no change" because users often do not knowingly update stored credentials.

Single fastest check:
- Test cthompson login from a different known-good device/session (private browser or fresh Windows session) to quickly separate account issue from local credential cache issue.

## Notes
- This is a hypothesis ranking based only on provided scope facts.
- No single root cause is confirmed yet.
- Next step should be to run the five fast checks in order until one is confirmed or ruled out.

## Evidence Assessment Against Incident Event Logs (08:44-09:12)

### 1) Account lockout due to bad password attempts
Judgement: Supports

Why:
- Repeated bad-password validation failures are followed immediately by a lockout event, then a locked-out failure.

Determining events:
- 08:44:01 - Event 4776 - Error 0xC000006A (wrong password)
- 08:44:03 - Event 4625 - bad password
- 08:44:28 - Event 4625 - bad password
- 08:44:55 - Event 4625 - bad password
- 08:44:56 - Event 4740 - account locked out
- 08:45:10 - Event 4625 - failure reason: account locked out

### 2) Password expired or account set to require password reset
Judgement: Contradicts

Why:
- The logged failures indicate wrong password and subsequent lockout rather than password-expired or password-change-required conditions.

Determining events:
- 08:44:01 - Event 4776 - Error 0xC000006A (wrong password)
- 08:45:44 - Event 4771 - Failure code 0x18 (wrong password)
- 08:46:01 - Event 4771 - Failure code 0x18 (wrong password)
- 08:46:33 - Event 4771 - Failure code 0x18 (wrong password)

### 3) User account disabled, restricted, or expired (administrative/account lifecycle action)
Judgement: Contradicts

Why:
- Event sequence shows an active account receiving wrong-password attempts and then being locked out by policy, not disabled/expired-state rejection.

Determining events:
- 08:44:01 - Event 4776 - credential validation attempted, wrong password returned
- 08:44:56 - Event 4740 - account locked out
- 08:45:10 - Event 4625 - failure reason: account locked out

### 4) MFA or Conditional Access challenge failure affecting only this identity
Judgement: Contradicts

Why:
- Failures shown are primary credential failures (wrong password) in Windows security events, not MFA challenge failure or CA policy block outcomes.

Determining events:
- 08:44:01 - Event 4776 - Error 0xC000006A (wrong password)
- 08:45:44 - Event 4771 - Failure code 0x18 (wrong password)
- 08:46:01 - Event 4771 - Failure code 0x18 (wrong password)
- 08:46:33 - Event 4771 - Failure code 0x18 (wrong password)

### 5) Cached/stored stale credentials from one endpoint causing repeated failed auth
Judgement: Supports

Why:
- Additional wrong-password Kerberos failures continue from a different source IP than the user workstation, consistent with stale credentials on another device/session/service retrying.

Determining events:
- 08:45:44 - Event 4771 - Failure code 0x18 (wrong password), Source IP 10.10.8.112
- 08:46:01 - Event 4771 - Failure code 0x18 (wrong password), Source IP 10.10.8.112
- 08:46:33 - Event 4771 - Failure code 0x18 (wrong password), Source IP 10.10.8.112
- Comparison reference: DESKTOP-FB022 interactive failures were from source workstation DESKTOP-FB022 (10.10.1.88)

### Interim Position
- All five hypotheses have been assessed against evidence.
- No single winner is selected yet, per instruction.

## Addendum - Event Detail, Surviving Hypothesis, and Resolution Plan

### A) Incident Event Details (Chronological)
- 08:44:01 - Event 4776 - Domain credential validation failed for FINBRIDGE\cthompson, Error 0xC000006A (wrong password), Source workstation DESKTOP-FB022.
- 08:44:03 - Event 4625 - Interactive logon failure (Type 2), unknown user name or bad password, Source DESKTOP-FB022.
- 08:44:28 - Event 4625 - Interactive logon failure (Type 2), unknown user name or bad password, Source DESKTOP-FB022.
- 08:44:55 - Event 4625 - Interactive logon failure (Type 2), unknown user name or bad password, Source DESKTOP-FB022.
- 08:44:56 - Event 4740 - Account FINBRIDGE\cthompson locked out, caller computer DESKTOP-FB022.
- 08:45:10 - Event 4625 - Unlock attempt failure (Type 7), failure reason: account locked out, Source DESKTOP-FB022.
- 08:45:44 - Event 4771 - Kerberos pre-authentication failed, Failure code 0x18 (wrong password), Source IP 10.10.8.112.
- 08:46:01 - Event 4771 - Kerberos pre-authentication failed, Failure code 0x18 (wrong password), Source IP 10.10.8.112.
- 08:46:33 - Event 4771 - Kerberos pre-authentication failed, Failure code 0x18 (wrong password), Source IP 10.10.8.112.

### B) Surviving Hypothesis After Elimination
Surviving hypothesis:
- Cached/stored stale credentials on an additional source (10.10.8.112) repeatedly attempted authentication with an old/incorrect password, increasing bad-password count and triggering lockout for cthompson.

Why this survives the evidence:
- Wrong password is explicitly recorded (4776/0xC000006A and 4771/0x18).
- Lockout is explicitly recorded (4740) after repeated bad-password failures.
- A second source (10.10.8.112) continues wrong-password attempts after lockout, indicating a background process/device/session separate from DESKTOP-FB022 (10.10.1.88).

### C) Detailed Resolution Steps
1. Immediate containment
- Identify the host mapped to 10.10.8.112 (DHCP/IPAM/DNS/CMDB).
- Stop credential retries from that source: sign out sessions, stop tasks/services running as cthompson, and disconnect persistent auth sessions.

2. Remove stale credentials from all likely stores
- On DESKTOP-FB022 and the 10.10.8.112 host, remove saved entries in Windows Credential Manager.
- Update or clear stored credentials in apps (Outlook/Teams/OneDrive/VPN/legacy clients).
- Review mapped drives, scheduled tasks, and services using cthompson credentials.

3. Recover account access
- Reset cthompson password to a temporary strong value.
- Unlock the account.
- Perform first sign-in on a known-good endpoint.
- Have the user update credentials on all endpoints and mobile clients.

4. Validate recovery success
- Monitor for no further 4771 wrong-password events for cthompson.
- Monitor for no new 4740 lockout events.
- Confirm successful authentication events from expected workstation/session.

5. Prevent recurrence
- Replace personal-user credentials in scheduled tasks/services with managed service accounts where applicable.
- Document source system and retry mechanism in incident record.
- Add lockout triage runbook steps to correlate 4740 with preceding 4776/4771 by account and source.
