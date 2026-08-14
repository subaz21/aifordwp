[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [datetime]$DeploymentTime,

    [switch]$DryRun,

    [string]$OutputRoot = "$env:ProgramData\DWP\IncidentEvidence",

    [int]$MaxEvents = 200
)

$deviceName = $env:COMPUTERNAME
$collectedAt = Get-Date
$windowStart = $DeploymentTime
$outputFile = Join-Path $OutputRoot "$deviceName-$($collectedAt.ToString('yyyyMMdd-HHmmss'))-handcorrected-evidence.json"

$plan = [ordered]@{
    Device            = $deviceName
    DeploymentTime    = $DeploymentTime
    SearchWindowStart = $windowStart
    SearchWindowEnd   = $collectedAt
    OutputFile        = $outputFile
    Steps             = @(
        "dsregcmd /status (join/compliance indicators)"
        "Get-CimInstance Win32_OperatingSystem (last boot)"
        "Pending-reboot registry indicators"
        "MDM/Intune Admin events in deployment window"
        "System 8001/8002 Group Policy logon-duration events"
    )
}

if ($DryRun) {
    Write-Host "DRY RUN - no collection or file writes will occur." -ForegroundColor Yellow
    $plan | ConvertTo-Json -Depth 4
    return
}

if (-not (Test-Path -Path $OutputRoot)) {
    New-Item -Path $OutputRoot -ItemType Directory -Force | Out-Null
}

function Get-SafeResult {
    param(
        [Parameter(Mandatory = $true)]
        [scriptblock]$Action,

        [Parameter(Mandatory = $true)]
        [string]$StepName
    )

    try {
        return [PSCustomObject]@{
            Step    = $StepName
            Success = $true
            Data    = (& $Action)
            Error   = $null
        }
    }
    catch {
        return [PSCustomObject]@{
            Step    = $StepName
            Success = $false
            Data    = $null
            Error   = $_.Exception.Message
        }
    }
}

$joinState = Get-SafeResult -StepName "JoinState" -Action {
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
    $wu = Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired"
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
    } -MaxEvents $MaxEvents -ErrorAction Stop |
        Select-Object TimeCreated, Id, LevelDisplayName, Message
}

$gpEvents = Get-SafeResult -StepName "LogonDurationEvents" -Action {
    Get-WinEvent -FilterHashtable @{
        LogName   = "System"
        Id        = 8001, 8002
        StartTime = $windowStart
        EndTime   = $collectedAt
    } -MaxEvents $MaxEvents -ErrorAction Stop |
        Select-Object TimeCreated, Id, Message
}

$evidence = [ordered]@{
    Hypothesis         = "Deployment-forced reboot/policy re-sync flipped device to Not Compliant and CA blocked/delayed sign-in"
    Device             = $deviceName
    CollectedAtUtc     = $collectedAt.ToUniversalTime()
    DeploymentTime     = $DeploymentTime
    SearchWindowStart  = $windowStart
    SearchWindowEnd    = $collectedAt
    JoinState          = $joinState
    BootInfo           = $bootInfo
    PendingReboot      = $pendingReboot
    ComplianceEvents   = $complianceEvents
    GpoLogonEvents     = $gpEvents
}

$evidence | ConvertTo-Json -Depth 6 | Out-File -FilePath $outputFile -Encoding utf8

Write-Host "Evidence written to $outputFile" -ForegroundColor Green
[PSCustomObject]@{
    Device                   = $deviceName
    PendingRebootDetected    = $pendingReboot.Data.AnyPendingReboot
    ComplianceEventsFound    = @($complianceEvents.Data).Count
    LogonDurationEventsFound = @($gpEvents.Data).Count
    OutputFile               = $outputFile
} | Format-List
