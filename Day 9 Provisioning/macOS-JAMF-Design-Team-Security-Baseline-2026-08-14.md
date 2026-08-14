# macOS – JAMF Pro Configuration Profile: Security Baseline Translation

**Author:** DWP Engineer
**Date:** 2026-08-14
**Scope:** 25 macOS devices, FinBridge Design team, enrolled in JAMF Pro
**Grace Period (all settings):** No native JAMF grace-period field exists (see note below) — non-compliant devices are surfaced via a Smart Group within one inventory cycle and given **7 days** to remediate before Self Service/Conditional Access restriction is applied, matching the Day 6 Intune grace period for consistency.

**Naming/UI validation:** JAMF Pro payload names, tab labels, and checkbox wording have changed across releases (classic payloads vs. newer declarative device management payloads). Reviewed against general JAMF Pro administration guidance, but **not** validated against a specific current release — confirm every payload/label below against your own JAMF Pro instance before building the profile, the same discipline used for the Day 6 Intune labs.

---

## Portal Navigation Note

This guide assumes the standard JAMF Pro configuration profile navigation:

**Computers > Configuration Profiles > New**

When creating a new macOS configuration profile, the current workflow uses:

- **Level:** Computer Level
- **Distribution Method:** Install Automatically

If your JAMF Pro instance shows a different landing page (e.g., a **Devices** unified navigation for Apple + mobile), use the equivalent macOS computer configuration profile location.

---

## How JAMF Handles the "Grace Period" Concept

JAMF Pro does **not** have a built-in "mark device noncompliant after N days" scheduler the way Intune compliance policies do. The equivalent outcome is normally assembled from three separate pieces:

1. A **Smart Group** per requirement (or one combined Smart Group) built from inventory criteria (e.g., FileVault Status, Firewall enabled, Gatekeeper status, OS version).
2. A **time delay** built into the Smart Group logic or a follow-up policy (e.g., "Last Inventory Update" combined with "days since profile installed") to approximate a grace period before an action fires.
3. An **enforcement action** — typically restricting Self Service access, or, if JAMF Pro is integrated with Microsoft Entra Conditional Access as a compliance partner, feeding a compliant/non-compliant signal to Entra for access blocking.

**Flag for verification:** the exact Conditional Access integration path and its current name (JAMF's compliance connector to Entra ID) should be confirmed directly in your tenant/instance — this integration and its terminology have changed over time and are not detailed here.

## How to Create the Profile

In JAMF Pro: **Computers > Configuration Profiles > New**

Set the following on the **General** payload:

- **Name:** `macOS Design Team Security Baseline`
- **Description:** `macOS security baseline for Design team covering FileVault, Gatekeeper, minimum OS version, Firewall, password after sleep, and automatic security updates.`
- **Level:** Computer Level
- **Distribution Method:** Install Automatically

After completing **General**, the remaining payloads are configured directly on the left-hand payload list within the same profile — unlike Intune's multi-step wizard, JAMF assembles all payloads into one profile before scoping.

## Where to Configure the Requirements

Five of the six requirements below are configured as payloads within the same configuration profile:

**Computers > Configuration Profiles > New > [Payload list on the left]**

The sixth (minimum OS version) is **not** a profile payload and is configured separately via Smart Groups/Patch Management, as detailed in Requirement 3.

---

## Detailed Step-by-Step Process

This section reflects the general JAMF Pro configuration profile flow. Confirm exact payload/tab names in your instance before executing.

### Step 1 – Create the configuration profile shell

1. Sign in to JAMF Pro.
2. Go to **Computers > Configuration Profiles**.
3. Select **New**.
4. On **General**, set **Level** to **Computer Level** and **Distribution Method** to **Install Automatically**.

### Step 2 – Complete the General payload

1. In **Name**, enter `macOS Design Team Security Baseline`.
2. In **Description**, enter a supportable description covering all six requirements.
3. Confirm **Level** shows **Computer Level**.
4. Leave **Category** and **Site** at your organization's standard values.

### Step 3 – Configure Requirement 1: FileVault disk encryption

1. From the payload list, select **FileVault**.
2. Set **FileVault** to **Enable**.
3. Set **Recovery Key Type** to **Individual**.
4. Enable **Escrow Location** so the recovery key is stored in JAMF Pro (wording may show as "Escrow personal recovery key" in some versions).
5. Set the deferral/enforcement behavior so encryption is not indefinitely postponable (e.g., enforce at next login rather than an open-ended deferral count).
6. Record an admin note that Apple's FileVault status is only re-evaluated at login/unlock, so a device can lag behind actual encryption state until the user's next authentication.

### Step 4 – Configure Requirement 2: Gatekeeper (identified developers only)

1. From the payload list, select **Security & Privacy**.
2. On the **General** tab, set **Allow apps downloaded from:** to **App Store and identified developers**.
3. Confirm no separate Restrictions payload setting conflicts with this (some JAMF Restrictions payload versions also expose an app-source control — do not configure both unless intentional).
4. Record that repeated Gatekeeper blocks on unnotarized plugins/tools common to Design workflows can lead users to disable Gatekeeper manually (`sudo spctl --master-disable`), which will surface as a compliance failure distinct from a misconfigured profile.

### Step 5 – Configure Requirement 3: Minimum macOS version

1. There is no profile payload for this — go to **Smart Computer Groups** instead.
2. Create a Smart Group with criterion **Operating System Version** `less than` the value you determine represents "current stable minus one point release."
3. **Do not guess this value from training data** — confirm Apple's current shipping macOS version directly (Apple's official release notes/support pages) and calculate N-1 from that.
4. Use the Smart Group to scope either a restricted Self Service policy (blocking access until updated) or a Patch Management / declarative OS update deadline enforcement, depending on what your JAMF Pro version supports.
5. Record that devices which installed the qualifying update but have not yet rebooted can still report the old build to JAMF inventory until the next check-in/reboot.

