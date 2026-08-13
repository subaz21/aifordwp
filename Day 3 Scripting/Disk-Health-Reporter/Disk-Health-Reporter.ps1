#requires -version 5.1
<#
    Disk Health Reporter (Read-Only)
    Audience: DWP Engineers

    Purpose:
    - Report disk inventory and health indicators.
    - Report optimization status signals without performing optimization.

    Read-only guarantee:
    - This script only reads system metadata (storage, SMART-related status, tasks, event logs).
    - It never runs defrag/optimize and never changes system configuration.
#>

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
Write-Host 'Disk Health Reporter (Read-Only)'
Write-Host ('Generated: {0}' -f (Get-Date))
Write-Host ('Computer : {0}' -f $env:COMPUTERNAME)
Write-Host ('User     : {0}' -f $env:USERNAME)

<#
    SECTION: Pre-Run Verification
    Flags checks to verify before collecting data.
#>
Write-Section -Title 'Pre-Run Verification (Please Confirm)'
Write-Host '- Run in Windows PowerShell 5.1 for expected compatibility.'
Write-Host '- Some storage cmdlets return fuller data when run as Administrator.'
Write-Host '- Defrag operational log may be disabled on some endpoints.'
Write-Host '- This script is read-only and never starts optimization or defragmentation.'

<#
    SECTION 1: Physical Disk Health Summary
    Reads physical disk details and health/operational status indicators.
#>
Write-Section -Title '1) Physical Disk Health Summary'
try {
    $physicalDisks = Get-PhysicalDisk | Select-Object FriendlyName, MediaType, CanPool, HealthStatus, OperationalStatus, Size

    if ($physicalDisks) {
        $diskReport = $physicalDisks | Select-Object FriendlyName, MediaType, HealthStatus, OperationalStatus,
            @{ Name = 'Size'; Expression = { Convert-ToReadableSize -Bytes $_.Size } }

        $diskReport | Format-Table -AutoSize | Out-String | Write-Host
    }
    else {
        Write-Host 'No physical disk data was returned.'
    }
}
catch {
    Write-Warning ('Unable to read physical disk data: {0}' -f $_.Exception.Message)
}

<#
    SECTION 2: Logical Volume Capacity and Health
    Reads volume-level capacity and health information.
#>
Write-Section -Title '2) Logical Volume Capacity and Health'
try {
    $volumes = Get-Volume |
        Where-Object { $_.DriveLetter -or $_.FileSystemLabel } |
        Select-Object DriveLetter, FileSystemLabel, FileSystem, HealthStatus, Size, SizeRemaining

    if ($volumes) {
        $volumeReport = $volumes | Select-Object `
            @{ Name = 'Volume'; Expression = {
                    if ($_.DriveLetter) { ('{0}:' -f $_.DriveLetter) } else { '[NoLetter]' }
                }
            },
            FileSystemLabel,
            FileSystem,
            HealthStatus,
            @{ Name = 'Size'; Expression = { Convert-ToReadableSize -Bytes $_.Size } },
            @{ Name = 'Free'; Expression = { Convert-ToReadableSize -Bytes $_.SizeRemaining } },
            @{ Name = 'FreePct'; Expression = {
                    if ($_.Size -gt 0) { [math]::Round(($_.SizeRemaining / $_.Size) * 100, 2) } else { $null }
                }
            }

        $volumeReport | Format-Table -AutoSize | Out-String | Write-Host
    }
    else {
        Write-Host 'No volume data was returned.'
    }
}
catch {
    Write-Warning ('Unable to read volume data: {0}' -f $_.Exception.Message)
}

<#
    SECTION 3: Optimization Task Status
    Reads the ScheduledDefrag task status without running it.
#>
Write-Section -Title '3) Scheduled Optimization Task Status'
try {
    $defragTask = Get-ScheduledTask -TaskPath '\Microsoft\Windows\Defrag\' -TaskName 'ScheduledDefrag' -ErrorAction SilentlyContinue

    if ($null -eq $defragTask) {
        Write-Host 'ScheduledDefrag task not found.'
    }
    else {
        $taskInfo = Get-ScheduledTaskInfo -TaskPath '\Microsoft\Windows\Defrag\' -TaskName 'ScheduledDefrag'

        $taskReport = [pscustomobject]@{
            TaskName        = $defragTask.TaskName
            State           = $defragTask.State
            LastRunTime     = $taskInfo.LastRunTime
            LastTaskResult  = $taskInfo.LastTaskResult
            NextRunTime     = $taskInfo.NextRunTime
            NumberOfMissedRuns = $taskInfo.NumberOfMissedRuns
        }

        $taskReport | Format-List | Out-String | Write-Host
    }
}
catch {
    Write-Warning ('Unable to read scheduled optimization task state: {0}' -f $_.Exception.Message)
}

<#
    SECTION 4: Last Optimization Events
    Reads recent optimization/defrag operational events for status evidence.
#>
Write-Section -Title '4) Last Optimization Events (Defrag Operational Log)'
try {
    $defragLog = 'Microsoft-Windows-Defrag/Operational'
    $recentEvents = Get-WinEvent -LogName $defragLog -MaxEvents 50 -ErrorAction SilentlyContinue

    if (-not $recentEvents) {
        Write-Host 'No events found, or log is unavailable.'
    }
    else {
        $interesting = @(
            $recentEvents |
                Where-Object {
                    $_.LevelDisplayName -in @('Information', 'Warning', 'Error')
                } |
                Select-Object -First 10 TimeCreated, Id, LevelDisplayName, Message
        )

        if ($interesting.Count -eq 0) {
            Write-Host 'No relevant optimization events found in the last 50 entries.'
        }
        else {
            $interesting | Format-List | Out-String | Write-Host
        }
    }
}
catch {
    Write-Warning ('Unable to read defrag operational events: {0}' -f $_.Exception.Message)
}

<#
    SECTION 5: Quick Risk Flags
    Highlights simple risk conditions from collected data.
#>
Write-Section -Title '5) Quick Risk Flags'
try {
    $riskFlags = @()

    $volumesForRisk = Get-Volume | Where-Object { $_.DriveLetter -and $_.Size -gt 0 }
    foreach ($v in $volumesForRisk) {
        $freePct = ($v.SizeRemaining / $v.Size) * 100
        if ($freePct -lt 15) {
            $riskFlags += ('Low free space: {0}: has {1}% free' -f $v.DriveLetter, ([math]::Round($freePct, 2)))
        }
        if ($v.HealthStatus -ne 'Healthy') {
            $riskFlags += ('Volume health warning: {0}: status is {1}' -f $v.DriveLetter, $v.HealthStatus)
        }
    }

    $physicalForRisk = Get-PhysicalDisk
    foreach ($d in $physicalForRisk) {
        if ($d.HealthStatus -ne 'Healthy') {
            $riskFlags += ('Physical disk health warning: {0} is {1}' -f $d.FriendlyName, $d.HealthStatus)
        }
        if ($d.OperationalStatus -ne 'OK') {
            $riskFlags += ('Physical disk operational warning: {0} is {1}' -f $d.FriendlyName, ($d.OperationalStatus -join ','))
        }
    }

    if ($riskFlags.Count -eq 0) {
        Write-Host 'No immediate risk flags detected by this quick check.'
    }
    else {
        $riskFlags | ForEach-Object { Write-Host ('- {0}' -f $_) }
    }
}
catch {
    Write-Warning ('Unable to compute risk flags: {0}' -f $_.Exception.Message)
}

Write-Host ''
Write-Host 'Report complete.'