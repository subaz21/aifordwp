# Shared Drive Access Failure Analysis - Fault-B-Finance-Shared-Drives

Date: 2026-08-07
Analyst: DWP Engineer

## Scope Facts Used
- Symptom: finance users cannot access shared drives
- Who: all finance users (approximately 45 users)
- Since: around 08:00 startup/login window
- Change: drive mapping moved from GPO user logon script to Intune script running as SYSTEM at 23:30 previous night

## Ranked Most Likely Causes (Most Probable First)

## 1) Script context mismatch: mapping script executed as SYSTEM instead of USER
Why this fits the scope facts:
- Incident started immediately after migration from user-context script to SYSTEM-context execution.
- UNC access and user-mapped drives typically depend on user token and user credential context.
- All Finance endpoints were affected, consistent with centralized script behavior.

Single fastest check:
- Check Intune script execution context and confirm script ran as SYSTEM rather than user.

## 2) Startup timing race: script ran before network stack was ready for UNC access
Why this fits the scope facts:
- Script failed at 08:00:03 while Workstation service only entered running state at 08:00:05.
- Early execution can fail UNC path availability checks.

Single fastest check:
- Compare script execution timestamp with Workstation service-ready timestamp on multiple devices.

## 3) File server/share outage or DNS name resolution issue for finbridge-fs01
Why this fits the scope facts:
- Error text includes network name/path not found.
- Could impact all users if server or name resolution failed globally.

Single fastest check:
- Test direct UNC and DNS resolution for finbridge-fs01 from affected and unaffected contexts.

## 4) Drive letter assignment conflict (S: already in use or unavailable)
Why this fits the scope facts:
- NTFS warning indicates S: could not be assigned.
- Could block visibility of mapped drive even if share is reachable.

Single fastest check:
- Query existing drive assignments and mount points for S: on impacted endpoints.

## 5) Finance share permission changes removed access
Why this fits the scope facts:
- Broad user impact could occur if NTFS/share ACL changed for Finance group.
- Users report drive inaccessible rather than app-specific failures.

Single fastest check:
- Validate ACL entries for Finance AD groups on \\finbridge-fs01\Finance.

## Evidence Assessment Against Incident Event Logs

### 1) Script context mismatch: mapping script executed as SYSTEM instead of USER
Judgement: Supports
Why:
- Logs explicitly state SYSTEM execution context and immediate UNC failure.
Determining events:
- 08:00:02 - ScriptRunner Info - Script context: SYSTEM account
- 08:00:03 - ScriptRunner Warning/Error - UNC path not accessible and script failed with network name cannot be found
- Prior change note 2024-03-14 23:30 - migration from GPO user script to Intune SYSTEM script without context handling update

### 2) Startup timing race: script ran before network stack was ready for UNC access
Judgement: Supports
Why:
- Script failure occurs before Workstation service running event on same host.
Determining events:
- 08:00:03 - ScriptRunner failure
- 08:00:05 - Event 7036 - Workstation service entered running state

### 3) File server/share outage or DNS name resolution issue for finbridge-fs01
Judgement: Neutral
Why:
- Network name error appears, but evidence also strongly indicates context/timing issue; no direct proof of server-wide outage.
Determining events:
- 08:00:03 - ScriptRunner Error - Network name cannot be found

### 4) Drive letter assignment conflict (S: already in use or unavailable)
Judgement: Neutral
Why:
- NTFS warning confirms mapping did not assign S:, but this appears downstream of script/UNC failure.
Determining events:
- 08:00:07 - Event 98 - File system could not map drive letter S:

### 5) Finance share permission changes removed access
Judgement: Contradicts
Why:
- Change log points to script execution context issue, and Group Policy processing succeeded; no ACL change evidence provided.
Determining events:
- 08:00:06 - Event 1500 - Group Policy processed successfully
- Prior change note 2024-03-14 23:30 identifies script-context migration as introduced change

### Interim Position
- All five hypotheses have been assessed.
- No winner selected yet.

## Addendum - Event Detail, Surviving Hypothesis, and Resolution Plan

### A) Incident Event Details (Chronological)
- 2024-03-14 23:30 - Change deployed: mapping moved from GPO user logon script to Intune PowerShell script running as SYSTEM.
- 08:00:01 - ScriptRunner Info - Executing Map-FinBridgeDrives.ps1.
- 08:00:02 - ScriptRunner Info - Script context SYSTEM account.
- 08:00:03 - ScriptRunner Warning - \\finbridge-fs01\Finance not accessible from SYSTEM context.
- 08:00:03 - ScriptRunner Error - Script failed (Exit 1, network name cannot be found).
- 08:00:04 - ScriptRunner Info - No retry configured.
- 08:00:05 - Event 7036 - Workstation service entered running state.
- 08:00:06 - Event 1500 - Group Policy processed successfully.
- 08:00:07 - Event 98 - Could not map drive letter S:.

### B) Surviving Hypothesis After Elimination
Surviving hypothesis:
- Drive-mapping mechanism failed because script was moved to SYSTEM context without redesign for user-context credential and network dependency handling, with startup timing aggravating failure.

Why this survives the evidence:
- Explicit SYSTEM context at runtime.
- Explicit UNC failure from SYSTEM context.
- Failure occurs before Workstation service reached running state.
- Change note directly links migration design gap to this behavior.

### C) Detailed Resolution Steps
1. Restore mapping execution to user context (Intune user script, scheduled task at user logon, or revert to GPO logon script).
2. Add prerequisite checks in script (Workstation service running, DNS/UNC reachability) before attempting drive mapping.
3. Add retry logic with bounded backoff (for example 3 attempts with short delay).
4. Ensure idempotent mapping logic handles existing stale mappings and re-map safely.
5. Pilot on small Finance subset, then full rollout.
6. Validate S: mapping and access to \\finbridge-fs01\Finance across representative endpoints.
