# Windows 11 – Intune Compliance Policy: Security Baseline Translation

**Author:** DWP Engineer  
**Date:** 2026-08-11  
**Scope:** Windows 11 managed devices enrolled in Microsoft Intune  
**Grace Period (all settings):** 7 days – devices flagged as non-compliant will have 7 days to remediate before access is blocked via Conditional Access.

**Microsoft Learn validation:** Reviewed against current Microsoft Learn Windows compliance settings guidance and noncompliance actions guidance, last updated in July 2026 and June 2026 respectively.

---

## Portal Navigation Note

This guide has been aligned to the newer Intune device navigation shown in the current admin center:

**Devices > Compliance > Policies**

When creating a new Windows compliance policy, the current wizard shown in the portal uses:

- **Platform:** Windows 10 and later
- **Profile type:** Windows 10/11 compliance policy

If your tenant still shows **Compliance policies**, use the equivalent location under that legacy label.

---

## How to Apply the Grace Period

In Intune: use the **Actions for noncompliance** wizard step during policy creation, or go to **Devices > Compliance > Policies > [Policy] > Properties > Actions for noncompliance** for an existing policy.  
Set **"Mark device noncompliant"** action to **7 days**.

Microsoft documents that **Mark device noncompliant** is included by default in every compliance policy with a schedule of **0 days**. Changing it to **7 days** creates the grace period. The current admin center accepts whole numbers and decimal values in **0.25-day increments** for supported schedules.

## How to Create the Policy

In Intune: **Devices > Compliance > Policies > Create policy**

Set the following values in the creation pane:

- **Platform:** Windows 10 and later
- **Profile type:** Windows 10/11 compliance policy

After selecting those values, the current wizard flow is:

1. **Basics**
2. **Compliance settings**
3. **Actions for noncompliance**
4. **Assignments**
5. **Review + create**

On the **Basics** page, complete:

- **Name:** Use a clear policy name such as `Win11 Compliance Baseline`
- **Description:** Optional, but recommended. Example: `Windows 11 baseline compliance policy covering BitLocker, Secure Boot, OS version, Defender, Firewall, password, and device integrity.`
- **Platform:** Windows 10 and later
- **Profile type:** Windows 10/11 compliance policy

Select **Next** to move to **Compliance settings**, where the requirement mappings below are configured.

## Where to Configure the Requirements

All seven requirements below are configured in the same place in the current wizard:

**Devices > Compliance > Policies > Create policy > Basics > Compliance settings**

The only difference between them is the settings category and individual control selected on that page.

---

## Detailed Step-by-Step Process

This section reflects the current Windows compliance policy flow and setting labels documented in Microsoft Learn and shown in the current Intune admin center.

### Step 1 – Create the Windows compliance policy shell

1. Sign in to the Microsoft Intune admin center.
2. Go to **Devices > Compliance > Policies**.
3. Select **Create policy**.
4. Set **Platform** to **Windows 10 and later**.
5. Set **Profile type** to **Windows 10/11 compliance policy**.
6. Select **Create**.

### Step 2 – Complete the Basics page

1. In **Name**, enter a clear name such as `Win11 Compliance Baseline`.
2. In **Description**, enter a supportable description such as `Windows 11 compliance baseline for BitLocker, Secure Boot, OS version, Defender, Firewall, password, and device integrity.`
3. Confirm **Platform** shows **Windows 10 and later**.
4. Confirm **Profile type** shows **Windows 10/11 compliance policy**.
5. Select **Next**.

### Step 3 – Configure Requirement 1: BitLocker on OS drive

1. On **Compliance settings**, expand **Device Health**.
2. Set **Require BitLocker** to **Require**.
3. Leave unrelated Device Health settings at their intended values unless your security standard requires more controls.
4. Record an admin note that Microsoft evaluates this setting through Device Health Attestation and that devices can require a **reboot** before they report compliant.

### Step 4 – Configure Requirement 2: Secure Boot enabled

1. Stay in **Device Health**.
2. Set **Require Secure Boot to be enabled on the device** to **Require**.
3. Confirm your device scope does not include unsupported legacy hardware unless you have approved exceptions.
4. Record that devices without the required attestation support, especially devices lacking **TPM 2.0 or later**, can report **Not compliant**.

### Step 5 – Configure Requirement 3: Minimum OS build

