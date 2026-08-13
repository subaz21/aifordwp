# Startup Program Auditor and Disabler (PowerShell 5.1)

## What this script does

`Startup-Program-Auditor.ps1` is an audit and remediation tool for DWP engineers.

It does two things:
1. Lists startup programs from common startup locations.
2. Accepts a `-DisableProgramName` input and can disable matching entries.

## Disable behavior

When you disable an entry, the script changes startup configuration safely:

- Registry entry disable:
1. Moves value from `...\Run` to `...\Run-Disabled`
2. Removes the original value from `...\Run`

- Startup folder entry disable:
1. Moves shortcut/file to a `Disabled` subfolder in the same Startup folder

Use `-PreviewOnly` or `-WhatIf` before making real changes.

## Startup locations checked

The script audits these locations:
1. `HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run`
2. `HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run`
3. `C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup`
4. `%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup`

## Requirements

1. Windows PowerShell 5.1
2. Read access to HKLM/HKCU Run keys and Startup folders
3. Write permissions are required to disable entries
4. Elevated PowerShell may be required for Machine scope entries

## How to run

Open PowerShell in this folder:

```powershell
cd "C:\Users\labuser\Documents\Training\Day 3 - Scripting\Startup-Program-Auditor"
```

### 1) Run audit only

```powershell
.\Startup-Program-Auditor.ps1
```

### 2) Run audit + disable preview

```powershell
.\Startup-Program-Auditor.ps1 -DisableProgramName "Teams" -PreviewOnly
```

### 3) Run audit + disable preview via WhatIf

```powershell
.\Startup-Program-Auditor.ps1 -DisableProgramName "Teams" -WhatIf
```

### 4) Disable matching startup entries

```powershell
.\Startup-Program-Auditor.ps1 -DisableProgramName "Teams" -Confirm
```

## Understanding the output

### Startup Program Inventory
- `Name`: Display/entry name.
- `Source`: Where it came from (`RegistryRunKey` or `StartupFolder`).
- `Scope`: `Machine` or `CurrentUser`.
- `Path`: Registry path or file path.
- `Value`: Command/value in registry or file name in startup folder.

### Disable Workflow
- If no parameter is supplied, preview is skipped.
- If a name is supplied, matching entries are listed.
- If `-PreviewOnly` is used, no changes are made.
- If no preview switch is used, matched entries are disabled.
- If `-WhatIf` is used, PowerShell simulates the change.

## Why entries may be missing

Not every startup mechanism is covered by these paths. Some apps can start via:
- Scheduled Tasks
- Services
- Group Policy
- App-specific startup managers

This script is focused on common Run key and Startup folder locations.

## Quick troubleshooting

1. If no entries appear, check permissions and whether startup is managed elsewhere.
2. If `-DisableProgramName` finds no match, try a broader term (for example `Team` instead of `Teams`).
3. Ensure you are running in Windows PowerShell 5.1.
4. If disable fails for machine entries, run PowerShell as Administrator.
