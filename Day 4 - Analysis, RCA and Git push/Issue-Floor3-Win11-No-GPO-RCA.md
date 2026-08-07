# Root Cause Analysis Report
## Floor 3 Win11 - Group Policy Not Applying

Report Date: 2026-08-07
Incident Date: 2024-03-15
Incident ID: INC-FB-FLOOR3-GPO-20240315-01
Severity: High (multi-endpoint policy failure in finance OU)
Status: Resolved
Resolution Time: Approximately 1 hour 20 minutes from first startup failures to stable policy processing

---

## Executive Summary

Three of four Windows 11 devices on Floor 3 in OU=Finance failed Group Policy processing during startup. Event logs showed inability to resolve/reach the domain controller and SYSVOL. Investigation confirmed affected machines received an old DNS server through DHCP (decommissioned in migration), while the unaffected peer had the new DNS server and processed policy successfully. Updating the DHCP scope DNS option and renewing client leases restored DC resolution and Group Policy application.

---

## Scope and Impact

- Affected user/group: Finance Floor 3 devices (3 of 4 machines in OU=Finance)
- Affected systems: Domain policy processing at startup (Netlogon, DNS, GroupPolicy dependency chain)
- Business impact: Delayed policy enforcement and potentially missing security/configuration controls on affected endpoints

---

## Supporting Evidence

1. 07:40:08 - Event 5719 - No domain controller available; DNS query for FINBRIDGE-DC01 returned no response.
2. 07:40:09 - Event 1058 - Cannot access SYSVOL gpt.ini; error 0x3.
3. 07:40:10 - Event 1030 - Cannot query list of Group Policy objects; error 0x546.
4. 07:40:12 - Event 1129 - Group Policy failed due to no DC connectivity.
5. 07:41:05 - Event 1014 - DNS resolution timeout; configured DNS servers did not respond.
6. 07:42:18 - Event 50036 - Affected host DHCP-assigned DNS 10.10.3.250 (old/decommissioned).
7. 07:40:05 (FB029) - Event 50036 - Unaffected host DNS 10.10.0.10 (correct new DNS).
8. 07:40:11 (FB029) - Event 1500 - Group Policy processed successfully.

Interpretation:
- The fault is not a domain-wide outage. It is subnet/scope-specific DNS misconfiguration via DHCP, producing DC lookup failures and downstream GroupPolicy errors.

---

## Incident Timeline
| Time | Event | Evidence | Meaning |
|---|---|---|---|
| 02:00 | Migration wave decommissions old DNS | Change note | New DNS should be active for clients |
| 07:40:02 | NLA enters running state | Event 7036 | Network stack starts |
| 07:40:08 | Netlogon secure channel setup fails | Event 5719 | DC cannot be located |
| 07:40:09 | GPO file access fails | Event 1058 | SYSVOL path unresolved/unreachable |
| 07:40:10 | GPO enumeration fails | Event 1030 | Policy list retrieval failed |
| 07:40:12 | GPO no-DC connectivity error | Event 1129 | Policy pipeline blocked |
| 07:41:05 | DNS query timeout | Event 1014 | Name resolution path broken |
| 07:42:18 | DHCP lease confirms old DNS | Event 50036 | Direct misconfiguration evidence |
| 07:44:01 | GPO failure repeats | Event 1129 | Condition persists |
| 07:40:05 (FB029) | DHCP shows new DNS | Event 50036 | Correct config on unaffected host |
| 07:40:11 (FB029) | GPO processed successfully | Event 1500 | Confirms differential by DNS config |
| Post-fix | DHCP scope corrected and leases renewed | Remediation action | Connectivity and GPO restored |

---

## Root Cause Statement

The Floor 3 DHCP scope still referenced a decommissioned DNS server, causing affected Windows 11 clients to fail domain controller name resolution and preventing Group Policy retrieval from SYSVOL during startup.

---