1. Expand **Device Properties**.
2. In **Minimum OS version**, enter `10.0.22621.2861`.
3. Verify the value uses Microsoft’s required **major.minor.build.revision** format.
4. If your environment supports multiple approved Windows release branches, evaluate **Valid operating system builds** instead of relying on a single minimum version.
5. Record that devices might remain noncompliant until they reboot after patch installation.

### Step 6 – Configure Requirement 4: Defender real-time protection

1. Expand **System Security**.
2. Expand **Defender**.
3. Set **Real-time protection** to **Require**.
4. If your environment uses Microsoft Defender Antivirus as the primary AV, review whether you also want **Microsoft Defender Antimalware** and **Microsoft Defender Antimalware security intelligence up-to-date** enabled as adjacent controls.
5. If your environment uses a third-party AV product, verify whether this compliance signal is still appropriate or whether **machine risk score** is the stronger control.

### Step 7 – Configure Requirement 5: Firewall enabled

1. Stay in **System Security**.
2. Expand **Device security**.
3. Set **Firewall** to **Require**.
4. Check for existing Group Policy or other management tooling that disables Windows Firewall or allows all inbound traffic, because Microsoft documents that those conflicts can force a **Not compliant** result.
5. Record that a device can briefly show **Error** if it syncs immediately after reboot or wake.

### Step 8 – Configure Requirement 6: Password or PIN required

1. Stay in **System Security**.
2. Expand **Password**.
3. Set **Require a password to unlock mobile devices** to **Require**.
4. Set **Minimum password length** to `8`.
5. Set **Password type** to the value your standard requires:
	- **Device default** for mixed password or PIN acceptance.
	- **Numeric** if Windows Hello PIN is your standard.
	- **Alphanumeric** if a stronger character-based credential is required.
6. If you set **Password type** to **Alphanumeric**, set **Password complexity** to the level your security baseline requires.
7. Review whether kiosk, shared, or userless devices need to be excluded from this policy.

### Step 9 – Configure Requirement 7: Device integrity and risk

1. In **Device Health**, set **Require code integrity** to **Require**.
2. Expand **Microsoft Defender for Endpoint**.
3. If the section is available, set **Require the device to be at or under the machine risk score** to **Clear** for the strictest baseline, or **Low** if your risk model allows low-level findings.
4. If the **Microsoft Defender for Endpoint** section is missing, stop and confirm the Defender for Endpoint integration is enabled before claiming this requirement is implemented.
5. Record that test-signed drivers, unreachable Device Health Attestation endpoints, or missing TPM support can affect compliance outcomes.

### Step 10 – Configure Actions for noncompliance

1. Select **Next** to move to **Actions for noncompliance**.
2. Open the built-in **Mark device noncompliant** action.
3. Change **Schedule (days after noncompliance)** from the Microsoft default of **0** to **7**.
4. If you want reminder notifications, add **Send email to end user**.
5. In **Message template**, select an existing notification template. If the picker shows no results, create a template first using the process below.
6. If needed, add **Additional recipients** by selecting Microsoft Entra groups.
7. Note that Microsoft documents the schedule field as accepting whole numbers and **0.25-day increments**.
8. Select **Next**.

### Step 10A – Create a notification message template

Use this process if the **Notification message templates** pane is empty, which is what your screenshot shows.

1. Open a new browser tab in the Intune admin center.
2. Go to **Endpoint security > Device compliance > Notifications**.
3. Select **Create notification**.
4. On **Basics**, enter a friendly template name such as `Windows Compliance Warning - 7 Day Grace Period`.
5. Select **Next**.
6. On **Header and footer settings**, configure the branding you want Microsoft to include in the email:
	- show company logo if required
	- show company name
	- show contact information
	- optionally show the Company Portal website link
7. Select **Next**.
8. On **Notification message templates**, create at least one message.
9. Set **Locale** for the intended audience.
10. Enter a **Subject**.
11. Enter the **Message** body.
12. If you want personalized content, add supported Intune variables such as `{{UserName}}`, `{{DeviceName}}`, `{{DeviceId}}`, and `{{OSAndVersion}}`.
13. If you enable **Raw HTML editor**, use only Intune-supported HTML tags and HTTPS links.
14. Mark one message as **Is Default** so users without a matching locale still receive a notification.
15. If Intune shows the error **Select a default template**, open the message row menu or edit pane and explicitly set **Is Default** for one locale entry. A saved message by itself is not enough.
16. Confirm the **Is Default** column shows the default selection before moving on.
17. Select **Next**.
18. On **Scope tags**, apply any required RBAC scope tags.
19. Select **Next**.
20. On **Review + create**, confirm the settings and select **Create**.

