# Ticket T-1001 - BitLocker Recovery Prompting Every Boot

## Summary (one line)
New Windows 11 laptop prompts for BitLocker recovery key at every startup, suggesting a recurring startup trust or protector validation problem (to-verify).

## Impact (who/how many/business urgency)
- Who: One user on a newly issued Windows 11 laptop (to-verify).
- How many: One confirmed endpoint so far; possible wider impact if tied to provisioning baseline (to-verify).
- Business urgency: High for the affected user due to repeated access interruption at boot; potentially higher if this affects more new devices (to-verify).

## Known Facts
- Ticket reference: T-1001.
- Device context: New Windows 11 laptop.
- Reported symptom: Recovery key prompt appears every boot.
- No additional confirmed change history supplied yet (to-verify).

## Missing Information to Gather
- Whether the key is accepted and the user can reach desktop each time.
- When it started relative to first sign-in or updates.
- Whether firmware or startup security settings changed before issue started.
- Whether this occurs on restart and cold boot equally.
- Whether docking or external peripherals are connected at boot.
- Whether any other newly deployed laptops show the same pattern (to-verify).
- Confirmation that recovery key is present in approved escrow location.

## Likely Catagory
Endpoint Encryption / BitLocker Recovery Loop (to-verify).

## First Diagnostic Step
Using approved support tooling and process, verify current BitLocker protector and trusted startup state, then check for baseline drift after provisioning that would trigger repeated recovery (to-verify).