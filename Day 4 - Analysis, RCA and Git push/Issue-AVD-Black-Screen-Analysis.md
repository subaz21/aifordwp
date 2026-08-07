# AVD Incident Analysis: POOL-FIN-01 Black Screen
**Date**: 2026-08-06  
**Symptom**: Blank screen post-login; clears after 30s for ~40% of users on POOL-FIN-01, persists for others  
**Scope Facts**:
- Affects ~40% of users on POOL-FIN-01; POOL-FIN-02 completely unaffected
- Overnight image update to POOL-FIN-01 only at 02:00
- POOL-FIN-02 was NOT updated
- Symptoms observed starting ~07:00 (5-hour delay)

---

## Key Insight
**Image update to POOL-FIN-01 only at 02:00 → symptoms at 07:00 + POOL-FIN-02 completely unaffected = root cause is image-specific, not environment-wide.**

---

## Ranked Hypotheses (Most to Least Consistent with Timing Clue)

### 1. **Display Driver or GPU Initialization Failure**
**Consistency with "POOL-FIN-02 not updated, completely unaffected":**
- Driver packages are deployed **within the image only**
- If updated image contains broken driver version, POOL-FIN-02 (unchanged) has zero risk
- POOL-FIN-02 using old driver version explains perfect immunity
- **Direct causal link**: 02:00 image deployed → driver files installed → 07:00 first VM boots → driver enumeration on login fails → black screen

**Symptom fit:**
- 30s clear time matches GPU driver re-initialization or fallback to software rendering
- 40% user impact = driver cached on some VMs before update, or hardware variance (some VMs different GPU SKUs)

**Fastest confirmation check:**
```powershell
Get-WmiObject Win32_PnPDevice -Filter "DeviceID like '%DISPLAY%'" | Select Name, Status
```
+ Event Viewer → System logs for "atikmpag", "nvidia", or "dxgkrnl" errors 07:00–08:00

---

### 2. **Logon/Startup Scripts Added or Modified in Updated Image**
**Consistency with "POOL-FIN-02 not updated, completely unaffected":**
- New/modified scripts are packaged in the image
- If scripts were added to POOL-FIN-01's image, POOL-FIN-02 (not updated) has zero risk
- **Direct causal link**: 02:00 image deployment adds scripts → 07:00 morning logons execute new scripts → hang/timeout
- POOL-FIN-02 still running old scripts = no symptoms

**Symptom fit:**
- 30s clear time = script timeout or completion (typical Group Policy/login script window)
- 40% impact = only users with full-profile logons trigger scripts (cached profiles skip)

**Fastest confirmation check:**
- Press Ctrl+Shift+Esc during black screen, check Task Manager for unusual processes
```powershell
Get-EventLog System -After (Get-Date).AddHours(-8) | Where-Object {$_.EventID -eq 1000 -or $_.EventID -eq 1001} | Select TimeGenerated, Message
```

---

### 3. **UPD/Profile Container Configuration or Mount Path Changed in Updated Image**
**Consistency with "POOL-FIN-02 not updated, completely unaffected":**
- Profile handling is image-specific
- If updated image changed FSLogix/UPD mount config, POOL-FIN-02 (unchanged) continues using old config
- **Direct causal link**: 02:00 image deployment changes profile handling → 07:00 first logons use new (problematic) profile mount → delay/hang
- POOL-FIN-02 unaffected because unchanged profile config

**Symptom fit:**
- 30s clear = profile finally loads after mount delay
- 40% impact = only users with large profiles or network latency experience persistent hang; others load in 30s

**Fastest confirmation check:**
```powershell
Get-ItemProperty "HKLM:\SOFTWARE\FSLogix\Profiles"
Get-Volume | Where-Object {$_.FileSystem -eq 'NTFS'} | Sort-Object Name
# Compare C:\Users timestamp deltas between affected/unaffected users
```

---

### 4. **Registry Configuration or Shell Initialization Corruption (from Partial Image Update Rollback/Failure)**
**Consistency with "POOL-FIN-02 not updated, completely unaffected":**
- Corruption from failed/partial image deployment would only affect POOL-FIN-01
- POOL-FIN-02 never got the update, so no rollback, no corruption
- **Weaker causal link** than driver/script (which are active code paths); this is passive state corruption

**Symptom fit:**
- 30s clear = explorer.exe eventually recovers from corrupted registry hive load
- 40% impact = only VMs where rollback was incomplete/partial

