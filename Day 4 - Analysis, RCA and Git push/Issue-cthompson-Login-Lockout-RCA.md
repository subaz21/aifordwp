# Root Cause Analysis Report
## User Login Failure - FINBRIDGE\cthompson

Report Date: 2026-08-07  
Incident Date: 2024-03-15  
Incident ID: INC-CTHOMPSON-20240315-01  
Severity: Medium (single-user impact)  
Status: Resolved  
Resolution Time: Approximately 29 minutes from first observed failure sequence (08:40-09:09)

---

## Executive Summary

User FINBRIDGE\cthompson was unable to log in starting around 08:40. Security event logs show multiple wrong-password authentication failures from the primary workstation (DESKTOP-FB022), followed by account lockout. After lockout, additional wrong-password Kerberos pre-authentication attempts continued from a different source IP (10.10.8.112), indicating a secondary endpoint/session/service retrying stale credentials.

The issue was resolved at 09:09 after account state restoration and credential-path cleanup actions. Verification shows successful interactive logon and no further user-reported issues.

Root cause determined:
- Repeated bad-password attempts, including retries from an additional source with stale credentials, triggered account lockout and blocked user logon.

---

## Scope and Impact

- Affected user: FINBRIDGE\cthompson
- Affected systems: DESKTOP-FB022 and an additional source at 10.10.8.112
- User impact: Inability to sign in during incident window
- Wider impact: No evidence of multi-user or platform-wide outage

---

## Supporting Evidence

### Primary Failure Evidence

1. 08:44:01 - Event 4776 (Audit Failure)
- Domain controller attempted credential validation
- Error Code: 0xC000006A (wrong password)
- Source workstation: DESKTOP-FB022

2. 08:44:03 - Event 4625 (Audit Failure)
- Logon failure: Unknown user name or bad password
- Logon type: 2 (Interactive)
- Source: DESKTOP-FB022

3. 08:44:28 - Event 4625 (Audit Failure)
- Logon failure: Unknown user name or bad password
- Logon type: 2 (Interactive)
- Source: DESKTOP-FB022

4. 08:44:55 - Event 4625 (Audit Failure)
- Logon failure: Unknown user name or bad password
- Logon type: 2 (Interactive)
- Source: DESKTOP-FB022

5. 08:44:56 - Event 4740 (Audit Failure)
- Account locked out
- Account: FINBRIDGE\cthompson
- Caller computer: DESKTOP-FB022

6. 08:45:10 - Event 4625 (Audit Failure)
- Logon failure reason: Account locked out
- Logon type: 7 (Unlock attempt)
- Source: DESKTOP-FB022

### Secondary Source Retry Evidence

7. 08:45:44 - Event 4771 (Audit Failure)
- Kerberos pre-authentication failed
- Failure code: 0x18 (wrong password)
- Source IP: 10.10.8.112

8. 08:46:01 - Event 4771 (Audit Failure)
- Kerberos pre-authentication failed
- Failure code: 0x18 (wrong password)
- Source IP: 10.10.8.112

9. 08:46:33 - Event 4771 (Audit Failure)
- Kerberos pre-authentication failed
- Failure code: 0x18 (wrong password)
- Source IP: 10.10.8.112

Interpretation:
- Source IP 10.10.8.112 differs from DESKTOP-FB022 (10.10.1.88), proving at least one additional source was retrying invalid credentials.

### Recovery Verification Evidence

10. 09:08:14 - Event 4722 (Audit Success)
- User account enabled
- Account: FINBRIDGE\cthompson
- Performed by: FINBRIDGE\helpdesk-admin

11. 09:09:01 - Event 4624 (Audit Success)
- Successful interactive logon
- Account: FINBRIDGE\cthompson
- Logon type: 2 (Interactive)
- Source: DESKTOP-FB022

Validation outcome:
- User successfully logged in at 09:09.
- No post-resolution issues reported by user.

---

## Incident Timeline

| Time | Event | Evidence | Meaning |
|---|---|---|---|
| ~08:40 | User unable to log in begins | Scope statement | Incident start window |
| 08:44:01 | Credential validation fails | Event 4776, 0xC000006A | Wrong password in auth path |
| 08:44:03 | Interactive logon fail #1 | Event 4625 Type 2 | User logon blocked |
| 08:44:28 | Interactive logon fail #2 | Event 4625 Type 2 | Repeated bad credentials |
| 08:44:55 | Interactive logon fail #3 | Event 4625 Type 2 | Lockout threshold approached |
| 08:44:56 | Account locked | Event 4740 | Access blocked by policy |
| 08:45:10 | Unlock attempt fails | Event 4625 Type 7 | Lockout condition confirmed |
| 08:45:44 | Kerberos fail from 10.10.8.112 | Event 4771, 0x18 | Secondary stale credential source |
| 08:46:01 | Kerberos fail from 10.10.8.112 | Event 4771, 0x18 | Ongoing retries continue |
| 08:46:33 | Kerberos fail from 10.10.8.112 | Event 4771, 0x18 | Persistent retry loop |
| 09:08:14 | Account enabled by helpdesk | Event 4722 | Account state restored |
| 09:09:01 | Successful interactive logon | Event 4624 Type 2 | Service restored |
| 09:09+ | User confirms no issues | User verification | Incident resolved |

