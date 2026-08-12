# FinBridge Finance Copilot Readiness and Risk Plan (2026-08-12)

## Input Baseline
- Department: Finance (~200 users)
- Data sensitivity: High (payroll, board packs, M&A documents, client financial data on shared drives)
- Current state: SharePoint permissions inherited from 2019 migration and not fully audited since
- Licensing: M365 E5 confirmed for all users; Copilot for M365 add-on not yet assigned

## Decision Summary
Do not assign Copilot add-ons to all 200 Finance users yet.

Run a controlled pilot only after access governance controls are in place. Current permission uncertainty creates elevated oversharing risk for AI-assisted retrieval across SharePoint and connected M365 workloads.

## Risk Rating
- Confidentiality risk: High
- Integrity risk: Medium
- Availability risk: Low
- Overall rollout risk today: High

## Why The Risk Is High
- Copilot only respects existing permissions; it does not fix legacy over-permissioning.
- A 2019 inherited model with no full audit is a known oversharing pattern.
- Finance content includes highly sensitive classes where accidental exposure has legal and regulatory impact.

## Gate Criteria Before Broad Enablement
1. Complete a full SharePoint permissions audit for Finance sites, libraries, and sensitive folders.
2. Remove broad access groups and break unnecessary inheritance on high-risk locations.
3. Validate owner accountability for each Finance site and library.
4. Apply sensitivity labels and retention coverage to high-risk document classes.
5. Confirm audit logging, alerting, and investigation workflow for unusual access patterns.
6. Run user communication and acceptable-use acknowledgment before license assignment.

## Recommended Rollout Model
### Phase 0: Control Hardening (Required)
- Scope: All Finance SharePoint locations and Teams-connected document stores
- Outcome: Verified least-privilege baseline and documented data owners

### Phase 1: Limited Pilot (15-25 users)
- Audience: Finance leadership support staff, analysts, and one risk/compliance representative
- Duration: 2-4 weeks
- Controls: Weekly access review, prompt-use guidance, and monitored activity logs
- Success threshold: No high-severity oversharing events and measurable productivity benefit

### Phase 2: Staged Expansion
- Expand by sub-team in waves (for example: FP&A, Payroll, AP/AR, Controllership)
- Require sign-off per wave from Data Owner + Security + Service Owner

### Phase 3: Full Department Enablement
- Assign remaining Copilot add-ons after successful staged validation
- Keep monthly access recertification for Finance high-sensitivity repositories

## Minimum Technical and Governance Controls
- Entra ID group hygiene for Finance roles (remove stale memberships)
- SharePoint restricted access for M&A and board-pack repositories
- Purview sensitivity labels aligned to Finance data classes
- DLP and exfiltration policy review for labeled files
- Audit queries and incident runbook for suspected overexposure

## KPI and Exit Metrics
- Permission remediation completion: >= 95% of identified issues resolved before scale-out
- Oversharing incidents during pilot: 0 high severity
- License activation completion in target wave: >= 98%
- User-reported time savings in pilot: target >= 20% for selected workflows

## Communications (Plain Language)
Finance will get Copilot in phases, not all at once. This is to protect sensitive data and ensure access is correctly limited before rollout. No action is required yet for most staff. Pilot users will receive separate onboarding instructions.

## Immediate Next Actions (This Week)
1. Freeze broad Copilot assignment for Finance.
2. Start permissions audit backlog from highest-sensitivity repositories first (Payroll, board, M&A).
3. Nominate pilot cohort and business owner.
4. Publish one-page acceptable-use guidance for Finance pilot users.
5. Schedule a go/no-go checkpoint for pilot start.