### Step 10B – Assign the template to the compliance policy

1. Return to the **Actions for noncompliance** step in your Windows compliance policy.
2. In the **Send email to end user** row, select the **Message template** field.
3. Choose the template you just created.
4. Select **Select** to apply it.
5. Confirm the template name now appears in the policy row instead of **None selected**.
6. Continue with the rest of the policy wizard.

### Step 10C – Troubleshoot the 'Select a default template' error

1. Stay on **Notification message templates**.
2. Locate the message entry you created for the locale, for example **English (United States)**.
3. Open the row action menu or edit the entry.
4. Enable **Is Default** for that message.
5. Save the message.
6. Confirm the **Is Default** column reflects the default selection.
7. Select **Review + create** again.

Use this fix because Intune requires one default locale template before it allows the notification template to be created. Without a default entry, the wizard blocks submission even if a subject and message already exist.

### Step 11 – Assign the policy

1. On **Assignments**, add the Microsoft Entra device or user groups that should receive this compliance policy.
2. Exclude known exception groups such as kiosk devices, approved developer exception devices, or legacy hardware groups if those exceptions are part of the design.
3. Confirm the assignment scope matches the devices that are actually Windows 11 managed endpoints.
4. Select **Next**.

### Step 12 – Review and create

1. On **Review + create**, verify each requirement is present with the expected value.
2. Verify **Mark device noncompliant** shows **7 days**.
3. Select **Create**.

### Step 13 – Post-deployment validation

1. Deploy first to a pilot group of 5 to 10 devices.
2. Force a sync on at least one pilot device and confirm the device checks in successfully.
3. Reboot at least one BitLocker-targeted pilot device so Device Health Attestation settings can re-evaluate.
4. Review **Devices > Compliance** for compliant, noncompliant, and error states.
5. Investigate any firewall-related transient **Error** states after reboot or wake before broad rollout.
6. Confirm the Microsoft Defender for Endpoint risk score is returning expected results if Requirement 7 is enabled.
7. Only after pilot validation, bind Conditional Access to require compliant devices.

### Step 14 – Validate one synced test device against this specific policy

Use this when the policy is already assigned to all devices and a test device has just synced.

1. Go to **Devices > Compliance > Policies**.
2. Select your Windows policy, for example **Win11 Compliance Baseline**.
3. Open **Device status** to see all targeted devices and each device state for this policy.
4. Search for the test device name and open it to view setting-level results.
5. Alternate path for the same validation: **Devices > All devices > [Test Device] > Device compliance > Policies > [Policy Name]**.

Compliance state meaning and Conditional Access impact:

1. **Compliant**: Device meets policy checks. If Conditional Access requires a compliant device, access is allowed.
2. **Not compliant**: Device failed one or more checks and is marked noncompliant. If Conditional Access requires a compliant device, access is blocked.
3. **In grace period**: Device has a detected issue, but the configured **Mark device noncompliant** delay has not expired yet. Access is typically still allowed until the grace timer ends, then the state becomes **Not compliant** if unresolved.

BitLocker false-positive triage for devices that appear noncompliant even though BitLocker is enabled:

1. **Most common cause: reboot pending for Device Health Attestation refresh**.
	Fastest check: confirm last reboot time and perform one reboot plus a manual sync, then recheck policy state.
2. **Common cause: encryption not fully complete on the OS volume**.
	Fastest check: run `manage-bde -status C:` and verify conversion is 100% and protection status is on.
3. **Common cause: stale compliance telemetry or unreachable attestation path**.
	Fastest check: confirm recent check-in in Intune, trigger a manual sync, and verify connectivity to `has.spserv.microsoft.com` over 443 from the device network path.

24-hour validation checks after assigning policy to broad scope:

1. In policy **Device status**, trend counts for **Compliant**, **Not compliant**, and **In grace period** every few hours.
2. In setting-level results for failed devices, confirm whether failures are concentrated on BitLocker only.
3. Measure how many BitLocker failures self-resolve after one reboot and sync cycle.
4. Monitor Conditional Access sign-in impact for unexpected access blocks linked to device compliance.
5. If BitLocker false positives remain elevated, hold CA enforcement expansion until reboot coverage and attestation connectivity are confirmed.

