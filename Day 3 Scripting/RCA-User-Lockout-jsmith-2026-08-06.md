# Root Cause Analysis (RCA)

## Incident Summary
- Incident type: User account lockout
- User: jsmith
- Time window reviewed: 08:02:14 to 08:23:44 (approximately 22 minutes)
- Impact: User unable to sign in/unlock until administrative intervention
- System involved: DESKTOP-FB001

## Scope and Data Reviewed
- Windows Security Event Log entries provided for Event IDs 4625, 4740, 4722, and 4624.
- Source host referenced in failed attempts and lockout trigger: DESKTOP-FB001.

## Event ID Explanations

### Event ID 4625 (Audit Failure)
Records a failed logon attempt. It captures the attempted account name, failure reason, logon type, and source machine/process context.
- In this case, 4625 appears with:
  - Failure reason: Unknown username or bad password (interactive sign-in attempts)
  - Failure reason: Account locked out (unlock attempt after lockout)

### Event ID 4740 (Audit Failure)
Records that an account has been locked out by the domain or local account lockout policy. It includes the account and the calling computer that submitted the bad authentication attempts.
- In this case, account jsmith was locked out and the calling computer is DESKTOP-FB001.

### Event ID 4722 (Audit Success)
Records that a user account was enabled (or re-enabled) by an administrator/security principal.
- In this case, FINBRIDGE\helpdesk-admin enabled jsmith.

### Event ID 4624 (Audit Success)
Records a successful logon event and includes logon type and account context.
- In this case, jsmith successfully performed an interactive logon (type 2) after admin action.

## Reconstructed Sequence of Events (Plain English)
1. At 08:02:14, jsmith attempted an interactive sign-in on DESKTOP-FB001 and entered invalid credentials (4625).
2. At 08:04:22, a second interactive sign-in attempt from the same machine also failed for bad username/password (4625).
3. At 08:06:01, lockout policy threshold was reached and jsmith was locked out, with DESKTOP-FB001 identified as the caller (4740).
4. At 08:07:45, an unlock attempt was made, but failed because the account was already locked (4625, logon type 7 Unlock).
5. At 08:22:10, helpdesk admin FINBRIDGE\helpdesk-admin re-enabled the account (4722).
6. At 08:23:44, jsmith logged on successfully interactively (4624), confirming restored access.

## Most Likely Cause of Lockout
The most likely cause is repeated invalid credential entry by the user on DESKTOP-FB001, triggering the configured lockout threshold.

### Evidence
- Two consecutive bad-password interactive failures for jsmith from DESKTOP-FB001 before lockout:
  - 08:02:14 (4625, bad username/password)
  - 08:04:22 (4625, bad username/password)
- Direct lockout event tied to same account and calling computer:
  - 08:06:01 (4740, called from DESKTOP-FB001)
- Post-lockout failure reason explicitly states account lockout:
  - 08:07:45 (4625, account locked out, logon type 7)
- Successful logon after admin intervention:
  - 08:23:44 (4624)

## 5 Whys Analysis

### Problem Statement
User jsmith was locked out and unable to access their machine until helpdesk intervention.

1. Why was jsmith unable to access the machine?
- Because the account became locked under security policy (event 4740).

2. Why did the account become locked?
- Because repeated failed authentication attempts occurred within the lockout observation window (events 4625).

3. Why were authentication attempts failing?
- The credential entered at sign-in was invalid (failure reason: unknown username or bad password).

4. Why did attempts continue after failed sign-ins?
- The user retried sign-in/unlock without first correcting credentials, culminating in threshold breach and then a failed unlock while locked (4625 logon type 7).

5. Why did recovery require helpdesk?
- Administrative action was needed to re-enable account access in this environment (event 4722 by FINBRIDGE\helpdesk-admin).

## Root Cause
Primary root cause: Invalid credential retries at the endpoint DESKTOP-FB001 exceeded lockout threshold.

## Contributing Factors
- Account lockout policy sensitivity (threshold/observation window).
- User behavior during unlock attempts after lockout.
- No evidence in provided data of external attack source; all attempts point to DESKTOP-FB001.

## Corrective Actions Taken
- Helpdesk admin re-enabled account (event 4722).
- User successfully logged on afterward (event 4624).

## Preventive Actions Recommended
1. User guidance: Confirm username format and reset password promptly after repeated failures.
2. Endpoint checks: Verify no stale cached credentials in mapped drives, scheduled tasks, services, or credential manager entries.
3. Monitoring: Alert on 4625 burst patterns from a single endpoint before 4740 threshold is hit.
4. Policy review: Confirm lockout threshold balances security and usability.
5. Runbook update: Add quick triage steps for 4625 -> 4740 -> 4722 sequence.

## Confidence and Limitations
- Confidence in immediate cause: High.
- Limitation: Only a short event subset was provided; full Security log correlation (process, source network address, workstation unlock patterns) would further validate whether failures were purely manual versus background credential replay.

## Appendix: Timeline Table
| Time | Event ID | Outcome | Key Detail |
|---|---:|---|---|
| 08:02:14 | 4625 | Failed logon | Bad username/password, logon type 2, source DESKTOP-FB001 |
| 08:04:22 | 4625 | Failed logon | Bad username/password, logon type 2, source DESKTOP-FB001 |
| 08:06:01 | 4740 | Account lockout | Account locked, called from DESKTOP-FB001 |
| 08:07:45 | 4625 | Failed unlock | Account locked out, logon type 7 |
| 08:22:10 | 4722 | Account enabled | Action by FINBRIDGE\helpdesk-admin |
| 08:23:44 | 4624 | Successful logon | Interactive logon type 2 |
