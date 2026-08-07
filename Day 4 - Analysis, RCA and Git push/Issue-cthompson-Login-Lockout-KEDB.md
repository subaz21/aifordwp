Symptom     : User FINBRIDGE\cthompson was unable to log in. Authentication attempts failed, then the account was locked out.

Cause       : Repeated wrong-password attempts, including retries from a secondary source (10.10.8.112) using stale stored credentials, triggered account lockout.

Scope       : Impact was limited to one user account (cthompson). Incident window was approximately 08:40 to 09:09 on 2024-03-15. No wider platform impact was observed.

Workaround  : Immediate restore path was to stop background credential retries from secondary source(s), unlock/enable the account, reset password, and clear/update saved credentials on user endpoints and apps.

Permanent fix: Enforce lockout triage correlation (Event 4740 with preceding 4776/4625/4771 by account and source), require secondary-source investigation on single-user lockouts, and add alerting for repeated Event 4771 (0x18) from multiple sources for one account.

How to spot it: Look for Event 4776 with 0xC000006A (wrong password) and repeated Event 4625 failures followed by Event 4740 (account locked out). Then check for continued Event 4771 failures with code 0x18 from a different source than the user's primary workstation. In this incident: 4776 at 08:44:01; 4625 at 08:44:03, 08:44:28, 08:44:55; 4740 at 08:44:56; 4625 (locked out) at 08:45:10; and 4771 at 08:45:44, 08:46:01, 08:46:33 from 10.10.8.112.