---

## Requirement 1 – BitLocker Must Be Enabled on the OS Drive

| Field | Detail |
|---|---|
| **Settings Name** | Require BitLocker |
| **Intune UI Path** | Devices > Compliance > Policies > Create policy > Basics > **Compliance settings > Device Health > BitLocker** |
| **Value** | Require |
| **Effect** | Enforces that the OS (C:) drive is encrypted with BitLocker. Devices without drive encryption are marked non-compliant and blocked from corporate resources via Conditional Access. |
| **False-Positive Risk** | Microsoft documents that this setting is measured at **boot time** through Device Health Attestation. Even if encryption has completed, the device can remain noncompliant until it **reboots** and checks in again. Devices with TPM issues or delayed attestation updates can also report false negatives. |
| **Recommendation** | Pair this policy with a **Device Configuration profile** that silently enables BitLocker (Endpoint Security > Disk Encryption) so encryption is deployed before compliance is evaluated. The 7-day grace period provides buffer for encryption to complete on existing devices. |

> ⚠️ **UI Change Notice:** Current tenants commonly show the newer **Devices > Compliance > Policies** path rather than the older **Compliance policies** label. If you are working from **Endpoint Security > Disk Encryption**, avoid configuring duplicate controls in both places unless that overlap is intentional.

---

## Requirement 2 – Secure Boot Must Be Enabled

| Field | Detail |
|---|---|
| **Settings Name** | Require Secure Boot to be enabled on the device |
| **Intune UI Path** | Devices > Compliance > Policies > Create policy > Basics > **Compliance settings > Device Health > Require Secure Boot** |
| **Value** | Require |
| **Effect** | Confirms the device boots using only firmware trusted by the OEM. Prevents boot-level rootkits and unsigned OS loaders from executing. |
| **False-Positive Risk** | Microsoft notes this setting is supported on some TPM 1.2 and 2.0 devices. Devices that do not support the required attestation path, especially devices without **TPM 2.0 or later**, can show as **Not compliant** even if they are otherwise usable. Developer workstations and dual-boot builds can also fail intentionally. |
| **Recommendation** | Maintain a separate compliance policy scope (via Intune dynamic group) for any legacy or dev-exception hardware, with a documented risk acceptance. Do not weaken the primary policy. |

---

## Requirement 3 – Minimum OS Build: N-1 (22621.2861)

| Field | Detail |
|---|---|
| **Settings Name** | Minimum OS version |
| **Intune UI Path** | Devices > Compliance > Policies > Create policy > Basics > **Compliance settings > Device Properties > Minimum OS version** |
| **Value** | `10.0.22621.2861` |
| **Effect** | Devices running a Windows Update build older than 22H2 build 2861 (N-1 of current known good 3155) are marked non-compliant. Ensures all devices carry at least one prior patch cycle's security fixes. |
| **False-Positive Risk** | Devices that received a Windows Update but have **not yet rebooted** will report the old build number until restart. Devices in a paused Windows Update ring (e.g., a 21-day pause policy) may legitimately fall behind the N-1 threshold. |
| **Recommendation** | Align Windows Update ring **deferral periods** with this threshold. If the update ring defers quality updates by more than the patch cadence between N and N-1, devices will fail before they can update. Microsoft also now documents **Valid operating system builds** as a more flexible option when you need to allow multiple supported Windows release branches at the same time. |

> ⚠️ **UI Change Notice:** Microsoft Learn specifies the format as **major.minor.build.revision** and explicitly notes that Windows 11 versions should include the Windows version prefix, for example `10.0.22621.2861`. If you need to support multiple acceptable build ranges, consider **Valid operating system builds** instead of a single minimum version.

### Fleet Migration Risk Control (10,000-device scenario)

For large Win11 migrations, the single setting most likely to trigger a mass false non-compliant event is:

- **Minimum OS version**

Why this is highest risk:

1. It applies as a hard numeric gate to every assigned device at once.
2. Migration waves naturally include mixed build states across update rings and reboot windows.
3. A threshold that is too strict can flip thousands of in-progress devices to non-compliant in a single evaluation cycle.

Specific false-positive scenario:

1. A device installs the target cumulative update.
2. The device has not yet rebooted, or Intune reports a stale pre-reboot build for the next check-in.
3. The policy evaluates the old build and marks the device non-compliant, even though the device is effectively in remediation.

