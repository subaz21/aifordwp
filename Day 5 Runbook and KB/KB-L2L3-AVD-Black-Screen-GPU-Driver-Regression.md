Title: KB-L2L3-AVD-Black-Screen-GPU-Driver-Regression
Version Header: v 1.0, 07/08/2026, status : Draft
Audience: DWP L2/L3 Engineers
Scope: Diagnose and resolve AVD post-logon black screen caused by GPU driver regression

## Background

Azure Virtual Desktop (AVD) session hosts rely on Desktop Window Manager (DWM) to render the user desktop after authentication. DWM depends on the display/GPU driver stack at logon time. If that stack crashes, users can authenticate successfully but still receive a black screen or disconnect.

Why this matters:
- Authentication can be healthy while user productivity is blocked.
- The failure can look intermittent and user-specific unless logs are correlated.
- A bad image/driver can affect one host pool while another pool remains healthy, so pool-to-pool comparison is critical.

## Symptom

What engineer observes:
- Affected pool users authenticate, then see black screen or are disconnected.
- Some sessions recover after reconnect; others fail repeatedly.
- Session hosts remain online/Available in Azure portal, so this is not a host-down outage.

What users report:
- "I can sign in, but desktop stays black."
- "It disconnects right after login."
- "After reconnecting once or twice, it sometimes works."

Known scope pattern from incident:
- Affected: POOL-FIN-01.
- Unaffected comparator: POOL-FIN-02.

## Root Cause

Specific technical cause:
- Intel GPU driver module `igdumd64.dll` version `31.0.101.4146` (introduced via overnight image update) caused `dwm.exe` to crash during DWM initialization with exception code `0xc0000005` (Access Violation).

Evidence confirming root cause:
- Event ID `1000` (Application Error) on affected hosts:
	- Faulting application: `dwm.exe`
	- Faulting module: `igdumd64.dll`
	- Module version: `31.0.101.4146`
	- Exception code: `0xc0000005`
	- Fault offset observed: `0x0000000000047f12`
- Event ID `9009` follows the crash, indicating DWM exit (`0x40010004`).
- Event ID `21` (successful session logon) appears before failure, proving auth success and post-logon rendering failure.
- Event ID `40` (session disconnect) aligns to crash cycle.
- Unaffected pool (POOL-FIN-02) shows Event ID `9011` (DWM started successfully), and no matching Event ID `1000`/`9009` pattern.

Event IDs used in this KB:
- `21`, `40`, `1000`, `9009`, `9011`

## Detection

Confirm the incident signature fully before applying remediation.

Target: complete all six steps in under 3 minutes using the commands below. Portal steps are secondary verification only.

### Step 1: Confirm host pool impact pattern (Pool 1 vs Pool 2)

Command (run from any machine with the Az PowerShell module and access to the subscription):

```powershell
# Compare session host status across both pools
foreach ($pool in @('POOL-FIN-01','POOL-FIN-02')) {
    Write-Host "`n=== $pool ===" -ForegroundColor Cyan
    Get-AzWvdSessionHost -ResourceGroupName '<ResourceGroupName>' -HostPoolName $pool |
        Select-Object @{N='Host';E={$_.Name.Split('/')[1]}}, Status, Session
}
```

What to look for:
- `POOL-FIN-01`: hosts show `Available` but users report black screen/disconnect (status alone does not confirm healthy rendering).
- `POOL-FIN-02`: no equivalent session spike or disconnect trend.

Portal fallback:
- Azure Portal -> Azure Virtual Desktop -> Host pools -> `POOL-FIN-01` / `POOL-FIN-02` -> Session hosts

### Step 2: Validate Application log crash signature on affected host

Log: **Windows Logs -> Application**

Command (run on or remoted into an affected POOL-FIN-01 host):

```powershell
# Pull Event ID 1000 entries from the Application log that match the DWM + igdumd64.dll signature
Get-WinEvent -FilterHashtable @{LogName='Application'; Id=1000} -MaxEvents 100 |
    Where-Object { $_.Message -like '*igdumd64.dll*' } |
    Select-Object TimeCreated,
        @{N='FaultingApp';   E={ ($_.Message -split '\r?\n' | Select-String 'Faulting application name').Line.Trim() }},
        @{N='FaultingModule';E={ ($_.Message -split '\r?\n' | Select-String 'Faulting module name').Line.Trim() }},
        @{N='ModuleVersion'; E={ ($_.Message -split '\r?\n' | Select-String 'Faulting module version').Line.Trim() }},
        @{N='ExceptionCode'; E={ ($_.Message -split '\r?\n' | Select-String 'Exception code').Line.Trim() }} |
    Format-List
