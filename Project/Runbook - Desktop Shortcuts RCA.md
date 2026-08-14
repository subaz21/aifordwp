# Runbook - Desktop Shortcuts RCA (DWP)

## Purpose
Provide a repeatable DWP runbook to investigate, confirm root cause, remediate, and prevent recurrence when desktop shortcuts disappear after software rollout.

## Scope
- Windows 10/11 managed endpoints
- Intune-delivered application packages (Win32/MSI/scripted)
- User and public desktop shortcut loss
- Related Start menu/taskbar shortcut regressions

## Trigger conditions
Start this runbook when all are true:
- Multiple users report missing desktop shortcuts in the same time window.
- A recent app rollout, packaging update, or policy change occurred.
- Users can still launch apps via alternate paths (Start/Search/URL), indicating usability regression rather than full outage.

## Severity and ownership
- Default severity: Sev-3
- Upgrade to Sev-2 if impacted cohort exceeds support threshold or critical teams are blocked.
- Incident owner: DWP Incident Lead
- Technical owners: Intune Admin, Packaging Engineer, Endpoint Engineer

## Inputs required
- Incident start time and first report timestamp
- Affected user/device list
- Rollout identifier, assignment groups, and deployment version
- Current install/uninstall script versions
- Detection rule definition

## Tooling and data sources
- Intune admin center: app deployment status, assignment history, script versioning
- Endpoint logs: Intune Management Extension logs and installer logs
- File system checks: user and public desktop paths, Start menu paths
- Change records: CAB ticket, deployment notes, release timeline

## Paths to validate
- C:\Users\Public\Desktop
- C:\Users\<user>\Desktop
- C:\ProgramData\Microsoft\Windows\Start Menu\Programs
- C:\Users\Default\Desktop

## Step 1 - Contain and stabilize (0-30 minutes)
1. Create incident bridge and assign owners.
2. Pause further rollout waves for the impacted package only.
3. Broadcast user workaround:
   - Launch app via Start/Search or approved URL.
4. Capture one affected and one unaffected device for side-by-side comparison.

## Step 2 - Build evidence set (30-60 minutes)
Collect from at least 8 devices across different groups:
- Device name, user, OS build
- Rollout ring and assignment group
- App install timestamp
- Shortcut presence in all target paths
- Install/uninstall return codes
- Relevant script log entries

Record this in a single incident evidence table.

## Step 3 - Root cause decision tree
### Decision A: Did rollout script/package modify shortcut locations?
- Evidence signals:
  - Delete/remove commands targeting Desktop or Start Menu
  - Wildcard cleanup commands without allowlist
  - Overwrite behavior replacing profile defaults
- If Yes:
  - Root cause class: Packaging regression
  - Go to Step 4A
- If No:
  - Continue to Decision B

### Decision B: Did policy alter shell layout behavior?
- Evidence signals:
  - New or modified Start layout/taskbar profile policy
  - GPO/Intune policy assignment change during incident window
- If Yes:
  - Root cause class: Policy regression
  - Go to Step 4B
- If No:
  - Continue to Decision C

### Decision C: Is profile virtualization/login processing involved?
- Evidence signals:
  - FSLogix/profile container mount delays or conflicts
  - Login script order race conditions
  - Intermittent shortcut creation on second sign-in
- If Yes:
  - Root cause class: Profile/session regression
  - Go to Step 4C
- If No:
  - Root cause class: Unknown
  - Escalate to advanced endpoint diagnostics and vendor support

## Step 4A - Corrective actions for packaging regression
1. Remove destructive file operations from install/uninstall scripts.
2. Implement idempotent shortcut creation logic:
   - Create only if missing or target invalid.
   - Do not touch unrelated shortcuts.
3. Update detection rule to validate shortcut existence and target path.
4. Pilot corrected package to small cohort before broad deploy.

## Step 4B - Corrective actions for policy regression
1. Roll back or scope-limit newly changed shell/layout policy.
2. Reapply known-good policy baseline to pilot group.
3. Force policy sync and validate shortcut persistence after reboot/sign-in.

## Step 4C - Corrective actions for profile/session regression
1. Validate profile container health and mount sequence.
2. Reorder login tasks so shortcut creation occurs after profile readiness.
3. Add retry logic with bounded timeout for first sign-in race conditions.

## Step 5 - Fleet remediation
Choose one controlled path:
- Option 1: Intune remediation script to recreate approved shortcuts.
- Option 2: Corrected app redeploy with explicit post-install verification.

For either option:
- Start with pilot ring.
- Measure success rate.
- Expand in waves with rollback checkpoint after each wave.

## Step 6 - Verification gates
Do not close incident until all pass:
- Shortcut restoration success rate meets target across impacted cohort.
- No new shortcut-loss tickets for one business day.
- Start menu/taskbar behavior unchanged or improved.
- No collateral impact on unrelated desktop items.

## Evidence pack for RCA record
Include:
- Timeline (report, containment, fix, verification)
- Before/after script versions and policy states
- Device sample table and success metrics
- Why root cause was selected and alternatives ruled out
- Preventive controls committed and owner/date

## Preventive controls
- Add packaging lint rule to block wildcard deletes in profile paths.
- Add pre-prod test case for desktop/start shortcut persistence.
- Require change-review checkpoint for script operations touching user profile locations.
- Add post-deploy telemetry query for shortcut presence across pilot devices.

## Rollback plan
If remediation causes side effects:
1. Stop current deployment wave.
2. Revert to last known-good package/policy.
3. Remove temporary remediation script assignment.
4. Re-validate pilot cohort before reopening rollout.

## Communications template (internal)
- Incident: Desktop shortcut loss after rollout
- Current status: Investigating or remediating
- Confirmed root cause class: Packaging or Policy or Profile or Unknown
- Current impact: <count>/<population>
- Next update time: <timestamp>

## Closure criteria
- Root cause confirmed with evidence.
- Permanent fix deployed and validated.
- Preventive controls tracked in change backlog.
- RCA and runbook improvement notes published.
