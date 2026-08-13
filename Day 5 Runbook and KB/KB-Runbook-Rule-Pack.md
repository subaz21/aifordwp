# KB + Runbook Rule Pack (Single File)

Purpose:
- Single master rule file to generate 2 operational artifacts from one RCA input:
  1. L1 Self-Service KB for non-technical end users
  2. Engineer Runbook for IT responders

How to use:
- Provide one RCA file as source of truth.
- Request generation of both artifacts using this rule pack.
- Do not invent facts not present in RCA; if data is missing, insert "<TBD from incident owner>".

Input required from RCA:
- Incident title and summary
- Confirmed cause and resolution actions
- Verification evidence
- Preventive actions
- Any user-safe workaround steps

Standard output naming:
- KB-L1-<Incident-Short-Name>-Self-Service.md
- Runbook-<Incident-Short-Name>-Recovery.md

---

## Rule 1: L1 Self-Service KB Document

Purpose:
- Create a short, calm, non-technical self-help article for office users.

Mandatory constraints:
- Maximum 400 words.
- Zero jargon.
- Do not use terms like: DWM, image, host pool, session host, dll, graphics driver, registry, policy object, PowerShell.
- Include only safe user actions.
- Never include admin-only steps.
- Reassure that user data is safe.
- End with clear contact line: "Contact the Service Desk if..."
- Include a list of details user should include in ticket.

Required structure:
1. Title
2. Version header
- Version: v 1.0
- Date: <DD/MM/YYYY>
- Status: Draft
3. Opening reassurance line
4. "What you can do now" numbered list
5. "What not to do" bullets
6. "If you need help" line
7. "Details to include in your help request" bullets
8. Closing reassurance line

Language rules:
- Use plain words: login name, computer name, local time, internet connection.
- Prefer short sentences.
- Friendly and calm tone.

Template:
```markdown
# Help Guide: <User-Friendly Incident Title>

Version: v 1.0
Date: <DD/MM/YYYY>
Status: Draft

<Reassure user data is safe and issue is understood.>

## What you can do now
1. <Safe user action>
2. <Safe user action>
3. <Safe user action>

## What not to do
- <Do not perform risky action>
- <Do not repeat rapid retries>

## If you need help
Contact the Service Desk if <clear trigger conditions>.

## Details to include in your help request
- Full name and work login name
- Time issue started (local time)
- Computer name (if known)
- Location and internet type
- What was seen on screen
- Steps already tried
- Screenshot/photo if possible

<Final reassurance sentence.>
```

---

## Rule 2: Engineer Runbook Document

Purpose:
- Create a cold-start, pressure-safe technical runbook for L2/L3 engineers.

Required structure:
1. Title
2. Version header
- Title: <Runbook file title>
- Version: 1.0
- Date: <DD/MM/YYYY>
- Author: <name>
- Reviewed: self
- Status: draft
- Change: initial version from RCA
3. Incident pattern covered
4. RCA reference line
5. Section 1: Prerequisites
- Access checklist
- Tools checklist
- Mandatory end-user input checklist
- Incident context checklist
6. Section 2: Procedure
- Numbered steps
- One action per step
- Expected result after each step
- Explicit portal path/console path/log path where relevant
- Flag elevated steps with [ELEVATED]
7. Section 3: Verification
- Explicit portal/log locations and filters
- Clear pass/fail criteria
8. Section 4: Rollback
- Immediate, actionable rollback sequence
- Must be executable in under 3 minutes to start containment
- Explicit portal/log locations
- [ELEVATED] markers where required
9. Section 5: Notes
- Edge cases
- Warnings
- Related incident documents

Runbook writing rules:
- No vague instructions like "check logs" without exact location.
- Every step must be concrete and deterministic.
- No step should require guessing next action.
- Keep sequence operationally safe (containment before broad rollout).

Portal/log location format examples:
- Azure Virtual Desktop -> Host pools -> <AffectedHostPool> -> Session hosts
- Windows Logs -> Application
- Windows Logs -> System
- Applications and Services Logs -> Microsoft -> Windows -> <Component> -> Operational

Template:
```markdown
# Runbook: <Incident Name>

Title: <Runbook-File-Name>
Version: 1.0
Date: <DD/MM/YYYY>
Author: <author>
Reviewed: self
Status: draft
Change: initial version from RCA

Incident pattern covered:
- <Pattern 1>
- <Pattern 2>

Use this runbook for incidents matching the RCA in <RCA filename>.

---

## 1. Prerequisites
### A) Access Checklist
- [ ] [ELEVATED] <Access requirement>

### B) Tools Checklist
- [ ] <Tool requirement>

### C) Mandatory End-User Input Checklist
- [ ] <Required user detail>

### D) Incident Context Checklist
- [ ] <Context requirement>

---

## 2. Procedure
1. <Single concrete action with path/location>
Expected result: <Outcome>

---

## 3. Verification
1. <Verification action with exact location/filter>
Expected result: <Pass condition>

---

## 4. Rollback
Goal:
- Complete emergency containment and rollback start in under 3 minutes.

1. [ELEVATED] <Immediate containment action with exact path>
Expected result: <Outcome>

---

## 5. Notes
Edge cases
- <Edge case>

Warnings
- <Warning>

Related incidents
- <Analysis file>
- <RCA file>
- <KEDB file>
- <Closure note file>
```

---

## One-Call Prompt Template

Use this exact prompt format to generate both outputs from any new RCA:

```text
Refer <RCA file path>. Using KB-Runbook-Rule-Pack.md, generate:
1) KB-L1-<Incident-Short-Name>-Self-Service.md
2) Runbook-<Incident-Short-Name>-Recovery.md

Requirements:
- Keep KB under 400 words and zero jargon.
- Keep runbook with explicit portal/log paths and [ELEVATED] tags.
- If RCA is missing data, mark as <TBD from incident owner>.
- Save both files under Day 5 - Playbook.
```
