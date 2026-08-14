# RCADesktop

## Purpose
Detailed fix runbook for Section 4 of the desktop shortcuts RCA, focused on immediate corrective actions by root-cause class.

## Prerequisites
1. Incident owner assigned and bridge active (DWP, Intune Admin, Packaging Engineer, Endpoint Engineer).
2. Impacted app package, rollout ring, and affected device list confirmed.
3. Evidence baseline captured:
- Install/uninstall script versions
- Detection rule configuration
- One affected and one unaffected endpoint snapshot
4. Change approval in place for emergency package/policy corrections.
5. Pilot cohort identified (small, representative set of devices/users).

## Numbered procedure with expected result
1. Classify root-cause branch from Section 3 (Packaging, Policy, or Profile/session).
Expected result: Single primary branch selected and documented.

2. If Packaging branch, remove destructive file actions in install/uninstall scripts.
Expected result: No delete/wildcard operation remains for desktop/start-menu paths.

3. Add idempotent shortcut-creation logic to package script.
Expected result: Missing shortcuts are recreated; existing valid shortcuts are unchanged.

4. Update detection rule to validate shortcut presence and valid target path.
Expected result: Deployment reports success only when shortcut state is correct.

5. If Policy branch, roll back or scope-limit changed shell/layout policy.
Expected result: Affected pilot devices receive known-good layout behavior.

6. If Profile/session branch, reorder login processing so shortcut creation runs after profile readiness.
Expected result: Shortcuts persist after first sign-in and reboot.

7. Deploy fix to pilot cohort.
Expected result: Pilot success rate meets target with no collateral desktop impact.

8. Expand deployment in controlled waves with checkpoint after each wave.
Expected result: Restoration scales safely and new incident volume does not increase.

## Verification
1. Confirm shortcut restoration on pilot and production cohorts.
Expected result: Required shortcuts present in user/public desktop and start menu locations.

2. Monitor tickets for one business day.
Expected result: No sustained new shortcut-loss trend.

3. Validate unaffected desktop items remain intact.
Expected result: No collateral removal or overwrite reported.

4. Record before/after evidence in incident timeline.
Expected result: RCA package is audit-ready.

## Rollback
1. Stop active rollout wave.
2. Revert to last known-good package or policy baseline.
3. Remove temporary remediation assignment.
4. Revalidate pilot devices before resuming deployment.

Expected rollback outcome: Stable user access restored without additional desktop regression.
