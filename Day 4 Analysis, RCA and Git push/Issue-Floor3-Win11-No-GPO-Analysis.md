# Group Policy Failure Analysis - Floor3-Win11-No-GPO

Date: 2026-08-07
Analyst: DWP Engineer

## Scope Facts Used
- Symptom: three Windows 11 machines on Floor 3 did not apply Group Policy at startup
- Who: 3 of 4 machines in OU=Finance affected
- Since: startup window approximately 07:40 to 07:55 on 2024-03-15
- Change: DNS migration/decommission completed overnight; old DNS server retired

## Ranked Most Likely Causes (Most Probable First)

## 1) DHCP scope still assigning decommissioned DNS server
Why this fits the scope facts:
- Affected machines show DHCP-assigned DNS pointing to old/decommissioned resolver.
- Group Policy and DC reachability failures are consistent with broken DNS resolution.
- 3 of 4 affected while one unaffected matches mixed DNS assignment state.

Single fastest check:
- On an affected host, run `ipconfig /all` and confirm DHCP-provided DNS server value.

## 2) Domain controller outage or SYSVOL unavailable
Why this fits the scope facts:
- Events show inability to reach DC and access SYSVOL path.
- GPO errors 1058/1030 commonly appear when SYSVOL/DC is unavailable.

Single fastest check:
- From multiple subnets, test `\\FINBRIDGE-DC01\sysvol` and review DC service health.

## 3) Local NIC/network initialization race at boot
Why this fits the scope facts:
- Early boot can trigger temporary domain-unreachable state before network settles.
- NLA reaches running state just before Netlogon/GPO failures.

Single fastest check:
- Compare first successful DNS query time vs first GPO attempt in boot timeline.

## 4) OU-level GPO link or ACL issue
Why this fits the scope facts:
- Policy retrieval errors can occur when OU-linked GPO cannot be enumerated.
- Affects only a subset of OU endpoints in observed scope.

Single fastest check:
- Validate GPO link status and security filtering for OU=Finance in GPMC.

## 5) Machine secure channel break (computer account trust)
Why this fits the scope facts:
- Netlogon 5719 can appear with secure channel issues.
- Could cause DC auth failures and downstream GPO processing errors.

Single fastest check:
- Run secure channel test (`Test-ComputerSecureChannel`) on an affected host.

## Evidence Assessment Against Incident Event Logs

### 1) DHCP scope still assigning decommissioned DNS server
Judgement: Supports
Why:
- Affected host obtained old DNS via DHCP; comparison host obtained new DNS and processed GPO successfully.
Determining events:
- 07:42:18 - Event 50036 - DNS assigned 10.10.3.250 (old/decommissioned)
- 07:40:05 (comparison FB029) - Event 50036 - DNS assigned 10.10.0.10 (correct)
- 07:40:11 (comparison FB029) - Event 1500 - GPO processed successfully

### 2) Domain controller outage or SYSVOL unavailable
Judgement: Contradicts
Why:
- DC/SYSVOL were reachable for unaffected comparison machine during same window, indicating no global outage.
Determining events:
- 07:40:11 (comparison FB029) - Event 1500 - GPO success in same OU/time window
- 07:40:08 - Event 5719 and 07:40:09/07:40:11 - Event 1058 on affected host indicate local reachability failure, not DC-wide outage

### 3) Local NIC/network initialization race at boot
Judgement: Neutral
Why:
- Timing could contribute, but persistent DNS timeout and wrong DHCP DNS assignment provide stronger primary explanation.
Determining events:
- 07:40:02 - Event 7036 - NLA service running
- 07:41:05 - Event 1014 - DNS timeout, configured DNS servers not responding
- 07:44:01 - Event 1129 - repeated GPO failure beyond initial boot seconds

### 4) OU-level GPO link or ACL issue
Judgement: Contradicts
Why:
- Unaffected machine in same OU processed GPO successfully, which is inconsistent with OU-wide link/ACL failure.
Determining events:
- 07:40:11 (comparison FB029) - Event 1500 - Group Policy settings processed successfully

### 5) Machine secure channel break (computer account trust)
Judgement: Contradicts
Why:
- Secure channel error appears alongside DNS failures and wrong DNS assignment; pattern points to name-resolution dependency failure rather than trust break.
Determining events:
- 07:40:08 - Event 5719 - no domain controller available
- 07:41:05 - Event 1014 - DNS resolution timeout for FINBRIDGE-DC01
- 07:42:18 - Event 50036 - wrong DNS server assigned

### Interim Position
- All five hypotheses have been assessed.
- No winner selected yet.

## Addendum - Event Detail, Surviving Hypothesis, and Resolution Plan

### A) Incident Event Details (Chronological)
- 07:40:02 - Event 7036 - Network Location Awareness entered running state.
- 07:40:08 - Event 5719 - Netlogon secure channel setup failed; no DC available; DNS query for FINBRIDGE-DC01 no response.
- 07:40:09 - Event 1058 - GPO failed; cannot access SYSVOL gpt.ini; error 0x3.
- 07:40:10 - Event 1030 - Cannot query list of GPO objects; error 0x546.
- 07:40:11 - Event 1058 - GPO failure repeated.
- 07:40:12 - Event 1129 - GPO failed due to no DC connectivity.
- 07:41:05 - Event 1014 - DNS name resolution timed out; configured DNS servers did not respond.
- 07:42:18 - Event 50036 - DHCP lease assigned DNS server 10.10.3.250 (old).
- 07:44:01 - Event 1129 - GPO failure repeated.
- Comparison host FB029: 07:40:05 Event 50036 assigned DNS 10.10.0.10 (correct), 07:40:11 Event 1500 GPO success.

### B) Surviving Hypothesis After Elimination
Surviving hypothesis:
- DHCP scope for Floor 3 still referenced a decommissioned DNS server, causing DC name resolution failures and blocking Group Policy processing.

Why this survives the evidence:
- Affected machines got old DNS and failed DC lookup/GPO.
- Unaffected machine got correct DNS and succeeded in GPO in same OU/time window.
- DNS timeout + Netlogon/DC/SYSVOL errors align directly with broken DNS path.

### C) Detailed Resolution Steps
1. Correct DHCP scope option for Floor 3 subnet to DNS 10.10.0.10.
2. Force DHCP renew on affected clients (`ipconfig /release` and `ipconfig /renew`).
3. Validate DNS server list on endpoints now shows only valid resolver(s).
4. Test DC name resolution and SYSVOL path access.
5. Trigger Group Policy update (`gpupdate /force`) and confirm success events.
6. Monitor startup cycle on all Floor 3 finance endpoints for no repeat 5719/1058/1030/1129/1014.
