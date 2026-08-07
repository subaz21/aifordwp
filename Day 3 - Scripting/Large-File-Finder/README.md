# Large File Finder (PowerShell 5.1)

## Overview

Large-File-Finder.ps1 is a read-only auditing script for DWP engineers.

It recursively scans a target path and reports files larger than a specified threshold.

Default threshold:
1. 100 MB

## What the script does

1. Validates input path and threshold.
2. Recursively reads file metadata using Get-ChildItem.
3. Filters files where size is greater than or equal to threshold.
4. Sorts results by size descending.
5. Prints a detailed report.
6. Prints summary counts and skipped errors.

## Read-only assurance

This script does not change system state.

It does not:
1. Modify files or folders
2. Change permissions
3. Update registry
4. Start or stop service
5. Install or remove software

It only reads file system metadata.

## Parameters

1. ThresholdMB
- Type: Integer
- Default: 100
- Meaning: Minimum file size in MB to include in report

2. ScanPath
- Type: String
- Default: C:\
- Meaning: Root path to scan recursively

## Requirements

1. Windows PowerShell 5.1
2. Read access to the target path
3. Enough time for recursive scanning (can be long on C:\)

## Verify before running

1. Confirm you are in Windows PowerShell 5.1.
2. Confirm the scan path exists and is reachable.
3. Confirm the threshold is appropriate for your use case.
4. Expect access-denied errors on protected folders; script skips and counts them.
5. Large scans can consume time and disk I/O for enumeration only.

## Usage

Open PowerShell and change to script folder:

```powershell
cd "C:\Users\labuser\Documents\Training\Day 3 - Scripting\Large-File-Finder"
```

Run with defaults:

```powershell
.\Large-File-Finder.ps1
```

Run with custom threshold:

```powershell
.\Large-File-Finder.ps1 -ThresholdMB 250
```

Run with custom path and threshold:

```powershell
.\Large-File-Finder.ps1 -ScanPath "C:\Users" -ThresholdMB 50
```

## Understanding output

Large File Report columns:
1. Size: Human-readable size
2. SizeBytes: Exact size in bytes
3. FullName: Full file path
4. LastWriteTime: Last modification time

Summary section:
1. Large files found: Count of matching files
2. Total size (large only): Combined size of matching files
3. Skipped errors: Number of inaccessible/error items

## Performance notes

1. Scanning C:\ can take a long time.
2. Network paths can be slower and may disconnect.
3. Lower thresholds produce bigger outputs.

## Troubleshooting

1. Error: Scan path does not exist
- Check the ScanPath value and spelling.

2. Few or no results
- Lower ThresholdMB and scan again.

3. Many skipped errors
- Run in a context with broader read access if permitted.

4. Slow execution
- Limit scan to a smaller path such as C:\Users or a project folder.
