# Jargon- People cant login

## Purpose
This is the one-page guide for this resolved login incident.

What happened:
- A large group of users on Floor 6 could not log in, or login was very slow.
- The issue affected work at the start of the day.

What is being done:
- Login error details are checked first.
- The immediate fix is applied to the right user group.
- The fix is tested on a small group, then expanded safely.

What is still open:
- Confirm no hidden impact in nearby teams.
- Complete final evidence and sign-off.

## Prerequisites
1. Start an incident call and assign one owner.
2. Confirm number of affected users and first known failure time.
3. Gather sample users:
- 6 to 10 affected users
- 2 unaffected users for comparison
4. Save before-change records:
- Login error codes and times
- Policy/compliance status
- Recent related changes
5. Confirm rollback path (last known good policy/state).

## Procedure (numbered)
1. Capture impact snapshot.
Action: Record fail vs slow login count, impacted team, and start time.
Expected result: Scope is clear.

2. Pull login error details for sample users.
Action: Capture user, device, failure code, and timestamp.
Expected result: Clear error pattern is visible.

3. Group failures by primary cause.
Action: Separate into policy, compliance, credentials, or service/network.
Expected result: One main fix path is selected.

4. Apply targeted fix to pilot group only.
Action: Use the matching fix for the primary cause.
Expected result: Pilot users start recovering login access.

5. Re-test pilot users immediately.
Action: Ask pilot users to retry login and confirm results.
Expected result: Login success improves without new side effects.

6. Expand fix in controlled waves.
Action: Apply fix to larger groups in stages.
Expected result: Broad recovery without creating new failures.

7. Monitor every 15 minutes.
Action: Track success rate and new ticket volume.
Expected result: Stable recovery trend is confirmed.

8. Remove temporary exceptions after stable recovery.
Action: Clean up temporary allowances and keep only permanent fixes.
Expected result: Secure steady state is restored.

## Verification
1. Login success rate is back to normal for affected users.
Expected result: Users can work normally.

2. No sustained login spike for at least 60 minutes.
Expected result: Recovery is stable.

3. Service desk confirms ticket volume is returning to normal.
Expected result: Incident pressure has reduced.

4. Final records are complete.
Expected result: Timeline, fix actions, and approvals are documented.

## Rollback
Use rollback if the fix makes things worse or does not improve results.

1. Stop new rollout of the current change.
2. Revert to last known good login policy/state.
3. Remove temporary broad exceptions.
4. Re-test pilot users.
5. Restart fix path only after incident owner approval.

Expected rollback outcome: System returns to stable baseline while a safer fix is prepared.

## Notes
- Keep updates short and plain language.
- Do not ask users to retry endlessly; collect one clean failure sample.
- Prefer targeted fixes over broad tenant-wide changes.
- Keep one owner accountable for decisions, timeline, and final sign-off.
