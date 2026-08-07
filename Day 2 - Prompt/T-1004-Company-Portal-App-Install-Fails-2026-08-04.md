# Ticket T-1004 - Company Portal App Install Failure

## Summary (one line)
Company app installation from Company Portal fails with error 0x87D1041C, indicating an application assignment, requirement, or installation state issue (to-verify).

## Impact (who/how many/business urgency)
- Who: User(s) requiring the company app to perform role tasks (to-verify).
- How many: At least one device reported; possible wider impact if assignment or package issue is tenant-wide (to-verify).
- Business urgency: Medium to high depending on app criticality to daily operations (to-verify).

## Known Facts
- Ticket reference: T-1004.
- Reported platform: Company Portal.
- Symptom: Company app fails to install.
- Reported code: 0x87D1041C.

## Missing Information to Gather
- App name and version being installed.
- Whether failure is on one device or multiple devices.
- Device compliance and enrollment status at failure time (to-verify).
- Whether user/device meets assignment targeting and app requirements (to-verify).
- Whether any pending restart or competing install is present (to-verify).
- Whether same app installs successfully on a comparable test device.

## Likely Catagory
Intune / Company Portal / Application Deployment Failure (to-verify).

## First Diagnostic Step
Review the app deployment status for the affected user/device in approved endpoint management console to confirm assignment, requirement checks, and installation result details before local remediation (to-verify).