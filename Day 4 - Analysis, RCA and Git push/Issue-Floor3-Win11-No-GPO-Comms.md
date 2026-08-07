# Floor 3 Win11 Group Policy Failure: Audience Communications

## Audience 1 - Non-technical executive
Service is restored and data remained safe. On 2024-03-15, three Windows 11 devices on Floor 3 in the finance group did not receive startup policy due to an incorrect network name-server setting distributed by DHCP after migration changes. We corrected the DHCP configuration, refreshed affected devices, and confirmed policy processing returned to normal. No wider outage was identified.

## Audience 2 - Affected end-user team (non-technical)
Your devices are now working normally and data is safe. During startup on 2024-03-15, some Floor 3 finance machines could not reach the company policy service because they received an outdated network name-server setting. We fixed the network setting at source, refreshed affected machines, and confirmed policy now applies correctly. If you see this again, restart once and contact Service Desk.

## Audience 3 - Engineer-to-engineer internal note
Incident: INC-FB-FLOOR3-GPO-20240315-01, Floor 3 Win11 no Group Policy processing, 2024-03-15 startup window.

Root cause:
- Floor 3 DHCP scope still referenced decommissioned DNS resolver after migration cutover.
- Affected clients failed DNS lookup for FINBRIDGE-DC01, causing Netlogon and GPO chain failures.
- Same OU comparison host with correct DNS (10.10.0.10) processed GPO successfully.

Exact action taken:
- Correlated Events 5719, 1058, 1030, 1129, and 1014 on affected hosts.
- Validated DHCP-assigned DNS mismatch via Event 50036 and host configuration.
- Updated DHCP scope DNS option to 10.10.0.10.
- Renewed DHCP leases on affected hosts and forced policy refresh.

Config and event details:
- Affected DNS assignment: 10.10.3.250 (decommissioned).
- Correct DNS assignment: 10.10.0.10.
- Failure pattern: 5719 (DC unavailable), 1058/1030 (policy retrieval failure), 1129 (no DC connectivity), 1014 (DNS timeout).
- Healthy comparison pattern: 1500 Group Policy success on FB029.

Verification:
- Post-fix hosts received correct DNS server from DHCP.
- DC resolution and SYSVOL path access restored.
- Group Policy processing completed successfully on previously affected devices.

Preventive action required:
- Add mandatory DHCP option validation during DNS migration waves.
- Add subnet sampling and automated drift alerting for DNS option mismatches.
- Add monitoring correlation for 5719 + 1058 + 1129 burst patterns.
