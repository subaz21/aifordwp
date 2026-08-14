# Version 1: AI-generated first draft (uncorrected)

param(
    [switch]$DryRun
)

Write-Host "Collecting compliance evidence..."

$dsreg = dsregcmd /status
Write-Host $dsreg

$os = Get-WmiObject Win32_OperatingSystem
Write-Host "Last boot: $($os.LastBootUpTime)"

$events = Get-WinEvent -LogName "Microsoft-Windows-DeviceManagement-Enterprise-Diagnostics-Provider/Admin" -MaxEvents 9999
foreach ($e in $events) {
    Write-Host "$($e.TimeCreated) - $($e.Message)"
}

$gpEvents = Get-WinEvent -LogName System -MaxEvents 9999 | Where-Object { $_.Id -eq 8001 -or $_.Id -eq 8002 }
foreach ($e in $gpEvents) {
    Write-Host "$($e.TimeCreated) - $($e.Message)"
}

"Evidence collected" | Out-File "C:\Temp\evidence.txt"
Write-Host "Done."

# ---------------------------------------------------------------------------

# Version 2: Hand-corrected version (what would actually be run)

<#
.SYNOPSIS
    Gathers device-side evidence for the "deployment-forced compliance/CA block" hypothesis
    on a Floor 6 endpoint, and writes a structured evidence record.

.PARAMETER DeploymentTime
    Timestamp of Friday's document management app deployment, used to bound the search window.

.PARAMETER DryRun
    When set, prints the exact collection plan and output location and performs no collection
    or file writes.

.PARAMETER OutputRoot
    Root folder for evidence output. Defaults to a ProgramData path so it survives the current
    user session and is not left under a user profile.
#>
param(
    [Parameter(Mandatory = $true)]
    [datetime]$DeploymentTime,

    [switch]$DryRun,

    [string]$OutputRoot = "$env:ProgramData\DWP\IncidentEvidence"
)

$deviceName = $env:COMPUTERNAME
$collectedAt = Get-Date
$windowStart = $DeploymentTime
$outputFile = Join-Path $OutputRoot "$deviceName-$($collectedAt.ToString('yyyyMMdd-HHmmss')).json"

$plan = [ordered]@{
    Device            = $deviceName
    DeploymentTime    = $DeploymentTime
    SearchWindowStart = $windowStart
    SearchWindowEnd   = $collectedAt
    OutputFile        = $outputFile
    Steps             = @(
        "dsregcmd /status (join/compliance state only, no identifiers retained)"
        "Last boot time via Get-CimInstance Win32_OperatingSystem"
        "Pending-reboot registry indicators"
        "MDM/Intune compliance events since deployment (Microsoft-Windows-DeviceManagement-Enterprise-Diagnostics-Provider/Admin)"
        "Group Policy logon-duration events 8001/8002 since deployment"
    )
}

if ($DryRun) {
    Write-Host "DRY RUN - no collection or file writes will occur. Plan:" -ForegroundColor Yellow
    $plan | ConvertTo-Json -Depth 3
    return
}

if (-not (Test-Path $OutputRoot)) {
    New-Item -Path $OutputRoot -ItemType Directory -Force | Out-Null
}

function Get-SafeResult {
    param([scriptblock]$Action, [string]$StepName)
    try {
        return @{ Step = $StepName; Success = $true; Data = (& $Action) }
    } catch {
        return @{ Step = $StepName; Success = $false; Error = $_.Exception.Message }
    }
}

$joinState = Get-SafeResult -StepName "dsregcmd" -Action {
    $raw = dsregcmd /status
    [PSCustomObject]@{
        AzureAdJoined = ($raw | Select-String "AzureAdJoined\s*:\s*(\S+)").Matches.Groups[1].Value
        DomainJoined  = ($raw | Select-String "DomainJoined\s*:\s*(\S+)").Matches.Groups[1].Value
        MdmUrl        = ($raw | Select-String "MdmUrl\s*:\s*(\S+)").Matches.Groups[1].Value
    }
}

$bootInfo = Get-SafeResult -StepName "LastBoot" -Action {
    (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
}

$pendingReboot = Get-SafeResult -StepName "PendingReboot" -Action {
    $cbs = Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending"
    $wu  = Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired"
    $pfr = (Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" -Name PendingFileRenameOperations -ErrorAction SilentlyContinue) -ne $null
    [PSCustomObject]@{
        ComponentBasedServicing = $cbs
        WindowsUpdate           = $wu
        PendingFileRename       = $pfr
        AnyPendingReboot        = ($cbs -or $wu -or $pfr)
    }
}

$complianceEvents = Get-SafeResult -StepName "MDMComplianceEvents" -Action {
    Get-WinEvent -FilterHashtable @{
        LogName   = "Microsoft-Windows-DeviceManagement-Enterprise-Diagnostics-Provider/Admin"
        StartTime = $windowStart
        EndTime   = $collectedAt
    } -MaxEvents 200 -ErrorAction Stop |
        Select-Object TimeCreated, Id, LevelDisplayName, Message
}

$gpEvents = Get-SafeResult -StepName "LogonDurationEvents" -Action {
    Get-WinEvent -FilterHashtable @{
        LogName   = "System"
        Id        = 8001, 8002
        StartTime = $windowStart
        EndTime   = $collectedAt
    } -MaxEvents 200 -ErrorAction Stop |
        Select-Object TimeCreated, Id, Message
}

$evidence = [ordered]@{
    Device            = $deviceName
    CollectedAtUtc    = $collectedAt.ToUniversalTime()
    DeploymentTime    = $DeploymentTime
    SearchWindowStart = $windowStart
    JoinState         = $joinState
    BootInfo          = $bootInfo
    PendingReboot     = $pendingReboot
    ComplianceEvents  = $complianceEvents
    GpoLogonEvents    = $gpEvents
}

$evidence | ConvertTo-Json -Depth 5 | Out-File -FilePath $outputFile -Encoding utf8

Write-Host "Evidence written to $outputFile" -ForegroundColor Green
[PSCustomObject]@{
    Device                 = $deviceName
    PendingRebootDetected  = $pendingReboot.Data.AnyPendingReboot
    ComplianceEventsFound  = $complianceEvents.Data.Count
    LogonDurationEventsFound = $gpEvents.Data.Count
    OutputFile             = $outputFile
} | Format-List
