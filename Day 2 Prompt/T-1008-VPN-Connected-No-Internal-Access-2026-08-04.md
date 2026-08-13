# Ticket T-1008 - VPN Connected but No Internal Resource Access

## Summary (one line)
After Windows 11 upgrade, VPN reports connected but internal resources are unreachable, suggesting a post-upgrade network path, routing, DNS, or policy enforcement issue (to-verify).

## Impact (who/how many/business urgency)
- Who: User requiring internal systems over remote access (to-verify).
- How many: One confirmed user; potential wider impact among similarly upgraded remote users (to-verify).
- Business urgency: High if user cannot access core internal applications or services remotely.

## Known Facts
- Ticket reference: T-1008.
- Context: Issue appears after Windows 11 upgrade.
- Symptom: VPN connects.
- Symptom: Internal resources are not reachable.
- No confirmed endpoint/network error code provided.

## Missing Information to Gather
- Which internal resources fail (web, file share, remote desktop, line-of-business app).
- Whether name-based access fails, direct address access fails, or both (to-verify).
- Whether issue occurs on multiple networks (home, hotspot, office guest).
- Whether other upgraded users on same VPN profile are impacted (to-verify).
- Whether local internet access remains normal while VPN is connected.
- Whether endpoint has received latest approved VPN client configuration (to-verify).

## Likely Catagory
Remote Access / VPN Connectivity / Post-Upgrade Internal Reachability (to-verify).

## First Diagnostic Step
Verify VPN session posture and route assignment in approved remote-access monitoring tools, then confirm whether traffic to internal destinations is correctly directed after upgrade (to-verify).