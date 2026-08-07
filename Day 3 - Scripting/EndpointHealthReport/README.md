# Endpoint Health Report (PowerShell 5.1)

## Overview

`Endpoint-Health-Report.ps1` is a read-only diagnostic script for DWP engineers.

It collects 10 health indicators from a Windows endpoint in a single run and prints a structured console report. An optional `-AsObject` switch returns all data as a single `PSCustomObject` for scripted/pipeline consumption.

---

## Read-only assurance

This script does not change system state. It does not:

- Modify registry values or keys
- Start, stop, or change services
- Install or remove software
- Write to any files or folders
- Change system configuration

The internet speed section streams data into memory only; it does not write any file to disk.

---

## Requirements

1. Windows PowerShell 5.1 (not PowerShell 7+)
2. Read permissions on System event log and hotfix history
3. Outbound HTTPS and DNS access for the speed test (optional; gracefully skipped if unavailable)
4. Microsoft Defender (WinDefend) may not be installed on all endpoints — section handles absence gracefully

---

## Verify before running

1. Confirm you are running Windows PowerShell 5.1.
2. Confirm your account can read the System event log.
3. DNS access to `speed.hetzner.de` or `proof.ovh.net` is needed for section 7 — blocked in some DWP environments.
4. WinDefend service may not exist on all device types.
5. Logged-in user count uses WMI associations; falls back to `quser` if WMI returns no results.

---

## Parameters

| Parameter   | Type   | Default | Description                                       |
|-------------|--------|---------|---------------------------------------------------|
| `-AsObject` | Switch | Off     | Returns all report data as a single PSCustomObject |

---

## How to run

```powershell
cd "C:\Users\labuser\Documents\Training\Day 3 - Scripting\EndpointHealthReport"
```

Standard console report:

```powershell
.\Endpoint-Health-Report.ps1
```

Return structured object (useful for automation or export):

```powershell
$report = .\Endpoint-Health-Report.ps1 -AsObject
$report | ConvertTo-Json -Depth 5
```

---

## Report sections

### 1) System Uptime
- Source: `Win32_OperatingSystem` via CIM
- Reports last boot time and elapsed uptime in days, hours, minutes

### 2) Free Disk Space
- Source: `Win32_LogicalDisk` (fixed drives only, DriveType=3)
- Reports size, free space (GB), and free percentage per drive

### 3) Pending Reboot
- Source: Registry keys and values
- Checks three locations:
  - `HKLM:\...\Component Based Servicing\RebootPending`
  - `HKLM:\...\WindowsUpdate\Auto Update\RebootRequired`
  - `HKLM:\...\Session Manager\PendingFileRenameOperations`
- Reports per-check result and an overall pending flag

### 4) Top 5 Processes by Memory
- Source: `Get-Process`
- Sorted by Working Set (physical RAM in use), descending
- Reports Name, PID, and WorkingSet in MB

### 5) Top 5 Processes by CPU
- Source: `Win32_Process` via CIM (KernelModeTime + UserModeTime)
- Excludes System Idle Process (PID 0)
- Reports cumulative CPU seconds since process start, not instantaneous usage

### 6) Last 5 System Log Errors
- Source: Windows Event Log (`System`, Level 2 = Error)
- Reports TimeCreated, Event ID, Provider, and Message

### 7) Internet Speed
- Source: HTTPS download from `speed.hetzner.de` (fallback: `proof.ovh.net`)
- Samples 1 MB using HTTP Range header; measures download throughput in Mbps
- DNS pre-checked before connection attempt; endpoint skipped if DNS fails

### 8) Microsoft Defender Service Status
- Source: `Get-Service -Name WinDefend`
- Reports service name, status, and whether it is running
- Reports clearly if the service is not installed

### 9) Logged-In Users Count
- Source: `Win32_LogonSession` + `Win32_LoggedOnUser` (logon types 2 and 10)
- Falls back to `quser` output if WMI associations return no results
- Reports unique user count and usernames

### 10) Last Windows Update Installed
- Source: `Get-HotFix`
- Finds the most recently installed hotfix by date
- Reports install date, KB number, and description

---

## -AsObject output structure

When `-AsObject` is used, the returned object has these top-level properties:

| Property               | Description                              |
|------------------------|------------------------------------------|
| `GeneratedAt`          | Timestamp of the run                     |
| `ComputerName`         | Machine name                             |
| `SystemUptime`         | Boot time, days, hours, minutes          |
| `FreeDiskSpace`        | Array of drive objects                   |
| `PendingRebootChecks`  | Array of per-check results               |
| `OverallPendingReboot` | Boolean                                  |
| `TopProcessesByMemory` | Array of top 5 by working set            |
| `TopProcessesByCPU`    | Array of top 5 by CPU seconds            |
| `LastSystemLogErrors`  | Array of last 5 system errors            |
| `InternetSpeed`        | Speed test result or error details       |
| `MicrosoftDefender`    | Service status object                    |
| `LoggedInUsers`        | Count and usernames array                |
| `LastWindowsUpdate`    | Hotfix date, KB ID, description          |

---

## Troubleshooting

| Symptom | Action |
|---|---|
| Speed test warning | Verify DNS and outbound HTTPS to test endpoints |
| Defender section shows not found | Expected on non-standard device types |
| Logged-in count shows 0 | Run elevated; WMI associations may need admin rights |
| Event log section errors | Confirm account has read access to System log |
| Get-HotFix returns nothing | Some update channels do not populate hotfix history |
