# Desktop RCA Section 4 fix

## Purpose
Provide an execution runbook for Section 4 corrective actions to restore missing desktop shortcuts safely and prevent repeat impact.

## Prerequisites
1. Incident bridge active with DWP Incident Lead, Intune Admin, Packaging Engineer, and Endpoint Engineer.
2. Root-cause branch confirmed from Section 3: Packaging, Policy, or Profile/session.
3. Change approval in place for package/policy/script updates.
4. Baseline evidence captured:
- Current install/uninstall scripts
- Detection rule configuration
- One affected and one unaffected endpoint snapshot
5. Pilot cohort selected (small, representative devices and users).
6. Backout package/policy baseline identified.

## Numbered procedure (expected result after each step)
1. Confirm root-cause branch and assign fix owner.
Expected result: Single fix path selected (4A, 4B, or 4C) with named owner.

2. Packaging path (4A): remove destructive file operations from install/uninstall scripts.
Expected result: No wildcard/delete action can remove desktop or Start menu shortcuts.

3. Packaging path (4A): implement idempotent shortcut creation logic.
Expected result: Missing shortcuts are recreated; valid existing shortcuts remain unchanged.

4. Packaging path (4A): update detection rule to validate shortcut presence and target path.
Expected result: Deployment reports success only when shortcut state is correct.

5. Policy path (4B): roll back or scope-limit changed shell/layout policy.
Expected result: Pilot devices receive known-good layout behavior.

6. Policy path (4B): force policy sync and retest after sign-in/reboot.
Expected result: Shortcuts persist across session restart.

7. Profile/session path (4C): reorder login tasks so shortcut creation runs after profile readiness.
Expected result: First sign-in no longer misses shortcut creation.

8. Profile/session path (4C): add bounded retry logic for first sign-in race conditions.
Expected result: Transient profile timing no longer causes shortcut loss.

9. Deploy selected fix to pilot cohort.
Expected result: Pilot restoration success meets target with no collateral desktop impact.

10. Expand deployment in controlled waves with checkpoint after each wave.
Expected result: Fleet-wide restoration completes without incident re-spike.

## Verification
1. Validate shortcut presence in required paths on pilot and production samples.
Expected result: Required shortcuts exist in user/public desktop and Start menu locations.

2. Validate app launch from restored shortcuts.
Expected result: Shortcuts resolve to correct targets and launch successfully.

3. Monitor incident/ticket trend for one business day.
Expected result: No sustained new shortcut-loss pattern.

4. Validate non-target desktop items remain unaffected.
Expected result: No collateral deletions or overwrites.

## Rollback
Use rollback if remediation introduces user impact.

1. Stop current deployment wave.
2. Revert to last known-good package/policy baseline.
3. Remove temporary remediation script assignment.
4. Revalidate pilot cohort before resuming rollout.

Expected rollback outcome: Stable user experience restored while preparing corrected fix version.
