# Ticket T-1005 - Teams Audio Not Working in Meeting Room

## Summary (one line)
Teams audio is not working on three machines in the same meeting room, suggesting a shared room audio path, device configuration, or local environment issue (to-verify).

## Impact (who/how many/business urgency)
- Who: Meeting participants using that room and room-based endpoints.
- How many: Three confirmed machines in one meeting room.
- Business urgency: High during meetings due to immediate communication disruption and potential service/decision delays.

## Known Facts
- Ticket reference: T-1005.
- Symptom: Teams audio non-functional.
- Scope: Three machines in the same meeting room.
- No confirmed client error message provided.

## Missing Information to Gather
- Whether issue affects microphone, speaker output, or both.
- Whether failure is specific to Teams or also affects system audio.
- Whether the same user account works in a different room/device.
- Current selected audio devices within Teams and operating system (to-verify).
- Recent room hardware, docking, or peripheral changes (to-verify).
- Whether problem occurs in all meetings or only a specific meeting/session.

## Likely Catagory
Microsoft Teams / Audio Peripherals / Meeting Room Endpoint (to-verify).

## First Diagnostic Step
On one affected room machine, validate active input/output device selection in operating system and Teams, then perform a controlled test call to determine whether the failure is app-level, profile-level, or shared room hardware path (to-verify).