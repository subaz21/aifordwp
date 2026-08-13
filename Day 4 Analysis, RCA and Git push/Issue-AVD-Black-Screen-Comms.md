# POOL-FIN-01 Black Screen Incident: Audience Communications

## Audience 1 - Non-technical executive
Your access is restored and your data is safe. On 2024-03-15, a 2:00 AM desktop image update in one finance desktop group caused sign-in black screens from about 7:00 to 10:00 for around 40% of users; a second finance desktop group was unaffected. We reverted that display update to the last stable version, redeployed, and confirmed no repeat errors. No action is required.

## Audience 2 - Affected end-user team (10 people, non-technical)
Your access is back and your data is safe. On 2024-03-15, an overnight 2:00 AM update in one finance desktop group caused some desktops to show a black screen at sign-in between about 7:00 and 10:00, affecting about 40% of users, while the second finance desktop group was unaffected. We rolled that display update back to the last stable version, redeployed, and confirmed the issue is not recurring. If you see it again, disconnect and reconnect once, then contact the Service Desk.

## Audience 3 - Engineer-to-engineer internal note
Incident: INC-20240315-001, POOL-FIN-01 post-logon black screen/disconnect, 2024-03-15 07:00-10:00.

Root cause:
- POOL-FIN-01 received image update at 02:00 containing Intel GPU driver module igdumd64.dll v31.0.101.4146.
- On user logon, dwm.exe crashed in igdumd64.dll with exception 0xc0000005 (Access Violation), then DWM exited (0x40010004), causing black screen/disconnect cycles.
- Differential check held: POOL-FIN-02 unchanged (build-20240313 baseline), no matching crash signature.

Exact action taken:
- Extracted known-good GPU driver baseline from POOL-FIN-02 pre-update image.
- Replaced igdumd64.dll v31.0.101.4146 and aligned related INF/driver entries in POOL-FIN-01 image.
- Built corrected image tag: POOL-FIN-01-corrected-igdumd64-rollback-20240315.
- Canary deployed to SHFIN-01-C and SHFIN-01-D, then full redeploy across remaining POOL-FIN-01 hosts.

Config details:
- Affected module/version: igdumd64.dll 31.0.101.4146.
- Unaffected baseline: image build 10.0.22621.2861-build-20240313 in POOL-FIN-02.
- Fault pattern: Event 1000 (dwm.exe -> igdumd64.dll, 0xc0000005) followed by Event 9009 (DWM exit 0x40010004).
- Healthy pattern post-fix: Event 9011 (DWM started successfully).

Verification:
- Canary validation: zero Event 1000 igdumd64.dll and zero Event 9009 during monitored logons; Event 9011 present.
- Post-full rollout by 10:00: no black screen recurrence reported; log review showed zero residual driver-fault signature.

Preventive action required:
- Enforce mandatory image validation gate before production rollout for any driver change: representative canary hosts, monitored user logons, and explicit event-log pass criteria (no DWM/GPU fault signature) prior to full deployment.