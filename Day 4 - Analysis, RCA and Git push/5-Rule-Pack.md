# Incident Documentation Rule Pack (Single File)

Purpose:
- Single master rule file to generate the standard 5-document incident pack:
  1. Analysis
  2. RCA
  3. Audience Communications
  4. Known Error Database (KEDB)
  5. Closure Note

How to use:
- Provide incident scope facts, event evidence, remediation actions, and verification outcome.
- Request generation of all 5 documents using this rule pack.

Standard output naming:
- Issue-<Incident-Short-Name>-Analysis-<YYYYMMDD>.md
- Issue-<Incident-Short-Name>-RCA-<YYYYMMDD>.md
- Issue-<Incident-Short-Name>-Comms.md
- Issue-<Incident-Short-Name>-KEDB.md
- Issue-<Incident-Short-Name>-Closure-Note-<YYYYMMDD>.md

---

## Rule 1: Analysis Document

Purpose:
- Create the incident analysis file with ranked hypotheses before final root cause confirmation.

Required structure:
1. Title line
- # <Incident Type> Analysis: <Incident-Short-Name>
2. Metadata lines
- Date
- Symptom
- Scope Facts (bullets)
3. Ranked hypotheses section
- Heading: Ranked Hypotheses (Most to Least Consistent)
- Exactly 5 hypotheses, numbered 1 to 5
- For each hypothesis include:
  - Why this fits scope facts
  - Single fastest confirmation check
4. Evidence assessment section (after event logs are available)
- Heading: Evidence Assessment Against Incident Event Logs
- For each of the 5 hypotheses include:
  - Judgement: Supports / Contradicts / Neutral
  - Why
  - Determining events (event id + timestamp)
5. Interim position
- State no winner selected until elimination is complete.
6. Addendum section (optional but recommended once elimination is done)
- Incident event details (chronological)
- Surviving hypothesis
- Detailed resolution steps

Formatting rules:
- Use Markdown headings and short bullets.
- Use concrete timestamps and event IDs when available.
- Keep ranking order explicit and preserved through evidence assessment.

Template:
```markdown
# <Incident Type> Analysis - <Incident-Short-Name>

Date: <YYYY-MM-DD>
Analyst: DWP Engineer

## Scope Facts Used
- Symptom: <symptom>
- Who: <affected users>
- Since: <time>
- Change: <known change or nil>

## Ranked Most Likely Causes (Most Probable First)

## 1) <Hypothesis 1>
Why this fits the scope facts:
- <reason>

Single fastest check:
- <fast check>

## 2) <Hypothesis 2>
Why this fits the scope facts:
- <reason>

Single fastest check:
- <fast check>

## 3) <Hypothesis 3>
Why this fits the scope facts:
- <reason>

Single fastest check:
- <fast check>

## 4) <Hypothesis 4>
Why this fits the scope facts:
- <reason>

Single fastest check:
- <fast check>

## 5) <Hypothesis 5>
Why this fits the scope facts:
- <reason>

Single fastest check:
- <fast check>

## Evidence Assessment Against Incident Event Logs

### 1) <Hypothesis 1>
Judgement: <Supports/Contradicts/Neutral>
Why:
- <reason>
Determining events:
- <timestamp> - Event <id> - <detail>

### 2) <Hypothesis 2>
Judgement: <Supports/Contradicts/Neutral>
Why:
- <reason>
Determining events:
- <timestamp> - Event <id> - <detail>

### 3) <Hypothesis 3>
Judgement: <Supports/Contradicts/Neutral>
Why:
- <reason>
Determining events:
- <timestamp> - Event <id> - <detail>

### 4) <Hypothesis 4>
Judgement: <Supports/Contradicts/Neutral>
Why:
- <reason>
Determining events:
- <timestamp> - Event <id> - <detail>

### 5) <Hypothesis 5>
Judgement: <Supports/Contradicts/Neutral>
Why:
- <reason>
Determining events:
- <timestamp> - Event <id> - <detail>

### Interim Position
- All five hypotheses assessed.
- No winner selected yet.
```

---

## Rule 2: RCA Document

Purpose:
- Create a detailed root cause analysis document after incident resolution.

Required structure:
1. Header
- # Root Cause Analysis Report
- ## <Incident Name>
2. Metadata block
- Report Date, Incident Date, Incident ID, Severity, Status, Resolution Time
3. Executive Summary
- What happened, who was affected, final root cause, high-level fix, outcome
4. Scope and Impact
- Affected users/systems and blast radius
5. Supporting Evidence
- Ordered evidence list with event IDs, timestamps, and interpretation
- Include recovery-verification events
6. Incident Timeline
- Table with Time, Event, Evidence, Meaning
7. Root Cause Statement
- Single definitive statement
8. 5 Whys Analysis
- Why 1 to Why 5 with evidence for each
- Include systemic cause line
9. Resolution Actions Performed
- Numbered operational actions
10. Preventive Actions
- Immediate, Near Term, Long Term
- Include owner and success metric where possible
11. Closure and Verification
- Evidence of successful recovery and user confirmation
12. Lessons Learned
- Short, practical learning points from the incident
- Each lesson must include: lesson, impact, and follow-up action

