#requires -version 5.1
<#
    Endpoint Health Report (Read-Only)
    Audience: DWP Engineers

    This script only reads system, service, event log, and network test data.
    It does not modify system state, registry, services, files, or settings.
#>

param(
    [switch]$AsObject
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$Report = [ordered]@{
    GeneratedAt = Get-Date
    ComputerName = $env:COMPUTERNAME
}

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

Write-Host 'Endpoint Health Report (Read-Only)'
Write-Host ('Generated: {0}' -f $Report.GeneratedAt)
Write-Host ('Computer : {0}' -f $Report.ComputerName)

<#
    PRE-RUN VERIFICATION
    This section flags items to verify before running because results depend on environment.
#>
Write-Section -Title 'Pre-Run Verification (Please Confirm)'
Write-Host '- Run in Windows PowerShell 5.1 (not PowerShell 7+) for expected compatibility.'
Write-Host '- Run with permissions that allow reading System event log and update history.'
Write-Host '- Internet speed test needs outbound HTTPS and DNS access to speed.hetzner.de or proof.ovh.net.'
Write-Host '- Some environments may not have Microsoft Defender (service WinDefend) installed.'

<#
    SECTION 1: System Uptime
    Reads last boot time from WMI/CIM and calculates elapsed uptime.
#>
Write-Section -Title '1) System Uptime'
try {
    $os = Get-CimInstance -ClassName Win32_OperatingSystem
    $lastBoot = $os.LastBootUpTime
    $uptime = (Get-Date) - $lastBoot
    $Report.SystemUptime = [pscustomobject]@{
        LastBootTime = $lastBoot
        Days = $uptime.Days
        Hours = $uptime.Hours
        Minutes = $uptime.Minutes
    }

    Write-Host ('Last Boot Time : {0}' -f $lastBoot)
    Write-Host ('Uptime         : {0} days {1} hours {2} minutes' -f $uptime.Days, $uptime.Hours, $uptime.Minutes)
}
catch {
    $Report.SystemUptime = [pscustomobject]@{ Error = $_.Exception.Message }
    Write-Warning ('Unable to read uptime: {0}' -f $_.Exception.Message)
}

<#
    SECTION 2: Free Disk Space
    Reads fixed local drives and reports free and total capacity in GB.
#>
Write-Section -Title '2) Free Disk Space'
try {
    $drives = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType=3" |
        Select-Object DeviceID,
            @{ Name = 'SizeGB'; Expression = { [math]::Round($_.Size / 1GB, 2) } },
            @{ Name = 'FreeGB'; Expression = { [math]::Round($_.FreeSpace / 1GB, 2) } },
            @{ Name = 'FreePct'; Expression = {
                    if ($_.Size -gt 0) {
                        [math]::Round(($_.FreeSpace / $_.Size) * 100, 2)
                    }
                    else {
                        $null
                    }
                }
            }

    if ($drives) {
        $Report.FreeDiskSpace = @($drives)
        $drives | Format-Table -AutoSize | Out-String | Write-Host
    }
    else {
        $Report.FreeDiskSpace = @()
        Write-Host 'No fixed disks found.'
    }
}
catch {
    $Report.FreeDiskSpace = [pscustomobject]@{ Error = $_.Exception.Message }
    Write-Warning ('Unable to read disk information: {0}' -f $_.Exception.Message)
}

<#
    SECTION 3: Pending Reboot Status
    Reads common registry locations that indicate whether a reboot is pending.
#>
Write-Section -Title '3) Pending Reboot (Registry Checks)'
try {
    $rebootChecks = @(
        @{
            Name = 'CBS RebootPending'
            Path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending'
            Type = 'Key'
        },
        @{
            Name = 'Windows Update RebootRequired'
            Path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired'
            Type = 'Key'
        },
        @{
            Name = 'Session Manager PendingFileRenameOperations'
            Path = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager'
            Value = 'PendingFileRenameOperations'
            Type = 'Value'
        }
    )

    $results = foreach ($check in $rebootChecks) {
        if ($check.Type -eq 'Key') {
            $exists = Test-Path -Path $check.Path
            [pscustomobject]@{
                Check   = $check.Name
                Pending = $exists
            }
        }
        else {
            $item = Get-ItemProperty -Path $check.Path -ErrorAction SilentlyContinue
            $hasProperty = $null -ne $item -and ($item.PSObject.Properties.Name -contains $check.Value)
            $hasValue = $hasProperty -and $null -ne $item.($check.Value)
            [pscustomobject]@{
                Check   = $check.Name
                Pending = $hasValue
            }
        }
    }

    $results | Format-Table -AutoSize | Out-String | Write-Host
    $isPending = $results.Pending -contains $true
    $Report.PendingRebootChecks = @($results)
    $Report.OverallPendingReboot = $isPending
    Write-Host ('Overall Pending Reboot: {0}' -f $isPending)
}
catch {
    $Report.PendingRebootChecks = [pscustomobject]@{ Error = $_.Exception.Message }
    Write-Warning ('Unable to evaluate pending reboot status: {0}' -f $_.Exception.Message)
}

<#
    SECTION 4: Top 5 Processes by Memory
    Reads running process working set and returns the top 5 highest consumers.
#>
Write-Section -Title '4) Top 5 Processes by Memory (Working Set)'
try {
    $topMem = Get-Process |
        Sort-Object -Property WorkingSet64 -Descending |
        Select-Object -First 5 Name, Id,
            @{ Name = 'WorkingSetMB'; Expression = { [math]::Round($_.WorkingSet64 / 1MB, 2) } }

    $Report.TopProcessesByMemory = @($topMem)
    $topMem | Format-Table -AutoSize | Out-String | Write-Host
}
catch {
    $Report.TopProcessesByMemory = [pscustomobject]@{ Error = $_.Exception.Message }
    Write-Warning ('Unable to read process memory data: {0}' -f $_.Exception.Message)
}

<#
    SECTION 5: Top 5 Processes by CPU
    Reads accumulated CPU time and returns the top 5 process consumers.
    Note: CPU is cumulative since process start, not instantaneous utilization.
#>
Write-Section -Title '5) Top 5 Processes by CPU'
try {
    # Use Win32_Process CPU times to avoid process property edge cases under strict mode.
    $topCpu = Get-CimInstance -ClassName Win32_Process |
        Where-Object { $_.ProcessId -ne 0 -and $_.Name -ne 'System Idle Process' } |
        Select-Object @{ Name = 'Name'; Expression = { $_.Name } },
            @{ Name = 'Id'; Expression = { $_.ProcessId } },
            @{ Name = 'CPUSeconds'; Expression = {
                    $kernel = if ($null -ne $_.KernelModeTime) { [double]$_.KernelModeTime } else { 0 }
                    $user = if ($null -ne $_.UserModeTime) { [double]$_.UserModeTime } else { 0 }
                    [math]::Round(($kernel + $user) / 10000000, 2)
                }
            } |
        Sort-Object -Property CPUSeconds -Descending |
        Select-Object -First 5 Name, Id, CPUSeconds

    $Report.TopProcessesByCPU = @($topCpu)
    $topCpu | Format-Table -AutoSize | Out-String | Write-Host
}
catch {
    $Report.TopProcessesByCPU = [pscustomobject]@{ Error = $_.Exception.Message }
    Write-Warning ('Unable to read process CPU data: {0}' -f $_.Exception.Message)
}

<#
    SECTION 6: Last 5 System Log Errors
    Reads the System event log and returns the latest 5 Error-level entries.
#>
Write-Section -Title '6) Last 5 System Log Errors'
try {
    $systemErrors = Get-WinEvent -FilterHashtable @{ LogName = 'System'; Level = 2 } -MaxEvents 5 |
        Select-Object TimeCreated, Id, ProviderName, Message

    if ($systemErrors) {
        $Report.LastSystemLogErrors = @($systemErrors)
        $systemErrors | Format-List | Out-String | Write-Host
    }
    else {
        $Report.LastSystemLogErrors = @()
        Write-Host 'No system errors found.'
    }
}
catch {
    $Report.LastSystemLogErrors = [pscustomobject]@{ Error = $_.Exception.Message }
    Write-Warning ('Unable to read system event log errors: {0}' -f $_.Exception.Message)
}

<#
    SECTION 7: Internet Speed
    Performs a read-only download test against a public file and estimates Mbps.
    This does not alter local system state; it only measures throughput.
#>
Write-Section -Title '7) Internet Speed (Estimated Download Mbps)'
try {
    $testUrls = @(
        'https://speed.hetzner.de/10MB.bin',
        'https://proof.ovh.net/files/10Mb.dat'
    )
    [int64]$maxBytesToRead = 1048576

    $completed = $false
    foreach ($testUrl in $testUrls) {
        try {
            $hostName = ([System.Uri]$testUrl).Host
            try {
                [System.Net.Dns]::GetHostAddresses($hostName) | Out-Null
            }
            catch {
                Write-Host ('Speed test endpoint failed (DNS): {0}' -f $testUrl)
                continue
            }

            $request = [System.Net.HttpWebRequest]::Create($testUrl)
            $request.Method = 'GET'
            $request.Timeout = 10000
            $request.ReadWriteTimeout = 10000
            $request.AddRange(0, $maxBytesToRead - 1)

            $sw = [System.Diagnostics.Stopwatch]::StartNew()
            $response = $request.GetResponse()
            $stream = $response.GetResponseStream()

            try {
                $buffer = New-Object byte[] 8192
                [long]$totalBytes = 0

                while ($totalBytes -lt $maxBytesToRead -and ($read = $stream.Read($buffer, 0, $buffer.Length)) -gt 0) {
                    $totalBytes += $read
                }
            }
            finally {
                if ($stream) {
                    $stream.Dispose()
                }
                if ($response) {
                    $response.Dispose()
                }
                $sw.Stop()
            }

            if ($sw.Elapsed.TotalSeconds -gt 0) {
                $mbps = [math]::Round((($totalBytes * 8) / 1MB) / $sw.Elapsed.TotalSeconds, 2)
                $Report.InternetSpeed = [pscustomobject]@{
                    SourceUrl = $testUrl
                    SampledMB = [math]::Round($totalBytes / 1MB, 2)
                    DurationSeconds = [math]::Round($sw.Elapsed.TotalSeconds, 2)
                    EstimatedMbps = $mbps
                }
                Write-Host ('Source URL: {0}' -f $testUrl)
                Write-Host ('Sampled {0} MB in {1} sec' -f ([math]::Round($totalBytes / 1MB, 2)), ([math]::Round($sw.Elapsed.TotalSeconds, 2)))
                Write-Host ('Estimated Download Speed: {0} Mbps' -f $mbps)
                $completed = $true
                break
            }
        }
        catch {
            Write-Host ('Speed test endpoint failed: {0}' -f $testUrl)
        }
    }

    if (-not $completed) {
        $Report.InternetSpeed = [pscustomobject]@{ Error = 'Unable to complete speed test from available endpoints.' }
        Write-Warning 'Unable to complete internet speed test from available endpoints. Verify DNS and outbound HTTPS connectivity.'
    }
}
catch {
    $Report.InternetSpeed = [pscustomobject]@{ Error = $_.Exception.Message }
    Write-Warning ('Unable to complete internet speed test: {0}' -f $_.Exception.Message)
}

<#
    SECTION 8: Microsoft Defender Service Status
    Reads the WinDefend service state to report whether it is running.
#>
Write-Section -Title '8) Microsoft Defender Service Status'
try {
    $defenderSvc = Get-Service -Name WinDefend -ErrorAction SilentlyContinue
    if ($null -eq $defenderSvc) {
        $Report.MicrosoftDefender = [pscustomobject]@{ ServiceName = 'WinDefend'; Installed = $false; IsRunning = $false }
        Write-Host 'WinDefend service not found on this endpoint.'
    }
    else {
        $Report.MicrosoftDefender = [pscustomobject]@{ ServiceName = $defenderSvc.Name; Installed = $true; Status = $defenderSvc.Status.ToString(); IsRunning = ($defenderSvc.Status -eq 'Running') }
        Write-Host ('Service Name: {0}' -f $defenderSvc.Name)
        Write-Host ('Status      : {0}' -f $defenderSvc.Status)
        Write-Host ('Is Running  : {0}' -f ($defenderSvc.Status -eq 'Running'))
    }
}
catch {
    $Report.MicrosoftDefender = [pscustomobject]@{ Error = $_.Exception.Message }
    Write-Warning ('Unable to read Defender service status: {0}' -f $_.Exception.Message)
}

<#
    SECTION 9: Logged-In Users Count
    Reads interactive and remote-interactive logon sessions and counts unique users.
#>
Write-Section -Title '9) Logged-In Users Count'
try {
    $interactiveSessions = Get-CimInstance -ClassName Win32_LogonSession -Filter "LogonType=2 OR LogonType=10"
    $links = Get-CimInstance -ClassName Win32_LoggedOnUser

    $sessionIds = @{}
    foreach ($s in $interactiveSessions) {
        $sessionIds[$s.LogonId] = $true
    }

    $users = @()
    foreach ($link in $links) {
        if ($link.Dependent -match 'Win32_LogonSession\.LogonId="(\d+)"') {
            $logonId = $Matches[1]
            if ($sessionIds.ContainsKey($logonId) -and $link.Antecedent -match 'Win32_Account.Domain="([^"]+)",Name="([^"]+)"') {
                $users += ('{0}\{1}' -f $Matches[1], $Matches[2])
            }
        }
    }

    $uniqueUsers = @($users | Sort-Object -Unique)

    # Fallback for environments where WMI associations are sparse.
    if ($uniqueUsers.Count -eq 0) {
        $quserLines = @(quser 2>$null)
        if ($quserLines.Count -gt 1) {
            $quserUsers = @()
            foreach ($line in $quserLines | Select-Object -Skip 1) {
                $trimmed = $line.TrimStart(' ', '>').Trim()
                if ([string]::IsNullOrWhiteSpace($trimmed)) {
                    continue
                }

                $name = ($trimmed -split '\s+')[0]
                if (-not [string]::IsNullOrWhiteSpace($name)) {
                    $quserUsers += $name
                }
            }

            $uniqueUsers = @($quserUsers | Sort-Object -Unique)
        }
    }

    $Report.LoggedInUsers = [pscustomobject]@{
        Count = $uniqueUsers.Count
        Users = @($uniqueUsers)
    }
    Write-Host ('Logged-In User Count: {0}' -f $uniqueUsers.Count)
    if ($uniqueUsers.Count -gt 0) {
        Write-Host 'Users:'
        $uniqueUsers | ForEach-Object { Write-Host (' - {0}' -f $_) }
    }
}
catch {
    $Report.LoggedInUsers = [pscustomobject]@{ Error = $_.Exception.Message }
    Write-Warning ('Unable to determine logged-in users: {0}' -f $_.Exception.Message)
}

<#
    SECTION 10: Last Windows Update Time
    Reads installed hotfixes and reports the most recent installation date.
#>
Write-Section -Title '10) Last Windows Update Installed'
try {
    $latestHotfix = Get-HotFix |
        Where-Object { $_.InstalledOn } |
        Sort-Object -Property InstalledOn -Descending |
        Select-Object -First 1

    if ($latestHotfix) {
        $Report.LastWindowsUpdate = [pscustomobject]@{
            InstalledOn = $latestHotfix.InstalledOn
            HotFixID = $latestHotfix.HotFixID
            Description = $latestHotfix.Description
        }
        Write-Host ('Installed On : {0}' -f $latestHotfix.InstalledOn)
        Write-Host ('HotFix ID    : {0}' -f $latestHotfix.HotFixID)
        Write-Host ('Description  : {0}' -f $latestHotfix.Description)
    }
    else {
        $Report.LastWindowsUpdate = $null
        Write-Host 'No hotfix installation data found.'
    }
}
catch {
    $Report.LastWindowsUpdate = [pscustomobject]@{ Error = $_.Exception.Message }
    Write-Warning ('Unable to read Windows Update history: {0}' -f $_.Exception.Message)
}

Write-Host ''
Write-Host 'Report complete.'

if ($AsObject) {
    [pscustomobject]$Report
}