Exact migration-safe value to reduce false positives while preserving security intent:

- Set **Minimum OS version** to **`10.0.22000.1`** during the migration window.

Rationale:

1. This enforces the Windows 11 floor (security intent preserved for OS generation).
2. It avoids mass failures caused by patch-level timing differences during rollout.
3. After migration stabilizes, raise the value in phases to your steady-state baseline (for example, `10.0.22621.2861`).

First 24-hour monitoring checklist after assignment:

1. Track non-compliant device count trend for this policy, specifically failures attributed to **Minimum OS version**.
2. Review failing device build distribution to confirm whether failures cluster just below target builds.
3. Measure recovery after reboot and sync (devices that move from non-compliant to compliant within 6 to 12 hours).
4. Compare failures by assignment group or update ring to identify rollout-timing rather than true security gaps.
5. Monitor Conditional Access user impact to ensure the policy is not causing broad access blocking.

---

## Requirement 4 – Windows Defender Real-Time Protection Must Be On

| Field | Detail |
|---|---|
| **Settings Name** | Real-time protection |
| **Intune UI Path** | Devices > Compliance > Policies > Create policy > Basics > **Compliance settings > System Security > Defender > Real-time protection** |
| **Value** | Require |
| **Effect** | Confirms Windows Defender (Microsoft Defender Antivirus) is actively scanning files and processes in real time. Devices with real-time protection disabled or a third-party AV that has passivated Defender will be flagged. |
| **False-Positive Risk** | Devices with a **third-party AV** (e.g., CrowdStrike, Sophos) registered as the primary AV provider will show Defender in **passive mode**, which this setting may flag depending on the reporting integration. Compliance status can also lag if the Defender service is restarting after an update. |
| **Recommendation** | Microsoft also exposes broader checks under **System Security > Device security > Antivirus** and **Antispyware**, plus additional Defender-specific checks like **Security intelligence up-to-date**. If a third-party AV is the standard, consider using **Require the device to be at or under the machine risk score** through Microsoft Defender for Endpoint instead of relying only on Defender service state. |

> ⚠️ **UI Change Notice:** Microsoft Learn separates **Device security** checks such as Antivirus from the **Defender** subsection that contains **Real-time protection**. Use the compliance policy location for compliance evaluation, and avoid duplicating the same control in another policy surface unless that overlap is intentional.

---

## Requirement 5 – Firewall Must Be Enabled for All Profiles

| Field | Detail |
|---|---|
| **Settings Name** | Firewall |
| **Intune UI Path** | Devices > Compliance > Policies > Create policy > Basics > **Compliance settings > System Security > Device security > Firewall** |
| **Value** | Require |
| **Effect** | Validates that Windows Firewall is active on all three network profiles: **Domain**, **Private**, and **Public**. Protects devices on untrusted networks (home, café Wi-Fi) from inbound lateral movement. |
| **False-Positive Risk** | Microsoft notes this setting can briefly report **Error** if the device syncs immediately after a reboot or wake event. Conflicting Group Policy that disables or weakens Windows Firewall can also force the device into **Not compliant** even when Intune tries to enable the firewall. |
| **Recommendation** | Audit for conflicting firewall GPOs before deployment and migrate those controls to Intune where possible. If you see transient errors immediately after startup or wake, manually sync the device and re-evaluate before treating it as a true failure. |

---

## Requirement 6 – A PIN or Password Must Be Configured

| Field | Detail |
|---|---|
| **Settings Name** | Require a password to unlock mobile devices |
| **Intune UI Path** | Devices > Compliance > Policies > Create policy > Basics > **Compliance settings > System Security > Password > Require a password to unlock mobile devices** |
| **Value** | Require |
| **Supporting Settings** | Set **Minimum password length** to `8`; set **Password type** to `Device default`, `Numeric`, or `Alphanumeric` as appropriate. If you choose `Alphanumeric`, Microsoft also exposes **Password complexity** options. |
| **Effect** | Ensures the device cannot be accessed without entering a credential. Combined with Windows Hello for Business, this enforces PIN/biometric at the lock screen, preventing unattended physical access. |
| **False-Positive Risk** | **Shared/kiosk devices** configured without a user sign-in (autologon or kiosk account) will fail this check. Devices enrolled as **userless** (device-only enrollment) may also report no password set. |
| **Recommendation** | Exclude kiosk and shared device AAD groups from this compliance policy and apply a separate, purpose-built kiosk compliance policy. For standard worker devices, enforce Windows Hello for Business via a Device Configuration profile alongside this compliance check. Microsoft also warns that when password requirements change on Windows desktop, users can be affected at the **next sign-in** when the device returns from idle to active. |

