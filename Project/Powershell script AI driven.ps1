[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [datetime]$DeploymentTime,

    [switch]$DryRun,

    [string]$OutputRoot = "$env:ProgramData\DWP\IncidentEvidence",

    [int]$MaxEvents = 250
)

$deviceName = $env:COMPUTERNAME
$collectedAt = Get-Date
$windowStart = $DeploymentTime
$windowEnd = $collectedAt
$outputFile = Join-Path $OutputRoot "$deviceName-$($collectedAt.ToString('yyyyMMdd-HHmmss'))-compliance-evidence.json"

$plan = [ordered]@{
    Device            = $deviceName
    DeploymentTime    = $DeploymentTime
    SearchWindowStart = $windowStart
    SearchWindowEnd   = $windowEnd
    OutputFile        = $outputFile
    Steps             = @(
        "Collect dsregcmd join/compliance indicators"
        "Collect last boot time and pending reboot indicators"
        "Collect MDM/Intune Admin log events in the deployment window"
        "Collect Group Policy 8001/8002 logon-duration events in the deployment window"
        "Collect Azure AD operational sign-in related events in the deployment window"
        "Collect IntuneManagementExtension log excerpts if present"
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
        [string]$StepName,

        [Parameter(Mandatory = $true)]
        [scriptblock]$Action
    )

    try {
        [PSCustomObject]@{
            Step    = $StepName
            Success = $true
            Data    = (& $Action)
            Error   = $null
        }
    }
    catch {
        [PSCustomObject]@{
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
        DeviceId      = ($raw | Select-String "DeviceId\s*:\s*(\S+)").Matches.Groups[1].Value
        TenantId      = ($raw | Select-String "TenantId\s*:\s*(\S+)").Matches.Groups[1].Value
        MdmUrl        = ($raw | Select-String "MdmUrl\s*:\s*(\S+)").Matches.Groups[1].Value
    }
}

$bootState = Get-SafeResult -StepName "BootAndRebootState" -Action {
    $os = Get-CimInstance Win32_OperatingSystem
    $cbs = Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending"
    $wu = Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired"
    $pfr = (Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" -Name PendingFileRenameOperations -ErrorAction SilentlyContinue) -ne $null

    [PSCustomObject]@{
        LastBootUpTime    = $os.LastBootUpTime
        PendingCBSReboot  = $cbs
        PendingWUReboot   = $wu
        PendingFileRename = $pfr
        AnyPendingReboot  = ($cbs -or $wu -or $pfr)
    }
}

$mdmEvents = Get-SafeResult -StepName "MDMComplianceEvents" -Action {
    Get-WinEvent -FilterHashtable @{
        LogName   = "Microsoft-Windows-DeviceManagement-Enterprise-Diagnostics-Provider/Admin"
        StartTime = $windowStart
        EndTime   = $windowEnd
    } -MaxEvents $MaxEvents -ErrorAction Stop |
        Where-Object {
            $_.Message -match "compliance|policy|error|failed|reboot|non.?compliant"
        } |
        Select-Object TimeCreated, Id, LevelDisplayName, Message
}

$gpoEvents = Get-SafeResult -StepName "GpoLogonDurationEvents" -Action {
    Get-WinEvent -FilterHashtable @{
        LogName   = "System"
        Id        = 8001, 8002
        StartTime = $windowStart
        EndTime   = $windowEnd
    } -MaxEvents $MaxEvents -ErrorAction Stop |
        Select-Object TimeCreated, Id, LevelDisplayName, Message
}

$aadEvents = Get-SafeResult -StepName "AadOperationalEvents" -Action {
    Get-WinEvent -FilterHashtable @{
        LogName   = "Microsoft-Windows-AAD/Operational"
        StartTime = $windowStart
        EndTime   = $windowEnd
    } -MaxEvents $MaxEvents -ErrorAction Stop |
        Select-Object TimeCreated, Id, LevelDisplayName, Message
}

$imeLog = Get-SafeResult -StepName "IntuneManagementExtensionLog" -Action {
    $imePath = "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\IntuneManagementExtension.log"
    if (-not (Test-Path -Path $imePath)) {
        return [PSCustomObject]@{
            Exists  = $false
            Path    = $imePath
            Matches = @()
        }
    }

    $matches = Select-String -Path $imePath -Pattern "compliance|policy|reboot|error|failed" -SimpleMatch:$false |
        Select-Object -First $MaxEvents -ExpandProperty Line

    [PSCustomObject]@{
        Exists  = $true
        Path    = $imePath
        Matches = $matches
    }
}

$evidence = [ordered]@{
    Hypothesis         = "Deployment-triggered compliance re-evaluation caused CA sign-in block/delay"
    Device             = $deviceName
    CollectedAtUtc     = $collectedAt.ToUniversalTime()
    DeploymentTime     = $DeploymentTime
    SearchWindowStart  = $windowStart
    SearchWindowEnd    = $windowEnd
    JoinState          = $joinState
    BootAndRebootState = $bootState
    MDMCompliance      = $mdmEvents
    GpoLogonDuration   = $gpoEvents
    AadOperational     = $aadEvents
    IntuneIMELog       = $imeLog
}

$evidence | ConvertTo-Json -Depth 8 | Out-File -FilePath $outputFile -Encoding utf8

$summary = [PSCustomObject]@{
    Device                  = $deviceName
    OutputFile              = $outputFile
    PendingRebootDetected   = $bootState.Data.AnyPendingReboot
    MdmEventsFound          = @($mdmEvents.Data).Count
    GpoDurationEventsFound  = @($gpoEvents.Data).Count
    AadOperationalEvents    = @($aadEvents.Data).Count
    ImeLogEvidenceLines     = if ($imeLog.Data.Exists) { @($imeLog.Data.Matches).Count } else { 0 }
}

Write-Host "Evidence written to $outputFile" -ForegroundColor Green
$summary | Format-List