**Fastest confirmation check:**
```powershell
sfc /scannow
DISM /Online /Cleanup-Image /RestoreHealth
```
+ Event Viewer → Application logs for Explorer.exe crashes or "Desktop Window Manager" errors 07:00–08:00

---

### 5. **Windows Update or Patch Deployment Triggered by Updated Image** ⚠️ **LEAST CONSISTENT**
**Consistency with "POOL-FIN-02 not updated, completely unaffected":**
- **Weak coupling**: Standard patch deployments are **not image-specific**
- Patches deployed via WSUS/Group Policy typically affect all pools, not pool-specific
- **If it's a standard patch, POOL-FIN-02 should be affected too (but it isn't)**
- Only if the updated image *explicitly triggers* new patches would this explain differential—but that's indirect
- The fact POOL-FIN-02 is "completely unaffected" suggests root cause is **image-specific, not environment-wide**

**Symptom fit:**
- 30s delay = Update Orchestrator downloading/installing patches silently
- 40% impact = selective patch applicability based on VM config/age

**Fastest confirmation check:**
```powershell
Get-HotFix | Sort-Object InstalledOn -Descending | Select-Object -First 10
# Compare HotFix lists between POOL-FIN-01 and POOL-FIN-02
```
Check `C:\Windows\SoftwareDistribution\Download` folder size—large = pending updates.

---

## Ranking Logic
**POOL-FIN-02 completely unaffected + image updated only to POOL-FIN-01 = root cause must be image-specific**

- ✓ Causes 1–4: Packaged in or directly triggered by the image deployment
- ✗ Cause 5: Could be environment-wide (should then affect POOL-FIN-02 too)

---

## Next Steps
1. **Start with Cause #1 (Display Driver)** — fastest, non-invasive check; if negative, move to #2–#4 in parallel
2. **Do NOT assume single cause yet** — the 40% selective impact suggests either:
   - Multiple VMs in post-update state variance, OR
   - Dependency chain (e.g., driver failure → script timeout → fallback behavior)
3. **Use pool differential as validation**: Any hypothesis should predict why POOL-FIN-02 has zero symptoms

---

## Event Log Evidence Analysis

### Event Data from Affected Host: SHFIN-01-A (POOL-FIN-01)
**Collection window:** 2024-03-15 07:00–07:30 (incident onset)

#### Timeline Summary
```
07:02:10  Session logon succeeded for user mlopez (Session ID: 3)
07:02:14  System boot time confirmed: 2024-03-15 02:03:11 (post-image-update)
07:02:16  ⚠️ Application Error (Event 1000): dwm.exe crashed in igdumd64.dll
07:02:17  Session disconnected (reason code: 0 = driver/graphics failure)
07:02:18  Desktop Window Manager exited with code 0x40010004
07:02:44  mlopez reconnects (first retry)
07:02:46  ⚠️ Application Error (Event 1000): dwm.exe crashes again in igdumd64.dll
07:02:47  Session disconnected
07:03:01  Desktop Window Manager exited with code 0x40010004
07:03:10  mlopez reconnects (second retry) — session persists cleanly
07:08:22  Second user (akapoor) logs in
07:08:24  ⚠️ Application Error (Event 1000): dwm.exe crashes in igdumd64.dll
```

#### Critical Event Details

**Event 1000 (Application Error)** @ 07:02:16, 07:02:46, 07:08:24
- **Faulting application:** dwm.exe (Desktop Window Manager) v10.0.22621.2861
- **Faulting module:** igdumd64.dll (Intel GPU driver) v31.0.101.4146
- **Exception code:** 0xc0000005 (Access Violation — memory fault)
- **Fault offset:** 0x0000000000047f12
- **Faulting process ID:** 0x1a4c
- **Report ID:** b7f2a3d1-44cc-4e88-9f12-3c1ab2d09e55

**Event 9009 (Desktop Window Manager Error)** @ 07:02:18, 07:03:01
- **Message:** Desktop Window Manager has exited with code 0x40010004
- **Timing:** Immediate follow-up to dwm.exe crash (secondary failure cascade)

### Comparison: Unaffected Host SHFIN-02-A (POOL-FIN-02)

**Image version:** 10.0.22621.2861-build-20240313 (pre-update, unchanged)  
**User logon:** 07:01:44 (bwalker, Session ID: 2)