```

Confirmed when output shows:
- `Faulting application name` = `dwm.exe`
- `Faulting module name` = `igdumd64.dll`
- `Faulting module version` = `31.0.101.4146`
- `Exception code` = `0xc0000005`

What to look for:
- Repeated Event 1000 entries with identical `dwm.exe` + `igdumd64.dll` signature across the incident window.

### Step 3: Correlate DWM exit immediately after crash

Log: **Windows Logs -> System**

Command (run on the same affected host):

```powershell
# Pull Event ID 9009 (DWM exit) from the System log
Get-WinEvent -FilterHashtable @{LogName='System'; Id=9009} -MaxEvents 20 |
    Select-Object TimeCreated, Message |
    Format-List
```

What to look for:
- `TimeCreated` of each Event 9009 falls within seconds after a corresponding Event 1000.
- Message includes DWM exit code `0x40010004`.
- Time-linked sequence `1000` -> `9009` on the same host confirms DWM crashed and exited.

### Step 4: Prove logon succeeded before crash (not an auth issue)

Log: **Applications and Services Logs -> Microsoft -> Windows -> TerminalServices-LocalSessionManager -> Operational**

Command (run on the same affected host):

```powershell
# Pull Events 21 (logon) and 40 (disconnect) from the session manager log
Get-WinEvent -FilterHashtable @{
    LogName = 'Microsoft-Windows-TerminalServices-LocalSessionManager/Operational'
    Id      = 21, 40
} -MaxEvents 50 |
    Select-Object TimeCreated, Id,
        @{N='User';     E={ $_.Properties[0].Value }},
        @{N='SessionID';E={ $_.Properties[1].Value }} |
    Sort-Object TimeCreated |
    Format-Table -AutoSize
```

What to look for:
- Event `21` (logon success) appears for the affected user **before** the Event 1000/9009 crash chain.
- Event `40` (disconnect) follows shortly after.
- Matching `User` and `SessionID` across both events confirms this is a post-logon rendering failure, not an authentication failure.

### Step 5: Compare against unaffected pool host (healthy baseline)

Logs checked on a **POOL-FIN-02** host: Application, System, and DWM Operational.

Command (run on or remoted into a POOL-FIN-02 host):

```powershell
# Check Application log for igdumd64.dll crashes — expect zero results on healthy host
$appHits = Get-WinEvent -FilterHashtable @{LogName='Application'; Id=1000} -MaxEvents 100 -ErrorAction SilentlyContinue |
    Where-Object { $_.Message -like '*igdumd64.dll*' }
Write-Host "Application Event 1000 (igdumd64.dll hits): $($appHits.Count)"

# Check System log for DWM exits — expect zero on healthy host
$sysHits = Get-WinEvent -FilterHashtable @{LogName='System'; Id=9009} -MaxEvents 20 -ErrorAction SilentlyContinue
Write-Host "System Event 9009 (DWM exits): $($sysHits.Count)"

