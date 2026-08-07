Symptom     : Users logging into AVD session hosts in POOL-FIN-01 saw a black screen after logon. About 60% recovered after around 30 seconds, while the rest were disconnected and had to reconnect.

Cause       : Intel GPU driver module igdumd64.dll version 31.0.101.4146, introduced in the 02:00 image update to POOL-FIN-01, caused dwm.exe to crash with exception 0xc0000005 during DWM initialization.

Scope       : Impact was limited to POOL-FIN-01 after the overnight image update; POOL-FIN-02 remained unaffected. Approximately 40% of POOL-FIN-01 users were affected (~350 of ~875 users) between 07:00 and 10:00.

Workaround  : During the incident window, users could disconnect and reconnect; repeated reconnect attempts allowed sessions to persist in observed cases. Example: mlopez reconnected at 07:03:10 and the session then remained stable.

Permanent fix: The team rolled back POOL-FIN-01 to the known-good pre-update GPU driver baseline from POOL-FIN-02, rebuilt the corrected image, validated on canary hosts, and redeployed to all POOL-FIN-01 hosts. The incident was resolved by 10:00 with zero recurrence during validation.

How to spot it: Look for Event ID 1000 (Application Error) with faulting application dwm.exe and faulting module igdumd64.dll v31.0.101.4146, exception code 0xc0000005 (timestamps observed: 07:02:16, 07:02:46, 07:08:24). Correlate with Event ID 9009 (Desktop Window Manager exited with code 0x40010004 at 07:02:18 and 07:03:01) and session disconnect Event ID 40 after successful logon Event ID 21.
