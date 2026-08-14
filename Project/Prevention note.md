# Prevention Note - FinBridge Floor 6 Monday Incident

Date: 2026-08-14

## Purpose
This note rewrites the technical resolution across the existing incident files into one evidence-led prevention record. Every conclusion below includes its reasoning path.

## 1) Technical resolution (with reasoning)

Conclusion:
The most likely login failure mechanism was deployment-triggered compliance/state re-evaluation, followed by Conditional Access block or delay for a subset of Floor 6 devices.

Reasoning:
1. Timing fit: The failures appeared on Monday morning immediately after a Friday deployment window, which matches reboot/check-in/compliance re-evaluation timing.
2. Cohort fit: The issue affected a multi-user cohort in one floor/population, which is more consistent with shared control-plane state than random endpoint faults.
3. Diagnostic fit: The existing check plan in 3a is designed to correlate device compliance and sign-in events within the deployment-to-incident window rather than using unbounded logs.
4. Action fit: The immediate recovery path in login response docs prioritizes scoped, reversible mitigation (sync/compliance refresh, narrow CA exception) over broad policy weakening.

## 2) Copilot incident classification (pass/fail marker)

Conclusion:
The Copilot matter-visibility event is a security signal, not a Copilot product bug.

Reasoning:
1. The Copilot runbook explicitly states Copilot surfaces content already accessible to the signed-in identity.
2. If a paralegal saw restricted matter content, an access path already existed (ACL/group/template drift), so the fault domain is permissioning.
3. Disabling Copilot without correcting access control would hide the symptom but leave over-permission active.
4. Because this is a law-firm ethical-wall context, unauthorized visibility is governance/security critical by definition and requires Legal/Compliance handling.

Reference:
- Runbook - Copilot Paralegal Issue RCA.md

## 3) Script evidence: AI-generated vs hand-corrected (actual before/after)

Source:
- Powershell command.ps1
-  3a. Build the check, don't just describe it.md

Version 1 (AI-generated excerpt):

```powershell
param(
    [switch]$DryRun
)

$os = Get-WmiObject Win32_OperatingSystem

$events = Get-WinEvent -LogName "Microsoft-Windows-DeviceManagement-Enterprise-Diagnostics-Provider/Admin" -MaxEvents 9999
$gpEvents = Get-WinEvent -LogName System -MaxEvents 9999 | Where-Object { $_.Id -eq 8001 -or $_.Id -eq 8002 }

"Evidence collected" | Out-File "C:\Temp\evidence.txt"
```

Version 2 (hand-corrected excerpt):

```powershell
param(
    [Parameter(Mandatory = $true)]
    [datetime]$DeploymentTime,
    [switch]$DryRun,
    [string]$OutputRoot = "$env:ProgramData\DWP\IncidentEvidence"
)

if ($DryRun) {
    $plan | ConvertTo-Json -Depth 3
    return
}

$bootInfo = Get-SafeResult -StepName "LastBoot" -Action {
    (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
}

$complianceEvents = Get-SafeResult -StepName "MDMComplianceEvents" -Action {
    Get-WinEvent -FilterHashtable @{
        LogName   = "Microsoft-Windows-DeviceManagement-Enterprise-Diagnostics-Provider/Admin"
        StartTime = $windowStart
        EndTime   = $collectedAt
    } -MaxEvents 200 -ErrorAction Stop |
        Select-Object TimeCreated, Id, LevelDisplayName, Message
}
```

Why the correction matters:
1. Evidence quality improved: window-bounded events prove or disprove causality better than unbounded event dumps.
2. Operational safety improved: DryRun became real behavior instead of a no-op.
3. Data minimization improved: only needed fields were retained from dsreg output.
4. Resilience improved: per-step error capture preserved partial evidence when one command fails.

## 4) One wrong first instinct, and what changed

Wrong first instinct:
Assume broad log collection was safer because "more data means better certainty."

Why evidence did not support that instinct:
1. Unbounded event pulls introduced historical noise unrelated to Friday-to-Monday causality.
2. Raw status output increased unnecessary identifier exposure in evidence files.
3. A declared DryRun with no execution branch gave false assurance.

What changed my mind:
Line-by-line verification against the target hypothesis in 3a showed that bounded, structured, hypothesis-linked collection was stronger and safer than full-history dumping.

## 5) One specific process change that would have caught this before Monday

Control name:
Friday Authentication-Compliance Guardrail (FACG)

Definition:
1. Scope trigger: any Friday app rollout that can force reboot, policy sync, or compliance re-evaluation.
2. Mandatory checks: at T+2 hours after rollout and Sunday 18:00 local.
3. Required dataset: Intune compliance-state transitions, Entra sign-in failures by cohort, Conditional Access evaluation results.
4. Pass criteria: no abnormal Not Compliant spike in rollout cohort and no new CA block code concentration versus control cohort.
5. Fail action: automatic freeze of next rollout wave plus incident-owner approval gate before Monday business start.

Why this would have caught the issue:
The suspected failure path depends on state transitions between deployment and first heavy login window. FACG explicitly checks that transition before users arrive Monday.

## 6) Runbook as single source for L1 and L2

Single source requirement:
Runbook - People Can't Login RCA.md is the canonical workflow.

Required re-expression rule:
1. L1 article is the user-facing compressed view of the same runbook logic.
2. L2 article is the operator-facing expanded view of the same runbook logic.
3. Any conflict is resolved in favor of the runbook.

Current mapping already visible:
1. Same failure classes in all three: Conditional Access, compliance, MFA/credential, service/network.
2. Same triage order: evidence first, then scoped mitigation.
3. Same verification intent: recovery trend and stability checks.

Reference:
- Runbook - People Can't Login RCA.md
- L1 People can't login RCA.md
- L2 People can't login issue.md

## 7) Partner-facing note (plain language, non-technical)

On Monday morning, some Floor 6 staff could not sign in, or sign-in was very slow. This happened after a Friday software rollout. We have already stopped that rollout from affecting more users and are restoring access for the people already impacted.

Separately, one paralegal was shown a client matter she should not have seen. We are treating this as a security and confidentiality issue, not a software glitch. The access route was removed immediately, evidence was preserved, and Legal/Compliance are reviewing impact.

At this point, we have no evidence that client data left the firm. We will provide a confirmed end-of-day update with any further actions.

## 8) Source files used

- A ranked differential for the login-performance problem.md
-  3a. Build the check, don't just describe it.md
- Powershell command.ps1
- Runbook - People Can't Login RCA.md
- L1 People can't login RCA.md
- L2 People can't login issue.md
- Runbook - Copilot Paralegal Issue RCA.md
- FinBridge-Floor6-Legal-Monday-Incident-Comms-2026-08-14.md