### Step 6 – Configure Requirement 4: Firewall enabled

1. Stay in the **Security & Privacy** payload, **Firewall** tab.
2. Set **Enable Firewall** to **On**.
3. Leave **Block all incoming connections** set to **Off** so signed/built-in services (AirDrop, screen sharing, printer discovery) remain functional.
4. Optionally enable **Enable stealth mode**.
5. Record that toggling "Block all incoming connections" On instead of Off is a common over-enforcement mistake that breaks legitimate Design team local-network workflows.

### Step 7 – Configure Requirement 5: Password required after sleep/screen saver

1. Stay in **Security & Privacy**, **General** tab.
2. Set **Require password after sleep or screen saver begins** to **Enabled**.
3. Set the delay to **Immediately** (or a short grace value such as 5 seconds if the business requires it).
4. Record that devices used for presentations (Keynote, Zoom, review sessions on Studio Displays) may have sleep/screen saver suppressed by the presenting app, which can make inventory reads of `com.apple.screensaver` look stale until the next full login.

### Step 8 – Configure Requirement 6: Automatic security updates

1. From the payload list, select **Software Update**.
2. Set **Automatically check for updates** to **On**.
3. Set **Install system data files and security updates** to **On** (this is the control mapped to automatic installation of critical/security updates and Rapid Security Responses).
4. Record that Apple's exact checkbox wording for this control has changed across System Settings redesigns (older "security updates" phrasing vs. newer "security responses and system files" phrasing) — confirm current wording in your instance.
5. Record that a device asleep at its scheduled check window, or a user who has used Apple's "Pause Updates" feature, can delay installation for days without the profile itself being misconfigured.

### Step 9 – Scope the profile

1. Select the **Scope** tab.
2. Add the target Smart Group or Static Group representing the 25 Design team devices.
3. Exclude any documented exception devices (e.g., approved developer exception machines) if applicable.
4. Confirm the scope count matches 25 devices before saving.

### Step 10 – Save and deploy

1. Select **Save**.
2. Confirm the profile shows **Install Automatically** and the correct scope count in the profile list.

### Step 11 – Post-deployment validation

1. Deploy first to a pilot group of 5–8 Design devices before the full 25-device rollout.
2. Force a recon/inventory update on at least one pilot device and confirm it checks in successfully.
3. Reboot/re-login on at least one FileVault-targeted pilot device so encryption and password-after-sleep settings can re-evaluate.
4. Review **Computers > Smart Groups** (compliant vs. non-compliant criteria) for unexpected results.
5. Investigate any Gatekeeper- or Firewall-related user complaints (broken plugins, broken AirDrop/screen sharing) before broad rollout.
6. Only after pilot validation, extend scope to the full 25-device Smart/Static Group and, if applicable, bind Conditional Access to the compliance signal.

