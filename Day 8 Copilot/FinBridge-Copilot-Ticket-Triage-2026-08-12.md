# FinBridge Copilot Ticket Triage (2026-08-12)

Rule applied: Default to non-Copilot causes unless evidence clearly rules them out.

## 1) Finance lead: Copilot will not summarise Q3 board pack in SharePoint
Ticket text: "It's right there, I can see it myself."

Likely cause (ranked):
1. data indexing lag
2. sensitivity label restriction
3. permissions/access boundary
4. license/client prerequisite issue
5. guest/external sharing limitation
6. genuine Copilot fault

Fastest check:
- Confirm whether the same board-pack file appears in Microsoft Search/Copilot grounding for the same user account (if not discoverable, indexing/label/access path is most likely).

Is this actually a Copilot bug?
- Unclear. User can open the file directly, but Copilot summarization failure is commonly caused by indexing timing or label/policy constraints rather than a product defect.

---

## 2) New hire (started yesterday): Copilot in Outlook knows nothing about recent emails

Likely cause (ranked):
1. data indexing lag
2. license/client prerequisite issue
3. permissions/access boundary
4. sensitivity label restriction
5. guest/external sharing limitation
6. genuine Copilot fault

Fastest check:
- Check whether the user was assigned Copilot license and has active service provisioning completion; day-one users are often not fully indexed/provisioned yet.

Is this actually a Copilot bug?
- No (most likely). New-starter timing strongly suggests normal indexing/provisioning delay or prerequisite gap, not a Copilot defect.

---

## 3) HR manager: Word Copilot cannot pull from sensitive salary spreadsheet ("I don't have access")

Likely cause (ranked):
1. sensitivity label restriction
2. permissions/access boundary
3. data indexing lag
4. license/client prerequisite issue
5. guest/external sharing limitation
6. genuine Copilot fault

Fastest check:
- Verify the spreadsheet's sensitivity label and protection settings (encryption/usage rights) for that user account.

Is this actually a Copilot bug?
- No. The error explicitly indicates access restriction, which aligns with labeling/permissions controls.

---

## 4) Sales rep: Teams Copilot cannot find contract shared via guest link from another org

Likely cause (ranked):
1. guest/external sharing limitation
2. permissions/access boundary
3. data indexing lag
4. sensitivity label restriction
5. license/client prerequisite issue
6. genuine Copilot fault

Fastest check:
- Confirm whether the content is only accessible through an external guest/share link and not as an internal, indexed tenant document.

Is this actually a Copilot bug?
- No. Cross-tenant guest-link scenarios commonly have grounding/discovery limitations by design.

---

## 5) IT admin: Copilot stopped for whole Finance team this morning; was fine yesterday

Likely cause (ranked):
1. license/client prerequisite issue
2. permissions/access boundary
3. data indexing lag
4. sensitivity label restriction
5. guest/external sharing limitation
6. genuine Copilot fault

Fastest check:
- Check Finance users' Copilot add-on license assignment status for bulk removal/assignment failure and any policy change applied this morning.

Is this actually a Copilot bug?
- Unclear. Tenant-wide/team-wide sudden impact more often indicates licensing/policy/client prerequisite changes than product defect.

---

## 6) Manager: Copilot summarized a file from a folder they forgot they could access

Likely cause (ranked):
1. permissions/access boundary
2. data indexing lag
3. sensitivity label restriction
4. license/client prerequisite issue
5. guest/external sharing limitation
6. genuine Copilot fault

Fastest check:
- Review the manager's effective permissions on that folder/library (group inheritance and direct grants).

Is this actually a Copilot bug?
- No. Copilot is permission-trimmed; this indicates real underlying access that needs governance cleanup, not a Copilot malfunction.

---

## 7) Analyst: Copilot gives generic answers and does not use internal SharePoint content

Likely cause (ranked):
1. license/client prerequisite issue
2. permissions/access boundary
3. data indexing lag
4. sensitivity label restriction
5. guest/external sharing limitation
6. genuine Copilot fault

Fastest check:
- Verify Copilot license assignment and supported Microsoft 365 Apps client version/sign-in state on the analyst's device.

Is this actually a Copilot bug?
- Unclear. Symptom often maps to missing prerequisites or no effective access to indexed content, not necessarily a product defect.

---

## 8) Executive assistant: Outlook Copilot cannot see shared mailbox calendar managed for director

Likely cause (ranked):
1. permissions/access boundary
2. license/client prerequisite issue
3. guest/external sharing limitation
4. data indexing lag
5. sensitivity label restriction
6. genuine Copilot fault

Fastest check:
- Confirm whether delegated/shared mailbox calendar access is supported for Copilot grounding in this scenario and whether assistant has correct delegate permissions.

Is this actually a Copilot bug?
- Unclear. Shared/delegated mailbox scenarios frequently have scope limitations or permission model constraints; not enough evidence for a true defect.

---

## Pattern Summary
- Most tickets are best explained first by access model, licensing/prerequisites, indexing timing, or sharing-model constraints.
- Only escalate to genuine Copilot fault after these checks are explicitly ruled out with evidence.
