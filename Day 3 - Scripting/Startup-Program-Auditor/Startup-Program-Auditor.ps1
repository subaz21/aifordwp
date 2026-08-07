#requires -version 5.1
<#
    Startup Program Auditor and Disabler
    Audience: DWP Engineers

    Purpose:
    - List startup programs from common registry Run keys and Startup folders.
    - Disable startup entries by program name when requested.
#>

[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
param(
    [string]$DisableProgramName,
    [switch]$PreviewOnly
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Write-Section {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Title
    )

    Write-Host ''
    Write-Host ('=' * 80)
    Write-Host $Title
    Write-Host ('=' * 80)
}

<#
    SECTION: Header
    Prints report metadata for traceability.
#>
Write-Host 'Startup Program Auditor and Disabler'
Write-Host ('Generated: {0}' -f (Get-Date))
Write-Host ('Computer : {0}' -f $env:COMPUTERNAME)
Write-Host ('User     : {0}' -f $env:USERNAME)

<#
    SECTION: Pre-Run Verification
    Flags checks the engineer should confirm before running.
#>
Write-Section -Title 'Pre-Run Verification (Please Confirm)'
Write-Host '- Run in Windows PowerShell 5.1 for expected behavior.'
Write-Host '- Disabling Machine-scope entries may require elevated rights.'
Write-Host '- Review matches with -PreviewOnly or -WhatIf before making changes.'
Write-Host '- Startup file disables move files into a Disabled subfolder.'
Write-Host '- Registry disables move values from Run to Run-Disabled.'

<#
    SECTION: Data Collection Functions
    Collects startup entries from registry and startup folders in a structured way.
#>
function Get-RegistryStartupEntries {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RegistryPath,
        [Parameter(Mandatory = $true)]
        [string]$Scope
    )

    if (-not (Test-Path -Path $RegistryPath)) {
        return @()
    }

    $item = Get-ItemProperty -Path $RegistryPath
    $entries = @()

    foreach ($prop in $item.PSObject.Properties) {
        if ($prop.Name -in @('PSPath', 'PSParentPath', 'PSChildName', 'PSDrive', 'PSProvider')) {
            continue
        }

        $entries += [pscustomobject]@{
            Name   = $prop.Name
            Source = 'RegistryRunKey'
            Scope  = $Scope
            Path   = $RegistryPath
            Value  = [string]$prop.Value
        }
    }

    return $entries
}

function Get-StartupFolderEntries {
    param(
        [Parameter(Mandatory = $true)]
        [string]$FolderPath,
        [Parameter(Mandatory = $true)]
        [string]$Scope
    )

    if (-not (Test-Path -Path $FolderPath)) {
        return @()
    }

    $files = Get-ChildItem -Path $FolderPath -File -ErrorAction SilentlyContinue
    $entries = @()

    foreach ($file in $files) {
        $entries += [pscustomobject]@{
            Name   = $file.BaseName
            Source = 'StartupFolder'
            Scope  = $Scope
            Path   = $file.FullName
            Value  = $file.Name
        }
    }

    return $entries
}

<#
    SECTION: Disable Functions
    Implements safe disable behavior for registry and startup folder entries.
#>
function Disable-RegistryStartupEntry {
    param(
        [Parameter(Mandatory = $true)]
        [pscustomobject]$Entry
    )

    $disabledPath = $Entry.Path -replace '\\Run$', '\\Run-Disabled'
    if (-not (Test-Path -Path $disabledPath)) {
        New-Item -Path $disabledPath -Force | Out-Null
    }

    Set-ItemProperty -Path $disabledPath -Name $Entry.Name -Value $Entry.Value -Type String
    Remove-ItemProperty -Path $Entry.Path -Name $Entry.Name
}