### Step 12 – Validate one synced test device against this specific profile

1. Go to **Computers > Configuration Profiles**.
2. Select your profile, e.g., **macOS Design Team Security Baseline**.
3. Open the device list/logs view to see install status per device.
4. Search for the test device name and confirm **Installed** status.
5. Alternate path: **Computers > Search Inventory > [Test Device] > Management > Configuration Profiles**.

Profile status meaning:

1. **Installed**: Profile applied successfully to the device.
2. **Pending**: Profile queued but not yet applied — usually resolves on next check-in.
3. **Failed**: Profile did not apply — investigate MDM connectivity or a payload conflict with an existing profile.

### Step 13 – FileVault false-positive triage (most common flagged setting)

1. **Most common cause: setting evaluated only at next login/unlock.**
	Fastest check: confirm the user's last login time and prompt a re-login, then recheck FileVault status in inventory.
2. **Common cause: encryption not fully complete on the boot volume.**
	Fastest check: run `fdesetup status` on the device and verify "FileVault is On."
3. **Common cause: device pre-encrypted before enrollment with a personal (non-escrowed) key.**
	Fastest check: confirm in JAMF Pro whether a recovery key is on file for the device; if absent, trigger a key rotation/escrow via `fdesetup changerecovery` or the equivalent JAMF workflow.

### Step 14 – 24-hour validation checks after assigning profile to full scope

1. Track Smart Group membership counts for each requirement's compliant/non-compliant criteria every few hours.
2. Review whether failures concentrate on FileVault (login-cycle lag) or Gatekeeper (plugin friction) specifically.
3. Measure how many FileVault "failures" self-resolve after one login/unlock cycle.
4. Monitor for Design team user complaints tied to Firewall or Gatekeeper (broken AirDrop, blocked plugins) as a leading indicator of over-enforcement.
5. If FileVault false positives remain elevated, hold any Conditional Access-style enforcement expansion until login-cycle coverage is confirmed.

---

## Requirement 1 – FileVault Disk Encryption Must Be Enabled

| Field | Detail |
|---|---|
| **Settings Name** | FileVault (Enable) |
| **JAMF UI Path** | Computers > Configuration Profiles > New > **FileVault payload** |
| **Value** | Enable = **On**; Recovery Key Type = **Individual**; Escrow Location = **On** (escrow to JAMF Pro); enforce at next login rather than an open-ended deferral |
| **Effect** | Encrypts the boot volume so data is unreadable without the correct login credential or recovery key — protects data at rest if a device is lost or stolen |
| **False-Positive Risk** | FileVault status is only fully re-evaluated at login/unlock, so a device can report "not yet encrypted" for a period after profile install until the user's next authentication. A device that was FileVault-enabled **before** enrollment with a personal (non-escrowed) key can show as encrypted but with **no valid recovery key on file**, which some Smart Groups treat as a separate failure. |
| **Recommendation** | Pair with a documented deferral limit rather than unlimited deferrals, and build a Smart Group specifically for "FileVault enabled but no recovery key escrowed" to catch the pre-enrollment-encryption edge case separately from true non-encryption. |

> ⚠️ **UI Change Notice:** The "FileVault" payload name itself is comparatively stable, but the escrow wording ("Escrow personal recovery key" vs. "Institutional recovery key") has varied across JAMF Pro versions — confirm the exact label in your instance.

---

## Requirement 2 – Gatekeeper Must Be Enabled (Identified Developers Only)

| Field | Detail |
|---|---|
| **Settings Name** | Allow apps downloaded from |
| **JAMF UI Path** | Computers > Configuration Profiles > New > **Security & Privacy payload > General tab** |
| **Value** | **App Store and identified developers** |
| **Effect** | Blocks execution of unsigned/unnotarized apps from unidentified sources, while still allowing normally distributed identified-developer and App Store apps to run |
| **False-Positive Risk** | Design workflows commonly rely on unnotarized plugins, ad-hoc signed builds, or in-house tools (Creative Cloud plugins, font managers, color profile tools). Users hitting repeated Gatekeeper blocks sometimes self-remediate with `sudo spctl --master-disable`, which then surfaces as Gatekeeper "disabled" on a device that was compliant until the user intervened. |
| **Recommendation** | Maintain an approved-plugin/notarization exception list for Design tooling so legitimate blocks don't drive users to disable Gatekeeper outright; monitor for `spctl --status` reporting disabled as a leading indicator of this workaround. |

