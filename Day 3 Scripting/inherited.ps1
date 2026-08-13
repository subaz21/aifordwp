<#
.SYNOPSIS
    System Health Snapshot

.DESCRIPTION
    Collects and displays a quick health summary of the local machine:
      - Computer name and total RAM
      - Free space on the C: drive
      - Top 5 processes by memory usage
      - Recent errors from the System event log
      - User profiles that have not been used in over 90 days

    This script is READ-ONLY. It does not modify any system settings,
    delete files, or change configuration.

.AUTHOR
    [Your Name]

.HOW TO RUN
    Open PowerShell and navigate to the script directory, then run:
        .\inherited.ps1

    No parameters required. No elevated (Admin) rights needed for most
    queries, though reading the System event log may require Admin rights
    on some machines.

.NOTES
    Tested on: Windows 10 / Windows 11
    PowerShell version: 5.1 or later
#>

# Retrieve general computer information (name, total RAM, domain, etc.)
$computerInfo = Get-CimInstance Win32_ComputerSystem

# Get the amount of free disk space on the C: drive, in bytes
$freeDiskSpaceBytes = Get-PSDrive C | Select-Object -ExpandProperty Free

# Get all running processes, sorted by memory usage (highest first), keep top 5
$topMemoryProcesses = Get-Process | Sort-Object WS -Descending | Select-Object -First 5

# Read the last 10 entries from the System event log and keep only errors (Level 2)
$recentSystemErrors = Get-WinEvent -LogName System -MaxEvents 10 | Where-Object { $_.Level -eq 2 }

# Find user profiles that are not system accounts and have not been used in 90+ days
$staleUserProfiles = Get-CimInstance Win32_UserProfile | Where-Object {
    -not $_.Special -and $_.LastUseTime -lt (Get-Date).AddDays(-90)
}

# Print the computer name and total physical RAM in bytes
Write-Host $computerInfo.Name $computerInfo.TotalPhysicalMemory

# Convert free disk space from bytes to GB, round to 2 decimal places, and print
Write-Host ([math]::Round($freeDiskSpaceBytes / 1GB, 2)) 'GB free'

# Print the name and memory working set (in bytes) for each of the top 5 processes
$topMemoryProcesses | ForEach-Object { Write-Host $_.Name $_.WS }

# Print the timestamp and message for each recent System error event
$recentSystemErrors | ForEach-Object { Write-Host $_.TimeCreated $_.Message }

# If any stale profiles were found, print how many
if ($staleUserProfiles.Count -gt 0) { Write-Host 'Stale profiles:' $staleUserProfiles.Count }
