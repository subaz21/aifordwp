# Desktop Shortcuts - Detailed Triage (FinBridge Floor 6, 2026-08-14)

## Incident summary
Some users report missing desktop shortcuts after Friday's document management app rollout.

## Why this is least urgent
- This is primarily a usability/friction issue rather than a confidentiality or service-availability outage.
- Users can generally continue working through alternative launch paths (Start menu, search, web links, pinned apps).
- Even so, broad user-facing friction can generate high ticket volume and should be contained quickly.

## What to check first
- The new document management app deployment package and Intune install/uninstall scripts.
- Specifically verify whether installer actions modify:
  - Public desktop path
  - Default profile shortcut locations
  - Start menu layout/pinning policy artifacts
  - Explorer shell shortcut targets

## Why this check first
- Timing correlation with Friday rollout makes installer side effects the highest-probability shared cause.
- Script/package inspection can confirm or rule out the common-cause path faster than per-user endpoint forensics.

## Severity and classification
- Initial severity: Sev-3 (upgrade only if issue expands to application launch failure or profile corruption).
- Incident type: endpoint UX/configuration regression likely linked to software deployment behavior.
- Business impact: moderate productivity drag and elevated support load.

## Triage objectives
1. Confirm whether deployment actions removed, replaced, or failed to recreate shortcuts.
2. Identify impacted scope (which users/devices/build rings).
3. Restore shortcuts with minimal disruption.
4. Prevent recurrence in next deployment cycle.

## First 30 minutes
- Create an incident work thread with Endpoint Engineering and Intune admin.
- Select a representative sample of affected and unaffected users.
- Gather for each sample endpoint:
  - Device name and user
  - Rollout assignment group
  - App install time from Intune logs
  - Presence/absence of expected shortcuts in public and user desktop paths
- Capture one known-good and one affected endpoint snapshot for comparison.

## Mandatory first check: deployment package behavior
- Review Intune Win32 app install command, uninstall command, and detection rules.
- Review script logic for any file operations against:
  - C:\Users\Public\Desktop
  - C:\Users\<user>\Desktop
  - C:\ProgramData\Microsoft\Windows\Start Menu
  - Default user profile template paths
- Check for wildcard deletes, overwrite flags, or profile reset steps.
- Verify whether post-install shortcut creation step is conditional and could be skipped.

## Decision point A
- If script/package mutation is confirmed:
  - Treat as deployment regression.
  - Pause broader rollout or new assignments.
  - Prepare corrected package/script and controlled redeploy.
- If script/package mutation is not confirmed:
  - Check GPO/Intune Start layout and shell policies.
  - Check profile container/FSLogix behavior and login script collisions.

## Scope and blast-radius analysis
- Determine affected percentage by floor/team/device type.
- Correlate impact with:
  - Rollout wave
  - Device compliance state
  - Windows build/version
  - User profile type (local, roaming, profile container)
- Validate whether issue is only desktop shortcuts or also Start menu entries and taskbar pins.

## Fast containment options
- Publish user workaround immediately:
  - Use Start search or direct app URL until fix lands.
- Push temporary remediation script to recreate required shortcuts for impacted cohort.
- If safe, redeploy corrected app package with explicit shortcut creation and verification step.

## Evidence to preserve
- Intune deployment status and timestamps per device.
- Original and updated install/uninstall scripts.
- File system snapshots from affected and unaffected endpoints.
- Policy assignment history (Intune/GPO) around rollout window.
- Change record linking rollout version to incident onset.

## Remediation implementation pattern
- Build corrected script with idempotent logic:
  - Create shortcut only if missing or invalid.
  - Do not delete unrelated shortcuts.
  - Write verbose install log for each file operation.
- Validate in pilot ring before broad redeploy.
- Add post-deploy verification query to confirm shortcut presence.

## Communications plan
- Send concise update to service desk every 60 minutes:
  - Affected count trend
  - Confirmed cause status
  - Workaround availability
  - ETA for fix deployment
- Send user-facing note once workaround/fix is ready.

## Exit criteria
- Shortcut presence restored for affected cohort.
- No new shortcut-loss tickets after one business day.
- Corrected package validated in pilot and production wave.
- RCA captured with preventive controls for future rollouts.

## Common mistakes to avoid
- Investigating user profiles one by one before checking the shared deployment script.
- Applying manual one-off fixes without preserving comparison evidence.
- Treating this as purely cosmetic when support volume is rising sharply.
- Redeploying untested script changes tenant-wide without pilot validation.