> ⚠️ **UI Change Notice:** Apple has changed the Gatekeeper end-user override flow (right-click "Open" bypass) across recent macOS versions. This doesn't change the payload name, but changes user-facing friction — confirm current override behavior for your fleet's macOS version separately from the profile configuration.

---

## Requirement 3 – Minimum macOS Version: Current Stable Minus One Point Release

| Field | Detail |
|---|---|
| **Settings Name** | *No direct settings name — not a configuration profile payload* |
| **JAMF UI Path** | **Computers > Smart Computer Groups > New** (criterion: **Operating System Version**), combined with **Patch Management** or a declarative OS update deadline workflow for enforcement |
| **Value** | **Not stated here** — do not invent a specific macOS version number. Confirm Apple's current shipping macOS version from an authoritative source and calculate N-1 from that at build time |
| **Effect** | Devices below the threshold are identified via Smart Group and either blocked from Self Service, flagged for follow-up, or forced to update by a deadline, keeping the fleet within one point release of current |
| **False-Positive Risk** | Devices that installed the qualifying update but have not yet rebooted can still report the old build number to JAMF inventory until the next check-in/reboot cycle. |
| **Recommendation** | Build the Smart Group criterion using a range/threshold rather than an exact single build string if your JAMF Pro version's OS update enforcement supports it, to reduce sensitivity to point-release patch timing. |

> ⚠️ **UI Change Notice — high risk.** Unlike Intune, JAMF Pro has no single stable "Minimum OS version" compliance payload. The available enforcement mechanism (classic Smart Group + Self Service restriction vs. newer declarative "Managed OS Update" deadline enforcement) has changed significantly across JAMF Pro releases. Verify what your specific version supports before committing to a design.

### Fleet Rollout Risk Control (25-device Design fleet)

For this fleet size, the setting most likely to generate user-visible friction (rather than a mass false-non-compliant event, given the small scale) is:

- **Gatekeeper (identified developers only)**

Why this is highest risk for a Design team specifically:

1. Design workflows depend heavily on third-party plugins and creative tools that are frequently unsigned or slow to notarize.
2. Blocking these outright drives users toward self-remediation (disabling Gatekeeper), which defeats the control.
3. Unlike BitLocker/FileVault's reboot-driven lag, this is a behavioral/workflow risk rather than a timing-based false positive.

Recommended mitigation:

1. Pilot the Gatekeeper setting with a small Design sub-group first and collect blocked-app reports before full rollout.
2. Maintain a reviewed allow-list process for recurring legitimate tools that trigger Gatekeeper blocks, rather than defaulting to "Anywhere" or disabling the control fleet-wide.
3. Monitor `spctl --status` via inventory/Extension Attribute to catch users who disable Gatekeeper as a workaround.

---

## Requirement 4 – Firewall Must Be Enabled

| Field | Detail |
|---|---|
| **Settings Name** | Enable Firewall |
| **JAMF UI Path** | Computers > Configuration Profiles > New > **Security & Privacy payload > Firewall tab** |
| **Value** | Enable Firewall = **On**; Block all incoming connections = **Off**; Stealth Mode = optional **On** |
| **Effect** | Blocks unsolicited inbound connections while still allowing normal signed application traffic, reducing exposure to network-based attacks |
| **False-Positive Risk** | If "Block all incoming connections" is mistakenly enabled instead of left off, legitimate Design workflows (AirDrop, screen sharing, local file transfer, printer/scanner discovery) break — a common over-enforcement mistake when translating "firewall must be enabled" too literally. |
| **Recommendation** | Explicitly document and test that "Block all incoming connections" stays Off during pilot, since this is the most common misconfiguration for this requirement. |

> ⚠️ **UI Change Notice:** The Firewall tab under Security & Privacy has been comparatively stable, but confirm the exact stealth-mode/signed-app-exception checkbox wording in your current version.

---

## Requirement 5 – Login Password Required After Sleep/Screen Saver

