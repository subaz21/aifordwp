# Microsoft 365 Copilot Readiness Checklist - Finance (200 Users)

## Scope and Context
- Department: Finance (~200 users)
- Data sensitivity: High (payroll, board packs, M&A documents, client financial data)
- Current state: M365 E5 licensed; Copilot add-on not assigned
- Critical risk note: SharePoint permissions inherited from 2019 migration and never fully audited

## How to Use This Checklist
- Mark each item as complete only when evidence is attached.
- Treat Section 1 as mandatory go/no-go gates.
- Do not proceed to license assignment until Section 1 is complete and signed off.

---

## 1) Highest Priority: Permissions and Oversharing Controls (Go/No-Go)

### 1.1 Full permissions audit (mandatory)
- [ ] Inventory all Finance SharePoint sites, document libraries, and connected Teams file stores.
- [ ] Export and review current permissions: Owners, Members, Visitors, and direct user grants.
- [ ] Identify and document legacy/broad groups from migration-era access.
- [ ] Identify unique permissions at folder/file level in sensitive libraries.
- [ ] Confirm site/library owner for every location (named accountable owner).

Evidence:
- [ ] Audit export attached
- [ ] Exception log attached
- [ ] Ownership matrix attached

### 1.2 Oversharing remediation (mandatory)
- [ ] Remove unnecessary broad access (for example, Everyone except external users where not required).
- [ ] Remove stale users and stale groups from Finance repositories.
- [ ] Break inheritance where needed for payroll, board packs, M&A, and client financial libraries.
- [ ] Restrict board and M&A libraries to approved need-to-know groups only.
- [ ] Validate least-privilege role mappings for Finance functions (Payroll, FP&A, AP/AR, Controllership).

Evidence:
- [ ] Before/after permission diff attached
- [ ] Remediation sign-off by Finance data owner
- [ ] Security sign-off recorded

### 1.3 Oversharing validation testing (mandatory)
- [ ] Run user-based access tests for each Finance role using test accounts.
- [ ] Confirm users cannot discover/access out-of-scope sensitive files via Microsoft Search.
- [ ] Confirm no out-of-scope retrieval in Copilot pre-production tests for pilot accounts.
- [ ] Run negative tests for payroll and M&A repositories (unauthorized access must fail).
- [ ] Record and remediate all failed test cases before rollout.

Evidence:
- [ ] Test scripts and results attached
- [ ] Failed tests resolved and retested
- [ ] Final go/no-go approval logged

Gate decision:
- [ ] Section 1 complete and approved by Security + Finance data owner + Service owner

---

## 2) Licensing Prerequisites
- [ ] Confirm all ~200 users have eligible base licenses (M365 E5 already confirmed).
- [ ] Procure/assign Microsoft 365 Copilot add-on licenses for pilot cohort first.
- [ ] Define license assignment groups (pilot, wave 1, wave 2, full rollout).
- [ ] Configure license assignment automation (group-based preferred).
- [ ] Confirm disabled/terminated accounts are excluded from assignment groups.

Evidence:
- [ ] License inventory snapshot attached
- [ ] Assignment group list attached

---

## 3) Microsoft 365 Apps Client Readiness
- [ ] Verify Microsoft 365 Apps are deployed for all target users.
- [ ] Confirm update channel is supported and consistent for Finance endpoints.
- [ ] Confirm Office client build meets current Copilot support requirements.
- [ ] Confirm users are signed in with Entra ID work accounts in Office apps.
- [ ] Validate Word, Excel, PowerPoint, Outlook, and Teams launch successfully on pilot devices.

Practical validation sample:
- [ ] Check at least 20 pilot devices across Finance sub-teams
- [ ] Check at least 2 devices per office/VDI profile type

Evidence:
- [ ] Client version report attached
- [ ] Non-compliant device remediation list attached

---

## 4) Identity, Access, and MFA Readiness
- [ ] Confirm MFA is enforced for all Finance users and break-glass exceptions are documented.
- [ ] Confirm Conditional Access policies are applied to Office and Teams access paths.
- [ ] Confirm sign-in risk/user risk policies are enabled and monitored.
- [ ] Confirm privileged/admin roles are separated from day-to-day user accounts.
- [ ] Confirm dormant accounts and external guests with Finance access are reviewed.

Evidence:
- [ ] MFA coverage report attached
- [ ] Conditional Access policy review notes attached

---

## 5) Sensitivity Labelling and Information Protection
- [ ] Define/confirm sensitivity labels for key Finance classes:
  - [ ] Payroll
  - [ ] Board packs
  - [ ] M&A confidential
  - [ ] Client financial confidential
- [ ] Apply labels to priority repositories and high-risk legacy content.
- [ ] Configure label-based protections (encryption/access restrictions) where required.
- [ ] Validate label behavior in SharePoint, OneDrive, Office apps, and Teams.
- [ ] Review DLP policies aligned to Finance labels.

Evidence:
- [ ] Label taxonomy and mapping document attached
- [ ] Label coverage report attached
- [ ] DLP validation results attached

---

## 6) Pilot Rollout Controls
- [ ] Define pilot cohort (15-25 users) including one compliance/risk representative.
- [ ] Publish approved pilot use-cases (for example: summarization, drafting, meeting recap).
- [ ] Block prohibited use-cases (for example: unrestricted handling of M&A confidential docs).
- [ ] Enable enhanced monitoring during pilot period.
- [ ] Schedule weekly pilot review (security, service desk, Finance owner).

Pilot exit criteria:
- [ ] Zero high-severity oversharing events
- [ ] All medium findings remediated or risk-accepted
- [ ] Positive productivity outcome captured

---

## 7) End-User Communications and Enablement
- [ ] Send Finance-targeted pre-launch communication:
  - [ ] Why phased rollout is required
  - [ ] What Copilot can and cannot access (permission-trimmed)
  - [ ] Data handling expectations for high-sensitivity content
- [ ] Deliver mandatory 30-minute onboarding for pilot users.
- [ ] Provide prompt guidance specific to Finance scenarios.
- [ ] Publish a one-page "safe use" quick reference.
- [ ] Confirm acknowledgment from pilot users before enablement.

Evidence:
- [ ] Comms pack attached
- [ ] Training attendance recorded
- [ ] User acknowledgment log attached

---

## 8) Final Go/No-Go and Deployment Waves
- [ ] Final readiness review completed.
- [ ] Security approval received.
- [ ] Finance data owner approval received.
- [ ] Service owner approval received.
- [ ] Wave plan approved (pilot -> sub-team waves -> full Finance).

Go-live rule:
- [ ] No broad Copilot assignment until Section 1 remains compliant after remediation validation.

## Owner and Date
- Service owner: ____________________
- Finance data owner: ____________________
- Security approver: ____________________
- Date: ____________________
