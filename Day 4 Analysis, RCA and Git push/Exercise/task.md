## 1. Wrong : "write something for the user about their email"

## Corrected ::

You are a DWP service-desk analyst. A FinBridge user’s shared mailbox access was broken after the Win11 migration and has now been restored — the cause was a stale Outlook profile that was recreated during remediation.

Write a message to the user confirming the issue is resolved.
Requirements:

Plain language, no jargon
Under 80 words
Reassure them their emails are safe and nothing was lost
Tell them what to do next (sign back into Outlook)
Friendly, calm tone
Return only the message — no subject line, no preamble.


## 2. “you are a helpful assistant who always gives detailed, accurate, professional, well-structured, clear and concise answers. Tell me about Intune.”

## Corrected ::

professional, well-structured, clear and concise answers. Tell me
about Intune."

"A user says their laptop is slow. What is the problem and fix it."

"List every possible reason a Windows 11 device might have any
kind of issue connecting to any kind of network resource."

"Rewrite this so it sounds better:
'Device non-compliant due to BitLocker not enabled. Remediation
applied. Compliance restored.'"

"You are a senior DWP engineer with 20 years experience. A user
cannot log in. Solve this completely and give me the guaranteed fix.

## 3. “A user says their laptop is slow. What is the problem and fix it.”

## Corrected ::

You are a DWP service-desk analyst. A FinBridge user reports their Win11 laptop feels slow after the recent migration. You have no further information yet.

Produce a ranked differential of the 5 most likely causes in a managed enterprise environment immediately post-migration. Most probable first. For each give:

Why it is likely in a post-migration context
The single fastest check to confirm or rule it out
Do not name a single definitive cause — you do not have enough information yet. Do not suggest fixes until a cause is confirmed. Mark anything uncertain as ‘to confirm’.

## 4. “List every possible reason a Windows 11 device might have any kind of issue connecting to any kind of network resource.”

## Corrected ::

You are a DWP service-desk analyst. A FinBridge Win11 laptop an reach the internet but cannot access internal SharePoint r mapped drives after migration. Other devices on the same loor are unaffected.

Produce a ranked list of the 5 most likely causes for this secific symptom, most probable first. For each give:

Why it fits the evidence (internet works, internal fails,
one device only, post-migration)
The single fastest check to confirm or eliminate it
Do not list generic network causes — rank specifically against the evidence given.

## 5. “Rewrite this so it sounds better: ‘Device non-compliant due to BitLocker not enabled. Remediation applied. Compliance restored.’”

## Corrected ::

Rewrite the engineer note below into two versions:

Version 1 — End-user message:

Plain language, no jargon (no ‘BitLocker’, ‘compliant’,
‘remediation’)
Under 60 words
Reassure the user their device is working normally
Tell them what if anything they need to do
Calm, friendly tone
Version 2 — IT audit log entry:

Technical shorthand is fine
Keep all technical detail: BitLocker status, remediation
action taken, compliance outcome
Under 40 words
Factual, no narrative
Return both versions clearly labelled. Do not add facts not present in the original note.

Note: Device non-compliant due to BitLocker not enabled. Remediation applied. Compliance restored.

## 6. "You are a senior DWP engineer with 20 years experience. A user cannot log in. Solve this completely and give me the guaranteed fix.

## Corrected ::

You are a DWP service-desk analyst. A FinBridge user on a Win11 device cannot log in this morning. You have no further information yet.

Produce a ranked differential of the 5 most likely causes, most probable first. For each give:

Why it is likely
The single fastest check to confirm or eliminate it
Then list the 3 scope questions you would ask the user or check in the logs before investigating further:

Is it one user or multiple?
Is it this device only or others too?
What is the exact error message or behaviour?
Do not provide a fix yet — a correct diagnosis requires evidence first. Do not claim certainty on any cause. Mark anything that depends on information you do not have as ‘to confirm’.