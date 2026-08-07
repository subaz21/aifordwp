# Disk Health Reporter (PowerShell 5.1)

## Overview

Disk-Health-Reporter.ps1 is a read-only health and optimization-status reporting script for DWP engineers.

It reports:
1. Physical disk health indicators
2. Logical volume health and free space
3. Scheduled optimization task status
4. Recent optimization-related events
5. Quick risk flags

Important:
1. The script never runs defrag or optimization commands.
2. The script only reads system data.

## Read-only assurance

This script does not change system state.

It does not:
1. Run defrag
2. Run Optimize-Volume
3. Change scheduled tasks
4. Modify registry or files
5. Start or stop services

## Requirements

1. Windows PowerShell 5.1
2. Access to Storage and ScheduledTasks cmdlets
3. Read access to event logs

## Verify before running

1. Run in Windows PowerShell 5.1.
2. Consider running as Administrator for fuller storage/task visibility.
3. Confirm event log access is permitted in your environment.
4. Note that some endpoints may not expose Defrag operational logs.

## Script sections explained

1. Physical Disk Health Summary
- Reads Get-PhysicalDisk and displays health and operational status.

2. Logical Volume Capacity and Health
- Reads Get-Volume and reports file system, free space, and free percentage.

3. Scheduled Optimization Task Status
- Reads \Microsoft\Windows\Defrag\ScheduledDefrag task state and last/next run data.

4. Last Optimization Events
- Reads Microsoft-Windows-Defrag/Operational log for recent optimization evidence.

5. Quick Risk Flags
- Highlights low free space and non-healthy disk/volume status.

## How to run

Open PowerShell in the script folder:

```powershell
cd "C:\Users\labuser\Documents\Training\Day 3 - Scripting\Disk-Health-Reporter"
```

Run the script:

```powershell
.\Disk-Health-Reporter.ps1
```

## Example output interpretation

1. Physical disk status
- Healthy + OK usually indicates no immediate hardware-level issue from this view.

2. Volume free space
- Less than 15 percent free is flagged as a risk in the report.

3. ScheduledDefrag task
- Disabled, repeated failures, or missed runs may indicate optimization drift.

4. Defrag events
- Missing events may mean log disabled or no recent task activity.

## Troubleshooting

1. Get-PhysicalDisk not recognized
- Ensure Storage module/cmdlets are available on the OS edition.

2. Scheduled task not found
- Check if endpoint image has task path \Microsoft\Windows\Defrag\.

3. Event log access denied
- Run with an account that can read Windows event logs.

4. Partial/empty output
- Re-run with elevated PowerShell and confirm endpoint has standard storage providers enabled.

## Operational notes

1. This script is suitable for support triage and evidence gathering.
2. It is not a replacement for vendor storage diagnostics.
3. Use findings with standard DWP incident procedures.