- **Event 9011 (Desktop Window Manager Information)** @ ~07:01:46
  - Message: "Desktop Window Manager started successfully"
- **No Application Error events in collection window**
- **No GPU driver faults (igdumd64.dll)**
- **Session persists cleanly**

---

## Hypothesis Evaluation Against Evidence

### 1. **Display Driver (GPU Initialization Failure)** ✅ **STRONGLY SUPPORTED**

**Judgement: SUPPORTS ROOT CAUSE**

**Specific evidence:**
- **Event 1000 crashes** consistently point to `igdumd64.dll` (Intel GPU driver v31.0.101.4146)
- **Exception code 0xc0000005** = Access Violation; classic driver memory fault pattern
- **Timing**: Crashes occur 6 seconds after logon Event 21 → during DWM/display initialization
- **Repeatability**: Same module faults on multiple user logons (mlopez 07:02:16/07:02:46, akapoor 07:08:24)
- **Recovery pattern**: User succeeds after 3 reconnect cycles → suggests transient initialization race condition, not persistent corruption
- **POOL-FIN-02 immunity**: Old driver version (pre-update image) → zero driver faults, DWM starts successfully (Event 9011)

**This is the smoking gun.** igdumd64.dll is deployed within the image; POOL-FIN-01 updated image contains corrupted/incompatible driver version.

---

### 2. **Logon/Startup Scripts** ✗ **CONTRADICTS**

**Judgement: CONTRADICTS**

**Specific evidence:**
- Crash occurs @ 07:02:16 — only **6 seconds after logon Event 21**
- Group Policy/startup scripts execute *after* desktop renders; this crash happens *during* DWM initialization (pre-desktop)
- **No script-related Event IDs present**: No Event 1096/1097 (GP errors), no timeout events, no script interpreter processes
- **Fault is GPU driver module, not script runtime**: Exception code 0xc0000005 in igdumd64.dll, not cmd.exe or powershell.exe
- If scripts caused hang, you would see timeout recovery + different Event signature

**Verdict:** Timing and module-specific fault rule out script execution as primary cause.

---

### 3. **UPD/Profile Container Configuration** ✗ **CONTRADICTS**

**Judgement: CONTRADICTS**

**Specific evidence:**
- **Event 21 (Session logon succeeded)** @ 07:02:10 proves profile successfully loaded
  - RDS session cannot establish without UPD mount and initialization
  - If profile mount failed, Event 21 would show "failed" or no event would exist
- **Crash occurs *after* profile load**: Profile mounted at 07:02:10, crash at 07:02:16
- **Issue is post-login display rendering**: Session disconnects due to DWM crash, not profile unavailability
- **Third logon succeeds and persists** (07:03:10) → if UPD was misconfigured, repeated logons would fail consistently

**Verdict:** Profile loaded successfully; disconnection is caused by display crash, not profile mount failure.

---

### 4. **Registry Corruption / Shell Initialization** ✗ **CONTRADICTS**

**Judgement: CONTRADICTS**

**Specific evidence:**
- **Crash is repeatable on *same module* then recovers**: All three faults point to igdumd64.dll, not varied explorer/shell errors
- If registry/shell was persistently corrupted, Explorer.exe would crash; instead only DWM faults
- **Persistent corruption wouldn't resolve after retries**: mlopez's third logon (07:03:10) succeeds cleanly → transient issue, not persistent state corruption
- **No Explorer.exe or shell errors present**: Only dwm.exe faults; indicates driver-level issue, not OS-level

**Verdict:** Recovery pattern + same-module crashes rule out persistent corruption; this is transient initialization failure.

---

### 5. **Windows Update / Patch Deployment** ✗ **CONTRADICTS**

**Judgement: CONTRADICTS**

**Specific evidence:**
- **Zero Windows Update events in logs**: No Event 19 (Install Started), 24 (Complete), 25 (Failed)
- No Microsoft-Windows-WindowsUpdateClient or Update Orchestrator activity
- **Boot at 02:03:11 shows clean startup**: No update installation artifacts or stalled processes
- **Crash signature is GPU driver, not patch-related**: igdumd64.dll Access Violation, not OS patch artifact
- **POOL-FIN-02 unaffected**: If patch deployment, POOL-FIN-02 should show update activity or be scheduled; instead shows normal operation with old image

