# Personal AI Usage Charter: DWP Desktop/Endpoint Engineering

**Purpose**  
I will use public AI assistants only as productivity aids. I remain accountable for protecting DWP information and for the accuracy, security, accessibility and operational impact of my work.

## Appropriate Uses

I may use public AI assistants for tasks involving **public, non-sensitive or fully synthetic information**, such as:

- Explaining generic Windows, PowerShell, Microsoft 365, Intune, Active Directory, networking or endpoint-management concepts.
- Drafting scripts using invented device names, accounts, paths, addresses and sample data.
- Suggesting troubleshooting steps for generic errors already documented publicly.
- Producing checklists, test cases, pseudocode, documentation structures or plain-language summaries.
- Reviewing fully sanitised or synthetic code and configuration fragments that do not reveal DWP systems, security controls or internal information.
- Comparing publicly documented technologies and vendor-supported approaches.

## One File Per Issue

For each new issue, I will create a separate Markdown (`.md`) file rather than replacing or appending to an existing issue file. The filename must include a simple, plain-English issue name that describes the reported problem.

- Use a unique filename in the format `YYYY-MM-DD-HHMM-Simple-Issue-Name.md`.
- Write the issue name as a few descriptive words separated by hyphens, for example `2026-08-04-0930-Laptop-Slowness.md` or `2026-08-04-1015-Outlook-Not-Opening.md`.
- Save each file in the approved working folder for that activity.
- Include only a structured summary: a generic issue description, non-sensitive symptoms, generic steps tried and the next action or resolution.
- Do not include raw logs, screenshots, commands or identifiers in the issue file.
- Never include a person's name, username, device name, asset number or other sensitive identifier in the filename.
- If a filename already exists, create a new uniquely named file and do not overwrite the earlier record.

## Prohibited Uses

I will not use a public AI assistant to:

- Process live incidents, tickets, logs, screenshots or exports containing DWP or claimant information.
- Diagnose a specific DWP endpoint by supplying its hostname, IP address, username, asset identifier, configuration or software inventory.
- Share internal architecture, network details, security findings, vulnerabilities, policies, procedures or unpublished configurations.
- Generate decisions or recommendations about an individual claimant, customer or colleague.
- Analyse malware, suspicious content or security incidents using material taken from DWP systems. I will use approved DWP tools and processes for this work.
- Circumvent security controls, monitoring, access restrictions or change-management requirements.
- Replace approved technical documentation, vendor guidance, peer review or authorised support channels.

## Data-Handling Rule

**I will never enter end-user PII, credentials or secrets into a public AI assistant.**

This includes names, addresses, dates of birth, National Insurance numbers, contact details, case information, usernames, passwords, passphrases, API keys, tokens, certificates, recovery codes and session data.

Redaction alone may be insufficient. Before submitting any technical material, I will remove or replace all identifying, sensitive and DWP-specific details with synthetic values. If I am uncertain whether information is safe to share, I will not submit it and will use an approved DWP tool or escalation route instead.

## Generate, Then Verify

I will treat every AI-generated script, command and system-change proposal as **untrusted draft material**.

Before use, I will:

1. Read and understand every command and dependency.
2. Check it against approved DWP standards and authoritative vendor documentation.
3. Look specifically for destructive actions, privilege changes, credential exposure, insecure downloads, unsupported settings and unintended scope.
4. Test with synthetic data in an isolated, non-production environment using least privilege.
5. Add logging, error handling, validation and rollback steps where appropriate.
6. Obtain required peer review, approval and change control.
7. Verify the result after execution and record the change through normal DWP processes.

I will not paste and run AI-generated commands directly on a live endpoint or deploy them at scale without completing these checks.

**Personal commitment:** AI may accelerate my work, but it does not authorise actions, approve risk or transfer accountability. DWP policy and approved processes always take precedence.
