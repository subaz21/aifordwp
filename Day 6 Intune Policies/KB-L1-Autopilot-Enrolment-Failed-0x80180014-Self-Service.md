# Help Guide: Autopilot Setup Fails with Enrolment Error

Version: v 1.0  
Date: 11/08/2026  
Status: Draft

If your device setup fails during company enrolment, do not worry. This is usually caused by an old management connection on the device and can be fixed by IT.

## What you can do now

1. Keep the device powered on and connected to the internet.
2. Take a photo of the error screen if visible.
3. Note the time of failure.
4. If instructed by IT, restart the device once.
5. Do not attempt repeated factory resets unless support asks you to.

## What not to do

- Do not try many enrolment retries quickly.
- Do not remove work/school connections unless guided by IT.
- Do not switch networks repeatedly during setup.

## What L1 should check quickly

1. Confirm the user and device are in scope for Autopilot wave.
2. Confirm the user has Intune and Autopilot licensing assigned.
3. Confirm required network access is available.
4. Capture the exact error code shown on the device.

## Escalate to L2/L3 immediately when

- Error code is `0x80180014`.
- Device shows it is already enrolled in MDM.
- Setup repeatedly fails after a guided restart.

## Details to include in the ticket

- User: domain and username
- Device name and serial number
- Error code and message (exact text)
- Time of failure
- Screenshot/photo of error
- Current network location (office/home)
- Whether device was previously manually enrolled

## User-facing message template

"Your setup failed because this device appears to have an older management connection still attached. We will remove the old record and rerun setup. Please keep the device available for a guided fix."
