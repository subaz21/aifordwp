# desktop issue

## Purpose
This is the one-page guide for this resolved desktop shortcut incident.

What happened:
- After a recent app rollout, some users lost desktop shortcuts.
- Most users could still work by opening apps from Start or Search.

What is being done:
- The rollout settings and install steps are checked.
- The shortcut fix is tested on a small group first.
- The fix is then rolled out in controlled waves.

What is still open:
- Confirm no similar shortcut loss in nearby user groups.
- Complete final evidence and sign-off.

## Prerequisites
1. Open an incident call and assign one owner.
2. Confirm affected app, affected users, and rollout group.
3. Save before-change records:
- Install and uninstall steps used in rollout
- Current detection rule
- One affected device snapshot and one unaffected device snapshot
4. Confirm rollback baseline (last known good app package or policy).
5. Select a pilot group of devices/users for safe testing.

## Procedure (numbered)
1. Pause further rollout of the affected app package.
Expected result: No new devices are affected while fix work is in progress.

2. Share temporary user workaround.
Action: Ask users to open the app from Start/Search.
Expected result: Users can continue work while fix is prepared.

3. Check install and uninstall steps for destructive actions.
Action: Look for wildcard deletes or overwrite actions in desktop/start-menu paths.
Expected result: Risky actions are found and removed.

4. Correct shortcut creation logic.
Action: Make shortcut creation safe and repeatable (create if missing, leave valid existing shortcut unchanged).
Expected result: Missing shortcuts are restored without affecting unrelated items.

5. Update detection rule.
Action: Ensure success only reports when shortcut exists and points to the correct app target.
Expected result: False success is prevented.

6. Test on pilot group.
Action: Deploy fix to pilot users/devices first.
Expected result: Pilot users regain shortcuts and app launch works.

7. Validate no collateral impact.
Action: Check non-target desktop items remain unchanged.
Expected result: No unrelated shortcut or desktop loss.

8. Roll out fix in controlled waves.
Action: Expand deployment in stages with checkpoint after each stage.
Expected result: Recovery scales safely without ticket spikes.

9. Capture after-change records and publish update.
Expected result: Before/after trail is complete and shared with stakeholders.

## Verification
1. Confirm required shortcuts exist on sample affected devices.
Expected result: Shortcuts are present in expected desktop/start locations.

2. Confirm shortcut launch works.
Expected result: Clicking shortcut opens the correct app.

3. Watch incident/ticket trend for one business day.
Expected result: No sustained new shortcut-loss pattern.

4. Confirm service desk reports stabilization.
Expected result: Ticket volume returns to normal levels.

## Rollback
Use rollback only if the fix causes user impact.

1. Stop active deployment wave.
2. Revert to last known good package/policy.
3. Remove temporary remediation assignment.
4. Re-test pilot group before resuming rollout.

Expected rollback outcome: Stable user experience is restored while revised fix is prepared.

## Notes
- Keep status updates short and plain-language.
- Avoid broad changes without before-change records.
- Keep one owner accountable for decisions, timing, and final evidence pack.
- If impact grows or users cannot launch apps at all, escalate severity immediately.
