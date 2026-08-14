# L2 Desktop issue

## Audience
L2 desktop/endpoint engineer responding to repeat incidents where desktop shortcuts disappear after an app rollout.

## Incident profile
- Typical severity: Sev-3 (upgrade to Sev-2 if business-critical users are blocked)
- Primary fault domains:
  - Packaging regression (install/uninstall script behavior)
  - Shell/layout policy regression
  - Profile/session timing regression

## Trigger to use this article
Use when multiple users report missing desktop shortcuts in the same rollout window and app launch may still work via Start/Search.

## Technical objective
1. Contain spread of regression.
2. Identify root-cause class quickly.
3. Restore shortcuts with minimal collateral impact.
4. Validate persistence and close with evidence.

## Required intake data
- Incident start time and first ticket timestamp
- Affected device/user list
- Rollout wave/ring and assignment group
- App package version and script version
- Detection rule state
- One affected and one unaffected device for comparison

## Prerequisites
1. Incident bridge active with DWP Lead, Intune Admin, Packaging Engineer, Endpoint Engineer.
2. Change approval path open for emergency script/policy remediation.
3. Baseline evidence captured before edits:
- Current install and uninstall scripts
- Current policy assignments (shell/layout)
- Current detection rule logic
- File-state snapshots on affected/unaffected endpoints
4. Pilot cohort defined for controlled remediation.
5. Last known-good package/policy baseline identified for rollback.

## Procedure (with expected result after each step)
1. Pause additional rollout waves for the impacted package.
Expected result: New devices are not exposed while fix is prepared.

2. Publish temporary user workaround (Start/Search/approved URL).
Expected result: Users can continue work while remediation proceeds.

3. Build evidence table from at least 8 endpoints across different groups.
Expected result: Reliable view of scope and pattern across rings/builds.

4. Determine root-cause class from evidence:
- Packaging
- Policy/layout
- Profile/session
Expected result: Single primary fix path selected and owned.

5. Packaging path: remove destructive wildcard/delete operations in scripts.
Expected result: Scripts no longer remove desktop/start-menu shortcuts unexpectedly.

6. Packaging path: implement idempotent shortcut creation logic and update detection rule.
Expected result: Missing shortcuts are recreated, valid existing shortcuts remain untouched, and success is only reported when shortcut target is valid.

7. Policy path: roll back or scope-limit changed shell/layout policy and force policy sync.
Expected result: Known-good layout returns and shortcuts persist after reboot/sign-in.

8. Profile/session path: reorder login sequence and add bounded retry after profile readiness.
Expected result: First sign-in race condition no longer drops shortcut creation.

9. Deploy fix to pilot cohort first.
Expected result: Pilot achieves restoration target with no collateral desktop impact.

10. Expand deployment in controlled waves with checkpoints.
Expected result: Fleet-wide recovery without ticket re-spike.

## Validation checklist
1. Shortcut existence verified in required locations:
- C:\Users\Public\Desktop
- C:\Users\<user>\Desktop
- C:\ProgramData\Microsoft\Windows\Start Menu\Programs
Expected result: Required shortcuts present with correct targets.

2. Shortcut launch behavior validated.
Expected result: Clicking shortcut launches intended app/resource.

3. Trend watch for one business day.
Expected result: No sustained new shortcut-loss trend.

4. Collateral check completed.
Expected result: Unrelated desktop items are unchanged.

## Rollback
Use if remediation causes side effects or fails to improve trend.

1. Stop active deployment wave.
2. Revert to last known-good package/policy baseline.
3. Remove temporary remediation assignment.
4. Revalidate pilot endpoints before resuming.

Expected rollback outcome: Stable endpoint behavior restored while revised fix is prepared.

## Escalate to L3 when
- Root cause remains Unknown after initial evidence pass.
- Regression affects multiple apps or profile integrity.
- Policy/package interactions cannot be isolated safely at L2.
- Required fix involves architecture-level packaging standards change.

## Evidence package for closure
- Timeline: detection, containment, fix, verification
- Before/after script and policy states
- Pilot and wave success metrics
- Ticket trend before and after
- Root-cause decision rationale and alternatives ruled out

## Common L2 mistakes to avoid
- Running tenant-wide redeploy without pilot validation.
- Editing scripts without preserving pre-change evidence.
- Treating all missing shortcuts as user-profile one-offs before checking rollout package behavior.
- Closing incident on initial recovery without trend monitoring.
