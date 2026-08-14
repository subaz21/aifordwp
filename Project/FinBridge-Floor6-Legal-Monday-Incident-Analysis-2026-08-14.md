# Multi-Symptom Incident Analysis - FinBridge Floor 6 (Legal)

Date: 2026-08-14
Analyst: DWP Engineer
Status: ANALYSIS IN PROGRESS - no event logs supplied yet; this document defines what evidence must be pulled and gives an interim ranked hypothesis set from scope facts alone.

## Scope Facts Used (from IT Ops Slack, 09:14)
- Location/population: Floor 6, Legal, ~45 people, recently migrated to Windows 11 and enrolled in Intune.
- Known change: a new document management app was deployed to this floor on Friday afternoon (last business day before the incident).
- Symptom cluster 1 - Access: at least a dozen people cannot log in, or login is very slow, as of Monday morning.
- Symptom cluster 2 - Data exposure: a paralegal was shown a client matter in Copilot that she has never had access to. This is the most severe symptom - in a law firm, exposure across matters is a potential conflicts-of-interest / ethical-wall breach, not just an IT fault.
- Symptom cluster 3 - Cosmetic/profile: desktop shortcuts have disappeared for at least one other user.
- No logs, exports, or tickets have been provided. Evidence must be actively pulled before any hypothesis can be confirmed.

## Why this is treated as one incident with three symptom clusters
All three symptoms surfaced on the first working day after a single fleet change (Friday's document management app rollout) landed on a single, recently-migrated device population. That shared timing and shared population is the reason to investigate them together under one incident, rather than assume one root cause explains all three - the hypotheses below deliberately include both a unifying cause and cluster-specific causes so the shared-timing coincidence itself gets tested, not assumed.

## Evidence Collection Plan (must be pulled before Evidence Assessment can be completed)
1. Entra ID sign-in logs for the affected Floor 6 users - filter to this morning, capture status/error code (e.g. Conditional Access blocked, compliance-blocked, password/MFA failure, timeout).
2. Intune device compliance report for the Legal device group - compliance state, last check-in time, and any policy that flipped a device to Not Compliant between Friday and Monday.
3. Intune/SCCM deployment and detection log for the new document management app - exact deployment window Friday, success/failure count, whether it included a required reboot, profile change, or Start layout/shortcut change.
4. SharePoint/OneDrive permissions and sharing report for the specific client matter library the paralegal should not see, plus her effective permissions (direct grants and group inheritance).
5. Entra ID/SharePoint audit log for group membership or permission changes in the window around Friday's deployment (was a broad or temporary access group created for the app rollout and not cleaned up).
6. Microsoft Purview audit log for Copilot interaction/content access events tied to the paralegal's account, to see which library the surfaced matter came from and when access was actually granted.
7. Local profile folder listing (a small sample of affected machines) - check for a new/second profile path (e.g. a rebuilt profile) created over the weekend versus the user's original profile.
8. Floor 6 service desk ticket volume and timestamps this morning, compared with the already-known fleet-wide post-migration ticket baseline (login speed and missing shortcuts are pre-existing themes fleet-wide, so Floor 6's ticket rate needs to be compared against that baseline, not treated as automatically new).
9. Change/deployment record for Friday's rollout - what the app installer/script does on the endpoint, and what access it needed to be granted to function (service accounts, groups, site permissions).

## Ranked Most Likely Causes (Most Probable First)

### 1) Weekend profile re-provisioning triggered by the new app's install/config process
Why this fits the scope facts:
- A rebuilt or newly-created local profile after a weekend deployment would explain both the login slowness/failures (first-login profile build, OneDrive/redirected-folder resync) and the missing desktop shortcuts (old profile's desktop items not present in a new profile) in a single mechanism.
- Matches FinBridge's own documented post-Win11-migration pattern where "Slow Login Performance" and "Desktop/Profile Reset and Missing Shortcuts" are already known feedback themes, suggesting profile handling is a soft spot in this migration.

Single fastest check:
- On 2-3 affected devices, compare the profile folder name/timestamp against the user's known original profile (look for a second/renamed profile created over the weekend).

### 2) Intune compliance/Conditional Access re-evaluation blocked sign-in for a subset of devices
Why this fits the scope facts:
- Devices recently migrated and enrolled in Intune are still inside compliance grace-period windows; a Friday app deployment that forces a reboot or policy re-sync can cause a device to re-evaluate compliance on Monday's first check-in and flip to Not Compliant, which Conditional Access can then use to block or delay sign-in.
- This is consistent with FinBridge's already-known "AVD Sign-In and Account Lockouts" theme from the wider Win11 migration.

Single fastest check:
- Pull Entra sign-in logs for 3-5 affected users and check for a Conditional Access/compliance-related failure reason at the exact time they attempted to log in.

### 3) The new document management app's installer/config script altered desktop or Start layout directly
Why this fits the scope facts:
- Some line-of-business installers pin/replace shortcuts, rewrite the public desktop, or apply a Start layout as part of their own setup - this would explain the shortcut symptom independent of login or permissions, and independent of hypothesis 1.

Single fastest check:
- Review the app's Intune Win32 deployment script/detection rule for any step that writes to the public desktop, user Start layout, or profile default folders.

### 4) Friday's rollout granted or left in place broader-than-intended access to a client matter, and Copilot surfaced real (but wrongly granted) underlying access
Why this fits the scope facts:
- Copilot only surfaces content the signed-in user already has permission to see; it does not itself over-share or bypass permissions. If the paralegal can see a matter she shouldn't, the access itself is real and was granted somewhere - most plausibly through a broad or temporary Entra/SharePoint group created to let the new app index or migrate matter content over the weekend, and not scoped or cleaned up correctly.
- This matches FinBridge's own known Copilot-oversharing risk pattern: legacy/inherited permission models are a documented oversharing risk, and a prior ticket-triage case reached the same conclusion for a near-identical symptom ("Copilot is permission-trimmed... indicates real underlying access that needs governance cleanup, not a Copilot malfunction").
- Severity note: regardless of where this ranks for probability, this hypothesis must be treated as Priority 1 for action because of the conflicts-of-interest/ethical-wall risk to a law firm, independent of how likely it is compared to the others.

Single fastest check:
- Pull the paralegal's effective permissions (direct + inherited) on the specific matter library and check whether the grant lines up with a group/permission change in Friday's deployment window.

### 5) The three symptoms are independent and largely coincidental with the deployment (null hypothesis)
Why this fits the scope facts:
- FinBridge already has a documented, fleet-wide tail of post-Win11-migration login-speed and missing-shortcut complaints unrelated to any single app, so Floor 6's login/shortcut reports could simply be continuation of that existing pattern rather than being caused by Friday's rollout.
- The permissions issue behind the Copilot exposure could equally predate Friday and have simply been noticed today.

Single fastest check:
- Compare Floor 6's ticket volume/timing today against the known fleet-wide migration ticket baseline, and check the audit-log timestamp of when the paralegal's excess permission was actually granted (before or after Friday's deployment window).

## Interim Position
- All five hypotheses are stated from scope facts only; no incident event logs have been reviewed yet.
- No hypothesis is confirmed. Evidence Collection Plan items 1-9 above must be pulled before an Evidence Assessment section can be completed.
- Hypothesis 4 (permission/Copilot exposure) is elevated to immediate containment regardless of final ranking, because of its severity - see the Immediate Actions document.

## Addendum - To Be Completed Once Evidence Is Pulled
- Incident event details (chronological), once sign-in logs, deployment logs, and audit logs are available.
- Surviving hypothesis after elimination.
- Detailed resolution steps and verification checks.
