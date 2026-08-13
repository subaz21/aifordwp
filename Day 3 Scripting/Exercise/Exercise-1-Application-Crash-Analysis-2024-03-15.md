# Exercise 1 - Application Crash Analysis

Date analyzed: 2026-08-07
Exercise source: Day 4 - Analysis, RCA and Git push/Exercise.md

## Prompt Used
You are a DWP analyst working on an application crash issue. Below are the relevant Application log entries from a Windows 11 endpoint where the crash occurs repeatedly.
Tasks:
1. Identify the distinct exception or error patterns, event IDs, and crash signatures present.
2. Provide a ranked remediation plan (most likely fix first) with specific validation checks for each step.
3. Treat all event details as given.
4. If uncertain about any interpretation, state uncertainty instead of guessing.
5. Mark anything that should be verified against Microsoft documentation.
6. Provide a concise analysis summary and a preliminary root cause statement.

## Input Log Highlights
- Event ID 1000 (Application Error) repeats for OUTLOOK.EXE.
- Faulting module: KERNELBASE.dll with same offset across crashes.
- Exception code: 0xc0000005.
- Event ID 1001 (WER): APPCRASH bucket recorded.
- Event ID 1026 (.NET Runtime): unhandled System.AccessViolationException.

## Analysis Output

### Distinct patterns and signatures
1. Repeated deterministic crash signature:
- Same process: OUTLOOK.EXE
- Same module: KERNELBASE.dll
- Same exception code: 0xc0000005
- Same fault offset: 0x000000000003a4b2

2. Telemetry consistency:
- WER 1001 confirms APPCRASH bucket generation.
- .NET Runtime 1026 confirms the process terminated due to unhandled access violation.

3. Interpretation note:
- KERNELBASE.dll is often the crash boundary, not always the true originating component.
- This should be verified against call stack or dump evidence.

### Ranked remediation plan with specific checks
1. Isolate Outlook add-ins first (most likely)
- Launch Outlook in safe mode.
- If stable, disable all COM add-ins and re-enable one-by-one.
- Check: crash no longer reproduces after disabling the offending add-in.

2. Repair Office installation integrity
- Confirm build 16.0.17126.20132 aligns with approved channel.
- Run Quick Repair, then Online Repair if needed.
- Check: no new Event ID 1000 entries for OUTLOOK.EXE after repair.

3. Validate Outlook profile and local cache
- Create a new Outlook profile and retest.
- Rebuild OST if profile-specific corruption is suspected.
- Check: crash follows old profile only, not the new one.

4. Validate OS component health
- Run SFC and DISM health restore.
- Check: no integrity violations remain; no repeated crash pattern afterward.

5. Correlate fault bucket
- Review WER bucket 1847362910 for known advisories or fixes.
- Check: determine whether a known issue or patch maps to this bucket.

### Items to verify against Microsoft documentation
- Exact mapping of fault bucket 1847362910.
- Known Outlook and Office build-specific crash advisories for this version.
- Recommended diagnostic sequence for repeated 0xc0000005 in Outlook.

## Preliminary root cause statement
Most likely cause is an Outlook memory access violation triggered by add-in or profile interaction, surfaced at KERNELBASE.dll with unhandled exception termination.
