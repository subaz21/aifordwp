# FinBridge Connect v3.1 - Phased Intune Deployment Plan

Date: 2026-08-12  
Owner: DWP Engineering  
Application: FinBridge Connect v3.1 (.intunewin already in Intune catalog)  
Target: 10,000 Windows 11 endpoints  
Deadline: 3 weeks (by 2026-09-02)

## 1. RING STRUCTURE

Ring 1 (Pilot)
- Size: 300 endpoints (3% of fleet).
- Duration: 3 calendar days deployment + 48-hour monitoring hold (minimum 5 days total before Ring 2 decision).
- Include:
  - IT endpoint engineering and EUC support users (known fast-feedback users).
  - 40 Finance users (non-critical roles only) for early business validation.
  - 30 devices from the at-risk 4 GB RAM cohort.
- Purpose:
  - Validate install behavior, detection rule accuracy, and upgrade behavior from v3.0.
  - Detect early app stability/performance regressions before exposing high-volume business users.
- Intune assignment group type:
  - Primary ring group: Assigned (static) Microsoft Entra device group: DWP-FBC31-R1-Pilot-Assigned.
  - At-risk validation subgroup: Dynamic device group using hardware filter (TotalPhysicalMemory <= 4 GB): DWP-FBC31-R1-LowSpec-Dynamic.

Ring 2 (Early)
- Size: 2,200 endpoints total.
- Duration: 4 calendar days deployment + 48-hour monitoring hold (minimum 6 days total before Ring 3 decision).
- Include:
  - Finance remaining 460 users (to complete all 500 by end of Week 1).
  - Additional business units with medium criticality workloads.
  - 140 additional 4 GB RAM devices (controlled exposure).
- Purpose:
  - Prove business readiness at scale across mixed departments.
  - Confirm support load remains manageable under larger rollout volume.
- Intune assignment group type:
  - Finance: Assigned (static) user group: DWP-FBC31-R2-Finance-Assigned.
  - Non-finance early adopters: Assigned (static) device group: DWP-FBC31-R2-Early-Assigned.
  - 4 GB RAM subset: Dynamic device group: DWP-FBC31-R2-LowSpec-Dynamic.

Ring 3 (Broad)
- Size: 7,500 endpoints (remaining fleet).
- Duration: 10 calendar days, deployed in daily wave slices of approximately 750 endpoints/day.
- Include:
  - Remaining standard hardware devices.
  - Remaining low-spec devices only after low-spec criteria pass in Ring 2.
- Purpose:
  - Complete enterprise-wide adoption inside the 3-week deadline.
  - Preserve control by using staged daily waves with pause points.
- Intune assignment group type:
  - Standard broad rollout: Dynamic device groups by department/region for operational batching: DWP-FBC31-R3-Broad-Dynamic-*.
  - Low-spec completion cohort: Assigned (static) fallback group for isolated control: DWP-FBC31-R3-LowSpec-Isolated-Assigned.

## 2. ADVANCE CRITERIA

Ring 1 -> Ring 2 advance criteria
- Install success rate: >= 98.0% successful installs in Ring 1, measured from Intune app install status within 48 hours of assignment.
- Error rate threshold: <= 1.5% failed installs in Ring 1 during the same 48-hour measurement window.
- User-reported issues threshold: <= 8 tickets per 100 users per 24 hours (ticket rate <= 8%) attributable to FinBridge v3.1, measured for two consecutive business days.
- Monitoring period: Minimum 48 hours after at least 95% of Ring 1 devices have checked in and received policy.

Ring 2 -> Ring 3 advance criteria
- Install success rate: >= 97.5% successful installs in Ring 2 within 72 hours of assignment.
- Error rate threshold: <= 2.0% failed installs in Ring 2 over that 72-hour window.
- User-reported issues threshold: <= 5 tickets per 100 users per 24 hours (ticket rate <= 5%) attributable to FinBridge v3.1 for two consecutive business days.
- Monitoring period: Minimum 72 hours after at least 95% of Ring 2 devices have checked in and received policy.

Hold condition (pause without full rollback)
- Trigger: Any single recurring install error code affecting >= 0.8% of devices in the active ring for >= 6 continuous hours while overall failure remains below rollback threshold.
- Action: Pause progression to the next wave/ring, keep current assignments in place, open problem record, remediate root cause, then re-evaluate after 24 hours.
- Specific example: Error 0x87D300C9 appears on 22 out of 2,200 Ring 2 devices (1.0%) continuously for 6+ hours; rollout is held pending packaging command-line fix validation.

## 3. ROLLBACK TRIGGERS

