# FinBridge Connect v3.1 Intune Rollout Plan

## Document Control

- Author: DWP Analyst
- Date: 2026-08-11
- App Package: FinBridge Connect v3.1 (.intunewin)
- Target Fleet: 10,000 Windows 11 endpoints
- Delivery Deadline: 3 weeks from 2026-08-11
- Priority Constraint: Finance team must receive app by end of Week 1 (500 users)
- Technical Constraint: 5% of fleet on older hardware (4 GB RAM) may struggle with v3.1
- Previous Stable Version: FinBridge Connect v3.0 (available in Intune)
- Detection Method: Registry version string check

---

## 1. Objective

Deliver FinBridge Connect v3.1 to 10,000 endpoints within 3 weeks while:

1. Meeting Finance priority by end of Week 1.
2. Reducing performance risk on low-spec devices (4 GB RAM cohort).
3. Maintaining service continuity with v3.0 rollback option.

---

## 2. Deployment Strategy

Use ring-based phased rollout with hard quality gates between rings.

### Ring Model

1. Ring 0 - Pilot IT/Engineering and support devices (100 devices)
2. Ring 1 - Finance priority users (500 users, must complete Week 1)
3. Ring 2 - Broad standard hardware wave A (3,000 devices)
4. Ring 3 - Broad standard hardware wave B (4,000 devices)
5. Ring 4 - Broad standard hardware wave C (1,900 devices)
6. Ring 5 - Low-spec hardware cohort (500 devices, controlled rollout)

Total: 10,000 endpoints

Note: Low-spec cohort is intentionally last to minimize production impact.

---

## 3. Timeline (3 Weeks)

## Week 1 (Priority and Validation)

### Day 1-2

- Deploy to Ring 0 (100 devices).
- Validate install success, launch success, and detection rule behavior.
- Monitor helpdesk and endpoint performance telemetry.

### Day 3-5

- Deploy to Ring 1 (Finance 500 users).
- Complete Finance deployment by end of Week 1.
- Keep v3.0 ready for immediate targeted rollback if critical issues emerge.

Week 1 Exit Criteria:

1. Install success >= 98% in Ring 1.
2. No Sev1 business outage in Finance workflows.
3. No widespread performance degradation attributable to v3.1.

## Week 2 (Main Fleet Expansion)

### Day 6-8

- Deploy Ring 2 (3,000 devices).
- Hold 24-hour quality check before next wave.

### Day 9-10

- Deploy Ring 3 (4,000 devices).
- Continue incident watch and performance checks.

Week 2 Exit Criteria:

1. Cumulative install success >= 97%.
2. Incident trend stable or improving.
3. Detection rule false negatives/positives within accepted threshold.

## Week 3 (Completion and Low-Spec Devices)

### Day 11-13

- Deploy Ring 4 (1,900 devices).

### Day 14-15

- Deploy Ring 5 low-spec cohort (500 devices) in two sub-batches of 250.
- Increase monitoring frequency during this phase.

Week 3 Exit Criteria:

1. Fleet deployment complete (10,000 devices).
2. Final install success >= 97%.
3. Residual failures triaged with remediation path or controlled rollback.

---

## 4. Targeting and Assignment Design in Intune

### 4.1 Required Azure AD Device/User Groups

1. FB-APP-FBCONNECT31-R0-PILOT
2. FB-APP-FBCONNECT31-R1-FINANCE
3. FB-APP-FBCONNECT31-R2-STD-A
4. FB-APP-FBCONNECT31-R3-STD-B
5. FB-APP-FBCONNECT31-R4-STD-C
6. FB-APP-FBCONNECT31-R5-LOWSPEC
7. FB-APP-FBCONNECT31-EXCLUSIONS

### 4.2 Exclusion Logic

Exclude from v3.1 assignment:

- Devices in FB-APP-FBCONNECT31-EXCLUSIONS
- Devices with active critical incidents
- Devices requiring temporary hold (CAB decision)

### 4.3 Assignment Type

- Primary method: Required deployment for each ring.
- Deadline behavior: align with weekly ring windows and business hours.

---

## 5. Low-Spec Hardware Risk Control (4 GB RAM cohort)

Because 5% of devices may struggle:

1. Keep low-spec devices in dedicated Ring 5.
2. Run first low-spec sub-batch of 250 devices.
3. Validate CPU/memory pressure and user-impact tickets for 24 hours.
4. Proceed to second sub-batch only if no Sev1/Sev2 spike.
5. If unacceptable performance is observed, rollback those devices to v3.0 and pause low-spec rollout.

Recommended dynamic grouping signal (if available):

- Device memory <= 4 GB for low-spec targeting.

---

## 6. Detection Rule Validation (Registry Version Check)

Current detection uses registry version string. Validate before broad deployment to avoid false compliance.

### Pre-Deployment Detection Tests

1. Clean device without app: detection must return Not Installed.
2. Device with v3.0 only: detection must return Not Installed for v3.1 app.
3. Device with v3.1 installed: detection must return Installed.
4. Upgrade path test v3.0 to v3.1: detection flips correctly after install.

### Detection Hardening

- Ensure rule checks exact v3.1 version string, not generic product name only.
- Prefer exact match over prefix match to avoid false positives.
- If multiple keys exist, validate expected key path order and architecture path.

---

## 7. Rollback Plan (v3.0)

v3.0 is available in Intune and is the approved rollback package.

### Rollback Triggers

Initiate rollback for a ring if any of the following occur:

1. Install success drops below 95% in ring for over 8 business hours.
2. Sev1 business function failure linked to v3.1.
3. Sustained endpoint performance degradation above agreed threshold.

### Rollback Actions

1. Pause v3.1 deployment to next ring.
2. Assign v3.0 required deployment to affected ring group.
3. Remove or supersede v3.1 assignment for impacted cohort.
4. Confirm app launch and business transaction recovery.
5. Publish rollback communication to impacted users and support teams.

---

## 8. Monitoring and Reporting

### Operational Dashboard Checks (at least 3 times daily during rollout)

1. Install status by ring (success, failed, pending).
2. Failure codes and top error distribution.
3. Device performance complaints and incident volume.
4. Detection mismatch cases (installed but not detected, or detected but not installed).

### First 24 Hours per Ring - Minimum Checks

1. Install success rate.
2. App launch confirmation sample.
3. Business workflow smoke test sample.
4. Helpdesk ticket trend delta versus baseline.

---

## 9. Support Model

### L1

- Verify assignment group membership and sync status.
- Confirm basic connectivity and retry policy sync.
- Escalate persistent install/detection failures to L2/L3.

### L2/L3

- Analyze Intune install logs and failure codes.
- Validate registry detection path on failed endpoints.
- Execute ring-level hold or rollback recommendation.

---

## 10. Communications Plan

1. T-2 days: announce pilot and Finance priority schedule.
2. Start of Week 1: notify Finance users of rollout window and support channel.
3. Before each new ring: send rollout advisory and known issue watchlist.
4. If rollback: send immediate user and leadership update with ETA and workaround.
5. End of Week 3: completion report with success metrics and open issues.

---

## 11. Governance and Change Control

1. CAB approval required before Ring 2 and Ring 5 progression.
2. No ring advancement without meeting exit criteria.
3. All exceptions documented in change record.

---

## 12. Final Acceptance Criteria

Rollout is complete when all conditions are true:

1. 10,000 targeted endpoints processed.
2. Finance 500 users completed by end of Week 1.
3. Overall success >= 97% with controlled residual failures.
4. Low-spec cohort either stable on v3.1 or formally rolled back to v3.0 with approved exception.
5. Post-implementation review completed and lessons captured.
