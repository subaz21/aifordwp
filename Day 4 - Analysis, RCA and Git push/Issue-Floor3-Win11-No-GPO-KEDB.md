Symptom     : Three Windows 11 machines on Floor 3 (OU=Finance) failed Group Policy processing at startup while one peer machine in same OU processed successfully.

Cause       : Floor 3 DHCP scope assigned a decommissioned DNS server, causing domain controller name resolution failure and preventing SYSVOL/GPO retrieval.

Scope       : 3 of 4 Floor 3 Finance machines affected during startup window on 2024-03-15 (approximately 07:40-07:55). Unaffected comparison machine was manually configured with correct DNS.

Workaround  : Manually set affected clients to correct DNS server (10.10.0.10), renew network configuration, and run `gpupdate /force` to restore policy processing.

Permanent fix: Update Floor 3 DHCP scope DNS option to 10.10.0.10, renew leases on impacted endpoints, and enforce migration-time DHCP scope validation and DNS drift monitoring.

How to spot it: Look for Event 5719 (no domain controller), Event 1058/1030 (GPO retrieval/query failure), Event 1129 (no DC connectivity), and Event 1014 (DNS timeout), then confirm Event 50036 shows wrong DHCP DNS assignment. In this incident: 5719 at 07:40:08, 1058 at 07:40:09 and 07:40:11, 1030 at 07:40:10, 1129 at 07:40:12 and 07:44:01, 1014 at 07:41:05, and DHCP Event 50036 at 07:42:18 assigning old DNS 10.10.3.250.
