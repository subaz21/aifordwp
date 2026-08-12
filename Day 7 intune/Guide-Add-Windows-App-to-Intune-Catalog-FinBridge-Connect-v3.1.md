# Step-by-Step Guide: Add a Windows App to the Intune App Catalog

## Document Control

1. Audience: DWP Engineers (L1/L2/L3)
2. Purpose: Add a Windows app in Intune before phased rollout starts
3. Worked example: FinBridge Connect v3.1
4. Package type: Windows LOB app packaged as `.intunewin`

---

## 1. Prerequisites

1. Confirm you have Intune admin permissions to create and assign apps.
2. Confirm the package file is ready:
   - `FinBridgeConnect_v3.1.intunewin`
3. Confirm command lines are approved:
   - Install: `FinBridgeConnect_Setup.exe /silent`
   - Uninstall: `FinBridgeConnect_Setup.exe /uninstall /silent`
4. Confirm detection requirement:
   - Registry key `HKLM\SOFTWARE\FinBridge\Connect`
   - Value name `Version`
   - Expected value `3.1`
5. Confirm pilot group exists before assignment:
   - Example group: `FB-APP-FBCONNECT31-R0-PILOT`

---

## 2. Where to Add an App in Intune

1. Sign in to Intune admin center.
2. Navigate to the Windows app catalog area.
   - Path shown in many current tenants (including your screenshot): `Apps > Windows > Windows apps`.
3. Select `Create`.
4. In the right-side pane, use `Select app type`.
3. Tenant label warning:
   - UI labels and menu grouping can differ by tenant version.
   - Verify live in your tenant and do not rely only on screenshots from another tenant.
   - In some tenants, app creation still starts from a generic `All apps` entry, but the app type choices are equivalent.

### 2.1 Choose the correct app type

1. For FinBridge Connect v3.1 packaged as `.intunewin`:
   - Select `Windows app (Win32)`.
2. Do not select `Line-of-business app` for `.intunewin`.
   - `Line-of-business app` is for other package formats (for example MSI/appx-style LOB scenarios), not Win32 `.intunewin` packaging.
2. For Microsoft Store apps:
   - Select Microsoft Store app type (new store experience in most tenants).
3. For web links:
   - Select `Web link` or `Windows web link` according to your tenant label.
4. Important:
   - For this worked example, the only correct type is `Windows app (Win32)`.

---

## 3. Create the FinBridge Connect v3.1 App Entry

## 3.1 Upload package

1. In the app creation wizard, select the Win32 app option.
2. Upload `FinBridgeConnect_v3.1.intunewin`.
3. Wait for package metadata extraction to complete.
4. Tenant label warning:
   - Step names can appear as `App package file`, `Program`, `Requirements`, `Detection rules`, `Assignments`, `Review + create` or similar.

## 3.2 App information (required)

1. Name: `FinBridge Connect v3.1`
2. Description: `FinBridge Connect desktop client version 3.1`
3. Publisher: `FinBridge`
4. App version: `3.1`
5. Optional but recommended:
   - Category
   - Information URL
   - Privacy URL
   - Icon

## 3.3 Program settings (required)

1. Install command:
   - `FinBridgeConnect_Setup.exe /silent`
2. Uninstall command:
   - `FinBridgeConnect_Setup.exe /uninstall /silent`
3. Install behavior:
   - Set to `System` for device-wide install unless there is a specific user-context requirement.
4. Device restart behavior:
   - Use your change standard (for example, determine behavior based on return codes).
5. Tenant label warning:
   - Install context may appear as `Install behavior`, `Device context`, or `User/System` selector depending on UI version.

## 3.4 Requirements (required)

1. Operating system architecture:
   - Select supported architecture(s) (for example, 64-bit if app supports x64 only).
2. Minimum operating system:
   - Set Windows minimum supported version for your estate baseline.
3. Optional requirement rules:
   - Add hardware/resource conditions if needed.
4. Tenant label warning:
   - Architecture and minimum OS fields can appear with different wording across tenants.

