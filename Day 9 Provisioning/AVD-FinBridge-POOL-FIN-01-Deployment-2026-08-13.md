# Azure Virtual Desktop Deployment Report
## FinBridge Windows 11 Migration — POOL-FIN-01

**Report Date:** 2026-08-13
**Engineer:** DWP Engineering (Azure CLI)
**Subscription:** 59b76132-b5e4-47a8-806b-9e477da77802 (labs29)
**Resource Group:** DWPAI-LAB-RG
**Region:** East US
**M365 Tenant:** zippyops.in
**Status:** COMPLETE — session host `Available`

---

## Executive Summary

Deployed an end-to-end Azure Virtual Desktop environment for the FinBridge Windows 11 migration: a pooled, breadth-first host pool, a Desktop application group registered to a workspace, and one Microsoft Entra ID–joined (cloud-only, no on-prem AD) Windows 11 multi-session host with Trusted Launch (Secure Boot + vTPM). RBAC was pre-checked before any role-assignment step. The session host initially failed to register with AVD; root-caused via in-guest `dsregcmd` logs to a **duplicate hostname conflict in Microsoft Entra ID**, not a networking or agent issue. Remediated by renaming the guest OS and rejoining. Final state confirmed via the AVD control-plane API: host `Available`, 0 sessions, accepting new connections.

---

## Environment / Inputs

| Item | Value |
|---|---|
| Subscription ID | 59b76132-b5e4-47a8-806b-9e477da77802 |
| Resource group | DWPAI-LAB-RG |
| Region | East US (`eastus`) |
| M365 tenant | zippyops.in |
| Target M365 account | p57@zippyops.in |
| Host pool | POOL-FIN-01 (Pooled, BreadthFirst, max 5 sessions/host) |
| Application group | POOL-FIN-01-DAG (Desktop) |
| Workspace | FinBridge-Workspace |
| Session host VM | vm-fin-01 (Standard_B2ms, Windows 11 24H2 AVD image) |

---

## Pre-Work: Permission Check

Before creating any resources or role assignments, the signed-in identity was verified per the request's explicit instruction to stop if role-assignment rights were missing.

- Signed-in identity: `traininguser77@zippyops.in`
- Effective RBAC on subscription `59b76132-b5e4-47a8-806b-9e477da77802`: **Owner** (inherited at subscription scope, covers the resource group)
- Conclusion: sufficient rights to create resources **and** role assignments — proceeded without stopping.

---

## Resources Built

### 1. Host pool — POOL-FIN-01
| Property | Value |
|---|---|
| Type | Pooled |
| Load balancer | BreadthFirst |
| Max session limit | 5 |
| Preferred app group type | Desktop |
| Custom RDP property | `targetisaadjoined:i:1;` (required for Entra-only, non-domain-joined session hosts) |

### 2. Application group — POOL-FIN-01-DAG
- Type: Desktop
- Host pool reference: POOL-FIN-01

### 3. Workspace — FinBridge-Workspace
- Application group registered: POOL-FIN-01-DAG

### 4. Networking
- VNet `vnet-finbridge-avd` (10.0.0.0/16) / subnet `snet-sessionhosts` (10.0.0.0/24) — auto-created alongside the VM by `az vm create`.
- NSG `vm-fin-01NSG` with an inbound RDP (3389) allow rule for direct admin connectivity.

### 5. Session host VM — vm-fin-01
| Property | Value |
|---|---|
| Image | `MicrosoftWindowsDesktop:windows-11:win11-24h2-avd:latest` |
| Size | Standard_B2ms |
| Security type | Trusted Launch |
| Secure Boot | Enabled |
| vTPM | Enabled |
| Identity | System-assigned managed identity |
| Domain membership | Microsoft Entra ID joined only (no on-prem AD in this environment) |

Extensions installed:
- `AADLoginForWindows` (Microsoft.Azure.ActiveDirectory) — enables Entra sign-in on the VM.
- `DSC` (Microsoft.Powershell, `Configuration.ps1\AddSessionHost`) — registers the VM into the host pool using a time-boxed registration token.

### 6. Role assignments (p57@zippyops.in)
| Role | Scope | Purpose |
|---|---|---|
| Virtual Machine Administrator Login | `vm-fin-01` | Direct RDP login to the VM using Entra credentials |
| Desktop Virtualization User | `POOL-FIN-01-DAG` | Entitlement to the published desktop via the AVD client |

---

## Issue Encountered: Session Host Would Not Register

### Symptom
After installing the AVD agent/bootloader and the DSC `AddSessionHost` extension (both reported `Succeeded`), the host pool's `sessionHosts` list remained empty:
```
GET .../hostPools/POOL-FIN-01/sessionHosts?api-version=2024-04-03
→ { "value": [] }
```

### Diagnosis (performed on the VM itself, not by re-running the same install)
1. Confirmed outbound connectivity to AVD control-plane endpoints (`rdbroker.wvd.microsoft.com`, `rddiagnostics.wvd.microsoft.com`) — both reachable on TCP 443. Ruled out network/firewall.
2. Confirmed `RdAgent` and `RDAgentBootLoader` services were installed and `Running`. Ruled out a failed MSI install.
3. Ran `dsregcmd /status` on the VM:
   - `AzureAdJoined : NO`
   - Ngc prerequisite check: `PreReqResult: WillNotProvision`
