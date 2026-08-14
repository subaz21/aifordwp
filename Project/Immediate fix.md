# Immediate fix - FinBridge Floor 6 (Legal) login incident

Date: 2026-08-14
Target cause: Ranked cause #1 from [A ranked differential for the login-performance problem.md](A%20ranked%20differential%20for%20the%20login-performance%20problem.md) - Friday's document management app deployment forced a reboot/policy re-sync that flipped Floor 6 devices to Not Compliant, and Conditional Access is blocking or delaying sign-in as a result.

## Reasoning to this cause
This ranks above the alternatives because it is the only hypothesis that is both a known, previously-seen failure mode for this exact population (Intune-enrolled devices still inside compliance grace-period handling) and directly triggered by the deployment mechanism itself, rather than merely coinciding with Monday morning. The check built in [ 3a. Build the check, don't just describe it.md](%203a.%20Build%20the%20check%2C%20don't%20just%20describe%20it.md) confirms or rules this out by correlating each affected device's compliance-state flip and Conditional Access block reason code against the Friday deployment window.

## The technical action (not a description - the actual commands)

### Step 1 - Stop the bleeding: pull Floor 6 out of the deployment ring
Retract the app assignment from the Legal-Win11 Floor 6 group so no device still pending its forced reboot flips to Not Compliant overnight.

```powershell
Connect-MgGraph -Scopes "DeviceManagementApps.ReadWrite.All"

$appId = "<Win32LobApp-Id-DocumentManagementApp>"
$groupId = "<AzureAD-Group-Id-Legal-Win11-Floor6>"

$assignment = Get-MgDeviceAppManagementMobileAppAssignment -MobileAppId $appId |
    Where-Object { $_.Target.AdditionalProperties.groupId -eq $groupId }

Remove-MgDeviceAppManagementMobileAppAssignment -MobileAppId $appId -MobileAppAssignmentId $assignment.Id
```

### Step 2 - Recover already-affected devices: force an immediate compliance re-check
Don't wait for the normal ~8-hour Intune check-in cycle. Trigger a sync on every affected device so it re-reports compliance state as soon as it's back in a good state, letting Conditional Access clear the block sooner.

```powershell
Connect-MgGraph -Scopes "DeviceManagementManagedDevices.PrivilegedOperations.All"

$affectedDevices = Get-MgDeviceManagementManagedDevice -Filter "startswith(deviceName,'FL6-')"

foreach ($device in $affectedDevices) {
    Sync-MgDeviceManagementManagedDevice -ManagedDeviceId $device.Id
}
```

### Step 3 - Only if Step 2 doesn't clear the block: narrow, time-boxed Conditional Access exclusion
If a device re-syncs clean but is still being blocked, add it to a temporary exclusion group scoped to this incident only - never a tenant-wide or policy-wide exclusion.

```powershell
Connect-MgGraph -Scopes "Group.ReadWrite.All"

$exclusionGroupId = "<AzureAD-Group-Id-CA-Incident-Exclusion-Floor6>"

foreach ($device in $affectedDevices) {
    New-MgGroupMember -GroupId $exclusionGroupId -DirectoryObjectId $device.AzureADDeviceId
}
```

This exclusion group must be removed from the Conditional Access policy and deleted once root cause is fixed - it is a containment measure, not a permanent policy change.

## Message to Floor 6

Some of you are having trouble logging in or logging in slowly this morning. We've traced this to Friday's document management app update, which is why it's affecting people who received that rollout. We've stopped it from affecting anyone else and are working through the affected devices now, starting with anyone still locked out. If you're able to log in, you don't need to do anything. If you're still stuck, sign out, wait a minute, and try once more - if that doesn't clear it, please log a ticket rather than retrying repeatedly, so we can prioritise your device. We don't have an exact time yet, but this has our full attention and we'll update you as soon as we do.
