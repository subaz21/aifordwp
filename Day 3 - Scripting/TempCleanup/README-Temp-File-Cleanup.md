# Temp-File-Cleanup.ps1

Safe temp file cleanup script for Windows endpoints (PowerShell 5.1).

## What this script does
- Scans one or more folders for files older than a specified age.
- Skips locked files and keeps running.
- Uses per-file try/catch error handling.
- Logs every action to a timestamped log file.
- Moves files to quarantine (instead of permanent delete) for safe rollback.
- Writes a run manifest to support rollback.
- Prints a summary at the end.

## Script location
- Script: `Temp-File-Cleanup.ps1`
- State folder (default): `TempCleanupState` under the script folder
  - `Logs` for timestamped logs
  - `Quarantine` for moved files
  - `Manifests` for rollback manifests

## Parameters
- `-Paths <string[]>`
  - One or more paths to scan.
  - Default: current user's temp folder (`$env:TEMP`) and `C:\Windows\Temp`.

- `-OlderThanDays <int>`
  - Only process files older than this many days.
  - Default: `0`.

- `-DryRun`
  - Lists files that would be cleaned.
  - No file move/delete is performed.

- `-Rollback`
  - Restores files from quarantine using a manifest.

- `-RunId <string>`
  - In cleanup mode: optional custom run ID.
  - In rollback mode: restore a specific run.
  - If omitted in rollback mode, latest manifest is used.

- `-StateRoot <string>`
  - Optional override for where logs/quarantine/manifests are stored.

## Usage examples
### 1) Dry run on default temp folder
```powershell
.\Temp-File-Cleanup.ps1 -DryRun
```

### 2) Cleanup files older than 7 days in user and Windows temp
```powershell
.\Temp-File-Cleanup.ps1 -Paths "$env:TEMP","C:\Windows\Temp" -OlderThanDays 7
```

### 3) Cleanup with custom state root
```powershell
.\Temp-File-Cleanup.ps1 -OlderThanDays 3 -StateRoot "C:\ProgramData\DWP\TempCleanup"
```

### 4) Rollback latest cleanup run
```powershell
.\Temp-File-Cleanup.ps1 -Rollback
```

### 5) Rollback a specific run
```powershell
.\Temp-File-Cleanup.ps1 -Rollback -RunId "PUT-RUN-ID-HERE"
```

## Idempotency and safety notes
- Running cleanup repeatedly is safe:
  - Already moved files are no longer in the source path.
  - Missing files are skipped and logged.
- Running rollback repeatedly is safe:
  - If original file already exists, restore is skipped and logged.
- Locked files are skipped and logged.
- Errors on one file do not stop the script.

## Operational recommendation
- Run with `-DryRun` first, review log output, then run cleanup.
- Keep manifests until you are sure rollback is no longer required.