---

## Root Cause Statement

The login failure was caused by account lockout triggered by repeated wrong-password attempts, with continued authentication retries from an additional source (10.10.8.112) using stale credentials. This combination sustained the failure condition until account state and credential paths were corrected.

---

## 5 Whys Analysis

Why 1: Why could cthompson not log in?
- Because the account was locked out.
- Evidence: Event 4740 at 08:44:56 and Event 4625 at 08:45:10 (account locked out).

Why 2: Why was the account locked out?
- Because multiple wrong-password attempts were submitted in a short period.
- Evidence: Event 4776 at 08:44:01 (0xC000006A) and Event 4625 at 08:44:03, 08:44:28, 08:44:55.

Why 3: Why did wrong-password attempts continue?
- Because at least one additional source continued pre-auth attempts with invalid credentials.
- Evidence: Event 4771 at 08:45:44, 08:46:01, 08:46:33 from 10.10.8.112.

Why 4: Why was an additional source using invalid credentials?
- Because stale stored credentials persisted in a secondary endpoint/session/service credential store.
- Evidence: Repeated 4771 (0x18 wrong password) from non-primary source after lockout.

Why 5: Why were stale credentials not prevented or detected earlier?
- Because credential hygiene and lockout triage controls were insufficient (no proactive stale-credential detection for user-linked service/session retries).
- Evidence: Repeated post-lockout failures from secondary source before remediation.

Systemic cause:
- Gaps in credential lifecycle hygiene and early lockout-source correlation allowed stale credentials to repeatedly trigger authentication failures.

---

## Resolution Actions Performed

1. Identified and confirmed lockout and wrong-password pattern from security logs.
2. Investigated secondary retry source (10.10.8.112) as contributor to persistent failures.
3. Restored account state (Event 4722 at 09:08:14).
4. Applied credential-path correction actions to stop stale retries.
5. Verified successful user sign-in (Event 4624 at 09:09:01) and user confirmation of normal operation.

---

## Preventive Actions

### Immediate (0-7 days)

1. Standard lockout triage checklist
- Require rapid correlation of Event 4740 with preceding 4776/4625/4771 by account and source.
- Owner: Service Desk Lead
- Success metric: Initial source isolation completed within 15 minutes for similar incidents.

2. Secondary source hunt on lockout
- During every single-user lockout, check for non-primary IP/source retry patterns.
- Owner: IAM Operations
- Success metric: 100% of lockout cases include source inventory notes.

3. User credential reset protocol
- After unlock/reset, enforce update on all active clients (desktop, mobile, VPN, mail profiles).
- Owner: End User Support
- Success metric: No repeat lockout within 24 hours after restore.

### Near Term (7-30 days)

4. Service/task account usage control
- Audit scheduled tasks/services running as personal user accounts; migrate to managed service accounts where feasible.
- Owner: Platform Engineering
- Success metric: 80% reduction in user-account-based scheduled task usage.

5. Monitoring and alerting
- Add SIEM alert for repeated Event 4771 (0x18) from multiple sources for one account in 10 minutes.
- Owner: SOC Engineering
- Success metric: Alert fires in test scenario and links source IP list.

### Long Term (30-90 days)

6. Credential hygiene awareness
- Publish user and support guidance on saved credentials after password changes.
- Owner: IT Service Management
- Success metric: Reduced monthly repeat lockout incidents.

7. Runbook hardening
- Update incident runbook with lockout decision tree and verification checkpoints.
- Owner: Major Incident Manager
- Success metric: Runbook adopted and referenced in 100% of relevant incidents.

---

## Closure and Verification

- Technical restoration confirmed by Event 4624 at 09:09:01 for FINBRIDGE\cthompson on DESKTOP-FB022.
- Account state restoration confirmed by Event 4722 at 09:08:14.
- User reported successful login and no remaining issue.
- Incident status: Closed as Resolved.

---

## Lessons Learned

| Lesson | Impact | Action |
|---|---|---|
| Stale credentials from secondary sources can repeatedly trigger lockout even after user retries stop | High | Add mandatory secondary-source check during lockout triage |
| Event correlation across 4776, 4625, 4740, and 4771 quickly narrows root cause | High | Standardize event-correlation checklist in Service Desk playbook |
| Account recovery is incomplete until background retry sources are cleared | High | Enforce post-unlock credential hygiene on all user endpoints and apps |
| Source-IP differential evidence is decisive in single-user incidents | Medium | Capture source host/IP mapping as required evidence in incident closure |
