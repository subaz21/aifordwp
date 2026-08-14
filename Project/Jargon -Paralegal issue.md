# Jargon -Paralegal issue

## Purpose
This is the one-page guide for handling this incident if it happens again.

What happened:
- A paralegal saw client matter content she should not have seen.
- The issue came from access settings, not from Copilot creating new access.

What is being done:
- Wrong access routes are removed.
- Similar matter areas are checked for the same problem.
- Legal and compliance teams are kept updated.

What is still open:
- Confirm there are no copy issues in nearby matter areas.
- Complete final evidence and sign-off.

## Prerequisites
1. Start an urgent incident call and assign one owner.
2. Bring in DWP, M365, IAM, document owner, legal, and compliance contacts.
3. Confirm exact affected location: site, library, folder, and file.
4. Save a before-change record:
- Access list
- Inheritance setting
- Group membership list
- Recent access and change logs
5. Prepare two test users:
- One who should have access
- One who should not have access

## Procedure (numbered)
1. Remove the reporting user's accidental access route first.
Expected result: The reporting user can no longer see the matter.

2. Pause non-essential permission updates in the same area.
Expected result: No new accidental exposure while fix work is in progress.

3. Build a full access list for the affected matter.
Expected result: All users and groups with access are listed.

4. Expand groups to real user names.
Expected result: Every person with effective access is visible.

5. Mark each person as Allowed, Not Allowed, or Needs Review.
Expected result: A signed review list is ready from matter owner/delegate.

6. Remove or narrow access for Not Allowed users/groups.
Expected result: Unauthorized users lose read access.

7. Test both control users.
Expected result: Allowed user can access; Not Allowed user is blocked.

8. Check nearby matters using the same setup.
Expected result: Similar exposure is either ruled out or fixed.

9. Save after-change records and share status on the incident call.
Expected result: Before/after trail is complete and visible to stakeholders.

10. Apply permanent access-template correction.
Expected result: New matters follow the correct default access model.

## Verification
1. Recheck effective access for reporting and exposed users.
Expected result: No unauthorized access route remains.

2. Review logs for new unauthorized access in the monitoring period.
Expected result: No new event is found.

3. Confirm approved matter team can still work.
Expected result: No business interruption for allowed users.

4. Capture written legal/compliance acknowledgement.
Expected result: Formal containment sign-off is recorded.

## Rollback
Use only if valid users lose access after the fix.

1. Stop further permission edits.
2. Restore last known good access state.
3. Reapply approved access mapping from signed review list.
4. Retest allowed and not-allowed control users.
5. Resume changes only after approval on the incident call.

Expected rollback outcome: Valid users regain access while unauthorized access remains blocked.

## Notes
- Keep all updates plain and short for non-technical readers.
- Do not share client or matter names in broad channels.
- Never do bulk permission edits without saving before-change records.
- Keep one owner responsible for decisions, timeline, and final evidence pack.
