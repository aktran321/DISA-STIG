<#
.SYNOPSIS
    This PowerShell script ensures STIG WN11-CC-000315 is satisfied. “Always install with elevated privileges” must be Disabled

.NOTES
    Author          : Khang Tran
    LinkedIn        : https://www.linkedin.com/in/khang-tran-622a44163/
    GitHub          : https://github.com/aktran321
    Date Created    : 2/21/2026
    Last Modified   : 2/21/2026
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN11-CC-000315

.TESTED ON
    Date(s) Tested  : 2/21/2026
    Tested By       : Khang Tran
    Systems Tested  : Windows 11 Pro
    PowerShell Ver. : 5.1.26100.7705

.USAGE
    Put any usage instructions here.
    Example syntax:
    PS C:\> .\WN11-CC-000315.ps1
#>
New-ItemProperty -Path $uPath -Name $name -PropertyType DWord -Value 0 -Force | Out-Null
$path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer"
$name = "AlwaysInstallElevated"
$desired = 0  # Disabled

if (-not (Test-Path $path)) { New-Item -Path $path -Force | Out-Null }
New-ItemProperty -Path $path -Name $name -PropertyType DWord -Value $desired -Force | Out-Null

# Verify
(Get-ItemProperty -Path $path -Name $name).$name