## 3.5 Detection rules (required)

Use registry detection for this app.

1. Detection rule type: `Registry`
2. Key path:
   - `HKEY_LOCAL_MACHINE\SOFTWARE\FinBridge\Connect`
3. Value name:
   - `Version`
4. Detection method:
   - `String comparison` equals
5. Expected value:
   - `3.1`
6. Validate rule behavior in pilot:
   - Device with v3.0 should not be detected as v3.1.
   - Device with v3.1 should detect as installed.

## 3.6 Return codes (required for robust behavior)

1. Review default return code mapping.
2. Ensure success codes are mapped correctly.
   - Typical success: `0`
   - Common success with restart required: `3010` (if app uses it)
3. Ensure failure codes are mapped as failure.
4. Tenant label warning:
   - Return code categories may appear as `Success`, `Soft reboot`, `Hard reboot`, `Retry`, `Failed`.
5. If vendor documentation provides custom exit codes, add them explicitly.

---

## 4. Assignment Basics

## 4.1 Assignment types

1. Required:
   - Intune enforces installation automatically for targeted devices/users.
2. Available:
   - App is published for self-service install (Company Portal), not forced.
3. Uninstall:
   - Intune removes app from targeted devices/users.

## 4.2 Why pilot first (not all 10,000 devices)

1. Prevents large-scale failure blast radius from packaging or detection mistakes.
2. Validates install command, uninstall command, detection logic, and return-code handling in production-like conditions.
3. Lets support teams validate user impact, performance, and incident volume before broad deployment.
4. For this app, always assign first to a small test group before broader rings.

## 4.3 Assign FinBridge Connect v3.1 to pilot

1. In Assignments, add pilot group (example: `FB-APP-FBCONNECT31-R0-PILOT`).
2. Assignment type for pilot:
   - Use `Required` for controlled test of enforced deployment.
3. Save and create app.

---

## 5. Verification Steps

## 5.1 Confirm app appears in catalog

1. Go to `Apps > Windows > Windows apps`.
2. Search for `FinBridge Connect v3.1`.
3. Open app record and verify:
   - Commands are correct
   - Detection rule is correct
   - Assignment includes pilot group

## 5.2 Check install status on test device

1. In the app record, open device install status view.
2. Locate the assigned test device.
3. Review state and error details if not successful.
4. On device, trigger sync and recheck if status is stale.

## 5.3 Interpret status values

1. Installed:
   - Intune reports app is installed and detection rule matched expected state.
2. Failed:
   - Installation attempted but command, detection, requirement, or return code evaluation failed.
3. Not applicable:
   - Device does not meet assignment applicability (for example OS version/architecture/filters/requirements mismatch).

---

## 6. Minimum Go/No-Go Checks Before Phased Rollout

1. Pilot install success rate meets your threshold (example >= 98%).
2. No critical incidents tied to install or app launch.
3. Detection rule correctly distinguishes v3.1 from prior versions.
4. Uninstall command tested successfully on at least one pilot device.
5. Return-code mapping verified against observed installer behavior.

---

## 7. Common Pitfalls and Fast Fixes

1. Wrong app type selected:
   - Fix: recreate as `Windows app (Win32)` for `.intunewin`; do not use `Line-of-business app` for this package type.
2. Detection false positive:
   - Fix: tighten registry rule to exact `Version = 3.1`.
3. Install fails silently:
   - Fix: validate install command syntax and installer working directory assumptions.
4. Devices show Not applicable unexpectedly:
   - Fix: review architecture/minimum OS/filters/requirements.
5. Rollout started too broad:
   - Fix: pause broad assignment and return to pilot-only until metrics stabilize.

---

## 8. Completion Checklist

1. App exists in catalog with correct metadata.
2. Program commands configured and validated.
3. Requirements aligned to fleet baseline.
4. Detection rule validated on real devices.
5. Return code mapping verified.
6. Pilot assignment active.
7. Pilot status reviewed and approved for phased rollout progression.
