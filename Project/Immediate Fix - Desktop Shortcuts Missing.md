# Immediate Fix - Desktop Shortcuts Missing (DWP)

## Immediate objective
Stop rollout side effects and restore shortcuts safely at scale.

## Severity
- Treat as Sev-3 unless impact expands to broader endpoint failure.

## First 0-30 minutes
- Open endpoint incident thread with Intune admin, packaging engineer, and endpoint engineer.
- Pause further rollout waves for impacted app/package.
- Publish workaround:
  - Launch app via Start/Search/approved URL
- Capture one affected and one unaffected device for comparison.

## First 30-60 minutes
- Inspect install/uninstall scripts and detection rules for:
  - Deletes in desktop/start-menu paths
  - Wildcards without allowlist
  - Overwrite/reset behavior on profile paths
- Determine regression class:
  - Packaging
  - Policy/layout
  - Profile/session

## Immediate fix path
- If packaging regression confirmed:
  - Remove destructive operations.
  - Add idempotent shortcut creation logic.
  - Pilot corrected package, then redeploy in waves.
- If policy regression confirmed:
  - Roll back/scope-limit changed layout policy.
  - Force policy sync and verify persistence.
- If profile/session issue:
  - Adjust login order and retry timing after profile readiness.

## Immediate success criteria
- Shortcuts restored for impacted pilot group.
- No new shortcut-loss spikes during rollout waves.
- No collateral impact to unrelated desktop items.

## Escalation trigger
- Escalate if issue expands to app launch failure, profile corruption, or large-scale business disruption.

## Handover to RCA
- Continue full investigation in: Runbook - Desktop Shortcuts RCA.
- Attach before/after script evidence and remediation validation metrics.