> ⚠️ **UI Change Notice:** The label **"Require a password to unlock mobile devices"** is legacy wording inherited from mobile MDM. For Windows 11 PC compliance, the functional equivalent is the **Password** section in System Security. Microsoft has been relabelling these settings; verify the exact label in your tenant version.

---

## Requirement 7 – Device Must Not Be Jailbroken or Rooted

| Field | Detail |
|---|---|
| **Settings Name** | Require code integrity and Require the device to be at or under the machine risk score |
| **Intune UI Path** | Devices > Compliance > Policies > Create policy > Basics > **Compliance settings > Device Health > Require code integrity** *and* **Compliance settings > Microsoft Defender for Endpoint > Require the device to be at or under the machine risk score** |
| **Value** | Code Integrity: **Require** / Machine risk score: **Clear** (or **Low** depending on MDE integration) |
| **Effect** | On Windows, "jailbreak/root" equivalent is enforced via **Device Health Attestation (DHA)** and **Code Integrity**, which confirm the OS and boot environment have not been tampered with. Code Integrity ensures only signed drivers and OS components run. Machine risk score (via Microsoft Defender for Endpoint) catches active compromise indicators. |
| **False-Positive Risk** | Test/developer machines with **test-signed drivers** enabled will fail Code Integrity. Devices that cannot reach the **Device Health Attestation service** (network issues, firewall blocking `has.spserv.microsoft.com`) will report attestation failure. Devices without a **TPM 2.0** chip cannot perform hardware attestation. |
| **Recommendation** | Ensure network egress allows traffic to Microsoft DHA endpoints. For developer machines that legitimately require test-signed drivers, create a separate compliance policy with Code Integrity not required, scoped to a documented security exception group with management sign-off. Require MDE integration for the risk score signal as it provides richer coverage than DHA alone. |

> ⚠️ **UI Change Notice:** Windows does not expose a literal "jailbreak" toggle — this is an Android/iOS concept. The Windows equivalent is the combination of **Device Health Attestation** and **Microsoft Defender for Endpoint risk score**. If your tenant has the **MDE connector** enabled, the risk score setting is the stronger control. Validate both are present in your tenant's compliance settings.

---

## Summary Table

| # | Requirement | Setting Name | Value |
|---|---|---|---|
| 1 | BitLocker on OS drive | Require BitLocker | Require |
| 2 | Secure Boot enabled | Require Secure Boot | Require |
| 3 | Minimum OS build N-1 | Minimum OS version | `10.0.22621.2861` |
| 4 | Defender real-time protection | Real-time protection | Require |
| 5 | Firewall all profiles | Firewall | Require |
| 6 | PIN or password configured | Require a password to unlock mobile devices | Require |
| 7 | Not jailbroken/rooted | Require code integrity + MDE machine risk score | Require / Clear |
| — | Grace period | Mark device noncompliant | 7 days |

---

## Notes on UI Path Accuracy

The following settings carry a **higher risk of UI label or path changes** in the current Intune admin center:

| Setting | Risk | Action |
|---|---|---|
| Real-time protection | Medium – Microsoft separates Defender and Device security categories | Confirm the setting appears under System Security > Defender |
| Machine risk score | Medium – shown only when Microsoft Defender for Endpoint integration is active | Confirm the MDE connector is enabled before relying on this control |
| Password / PIN setting label | Medium – legacy mobile MDM wording is still used for Windows | Verify the exact displayed label in your tenant |
| BitLocker (via Compliance vs Endpoint Security) | Medium – two overlapping policy surfaces | Avoid configuring in both blades simultaneously |

**Recommended validation step:** Deploy to a pilot AAD group of 5–10 devices before broad rollout. Review the compliance reporting area under **Devices > Compliance** after 48 hours to identify unexpected non-compliance before applying Conditional Access enforcement. Pay particular attention to devices that need a **reboot** for Device Health Attestation-based settings and to any devices receiving conflicting **Group Policy** firewall configuration.