| Field | Detail |
|---|---|
| **Settings Name** | Require password after sleep or screen saver begins |
| **JAMF UI Path** | Computers > Configuration Profiles > New > **Security & Privacy payload > General tab** |
| **Value** | Enabled; delay = **Immediately** (or a short grace value, e.g., 5 seconds, if required) |
| **Effect** | Prevents access to an unattended, unlocked session once the screen sleeps or the screen saver activates |
| **False-Positive Risk** | Devices used for presentations (Keynote, Zoom, review sessions on Studio Displays) may have sleep/screen saver suppressed by the presenting app, making cached `com.apple.screensaver` inventory reads look stale or inconsistent until the next full login. |
| **Recommendation** | Exclude known presentation-room/shared display devices from this policy only if there's a documented business exception, otherwise keep it fleet-wide given it's a core control. |

> ⚠️ **UI Change Notice:** This setting and its label have been stable across JAMF Pro versions — lower risk than others in this list, but still confirm before deployment.

---

## Requirement 6 – Automatic Security Updates Enabled

| Field | Detail |
|---|---|
| **Settings Name** | Install system data files and security updates |
| **JAMF UI Path** | Computers > Configuration Profiles > New > **Software Update payload** |
| **Value** | Automatically check for updates = **On**; Install system data files and security updates = **On** |
| **Effect** | Ensures critical security patches and Rapid Security Responses install automatically without waiting for manual user action |
| **False-Positive Risk** | A device asleep at its scheduled check-in/update window, or a user who has used Apple's built-in "Pause Updates" feature, can delay installation for days — this makes an otherwise-correctly-configured device appear non-current even though the profile itself is applied correctly. |
| **Recommendation** | Combine with a Smart Group tracking "days since last security update install" to distinguish a misconfigured profile from a device that's simply asleep/paused, before treating it as a true failure. |

> ⚠️ **UI Change Notice — medium-to-high risk.** Apple has renamed and re-split these checkboxes across macOS System Settings redesigns (older "security updates" phrasing vs. newer "security responses and system files" phrasing), and JAMF's payload labels have followed at different times. Confirm the exact current checkbox wording in your JAMF Pro console against the macOS version your fleet is running.

---

## Summary Table

| # | Requirement | Settings Name | Value |
|---|---|---|---|
| 1 | FileVault disk encryption | FileVault (Enable) | On / Individual key / Escrow On |
| 2 | Gatekeeper (identified developers) | Allow apps downloaded from | App Store and identified developers |
| 3 | Minimum OS version (N-1) | *No profile payload — Smart Group + enforcement* | Verify current stable version, do not assume |
| 4 | Firewall enabled | Enable Firewall | On (Block all incoming = Off) |
| 5 | Password after sleep/screen saver | Require password after sleep or screen saver begins | Enabled / Immediately |
| 6 | Automatic security updates | Install system data files and security updates | On |
| — | Grace period equivalent | Smart Group + Self Service/Conditional Access | ~7 days (approximated, not native) |

---

## Notes on UI Path Accuracy

The following settings carry a **higher risk of payload/label changes** in the current JAMF Pro console:

| Setting | Risk | Action |
|---|---|---|
| Minimum OS version enforcement | **High** – no fixed payload exists; mechanism varies by JAMF Pro version | Confirm whether your version supports declarative OS update deadlines or requires classic Smart Group + Self Service restriction |
| Automatic security updates checkbox wording | Medium-High – Apple/JAMF wording has changed across System Settings redesigns | Confirm exact current label before deployment |
| Gatekeeper end-user override behavior | Medium – payload name stable, but Apple's override UX has changed | Confirm current macOS version's Gatekeeper override flow |
| FileVault escrow wording | Low-Medium – "personal" vs. "institutional" recovery key phrasing varies | Confirm exact label in your instance |
| Firewall / Password after sleep | Low | Confirm labels as a standard pre-deployment step, lower priority than the above |

**Recommended validation step:** Deploy to a pilot group of 5–8 Design devices before the full 25-device rollout. Review configuration profile install status and relevant Smart Group membership after 24–48 hours to identify unexpected non-compliance before applying any Conditional Access-style enforcement. Pay particular attention to devices that need a **login/unlock cycle** for FileVault and password-after-sleep settings to re-evaluate, and to any user reports of broken plugins or local-network workflows tied to Gatekeeper/Firewall.