# Check DWM Operational for successful starts — expect results on healthy host
$dwmOk = Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-Dwm-Core/Operational'; Id=9011} -MaxEvents 10 -ErrorAction SilentlyContinue
Write-Host "DWM Operational Event 9011 (DWM started successfully): $($dwmOk.Count)"
```

What to look for:
- `Application Event 1000 (igdumd64.dll hits): 0` — no crash signature on POOL-FIN-02.
- `System Event 9009 (DWM exits): 0` — no DWM exit pattern.
- `DWM Operational Event 9011 (DWM started successfully): >0` — confirms healthy DWM startup.

This pool-to-pool contrast is the key differentiator confirming a pool-specific driver regression rather than a platform-wide failure.

### Step 6: Confirm driver version difference

Command (run on both an affected POOL-FIN-01 host and an unaffected POOL-FIN-02 host):

```powershell
# Report the file version of igdumd64.dll
$dll = 'C:\Windows\System32\igdumd64.dll'
if (Test-Path $dll) {
    (Get-Item $dll).VersionInfo | Select-Object FileName, FileVersion, ProductVersion
} else {
    Write-Warning "igdumd64.dll not found on this host."
}
```

What to look for:
- Affected host (POOL-FIN-01): `FileVersion` = `31.0.101.4146`
- Unaffected host (POOL-FIN-02): `FileVersion` = known-good pre-update baseline (any earlier version)

A version mismatch between pools at this point, combined with the Event 1000/9009 pattern, confirms the GPU driver regression as root cause.

## Resolution

Apply in controlled canary-first rollout. Complete all steps in order; do not proceed past Step 4 if canary validation fails — execute Rollback instead.

**Substitute these variables in every command below:**

```powershell
$rg      = '<ResourceGroupName>'      # Resource group containing POOL-FIN-01
$pool    = 'POOL-FIN-01'
$gallery = '<GalleryName>'            # Azure Compute Gallery name
$imgDef  = 'AVD-SessionHost-Image'    # Gallery image definition name
$goodVer = '<KnownGoodImageVersion>'  # Populated in Step 2 — e.g. 1.0.2
$subId   = '<SubscriptionId>'
```

### Step 1: Enable drain mode on all POOL-FIN-01 hosts

Portal path:
- Azure Portal → Azure Virtual Desktop → Host pools → **POOL-FIN-01** → Session hosts → select all host checkboxes → toolbar → **Allow new sessions** → **Off**

Command:

```powershell
Get-AzWvdSessionHost -ResourceGroupName $rg -HostPoolName $pool |
    ForEach-Object {
        $hostName = $_.Name.Split('/')[1]
        Update-AzWvdSessionHost -ResourceGroupName $rg -HostPoolName $pool `
            -Name $hostName -AllowNewSession:$false
        Write-Host "Drain mode ON: $hostName"
    }
```

Confirm drain mode is applied:

```powershell
Get-AzWvdSessionHost -ResourceGroupName $rg -HostPoolName $pool |
    Select-Object @{N='Host';E={$_.Name.Split('/')[1]}}, AllowNewSession, Status, Session |
    Format-Table -AutoSize
```

Expected result: `AllowNewSession = False` on every host; no new sessions will route to the pool.

### Step 2: Identify the known-good image version in Azure Compute Gallery

Portal path:
- Azure Portal → Azure Compute Gallery → **[gallery name]** → Image definitions → **AVD-SessionHost-Image** → Versions → review `Published date` column → select the version published **before** the overnight update window → record the version number.

Command:

```powershell
Get-AzGalleryImageVersion -ResourceGroupName $rg -GalleryName $gallery `
    -GalleryImageDefinitionName $imgDef |
    Select-Object Name,
        @{N='Published';E={$_.PublishingProfile.PublishedDate}},
        @{N='State';E={$_.ProvisioningState}} |
    Sort-Object Published -Descending |
    Format-Table -AutoSize
```

Expected result: a list of versions sorted newest-first. Identify the last version published **before** the overnight update — this is the known-good baseline. Set `$goodVer` to its `Name` value before continuing.

### Step 3: Reimage 2 canary hosts to the known-good version

Portal path:
- Azure Portal → Azure Virtual Desktop → Host pools → **POOL-FIN-01** → Session hosts → **[CanaryHost]** → click the VM name hyperlink → **Overview** → **Stop** (wait for `Stopped (deallocated)`) → **Disks** blade → **OS disk** → confirm `Image reference` → return to VM **Overview** → **Reimage** → under **Image** select the known-good gallery version → **OK**

Command (targets 2 canary VMs; assumes pooled hosts with gallery-sourced OS disk):

```powershell
$canaryVMs   = @('<CanaryHost1VMName>', '<CanaryHost2VMName>')
$correctImgId = "/subscriptions/$subId/resourceGroups/$rg/providers/Microsoft.Compute/" +
                "galleries/$gallery/images/$imgDef/versions/$goodVer"

foreach ($vmName in $canaryVMs) {
    Write-Host "Stopping: $vmName"
    Stop-AzVM -ResourceGroupName $rg -Name $vmName -Force

    $vm = Get-AzVM -ResourceGroupName $rg -Name $vmName
    $vm.StorageProfile.ImageReference = New-Object `
        Microsoft.Azure.Management.Compute.Models.ImageReference -Property @{ Id = $correctImgId }
    Update-AzVM -ResourceGroupName $rg -VM $vm | Out-Null

    Write-Host "Reimaging: $vmName"
    Set-AzVM -ResourceGroupName $rg -Name $vmName -Reimage | Out-Null
    Write-Host "Reimage submitted: $vmName"
}
```

Poll for canary hosts to return `Available` in the host pool:

```powershell
do {
    Start-Sleep -Seconds 30
    $statuses = Get-AzWvdSessionHost -ResourceGroupName $rg -HostPoolName $pool |
        Where-Object { $_.Name.Split('/')[1] -in $canaryVMs } |
        Select-Object @{N='Host';E={$_.Name.Split('/')[1]}}, Status
    $statuses | Format-Table -AutoSize
} while ($statuses.Status -contains 'Unavailable')
Write-Host "Both canary hosts are Available."
```

Expected result: both canary hosts show `Status = Available` in POOL-FIN-01.

### Step 4: Validate canary hosts — must pass before full rollout

Run on each canary host (requires PowerShell remoting or RDP):

```powershell
Invoke-Command -ComputerName $canaryVMs -ScriptBlock {
    $crashes = Get-WinEvent -FilterHashtable @{
        LogName   = 'Application'
        Id        = 1000
        StartTime = (Get-Date).AddMinutes(-30)
    } -ErrorAction SilentlyContinue |
        Where-Object { $_.Message -like '*igdumd64.dll*' }

    $dwmOk = Get-WinEvent -FilterHashtable @{
        LogName   = 'Microsoft-Windows-Dwm-Core/Operational'
        Id        = 9011
        StartTime = (Get-Date).AddMinutes(-30)
    } -ErrorAction SilentlyContinue

    [PSCustomObject]@{
        Host        = $env:COMPUTERNAME
        Crashes1000 = $crashes.Count    # must be 0
        DWMOk9011   = $dwmOk.Count      # must be > 0
    }
} | Format-Table -AutoSize
```

Pass criteria:
- `Crashes1000 = 0` on both canary hosts.
- `DWMOk9011 > 0` on both canary hosts.

**If either canary fails, stop here and execute Rollback. Do not continue to Step 5.**

### Step 5: Reimage remaining POOL-FIN-01 hosts in batches of 3

Portal path (per batch):
- Azure Portal → Azure Virtual Desktop → Host pools → **POOL-FIN-01** → Session hosts → select **2–3 host checkboxes** → toolbar → **Restart** (or navigate to each VM's **Overview** blade → **Reimage** → select known-good version → **OK**)

Command:

```powershell
$allHosts = (Get-AzWvdSessionHost -ResourceGroupName $rg -HostPoolName $pool).Name |
    ForEach-Object { $_.Split('/')[1] }
$remainingVMs = $allHosts | Where-Object { $_ -notin $canaryVMs }

$batchSize = 3
for ($i = 0; $i -lt $remainingVMs.Count; $i += $batchSize) {
    $batch = $remainingVMs[$i .. ([Math]::Min($i + $batchSize - 1, $remainingVMs.Count - 1))]
    Write-Host "Processing batch: $($batch -join ', ')"

    foreach ($vmName in $batch) {
        Stop-AzVM -ResourceGroupName $rg -Name $vmName -Force -NoWait | Out-Null
    }
    Start-Sleep -Seconds 90

    foreach ($vmName in $batch) {
        $vm = Get-AzVM -ResourceGroupName $rg -Name $vmName
        $vm.StorageProfile.ImageReference = New-Object `
            Microsoft.Azure.Management.Compute.Models.ImageReference -Property @{ Id = $correctImgId }
        Update-AzVM -ResourceGroupName $rg -VM $vm | Out-Null
        Set-AzVM -ResourceGroupName $rg -Name $vmName -Reimage | Out-Null
        Write-Host "Reimage submitted: $vmName"
    }
    Write-Host "Batch done. Waiting 120s before next batch..."
    Start-Sleep -Seconds 120
}
```

Expected result: hosts return to `Available` progressively without a reconnect storm.

### Step 6: Disable drain mode — re-enable session routing

Portal path:
- Azure Portal → Azure Virtual Desktop → Host pools → **POOL-FIN-01** → Session hosts → select all host checkboxes → toolbar → **Allow new sessions** → **On**

Command (run only after all hosts pass verification below):

```powershell
Get-AzWvdSessionHost -ResourceGroupName $rg -HostPoolName $pool |
    ForEach-Object {
        Update-AzWvdSessionHost -ResourceGroupName $rg -HostPoolName $pool `
            -Name $_.Name.Split('/')[1] -AllowNewSession:$true
        Write-Host "Drain mode OFF: $($_.Name.Split('/')[1])"
    }
```

Expected result: new sessions accepted by all remediated POOL-FIN-01 hosts.

---

## Verification

Run after Resolution Step 6. All four checks must pass before closing the incident.

### Check 1: All POOL-FIN-01 hosts Available and accepting sessions

Portal path:
- Azure Portal → Azure Virtual Desktop → Host pools → **POOL-FIN-01** → Session hosts → confirm `Status = Available` and `Allow new sessions = On` for every host in the list.

Command:

```powershell
Get-AzWvdSessionHost -ResourceGroupName $rg -HostPoolName $pool |
    Select-Object @{N='Host';E={$_.Name.Split('/')[1]}}, Status, AllowNewSession, Session |
    Format-Table -AutoSize
```

Pass criteria: every host shows `Status = Available` and `AllowNewSession = True`.

### Check 2: No new crash events on remediated hosts (last 1 hour)

Portal path (manual fallback):
- On each remediated host: Event Viewer → Windows Logs → **Application** → filter Event ID `1000`, last 1 hour.
- On each remediated host: Event Viewer → Windows Logs → **System** → filter Event ID `9009`, last 1 hour.
- On each remediated host: Event Viewer → Applications and Services Logs → Microsoft → Windows → **Desktop Window Manager → Operational** → filter Event ID `9011`, last 1 hour.

Command (run against all remediated hosts at once):

```powershell
Invoke-Command -ComputerName $allHosts -ScriptBlock {
    $crashes = Get-WinEvent -FilterHashtable @{
        LogName   = 'Application'
        Id        = 1000
        StartTime = (Get-Date).AddHours(-1)
    } -ErrorAction SilentlyContinue |
        Where-Object { $_.Message -like '*igdumd64.dll*' }

    $exits = Get-WinEvent -FilterHashtable @{
        LogName   = 'System'
        Id        = 9009
        StartTime = (Get-Date).AddHours(-1)
    } -ErrorAction SilentlyContinue

    $dwmOk = Get-WinEvent -FilterHashtable @{
        LogName   = 'Microsoft-Windows-Dwm-Core/Operational'
        Id        = 9011
        StartTime = (Get-Date).AddHours(-1)
    } -ErrorAction SilentlyContinue

    [PSCustomObject]@{
        Host         = $env:COMPUTERNAME
        Crashes1000  = $crashes.Count    # must be 0
        DWMExits9009 = $exits.Count      # must be 0
        DWMOk9011    = $dwmOk.Count      # must be > 0
    }
} | Format-Table -AutoSize
```

Pass criteria:
- `Crashes1000 = 0` on every host.
- `DWMExits9009 = 0` on every host.
- `DWMOk9011 > 0` on every host.

### Check 3: No new disconnect spike in Insights

Portal path:
- Azure Portal → Azure Virtual Desktop → Host pools → **POOL-FIN-01** → **Insights** → **Connections** workbook → set time range to last 60 minutes → review disconnect count.

Pass criteria: no spike above pre-incident baseline.

### Check 4: Service Desk queue clear

Check the Service Desk queue for tickets tagged `POOL-FIN-01` or `black screen` created in the last 60 minutes. Pass criteria: no new tickets.

---

## Rollback

Execute immediately if canary validation fails (Resolution Step 4) or if error rate worsens after full rollout. Run commands first, notify the team in parallel.

### Rollback Step 1: Re-enable drain mode immediately

Portal path:
- Azure Portal → Azure Virtual Desktop → Host pools → **POOL-FIN-01** → Session hosts → select all host checkboxes → toolbar → **Allow new sessions** → **Off**

Command:

```powershell
Get-AzWvdSessionHost -ResourceGroupName $rg -HostPoolName $pool |
    ForEach-Object {
        Update-AzWvdSessionHost -ResourceGroupName $rg -HostPoolName $pool `
            -Name $_.Name.Split('/')[1] -AllowNewSession:$false
    }
Write-Host "Drain mode ON — all POOL-FIN-01 hosts blocking new sessions."
```

Expected result: no new sessions routed to affected hosts within seconds.

### Rollback Step 2: Identify the stable pre-regression image version

Portal path:
- Azure Portal → Azure Compute Gallery → **[gallery name]** → Image definitions → **AVD-SessionHost-Image** → Versions → identify the version published before the regression-introducing update → record the version number.

Command:

```powershell
Get-AzGalleryImageVersion -ResourceGroupName $rg -GalleryName $gallery `
    -GalleryImageDefinitionName $imgDef |
    Select-Object Name,
        @{N='Published';E={$_.PublishingProfile.PublishedDate}},
        @{N='State';E={$_.ProvisioningState}} |
    Sort-Object Published -Descending |
    Format-Table -AutoSize
```

Set `$rollbackVer` to the stable version `Name` before running Step 3:

```powershell
$rollbackVer  = '<StableBaselineVersion>'
$rollbackImgId = "/subscriptions/$subId/resourceGroups/$rg/providers/Microsoft.Compute/" +
                 "galleries/$gallery/images/$imgDef/versions/$rollbackVer"
```

### Rollback Step 3: Reimage 2 rollback canary hosts to stable baseline

Portal path:
- Azure Portal → Virtual Machines → **[RollbackCanaryVM]** → **Overview** → **Stop** (wait for `Stopped (deallocated)`) → **Reimage** → under **Image** select the stable baseline version → **OK**

Command:

```powershell
$rollbackCanaries = @('<RollbackCanary1VMName>', '<RollbackCanary2VMName>')

foreach ($vmName in $rollbackCanaries) {
    Write-Host "Stopping: $vmName"
    Stop-AzVM -ResourceGroupName $rg -Name $vmName -Force

    $vm = Get-AzVM -ResourceGroupName $rg -Name $vmName
    $vm.StorageProfile.ImageReference = New-Object `
        Microsoft.Azure.Management.Compute.Models.ImageReference -Property @{ Id = $rollbackImgId }
    Update-AzVM -ResourceGroupName $rg -VM $vm | Out-Null
    Set-AzVM -ResourceGroupName $rg -Name $vmName -Reimage | Out-Null
    Write-Host "Reimage submitted: $vmName"
}
```

### Rollback Step 4: Validate rollback canaries before completing full rollback

Command:

```powershell
Invoke-Command -ComputerName $rollbackCanaries -ScriptBlock {
    $crashes = Get-WinEvent -FilterHashtable @{
        LogName   = 'Application'
        Id        = 1000
        StartTime = (Get-Date).AddMinutes(-30)
    } -ErrorAction SilentlyContinue |
        Where-Object { $_.Message -like '*igdumd64.dll*' }

    $dwmOk = Get-WinEvent -FilterHashtable @{
        LogName   = 'Microsoft-Windows-Dwm-Core/Operational'
        Id        = 9011
        StartTime = (Get-Date).AddMinutes(-30)
    } -ErrorAction SilentlyContinue

    [PSCustomObject]@{
        Host        = $env:COMPUTERNAME
        Crashes1000 = $crashes.Count    # must be 0
        DWMOk9011   = $dwmOk.Count      # must be > 0
    }
} | Format-Table -AutoSize
```

Pass criteria: `Crashes1000 = 0` and `DWMOk9011 > 0` on both rollback canaries. If either still fails, escalate to L3 — do not complete full rollback rollout.

### Rollback Step 5: Reimage remaining hosts to stable baseline in batches

Command:

```powershell
$remainingRollback = $allHosts | Where-Object { $_ -notin $rollbackCanaries }