Trigger 1: Install failure rate automatic halt
- Condition: Failed install rate >= 5.0% in any active ring over a rolling 4-hour window (from Intune app install status).
- Immediate action: Halt forward rollout (no new ring or wave assignments).
- Decision owner: Incident Commander (EUC Platform Lead) with Change Manager concurrence.
- Decision window: 60 minutes from threshold breach alert.
- Exact Intune execution:
  - Remove Required assignment of FinBridge v3.1 from impacted ring group(s).
  - Add impacted ring group(s) to FinBridge v3.0 Required assignment.
  - Add impacted ring group(s) to FinBridge v3.1 exclusion group: DWP-FBC31-Rollback-Exclude.

Trigger 2: Application crash rate rollback consideration
- Condition: App crash rate >= 3 crashes per 100 active devices per hour for 3 consecutive hours in the active ring (from endpoint analytics/crash telemetry linked to FinBridge process).
- Immediate action: Enter rollback review state and freeze next wave.
- Decision owner: Service Owner (Finance Apps) + EUC Platform Lead jointly.
- Decision window: 2 hours from confirming telemetry trend.
- Exact Intune execution if rollback approved:
  - Keep v3.1 assignment removed for impacted cohorts.
  - Enforce v3.0 Required assignment to same cohorts.
  - Keep unaffected rings on hold until post-incident review sign-off.

Trigger 3: Business-critical failure immediate rollback
- Condition: Finance payment authorization workflow cannot complete for production users after v3.1 install (for example, transaction signing module fails and blocks approvals).
- Immediate action: Immediate rollback regardless of percentages.
- Decision owner: Major Incident Manager can trigger immediately; Service Owner ratifies after execution.
- Decision window: 15 minutes (emergency change path).
- Exact Intune execution:
  - Remove FinBridge v3.1 Required assignment from Finance groups.
  - Assign FinBridge v3.0 as Required to Finance groups.
  - Place Finance groups in v3.1 exclusion group until hotfix validation completes.

Trigger 4: 4 GB RAM device failure ring isolation
- Condition: 4 GB RAM cohort failure rate >= 8.0% in any 24-hour period, or severe performance tickets >= 10 per 100 low-spec users/day.
- Immediate action: Isolate low-spec devices from main rollout; continue standard-hardware rollout only if other gates pass.
- Decision owner: EUC Platform Lead with Desktop Engineering Manager.
- Decision window: 4 hours from breach confirmation.
- Exact Intune execution:
  - Remove low-spec dynamic group from v3.1 Required assignment.
  - Add low-spec assigned isolation group to FinBridge v3.0 Required assignment.
  - Maintain standard hardware groups in current ring state pending CAB note.

## 4. FINANCE DEADLINE RESOLUTION

Option A - Compress pilot timeline so Finance lands in Ring 2 by end of Week 1
- Minimum safe pilot duration: 72 hours deployment plus 24-hour stability observation (4 days total).
- Risk introduced: Lower confidence in rare failure modes (for example, day-4/5 defects and non-peak-time crashes may be missed).
- Compensating control: Increase Ring 2 Finance rollout as two sub-waves (230 users + 230 users, 24 hours apart) with enhanced live monitoring and dedicated L2 on-call.

Option B - Separate Finance Ring 0 before main pilot
- Ring 0 structure:
  - Size: 120 Finance users across 3 sub-teams (40 each), mix of device types including 20 low-spec devices.
  - Duration: 2 days deployment + 24-hour hold.
  - Purpose: Validate finance-critical workflows first, before non-finance pilot.
  - Intune group type: Assigned static user group for strict membership control.
- Ring 0 advance conditions:
  - Install success >= 98.5% within 48 hours.
  - Finance-critical workflow success = 100% in defined smoke test set.
  - Ticket rate <= 6 per 100 users/day for 2 business days.
- Ring 0 rollback plan:
  - If workflow failure occurs once in production validation, immediate revert of Ring 0 users to v3.0 Required assignment and exclusion from v3.1 pending fix.

Recommendation (single clear decision)
- Recommend Option A.
- Justification:
  - It meets the hard Finance deadline by placing all 500 Finance users in Ring 2 by end of Week 1.
  - It avoids creating a separate pre-pilot governance track, which adds operational complexity and can delay the main 10,000-endpoint cadence.
  - Residual risk from compressed pilot is controlled by strong compensating controls: Finance sub-waves, stricter real-time monitoring, and pre-approved rollback automation to v3.0.
  - This keeps the full fleet on schedule for completion within 3 weeks while preserving measurable safety gates.
