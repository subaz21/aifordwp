#requires -version 5.1
<#
    Large File Finder (Read-Only)
    Audience: DWP Engineers

    Purpose:
    - Recursively scan a path and report files larger than a threshold.

    Read-only guarantee:
    - This script only reads file metadata.
    - It does not modify files, permissions, registry, services, or system settings.
#>

param(
    [Parameter(Mandatory = $false)]
    [ValidateRange(1, [int]::MaxValue)]
    [int]$ThresholdMB = 100,

    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]$ScanPath = 'C:\'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Write-Section {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Title
    )

    Write-Host ''
    Write-Host ('=' * 80)
    Write-Host $Title
    Write-Host ('=' * 80)
}

function Convert-ToReadableSize {
    param(
        [Parameter(Mandatory = $true)]
        [double]$Bytes
    )

    if ($Bytes -ge 1TB) { return ('{0:N2} TB' -f ($Bytes / 1TB)) }
    if ($Bytes -ge 1GB) { return ('{0:N2} GB' -f ($Bytes / 1GB)) }
    if ($Bytes -ge 1MB) { return ('{0:N2} MB' -f ($Bytes / 1MB)) }
    if ($Bytes -ge 1KB) { return ('{0:N2} KB' -f ($Bytes / 1KB)) }
    return ('{0:N0} Bytes' -f $Bytes)
}

<#
    SECTION: Header
    Prints report metadata for traceability.
#>
Write-Host 'Large File Finder (Read-Only)'
Write-Host ('Generated: {0}' -f (Get-Date))
Write-Host ('Computer : {0}' -f $env:COMPUTERNAME)
Write-Host ('User     : {0}' -f $env:USERNAME)

<#
    SECTION: Pre-Run Verification
    Flags items to verify before scanning, because large scans can take time.
#>
Write-Section -Title 'Pre-Run Verification (Please Confirm)'
Write-Host '- Run in Windows PowerShell 5.1 for expected behavior.'
Write-Host '- Confirm the scan path exists and is reachable.'
Write-Host '- Scanning C:\ recursively can take significant time on large endpoints.'
Write-Host '- Some folders may be inaccessible; access-denied items are counted and skipped.'
Write-Host '- Threshold is in MB. Default is 100 MB.'

<#
    SECTION: Input Validation
    Validates user inputs before starting the scan.
#>
Write-Section -Title 'Input Validation'
if (-not (Test-Path -Path $ScanPath)) {
    Write-Error ('Scan path does not exist: {0}' -f $ScanPath)
    exit 1
}

$thresholdBytes = [int64]$ThresholdMB * 1MB
Write-Host ('Scan Path    : {0}' -f $ScanPath)
Write-Host ('Threshold MB : {0}' -f $ThresholdMB)
Write-Host ('Threshold    : {0}' -f (Convert-ToReadableSize -Bytes $thresholdBytes))

<#
    SECTION: File Scan
    Recursively reads file metadata and selects files larger than the threshold.
#>
Write-Section -Title 'Large File Report'
try {
    $scanErrors = @()

    $allFiles = Get-ChildItem -Path $ScanPath -Recurse -File -Force -ErrorAction SilentlyContinue -ErrorVariable +scanErrors
    $largeFiles = @(
        $allFiles |
            Where-Object { $_.Length -ge $thresholdBytes } |
            Sort-Object -Property Length -Descending
    )

    if ($largeFiles.Count -eq 0) {
        Write-Host ('No files found above {0}.' -f (Convert-ToReadableSize -Bytes $thresholdBytes))
    }
    else {
        $report = $largeFiles | Select-Object `
            @{ Name = 'Size'; Expression = { Convert-ToReadableSize -Bytes $_.Length } },
            @{ Name = 'SizeBytes'; Expression = { $_.Length } },
            FullName,
            LastWriteTime

        $report | Format-Table -AutoSize | Out-String | Write-Host
    }

    <#
        SECTION: Summary
        Displays totals for findings and skipped items.
    #>
    Write-Section -Title 'Summary'
    $sizeMeasure = $largeFiles | Measure-Object -Property Length -Sum
    if ($null -ne $sizeMeasure -and ($sizeMeasure.PSObject.Properties.Name -contains 'Sum') -and $null -ne $sizeMeasure.Sum) {
        $totalLargeFileBytes = [double]$sizeMeasure.Sum
    }
    else {
        $totalLargeFileBytes = 0
    }

    Write-Host ('Large files found      : {0}' -f $largeFiles.Count)
    Write-Host ('Total size (large only): {0}' -f (Convert-ToReadableSize -Bytes $totalLargeFileBytes))
    Write-Host ('Skipped errors         : {0}' -f $scanErrors.Count)

    if ($scanErrors.Count -gt 0) {
        Write-Host ''
        Write-Host 'Sample skipped errors (up to 5):'
        $scanErrors | Select-Object -First 5 | ForEach-Object {
            Write-Host (' - {0}' -f $_.Exception.Message)
        }
    }
}
catch {
    Write-Warning ('Scan failed: {0}' -f $_.Exception.Message)
}

Write-Host ''
Write-Host 'Scan complete.'