4. Ran `dsregcmd /join` explicitly — failed with `Error code: 0x801c0083`.
5. Read `Microsoft-Windows-User Device Registration/Admin` event log (Event ID 304):
   > Server error: `{"odata.error":{"code":"Request_BadRequest","message":{"value":"Another object with the same value for property hostnames already exists."}, ...}}`

### Root Cause
The VM's hostname (`vm-fin-01`) collided with an **existing device object already registered in Microsoft Entra ID** under a different subscription/resource group (a stale/duplicate object from prior lab activity in the same tenant). Microsoft Entra ID rejects a new device join when the hostname is already claimed by another device object, so the Secure VM Join silently never completed — which meant the AVD agent had a running service but no valid Entra device identity to register against the host pool.

Deleting the conflicting Entra device object via Microsoft Graph (`DELETE /devices/{id}`) was attempted but returned `403 Authorization_RequestDenied` — the signed-in identity has Owner on the subscription but not sufficient Microsoft Entra directory privileges (e.g., Cloud Device Administrator) to remove device objects.

### Remediation
Since directory cleanup was not permitted, the conflict was resolved from the Azure/VM side instead:
1. Renamed the guest OS to a unique hostname (`avd-fb-77-9132`) via `Rename-Computer`, then restarted the VM.
2. Re-ran `dsregcmd /join` — **succeeded** (`Automatic Microsoft Entra SecureVM Join Succeeded`, event ID 389).
3. Regenerated a fresh host pool registration token and re-applied the DSC `AddSessionHost` extension with `--force-update`.
4. Restarted the VM once more to complete the agent registration handshake.
5. Re-queried the AVD session host API — host appeared as `Available`.

### Result
```json
[
  {
    "name": "POOL-FIN-01/avd-fb-77-9132",
    "status": "Available",
    "allowNewSession": true,
    "sessions": 0,
    "lastHeartbeat": "2026-08-13T11:53:11.23Z"
  }
]
```

---

## Other Issues Hit During Execution (tooling, not environment)

| Issue | Cause | Fix |
|---|---|---|
| `az role assignment list --scope ... --all` rejected | `--all` is mutually exclusive with `--scope` in this CLI version | Dropped `--all`, used `--include-inherited` with `--scope` |
| `az desktopvirtualization hostpool retrieve-registration-token --host-pool-name` failed | Wrong parameter name for this extension version | Used `hostpool show --query registrationInfo.token` instead |
| VM extension `--settings`/`--protected-settings` JSON parse errors in PowerShell | PowerShell quoting mangles inline JSON/`ConvertTo-Json -Compress` output when passed directly on the command line | Wrote settings/protected-settings to local `.json` files and passed with `@file` syntax |
| `az vm run-command invoke` — "Run command extension execution is in progress" | A prior run-command/extension operation was still active on the VM | Waited for the in-flight extension (`az vm extension wait --updated`) before issuing the next command |

---

## Final Verified State

- Host pool: `POOL-FIN-01` — Pooled / BreadthFirst / max 5 sessions ✔
- Application group: `POOL-FIN-01-DAG` (Desktop) registered to workspace `FinBridge-Workspace` ✔
- Session host: `avd-fb-77-9132` (Azure VM `vm-fin-01`) — **Available**, accepting new sessions, 0 active sessions ✔
- Security: Trusted Launch, Secure Boot enabled, vTPM enabled ✔
- Join type: Microsoft Entra ID joined only (no on-prem AD) ✔
- RBAC: `p57@zippyops.in` has both roles needed for direct RDP and AVD client access ✔

## Login Details for p57@zippyops.in

**Direct RDP to the VM:**
- Address: `20.85.209.72`
- Username: `AzureAD\p57@zippyops.in`
- Requires: Virtual Machine Administrator Login role (assigned)

**AVD client (published desktop):**
- Workspace: `FinBridge-Workspace`
- Sign in as: `p57@zippyops.in`
- Requires: Desktop Virtualization User role on `POOL-FIN-01-DAG` (assigned)

---

## Follow-Ups / Recommendations

1. **Entra device hygiene:** Request Cloud Device Administrator (or equivalent) rights be granted to the DWP engineering role so stale/duplicate device objects can be cleaned up directly, instead of working around them with hostname renames.
2. **Naming standard:** Adopt a hostname convention with a build-unique suffix (e.g., timestamp or sequence) for lab/POC session hosts to avoid future hostname collisions in this shared tenant.
3. **Secret hygiene:** A working file `dsc-protected.json` (contains a host pool registration token) and helper scripts (`avd-register-clean.ps1`, `dsc-settings.json`) were left in the repository root during this session. The registration token has a short expiry (~8 hours) but the file should still be deleted/untracked rather than left in the workspace.
4. **Scale-out:** Current pool has one session host at max 5 sessions/host; add hosts before onboarding more than 5 concurrent FinBridge users.