for ($i = 0; $i -lt $remainingRollback.Count; $i += $batchSize) {
    $batch = $remainingRollback[$i .. ([Math]::Min($i + $batchSize - 1, $remainingRollback.Count - 1))]
    Write-Host "Rollback batch: $($batch -join ', ')"

    foreach ($vmName in $batch) {
        Stop-AzVM -ResourceGroupName $rg -Name $vmName -Force -NoWait | Out-Null
    }
    Start-Sleep -Seconds 90

    foreach ($vmName in $batch) {
        $vm = Get-AzVM -ResourceGroupName $rg -Name $vmName
        $vm.StorageProfile.ImageReference = New-Object `
            Microsoft.Azure.Management.Compute.Models.ImageReference -Property @{ Id = $rollbackImgId }
        Update-AzVM -ResourceGroupName $rg -VM $vm | Out-Null
        Set-AzVM -ResourceGroupName $rg -Name $vmName -Reimage | Out-Null
        Write-Host "Reimage submitted: $vmName"
    }
    Start-Sleep -Seconds 120
}
```

Expected result: all hosts return to `Available` running the stable baseline image.

### Rollback Step 6: Disable drain mode after rollback verification passes

Portal path:
- Azure Portal → Azure Virtual Desktop → Host pools → **POOL-FIN-01** → Session hosts → select all host checkboxes → toolbar → **Allow new sessions** → **On**

Command:

```powershell
Get-AzWvdSessionHost -ResourceGroupName $rg -HostPoolName $pool |
    ForEach-Object {
        Update-AzWvdSessionHost -ResourceGroupName $rg -HostPoolName $pool `
            -Name $_.Name.Split('/')[1] -AllowNewSession:$true
    }
Write-Host "Drain mode OFF — users routed to stable POOL-FIN-01 hosts."
```

Expected result: users connect to stable hosts; black-screen reports stop.

## Preventive

Implement these specific controls to prevent recurrence.

### 1. Image pipeline release gate — pre-deployment smoke test

Day 6 - L2-L3 KB Creations- **Owner:** Image owner (raises); release engineer (operates gate).
- **Timing:** Pre-deployment — gate fires in the image CI/CD pipeline before any production host receives the new image.
- **Type:** Automated. [REQUIRES: image CI/CD pipeline with a post-logon event log assertion step]
- **Pass criteria:** Canary test logon on a staging host produces: zero Event `1000` with `dwm.exe` + `igdumd64.dll`; zero Event `9009` in the test window; at least one Event `9011` per test logon session.
- **Fail action:** Pipeline blocks promotion and notifies the image owner. Release is held until a corrected image version passes the gate — no manual override permitted without change manager approval.

### 2. Driver delta policy — pre-deployment approval gate

- **Owner:** Image owner (raises the change record); change manager (approves).
- **Timing:** Pre-deployment — change record must be approved before the image version containing any GPU driver version change enters the build pipeline.
- **Type:** Manual. Automation approach: add a pipeline gate that queries the ITSM API for a matching approved change record before the build starts.
- **Pass criteria:** A dedicated change record exists citing the specific driver version delta (old version → new version) with explicit change manager sign-off, separate from any generic OS patch bundle approval.
- **Fail action:** Release engineer blocks the image build. Image does not progress to canary stage. Image owner re-raises with correct documentation.

### 3. Pool-differential canary standard — in-flight deployment gate

- **Owner:** Release engineer.
- **Timing:** During deployment — canary phase runs against 2 hosts before any batch rollout to remaining hosts.
- **Type:** Manual. Automation approach: add the `Invoke-Command` event log check from Resolution Step 4 as a pipeline test step that gates promotion to batch rollout.
- **Pass criteria:** After reimage of 2 POOL-FIN-01 canary hosts, the Resolution Step 4 command returns `Crashes1000 = 0` and `DWMOk9011 > 0` on both canaries. POOL-FIN-02 (control pool, unchanged) shows zero new Event `1000`/`9009` in the same window.
- **Fail action:** Release engineer halts rollout immediately and executes Rollback. No further hosts receive the new image until root cause is identified.

### 4. Automated log analytics alerting — in-flight monitoring

- **Owner:** DWP engineer (creates and maintains the alert rule).
- **Timing:** During and after deployment — alert is active continuously; evaluated from canary reimage through 24 hours post-rollout.
- **Type:** Automated. [REQUIRES: Log Analytics workspace connected to AVD session host Windows Event log via Azure Monitor Agent]
- **Pass criteria (no alert):** Zero Event `1000` matching `dwm.exe` + `igdumd64.dll` on any POOL-FIN-01 host in any 10-minute window.
- **Fail action (alert fires):** On-call DWP engineer enables drain mode (Resolution Step 1) immediately without waiting for manager approval, then assesses whether to halt rollout or execute Rollback. Alert threshold: ≥ 3 Event `1000` on a single host within 10 minutes.

### 5. Release holdback window — in-flight soak gate

- **Owner:** Release engineer (monitors); change manager (approves early exit if required during business-critical windows).
- **Timing:** During deployment — holdback begins after canary reimage completes (Resolution Step 3) and ends only when the soak criteria below are met.
- **Type:** Manual. Automation approach: pipeline timer gate that re-runs the Resolution Step 4 `Invoke-Command` assertion after 30 minutes and promotes to batch rollout only on pass.
- **Pass criteria:** 30-minute soak on canary hosts with zero Event `1000` (`igdumd64.dll`) and at least one Event `9011` produced by a real or test user logon on each canary host during the window.
- **Fail action:** Holdback extends; release engineer reassesses or initiates Rollback. Business-critical-window deployments require change manager sign-off to continue after a failed soak.

### 6. Post-deployment validation gate — change closure check

*Gap addressed: no control previously required healthy-state confirmation before closing the change.*

- **Owner:** Release engineer (runs checks); change manager (approves closure).
- **Timing:** After deployment — run immediately before closing the change record, no later than 2 hours post-rollout.
- **Type:** Manual. Automation approach: wrap the Verification section `Invoke-Command` block into a scheduled pipeline job that outputs a pass/fail report for change manager sign-off.
- **Pass criteria:** All four Verification checks pass — every host `Available` with `AllowNewSession = True`; `Crashes1000 = 0` and `DWMOk9011 > 0` across all hosts; no new disconnect spike in POOL-FIN-01 Insights; zero new black-screen tickets in the last 60 minutes.
- **Fail action:** Change record stays open; release engineer escalates to L3 before any retry.

### 7. Rollback trigger threshold — explicit fire condition

*Gap addressed: Control 4 raised the alert but did not name a trigger owner or define the exact action threshold.*

- **Owner:** On-call DWP engineer (manual trigger); Azure Monitor action group (automated drain mode) [REQUIRES: Azure Automation runbook linked to Monitor action group].
- **Timing:** During deployment — evaluated continuously from canary reimage through full rollout completion.
- **Type:** Alert automated; response manual (automated response requires runbook). Automation approach: Azure Monitor alert action group invokes an Azure Automation runbook to call `Update-AzWvdSessionHost -AllowNewSession:$false` on the triggering host automatically.
- **Pass criteria (no trigger):** Zero Event `1000` (`igdumd64.dll`) per host in any 10-minute window across the entire rollout.
- **Fail action:** Trigger condition — ≥ 3 Event `1000` on a single host in 10 minutes, OR any canary validation failure in Resolution Step 4. Engineer runs Rollback Step 1 (drain mode) immediately; does not wait for batch to complete.

### 8. Knowledge update — incident learning integration

*Gap addressed: no control required this KB, the runbook, or the KEDB to be updated after an incident.*

- **Owner:** DWP engineer who led the incident (raises updates); image owner (reviews); service desk lead (updates L1 guidance if needed).
- **Timing:** After deployment — must be completed within 5 business days of incident closure.
- **Type:** Manual.
- **Pass criteria:** This KB, `Runbook-AVD-Black-Screen-GPU-Driver-Recovery.md`, and `Issue-AVD-Black-Screen-KEDB.md` are updated to reflect any new driver version, event offset, or pool name introduced by the incident. The change record number is cross-referenced in all three artifacts.
- **Fail action:** Service desk lead flags the update as overdue in the change record; no new image release is approved for POOL-FIN-01 until the knowledge update is complete.

## Related

Connected artifacts:
- Runbook: `Runbook-AVD-Black-Screen-GPU-Driver-Recovery.md`
- RCA: `Issue-AVD-Black-Screen-RCA.md`
- KEDB summary: `Issue-AVD-Black-Screen-KEDB.md`
- L1 user-facing KB: `KB-L1-Black-Screen-Sign-In-Self-Service.md`

Connected incident pattern:
- AVD post-logon black screen/disconnect after image update where one host pool is affected and a peer pool is healthy.