Formatting rules:
- Use factual language and event-based evidence.
- Keep sequence chronological and consistent across sections.
- Lessons Learned must be actionable, not generic.

Template:
```markdown
# Root Cause Analysis Report
## <Incident Name>

Report Date: <YYYY-MM-DD>
Incident Date: <YYYY-MM-DD>
Incident ID: <INC-ID>
Severity: <severity>
Status: Resolved
Resolution Time: <duration>

---

## Executive Summary
<summary paragraph>

---

## Scope and Impact
- Affected user/group: <value>
- Affected systems: <value>
- Business impact: <value>

---

## Supporting Evidence
1. <time> - Event <id> - <detail>
2. <time> - Event <id> - <detail>

Interpretation:
- <what evidence proves>

---

## Incident Timeline
| Time | Event | Evidence | Meaning |
|---|---|---|---|
| <time> | <event> | <evidence> | <meaning> |

---

## Root Cause Statement
<definitive root cause>

---

## 5 Whys Analysis
Why 1: <question>
- <answer>
- Evidence: <event/time>

Why 2: <question>
- <answer>
- Evidence: <event/time>

Why 3: <question>
- <answer>
- Evidence: <event/time>

Why 4: <question>
- <answer>
- Evidence: <event/time>

Why 5: <question>
- <answer>
- Evidence: <event/time>

Systemic cause:
- <systemic cause>

---

## Resolution Actions Performed
1. <action>
2. <action>

---

## Preventive Actions
### Immediate (0-7 days)
1. <action>
- Owner: <owner>
- Success metric: <metric>

### Near Term (7-30 days)
1. <action>
- Owner: <owner>
- Success metric: <metric>

### Long Term (30-90 days)
1. <action>
- Owner: <owner>
- Success metric: <metric>

---

## Closure and Verification
- <verification line>
- <user confirmation>

---

## Lessons Learned
| Lesson | Impact | Action |
|---|---|---|
| <what was learned> | <why it matters> | <what will be changed> |
| <what was learned> | <why it matters> | <what will be changed> |
```

---

## Rule 3: Audience Communications Document

Purpose:
- Create one communications file with 3 audience-specific sections.

Required structure:
1. Title
- # <Incident Name>: Audience Communications
2. Audience 1 - Non-technical executive
- One short paragraph
- Confirm service restored and data safety
- Include high-level cause, impact scope, action taken, and whether user action is needed
3. Audience 2 - Affected end-user team (non-technical)
- One short paragraph
- Plain language, reassurance, and simple next step if issue reoccurs
4. Audience 3 - Engineer-to-engineer internal note
- Incident line with ID and time window
- Root cause (bullets)
- Exact action taken (bullets)
- Config and event details (bullets)
- Verification (bullets)
- Preventive action required (bullets)

Formatting rules:
- Audience 1 and 2 must stay non-technical.
- Audience 3 should contain technical detail and event IDs.

Template:
```markdown
# <Incident Name>: Audience Communications

## Audience 1 - Non-technical executive
<plain-language executive update>

## Audience 2 - Affected end-user team (non-technical)
<plain-language end-user update>

## Audience 3 - Engineer-to-engineer internal note
Incident: <INC-ID>, <incident short description>, <date/time window>.

Root cause:
- <technical cause>

Exact action taken:
- <action>

Config and event details:
- <detail>

Verification:
- <evidence>

Preventive action required:
- <prevention>
```

---

## Rule 4: Known Error Database (KEDB) Document

Purpose:
- Create a concise known error record using fixed field labels.

Required structure:
- Symptom     : <text>
- Cause       : <text>
- Scope       : <text>
- Workaround  : <text>
- Permanent fix: <text>
- How to spot it: <text>

Formatting rules:
- Keep all six labels exactly as written for consistency.
- Use single-paragraph values per label.
- Include key event IDs/timestamps under How to spot it when available.

Template:
```markdown
Symptom     : <user-visible symptom>

Cause       : <root technical cause>

Scope       : <affected users/systems/time window>

Workaround  : <temporary or immediate restore path>

Permanent fix: <implemented durable correction>

How to spot it: <event signatures, logs, and timestamps>
```

---

## Rule 5: Closure Note Document

Purpose:
- Create a one-line closure note in fixed structure.

Required structure (single paragraph):
- Resolved. Cause: {cause}. Action: {action taken}. Preventive: {preventive step}. User confirmed working.

Formatting rules:
- Keep exactly the sentence order shown.
- Keep concise but specific.
- Include key evidence in Action where useful (event IDs/time).

Template:
```markdown
Resolved. Cause: <cause>. Action: <action taken>. Preventive: <preventive step>. User confirmed working.
```
