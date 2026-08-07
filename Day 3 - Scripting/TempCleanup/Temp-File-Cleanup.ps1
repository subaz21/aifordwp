<#
.SYNOPSIS
Safely cleans up temp files with dry-run, logging, summary reporting, and rollback support.

.DESCRIPTION
- Targets files older than a configurable number of days.
- Supports dry run mode that lists files that would be cleaned.
- Skips locked files and logs errors without stopping.
- Uses per-file try/catch handling.
- Logs every action to a timestamped log file.
- Moves files to a quarantine area so they can be rolled back.
- Includes rollback mode to restore files from a previous run.

.NOTES
PowerShell version: 5.1
#>

[CmdletBinding()]
param(
    # Paths to scan for temp files. Defaults to the current user's temp folder and C:\Windows\Temp.
    [Parameter(Mandatory = $false)]
    [string[]]$Paths = @($env:TEMP, 'C:\Windows\Temp'),

    # Only process files older than this many days. Default is 0 (all files older than now).
    [Parameter(Mandatory = $false)]
    [ValidateRange(0, 36500)]
    [int]$OlderThanDays = 0,

    # Dry run: list files that would be cleaned, but do not move/delete anything.
    [Parameter(Mandatory = $false)]
    [switch]$DryRun,

    # Rollback mode: restore files from quarantine using a run manifest.
    [Parameter(Mandatory = $false)]
    [switch]$Rollback,

    # Optional run identifier for rollback. If omitted in rollback mode, latest run is used.
    [Parameter(Mandatory = $false)]
    [string]$RunId,

    # Root folder for logs, quarantine, and manifests.
    [Parameter(Mandatory = $false)]
    [string]$StateRoot = (Join-Path -Path $PSScriptRoot -ChildPath "TempCleanupState")
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Region: Prepare state folders and log file.
$logsDir = Join-Path -Path $StateRoot -ChildPath 'Logs'
$quarantineDir = Join-Path -Path $StateRoot -ChildPath 'Quarantine'
$manifestsDir = Join-Path -Path $StateRoot -ChildPath 'Manifests'

foreach ($dir in @($StateRoot, $logsDir, $quarantineDir, $manifestsDir)) {
    if (-not (Test-Path -LiteralPath $dir)) {
        New-Item -Path $dir -ItemType Directory -Force | Out-Null
    }
}

$timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$logFile = Join-Path -Path $logsDir -ChildPath ("cleanup-{0}.log" -f $timestamp)

# Region: Logging helper.
function Write-Log {
    param(
        [Parameter(Mandatory = $true)][string]$Message,
        [Parameter(Mandatory = $false)][string]$Level = 'INFO'
    )

    $line = "{0} [{1}] {2}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $Level.ToUpperInvariant(), $Message
    Add-Content -LiteralPath $logFile -Value $line
    Write-Output $line
}

# Region: Format byte values for human-readable summary output.
function Format-ByteSize {
    param(
        [Parameter(Mandatory = $true)][Int64]$Bytes
    )

    if ($Bytes -ge 1TB) { return ('{0:N2} TB' -f ($Bytes / 1TB)) }
    if ($Bytes -ge 1GB) { return ('{0:N2} GB' -f ($Bytes / 1GB)) }
    if ($Bytes -ge 1MB) { return ('{0:N2} MB' -f ($Bytes / 1MB)) }
    if ($Bytes -ge 1KB) { return ('{0:N2} KB' -f ($Bytes / 1KB)) }
    return ('{0} B' -f $Bytes)
}

# Region: File lock detection helper.
function Test-FileLocked {
    param(
        [Parameter(Mandatory = $true)][string]$FilePath
    )

    try {
        $stream = [System.IO.File]::Open($FilePath, [System.IO.FileMode]::Open, [System.IO.FileAccess]::ReadWrite, [System.IO.FileShare]::None)
        if ($stream) {
            $stream.Close()
            $stream.Dispose()
        }
        return $false
    }
    catch [System.IO.IOException] {
        return $true
    }
}

# Region: Helper to locate a manifest for rollback.
function Get-ManifestForRollback {
    param(
        [Parameter(Mandatory = $false)][string]$RequestedRunId
    )

    if ($RequestedRunId) {
        $requested = Join-Path -Path $manifestsDir -ChildPath ("manifest-{0}.csv" -f $RequestedRunId)
        if (Test-Path -LiteralPath $requested) {
            return $requested
        }
        throw "No manifest found for RunId '$RequestedRunId'."
    }

    $latest = Get-ChildItem -LiteralPath $manifestsDir -Filter 'manifest-*.csv' -File -ErrorAction SilentlyContinue |
        Sort-Object -Property LastWriteTime -Descending |
        Select-Object -First 1

    if (-not $latest) {
        throw 'No manifest files found for rollback.'
    }

    return $latest.FullName
}

# Region: Rollback mode restores files from quarantine based on manifest.
if ($Rollback) {
    Write-Log -Message 'Rollback mode started.'

    try {
        $manifestPath = Get-ManifestForRollback -RequestedRunId $RunId
        Write-Log -Message ("Using manifest: {0}" -f $manifestPath)
    }
    catch {
        Write-Log -Message $_.Exception.Message -Level 'ERROR'
        throw
    }

    $entries = Import-Csv -LiteralPath $manifestPath
    $summary = [ordered]@{
        TotalEntries      = 0
        Restored          = 0
        SkippedAlreadyThere = 0
        SkippedMissingInQuarantine = 0
        Errors            = 0
    }

    foreach ($entry in $entries) {
        $summary.TotalEntries++

        try {
            $originalPath = $entry.OriginalPath
            $quarantinePath = $entry.QuarantinePath

            if (-not (Test-Path -LiteralPath $quarantinePath)) {
                $summary.SkippedMissingInQuarantine++
                Write-Log -Message ("Skip restore, quarantine file missing: {0}" -f $quarantinePath) -Level 'WARN'
                continue
            }

            if (Test-Path -LiteralPath $originalPath) {
                $summary.SkippedAlreadyThere++
                Write-Log -Message ("Skip restore, original already exists: {0}" -f $originalPath) -Level 'WARN'
                continue
            }

            $parent = Split-Path -Path $originalPath -Parent
            if (-not (Test-Path -LiteralPath $parent)) {
                New-Item -Path $parent -ItemType Directory -Force | Out-Null
            }

            Move-Item -LiteralPath $quarantinePath -Destination $originalPath -Force
            $summary.Restored++
            Write-Log -Message ("Restored: {0}" -f $originalPath)
        }
        catch {
            $summary.Errors++
            Write-Log -Message ("Restore failed for '{0}': {1}" -f $entry.OriginalPath, $_.Exception.Message) -Level 'ERROR'
        }
    }

    Write-Log -Message 'Rollback summary:'
    Write-Log -Message ("Total entries: {0}" -f $summary.TotalEntries)
    Write-Log -Message ("Restored: {0}" -f $summary.Restored)
    Write-Log -Message ("Skipped (original exists): {0}" -f $summary.SkippedAlreadyThere)
    Write-Log -Message ("Skipped (missing in quarantine): {0}" -f $summary.SkippedMissingInQuarantine)
    Write-Log -Message ("Errors: {0}" -f $summary.Errors)
    Write-Log -Message ("Log file: {0}" -f $logFile)

    return
}

# Region: Build file candidate list based on path and file age threshold.
$cutoff = (Get-Date).AddDays(-$OlderThanDays)
$candidates = New-Object System.Collections.Generic.List[System.IO.FileInfo]
$scannedPaths = New-Object System.Collections.Generic.List[string]
$candidateBytes = [Int64]0

Write-Log -Message ("Cleanup mode started. OlderThanDays={0}, Cutoff={1}, DryRun={2}" -f $OlderThanDays, $cutoff, $DryRun.IsPresent)

foreach ($path in $Paths) {
    try {
        if (-not (Test-Path -LiteralPath $path)) {
            Write-Log -Message ("Skip path, not found: {0}" -f $path) -Level 'WARN'
            continue
        }

        Write-Log -Message ("Scanning path: {0}" -f $path)
        $scannedPaths.Add($path) | Out-Null

        $found = Get-ChildItem -LiteralPath $path -File -Recurse -Force -ErrorAction Stop |
            Where-Object { $_.LastWriteTime -lt $cutoff }

        foreach ($file in $found) {
            $candidates.Add($file)
            $candidateBytes += [Int64]$file.Length
        }
    }
    catch {
        Write-Log -Message ("Path scan failed for '{0}': {1}" -f $path, $_.Exception.Message) -Level 'ERROR'
    }
}

# Region: If dry run is enabled, list all candidate files and exit with summary.
if ($DryRun) {
    Write-Log -Message ("Dry run selected. Candidate file count: {0}" -f $candidates.Count)

    foreach ($file in $candidates) {
        Write-Output ("[DRY-RUN] Would clean: {0}" -f $file.FullName)
        Write-Log -Message ("Dry run candidate: {0}" -f $file.FullName)
    }

    Write-Log -Message 'Summary:'
    Write-Log -Message ("Mode: DryRun")
    Write-Log -Message ("Scanned paths: {0}" -f $scannedPaths.Count)
    Write-Log -Message ("Age filter (days): {0}" -f $OlderThanDays)
    Write-Log -Message ("Cutoff timestamp: {0}" -f $cutoff)
    Write-Log -Message ("Candidates: {0}" -f $candidates.Count)
    Write-Log -Message ("Candidate size: {0} ({1} bytes)" -f (Format-ByteSize -Bytes $candidateBytes), $candidateBytes)
    Write-Log -Message 'Processed: 0'
    Write-Log -Message 'Moved to quarantine: 0'
    Write-Log -Message 'Skipped locked: 0'
    Write-Log -Message 'Skipped missing: 0'
    Write-Log -Message 'Errors: 0'
    Write-Log -Message ("Log file: {0}" -f $logFile)

    return
}

# Region: Process each file with per-file try/catch, lock skip, and manifest tracking.
$currentRunId = if ($RunId) { $RunId } else { [Guid]::NewGuid().ToString() }
$manifestFile = Join-Path -Path $manifestsDir -ChildPath ("manifest-{0}.csv" -f $currentRunId)
$manifestRows = New-Object System.Collections.Generic.List[object]

$summary = [ordered]@{
    Candidates      = $candidates.Count
    CandidateBytes  = $candidateBytes
    Processed       = 0
    MovedToQuarantine = 0
    MovedBytes      = [Int64]0
    SkippedLocked   = 0
    SkippedMissing  = 0
    Errors          = 0
}

foreach ($file in $candidates) {
    $summary.Processed++

    try {
        $fullName = $file.FullName

        if (-not (Test-Path -LiteralPath $fullName)) {
            $summary.SkippedMissing++
            Write-Log -Message ("Skip missing file: {0}" -f $fullName) -Level 'WARN'
            continue
        }

        $isLocked = $false
        try {
            $isLocked = Test-FileLocked -FilePath $fullName
        }
        catch {
            $summary.Errors++
            Write-Log -Message ("Lock check failed for '{0}': {1}" -f $fullName, $_.Exception.Message) -Level 'ERROR'
            continue
        }

        if ($isLocked) {
            $summary.SkippedLocked++
            Write-Log -Message ("Skip locked file: {0}" -f $fullName) -Level 'WARN'
            continue
        }

        $safeName = ($fullName -replace '[:\\/]', '_')
        $destination = Join-Path -Path $quarantineDir -ChildPath ("{0}_{1}" -f $currentRunId, $safeName)
        if (Test-Path -LiteralPath $destination) {
            $destination = Join-Path -Path $quarantineDir -ChildPath ("{0}_{1}_{2}" -f $currentRunId, [Guid]::NewGuid().ToString(), $safeName)
        }

        Move-Item -LiteralPath $fullName -Destination $destination -Force -ErrorAction Stop
        $summary.MovedToQuarantine++
        $summary.MovedBytes += [Int64]$file.Length

        $manifestRows.Add([PSCustomObject]@{
            RunId          = $currentRunId
            OriginalPath   = $fullName
            QuarantinePath = $destination
            MovedAtUtc     = (Get-Date).ToUniversalTime().ToString('o')
        }) | Out-Null

        Write-Log -Message ("Moved to quarantine: {0} -> {1}" -f $fullName, $destination)
    }
    catch {
        $summary.Errors++
        Write-Log -Message ("Failed processing '{0}': {1}" -f $file.FullName, $_.Exception.Message) -Level 'ERROR'
    }
}

# Region: Persist manifest for rollback and print final summary.
if ($manifestRows.Count -gt 0) {
    $manifestRows | Export-Csv -LiteralPath $manifestFile -NoTypeInformation
    Write-Log -Message ("Manifest saved: {0}" -f $manifestFile)
}
else {
    Write-Log -Message 'No files moved; no manifest created.'
}

Write-Log -Message 'Summary:'
Write-Log -Message ("Mode: Cleanup")
Write-Log -Message ("Scanned paths: {0}" -f $scannedPaths.Count)
Write-Log -Message ("Age filter (days): {0}" -f $OlderThanDays)
Write-Log -Message ("Cutoff timestamp: {0}" -f $cutoff)
Write-Log -Message ("Candidates: {0}" -f $summary.Candidates)
Write-Log -Message ("Candidate size: {0} ({1} bytes)" -f (Format-ByteSize -Bytes $summary.CandidateBytes), $summary.CandidateBytes)
Write-Log -Message ("Processed: {0}" -f $summary.Processed)
Write-Log -Message ("Moved to quarantine: {0}" -f $summary.MovedToQuarantine)
Write-Log -Message ("Moved size: {0} ({1} bytes)" -f (Format-ByteSize -Bytes $summary.MovedBytes), $summary.MovedBytes)
Write-Log -Message ("Skipped locked: {0}" -f $summary.SkippedLocked)
Write-Log -Message ("Skipped missing: {0}" -f $summary.SkippedMissing)
Write-Log -Message ("Errors: {0}" -f $summary.Errors)
Write-Log -Message ("RunId: {0}" -f $currentRunId)
Write-Log -Message ("Log file: {0}" -f $logFile)