**Verdict:** Event logs show zero update activity; issue is specifically GPU driver in updated image, not platform-wide patch.

### Summary: Hypothesis Evaluation Table

| Hypothesis | Judgement | Key Event ID(s) | Timing |
|---|---|---|---|
| **1. GPU Driver Failure** | ✅ **SUPPORT** | Event 1000 (igdumd64.dll), 9009 | 07:02:16, 07:02:46, 07:08:24 |
| **2. Startup Scripts** | ✗ **CONTRADICT** | None (no 1096/1097) | 6 sec after logon (too fast) |
| **3. UPD/Profile Mount** | ✗ **CONTRADICT** | Event 21 succeeded | Profile loaded before crash |
| **4. Registry Corruption** | ✗ **CONTRADICT** | Absence of varied errors | Recovers after retries |
| **5. Patch Deployment** | ✗ **CONTRADICT** | None (no 19/24/25) | Zero update events present |

---

## Root Cause: Intel GPU Driver Initialization Failure

**Confirmed Cause:** Intel GPU driver `igdumd64.dll` v31.0.101.4146 in POOL-FIN-01 updated image causes Access Violation (0xc0000005) during Desktop Window Manager initialization on user logon.

**Why it survives all evidence:**
- Direct, repeatable crashes in Event 1000 with fault module igdumd64.dll
- Timing: 07:00 image boots + 07:02 first user logon = driver initialization attempted
- POOL-FIN-02 (pre-update image, older driver version) shows zero driver faults
- Recovery after 3 retries matches user observation of "30s clear" + persistent cases (users who don't retry)
- 40% selective impact likely reflects:
  - Driver initialization race condition (timing-dependent)
  - Hardware variance (GPU SKU differences across POOL-FIN-01 VMs)

---

## Detailed Resolution Steps

### Phase 1: Immediate Mitigation (Stop the Bleeding)

**Step 1.1: Confirm problematic driver on affected POOL-FIN-01 hosts**
```powershell
# On affected POOL-FIN-01 session host
Get-WmiObject Win32_PnPDevice -Filter "DeviceID like '%VEN_8086%'" | Select-Object Name, Status

# Confirm driver version
Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\igdumd64" | Select-Object Version

# Expected: igdumd64.dll v31.0.101.4146 (the problematic version)
```

**Step 1.2: Test with known-good image baseline**
- Redeploy POOL-FIN-02's pre-update image (build-20240313) to a fresh test VM in POOL-FIN-01
- Logon with test user
- Verify Event 9011 (DWM started successfully) and zero Event 1000 igdumd64.dll faults
- **Confirms POOL-FIN-02's driver version is known-good baseline**

---

### Phase 2: Root Cause Analysis (Know What You're Fixing)

**Step 2.1: Extract driver versions from both images**
```powershell
# POOL-FIN-01 (problematic): 31.0.101.4146
# POOL-FIN-02 (working): [extract from comparison host]
$affectedVersion = "31.0.101.4146"
$workingVersion = (Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\igdumd64").Version

Write-Host "POOL-FIN-01 affected: $affectedVersion"
Write-Host "POOL-FIN-02 working: $workingVersion"
```

**Step 2.2: Check Intel driver release notes**
- Verify driver v31.0.101.4146 for known GPU initialization issues
- Research: Windows 11 22621.2861 incompatibilities, memory access violations, hardware regressions
- Identify last known-good driver version (likely what POOL-FIN-02 has)

**Step 2.3: Pull image update changelist**
- Determine what driver package was injected into POOL-FIN-01 at 02:00
- Was update intentional or accidental artifact?

---

### Phase 3: Remediation (Fix the Image)

**Step 3.1: Obtain previous driver version**
```powershell
# Option A: Extract from POOL-FIN-02 image (known-good)
# Mount POOL-FIN-02 image and backup driver files

# Option B: Download Intel driver for your GPU models
# Verify version is tested for Windows 11 22621.2861
```

**Step 3.2: Create corrected image with rolled-back driver**
```powershell
# Mount POOL-FIN-01 updated image
$imagePath = "C:\Images\POOL-FIN-01-updated.vhd"
$mountPath = "C:\Temp\ImageMount"

Mount-WindowsImage -ImagePath $imagePath -Index 1 -Path $mountPath

# Copy known-good igdumd64.dll from POOL-FIN-02 baseline
Copy-Item -Path "C:\Temp\POOL-FIN-02-drivers\igdumd64.dll" `
          -Destination "$mountPath\Windows\System32\igdumd64.dll" -Force

# Update driver INF registry entries if needed
# Dismount and commit
Dismount-WindowsImage -Path $mountPath -Save

# Tag corrected image
# POOL-FIN-01-corrected-igdumd64-rollback-20240315
```

**Step 3.3: Validate corrected image on test VM**
```powershell
# Deploy corrected image to fresh test VM in POOL-FIN-01
# Logon with 3-5 test users

# Verify NO crashes:
Get-EventLog Application -After (Get-Date).AddMinutes(-5) | 
  Where-Object {$_.EventID -eq 1000 -and $_.Message -like '*igdumd64*'} | 
  Select-Object TimeGenerated, Message

# Expected: Zero Event 1000 or Event 9009 errors
# Sessions persist without disconnect
```

---

### Phase 4: Redeployment and Validation

**Step 4.1: Stage corrected image**
```powershell
# Update POOL-FIN-01 image definition in image management system
# Tag: POOL-FIN-01-corrected-igdumd64-rollback-20240315
# Target: POOL-FIN-01 only (DO NOT deploy to POOL-FIN-02)
```

**Step 4.2: Canary reimage (1–2 hosts first)**
- Monitor Event logs during/after first user logons
- If clean (no Event 1000 igdumd64 faults), proceed to remaining POOL-FIN-01 hosts

**Step 4.3: Validate user experience post-remediation**
```powershell
# Query POOL-FIN-01 hosts after redeployment
Invoke-Command -ComputerName SHFIN-01-A, SHFIN-01-B, SHFIN-01-C {
    Write-Host "Host: $env:COMPUTERNAME"
    
    # Check for GPU driver crashes in last 30 minutes
    $dwmErrors = Get-EventLog Application -After (Get-Date).AddMinutes(-30) | 
        Where-Object {$_.EventID -eq 1000 -and $_.Message -like '*igdumd64*'}
    
    if ($dwmErrors) {
        Write-Host "  ⚠️ GPU driver errors detected:" -ForegroundColor Red
        $dwmErrors | Select-Object TimeGenerated, Message
    } else {
        Write-Host "  ✓ No GPU driver errors" -ForegroundColor Green
    }
    
    # Check DWM health
    $dwmHealthy = Get-EventLog System -After (Get-Date).AddMinutes(-30) | 
        Where-Object {$_.EventID -eq 9011}
    
    if ($dwmHealthy) {
        Write-Host "  ✓ DWM started successfully" -ForegroundColor Green
    }
}
```

**Step 4.4: Monitor incident metrics (24-hour post-fix)**
- Track "black screen on login" incidents for POOL-FIN-01
- Expected: Drop to zero
- Compare Event 9009 (DWM exit errors) before/after redeployment

---

### Phase 5: Root Cause Prevention (Prevent Recurrence)

**Step 5.1: Update image build pipeline**
- Add driver validation test before deployment
- Test image on VM with representative GPU hardware
- Logon test user → verify no Event 1000 crashes
- Check GPU device status → should be "OK" (no errors)

**Step 5.2: Lock driver version baseline**
- Record approved igdumd64.dll versions for POOL-FIN-01/02
- Create exception approval process before updating GPU drivers
- Require: 48-hour validation window + testing on representative hardware

**Step 5.3: Post-incident communication**
- Notify affected users: Issue resolved, no action needed
- Update change log: Driver v31.0.101.4146 rolled back to [previous version]
- Note: POOL-FIN-02 not affected; no changes required

---

## Expected Outcome

| Stage | Timeframe | Expected Result |
|---|---|---|
| **Image correction** | Immediate | Corrected image deployed to canary VMs |
| **First user logons** | 10–30 min | Zero Event 1000 igdumd64.dll faults; DWM Event 9011 success |
| **All affected users** | 2 hours | ~40% previously affected users logon cleanly without black screen |
| **Permanent fix** | Ongoing | Driver version locked to known-good baseline; new updates require validation gate |

**Success Criteria:**
- ✅ Zero Event 1000 igdumd64.dll faults across POOL-FIN-01 post-remediation
- ✅ Event 9011 (DWM successful starts) on all user logons
- ✅ No Event 40 (session disconnects) due to graphics failures
- ✅ User-reported "black screen" incidents drop to zero within 2 hours
