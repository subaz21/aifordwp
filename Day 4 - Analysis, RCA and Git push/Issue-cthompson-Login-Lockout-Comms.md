# cthompson Login Lockout Incident: Audience Communications

## Audience 1 - Non-technical executive
Access has been restored and data remained safe. On 2024-03-15, one user (cthompson) was unable to sign in from about 08:40 to 09:09 due to account lockout triggered by repeated invalid sign-in attempts, including retries from a secondary source with outdated saved credentials. The account was restored, stale credential paths were corrected, and successful sign-in was verified. No broader service impact was identified.

## Audience 2 - Affected end-user team (non-technical)
cthompson access is now restored and data is safe. On 2024-03-15, sign-in failed between about 08:40 and 09:09 because the account was temporarily locked after repeated incorrect credential attempts, including background retries from another saved sign-in source. Support restored the account and cleared the stale credential path, and login was confirmed working. If this reappears, contact Service Desk so we can immediately check for background credential retries.

## Audience 3 - Engineer-to-engineer internal note
Incident: INC-CTHOMPSON-20240315-01, user login lockout, 2024-03-15 08:40-09:09.

Root cause:
- Multiple wrong-password attempts were recorded for FINBRIDGE\cthompson from DESKTOP-FB022.
- Account lockout occurred (Event 4740) after repeated failures.
- Additional Kerberos pre-auth failures continued from secondary source 10.10.8.112 (Event 4771, code 0x18), indicating stale stored credentials outside the primary workstation.

Exact action taken:
- Confirmed bad-password and lockout sequence in Security logs.
- Identified secondary retry source behavior and stopped stale credential retries.
- Restored account state (Event 4722 at 09:08:14 by FINBRIDGE\helpdesk-admin).
- Verified successful interactive login (Event 4624 at 09:09:01 from DESKTOP-FB022).

Config and event details:
- Wrong password indicators: Event 4776 (0xC000006A) and Event 4771 (0x18).
- Lockout indicator: Event 4740.
- Locked account follow-on failure: Event 4625 with reason "Account locked out".
- Primary source: DESKTOP-FB022 (10.10.1.88).
- Secondary retry source: 10.10.8.112.

Verification:
- Account enabled successfully at 09:08:14 (Event 4722).
- User interactive sign-in succeeded at 09:09:01 (Event 4624).
- User confirmed working and no further issue reported.

Preventive action required:
- Enforce lockout triage correlation standard: map Event 4740 to preceding 4776/4625/4771 by account and source.
- Add mandatory secondary-source check for single-user lockouts (identify non-primary IP/workstation retries).
- Strengthen credential hygiene process after reset/unlock (update saved credentials across desktop, mobile, VPN, and apps).
- Add alerting for repeated Event 4771 (0x18) from multiple sources for one account within a short window.
