Symptom     : Finance users (about 45) could not access shared drives; S: mapping failed across DESKTOP-FB* endpoints.

Cause       : Drive mapping script was migrated to Intune and executed as SYSTEM, causing UNC mapping failure due to missing user-context credentials and early startup dependency timing.

Scope       : All Finance users in OU=Finance were affected during the 2024-03-15 08:00 startup window after prior-night script migration.

Workaround  : Use user-context mapping path (sign out/sign in after corrected deployment), then validate S: assignment and direct access to \\finbridge-fs01\Finance.

Permanent fix: Restore or redesign mapping to run in user context, add Workstation/UNC readiness checks with retry logic, and enforce canary validation for endpoint script migrations.

How to spot it: Look for ScriptRunner SYSTEM context followed by immediate UNC failure and exit code 1, then Event 98 drive-letter assignment warning. In this incident: 08:00:02 SYSTEM context, 08:00:03 UNC/network-name failure, 08:00:04 no retry configured, 08:00:05 Event 7036 Workstation service running, 08:00:06 Event 1500 GP success, 08:00:07 Event 98 S: not assigned.
