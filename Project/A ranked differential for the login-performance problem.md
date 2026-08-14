# A ranked differential for the login/performance problem

Date: 2026-08-14
Scope: Floor 6 (Legal), ~45 people, recently migrated to Win11/Intune. New document management app deployed Friday afternoon. At least a dozen users cannot log in or experience very slow login the following Monday morning.

## Reasoning frame
The defining fact is timing: the first full working-day logon after a Friday deployment is exactly when deployment-triggered side effects (forced reboot, policy re-sync, first-run processes, pending state) would surface - and also exactly when an unrelated Monday-morning pattern (login storm, capacity) would coincidentally appear. The ranking below favors causes that are directly triggered by the deployment mechanism itself over hypotheses that merely share the same morning.

## Ranked Most Likely Causes (Most Probable First)

### 1) Deployment forced a reboot/policy re-sync that pushed devices to Not Compliant, and Conditional Access blocked or delayed sign-in
Why this fits:
- Devices are recently enrolled in Intune and likely still inside compliance grace-period handling; an app deployment that forces a reboot commonly triggers a fresh compliance check-in on next logon.
- Matches FinBridge's already-documented fleet-wide "AVD Sign-In and Account Lockouts" theme from the wider Win11 migration - this is a known failure mode for this exact population, not a hypothetical one.

Fastest check:
- Pull Intune device compliance state history for the Legal-Win11 collection and Entra sign-in logs for a handful of affected users; look for a compliance state flip and/or a Conditional Access block reason code timestamped between Friday's deployment and Monday's failed logons.

### 2) New app's first-run process (indexing, licensing check-in, agent startup) runs at logon and extends logon duration
Why this fits:
- "Slow login" (not just outright failure) is a distinct symptom from lockout, and first-run setup work (e.g., initial index build, license validation, cache warm-up) commonly runs on the first logon after install, which for most users is this Monday.
- Matches FinBridge's already-documented fleet-wide "Slow Login Performance" theme, again a known pattern for this population.

Fastest check:
- On 2-3 slow-but-successful logons, capture a logon-time trace (Group Policy/User Profile Service logon duration events, or a simple Process Monitor/Task Manager startup check) and see whether the new app's process is active and consuming CPU/disk during the delay.

### 3) Deployment left devices in a pending-reboot/partially-applied state
Why this fits:
- If the installer required a restart that didn't complete cleanly over the weekend (device left asleep/hibernated rather than restarted), the device can be stuck between old and new state, which can interfere with policy processing or credential provider loading at next logon.

Fastest check:
- Query pending-reboot flag and last restart timestamp on affected devices; compare against the deployment's expected restart requirement and completion timestamp.

### 4) Install script ran in the wrong execution context and disrupted logon-time policy/script processing for a subset of devices
Why this fits:
- This is a previously seen failure pattern in this environment (a prior FinBridge incident involved a mapping script moved to SYSTEM context breaking user-context-dependent behavior) - the same class of mistake (deploying via a context that doesn't match what the logon path expects) is a credible, specific mechanism for a subset of devices to fail while others succeed.

Fastest check:
- Review the app's Intune Win32 deployment script for the execution context (SYSTEM vs user) and whether it touches logon scripts, GPO processing, or network profile detection; check ScriptRunner/Event logs for context and errors on affected devices.

### 5) Coincidental, deployment-unrelated Monday-morning issue (null hypothesis)
Why this fits:
- Monday-morning logon storms (many devices authenticating and pulling policy/profile at once after a weekend) are a generic, deployment-independent failure mode, and FinBridge already has a general post-migration login-slowness tail unrelated to any specific app.

Fastest check:
- Compare failure/slowness timestamps and rates on Floor 6 against another Win11/Intune floor that did not receive Friday's deployment, for the same Monday morning window.

## Evidence That Would Confirm the Deployment as the Cause
- Affected users are concentrated in (ideally limited to) devices that received Friday's deployment, not a random cross-section of Floor 6.
- Failure/slowdown timestamps cluster shortly after each device's first post-deployment logon or reboot, not spread evenly across the morning regardless of restart state.
- Compliance state changes, pending-reboot flags, or the new app's process activity line up in time with the specific users reporting problems.
- Other floors/collections without the deployment show a normal Monday-morning baseline for logon success and duration.

## Evidence That Would Rule Out the Deployment as the Cause
- Devices that did not receive Friday's deployment (excluded, failed install, or a different collection) show the same failure/slowness rate as devices that did.
- Failure timestamps or compliance flips predate the deployment window, or show no relationship to each device's restart/check-in time.
- Other floors, unrelated to this deployment, show the same elevated login failure/slowness on the same Monday morning, indicating a shared infrastructure or seasonal (Monday) cause instead.
- The new app's process/service is confirmed idle or absent during the affected logons.