function Disable-StartupFolderEntry {
    param(
        [Parameter(Mandatory = $true)]
        [pscustomobject]$Entry
    )

    $parentFolder = Split-Path -Path $Entry.Path -Parent
    $disabledFolder = Join-Path -Path $parentFolder -ChildPath 'Disabled'
    if (-not (Test-Path -Path $disabledFolder)) {
        New-Item -ItemType Directory -Path $disabledFolder -Force | Out-Null
    }

    $destination = Join-Path -Path $disabledFolder -ChildPath $Entry.Value
    if (Test-Path -Path $destination) {
        $timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
        $destination = Join-Path -Path $disabledFolder -ChildPath ("{0}.{1}.disabled" -f $Entry.Value, $timestamp)
    }

    Move-Item -Path $Entry.Path -Destination $destination
}

<#
    SECTION: Startup Program Inventory
    Reads startup locations and outputs a combined table.
#>
Write-Section -Title 'Startup Program Inventory'

try {
    $allEntries = @()

    # Registry Run keys
    $allEntries += Get-RegistryStartupEntries -RegistryPath 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run' -Scope 'Machine'
    $allEntries += Get-RegistryStartupEntries -RegistryPath 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run' -Scope 'CurrentUser'

    # Startup folders
    $allEntries += Get-StartupFolderEntries -FolderPath "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Startup" -Scope 'Machine'
    $allEntries += Get-StartupFolderEntries -FolderPath "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup" -Scope 'CurrentUser'

    $allEntries = @($allEntries | Sort-Object -Property Name, Source, Scope)

    if ($allEntries.Count -eq 0) {
        Write-Host 'No startup entries found in queried locations.'
    }
    else {
        $allEntries |
            Select-Object Name, Source, Scope, Path, Value |
            Format-Table -AutoSize |
            Out-String |
            Write-Host

        Write-Host ('Total startup entries found: {0}' -f $allEntries.Count)
    }
}
catch {
    Write-Warning ('Unable to enumerate startup programs: {0}' -f $_.Exception.Message)
    $allEntries = @()
}

<#
    SECTION: Disable Workflow
    Matches a program name and disables each matching startup entry unless preview mode is selected.
#>
Write-Section -Title 'Disable Workflow'

if ([string]::IsNullOrWhiteSpace($DisableProgramName)) {
    Write-Host 'No -DisableProgramName supplied. Disable workflow skipped.'
}
else {
    try {
        $needle = $DisableProgramName.Trim()
        $matches = @(
            $allEntries | Where-Object {
                $_.Name -like "*$needle*" -or $_.Value -like "*$needle*"
            }
        )

        if ($matches.Count -eq 0) {
            Write-Host ('No startup entries matched "{0}".' -f $needle)
        }
        else {
            Write-Host ('Matched startup entries for "{0}":' -f $needle)
            $matches |
                Select-Object Name, Source, Scope, Path, Value |
                Format-Table -AutoSize |
                Out-String |
                Write-Host

            if ($PreviewOnly) {
                Write-Host 'PreviewOnly is set. No changes were made.'
            }
            else {
                $results = @()

                foreach ($match in $matches) {
                    $target = '{0} [{1}]' -f $match.Name, $match.Source
                    try {
                        if ($PSCmdlet.ShouldProcess($target, 'Disable startup entry')) {
                            if ($match.Source -eq 'RegistryRunKey') {
                                Disable-RegistryStartupEntry -Entry $match
                            }
                            elseif ($match.Source -eq 'StartupFolder') {
                                Disable-StartupFolderEntry -Entry $match
                            }

                            $results += [pscustomobject]@{
                                Name = $match.Name
                                Source = $match.Source
                                Scope = $match.Scope
                                Status = 'Disabled'
                                Details = 'Success'
                            }
                        }
                    }
                    catch {
                        $results += [pscustomobject]@{
                            Name = $match.Name
                            Source = $match.Source
                            Scope = $match.Scope
                            Status = 'Failed'
                            Details = $_.Exception.Message
                        }
                    }
                }

                if ($results.Count -gt 0) {
                    Write-Host 'Disable results:'
                    $results | Format-Table -AutoSize | Out-String | Write-Host
                }
            }
        }
    }
    catch {
        Write-Warning ('Unable to run disable workflow: {0}' -f $_.Exception.Message)
    }
}

Write-Host ''
Write-Host 'Audit complete.'