## 5 Whys Analysis
Why 1: Why did Group Policy fail on 3 Floor 3 machines?
- Because clients could not reach a domain controller during policy processing.
- Evidence: Event 1129 at 07:40:12 and 07:44:01; Event 5719 at 07:40:08.

Why 2: Why could clients not reach the domain controller?
- Because DNS resolution for FINBRIDGE-DC01 timed out.
- Evidence: Event 1014 at 07:41:05; Event 5719 message indicates DNS query no response.

Why 3: Why did DNS resolution time out?
- Because affected clients were assigned an old decommissioned DNS server.
- Evidence: Event 50036 at 07:42:18 showing DNS 10.10.3.250.

Why 4: Why were clients assigned the old DNS server?
- Because Floor 3 DHCP scope options were not updated during the migration wave.
- Evidence: DHCP comparison and migration note showing old resolver retired at 02:00.

Why 5: Why was DHCP scope update missed?
- Because migration execution controls did not enforce subnet-level DHCP option verification before cutover completion.
- Evidence: Mixed state observed (3 hosts affected, 1 manually corrected host unaffected).

Systemic cause:
- Incomplete migration control for DHCP/DNS dependencies allowed stale scope configuration to remain active on a production subnet.

---

## Resolution Actions Performed
1. Identified DNS dependency failure pattern from Netlogon, GroupPolicy, and DNS events.
2. Compared affected and unaffected hosts in same OU/subnet context.
3. Confirmed incorrect DHCP-assigned DNS server on affected clients.
4. Updated Floor 3 DHCP scope DNS option to 10.10.0.10.
5. Renewed client DHCP leases and validated DNS settings.
6. Re-ran policy processing and confirmed successful Group Policy application.

---

## Preventive Actions
### Immediate (0-7 days)
1. Add mandatory DHCP scope validation checklist to every DNS migration wave.
- Owner: Network Operations
- Success metric: 100% of changed subnets signed off with post-change DHCP option evidence.

2. Run post-cutover endpoint sampling per subnet.
- Owner: EUC Support
- Success metric: Minimum 3 endpoint `ipconfig /all` samples per subnet show expected DNS.

### Near Term (7-30 days)
1. Automate DHCP option drift detection against approved DNS baseline.
- Owner: Infrastructure Automation Team
- Success metric: Drift alerts generated within 15 minutes of mismatch.

2. Add GPO startup failure alert correlation.
- Owner: Monitoring/SOC Engineering
- Success metric: Alert when Events 5719 + 1058 + 1129 co-occur on same subnet cohort.

### Long Term (30-90 days)
1. Introduce migration exit criteria requiring cross-team signoff (DNS, DHCP, EUC, AD).
- Owner: Change Management
- Success metric: No unresolved DHCP/DNS dependency defects at closure.

2. Standardize pre-cutover and post-cutover runbook with rollback checkpoints.
- Owner: Platform Engineering
- Success metric: 100% wave adherence audited quarterly.

---

## Closure and Verification
- Affected endpoints received corrected DNS configuration via DHCP after scope update.
- Domain controller name resolution and SYSVOL access were restored.
- Group Policy processing succeeded on previously affected devices.
- User/device owners confirmed normal startup policy behavior.

---

## Lessons Learned

| Lesson | Impact | Action |
|---|---|---|
| DNS migrations fail at endpoint level when DHCP scopes are not updated in lockstep | High | Add mandatory DHCP scope verification checkpoint to migration runbook |
| Same-OU affected vs unaffected comparison can isolate network configuration faults quickly | High | Require peer-host differential checks in first 15 minutes of triage |
| GroupPolicy errors 1058/1030/1129 with Netlogon 5719 usually indicate upstream DNS/DC reachability issue | High | Add event-pattern detection and automated alert correlation |
| Manual pre-configuration can mask systemic scope defects | Medium | Validate at subnet level, not only with pre-configured pilot endpoints |
