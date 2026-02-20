<#
.SYNOPSIS
    This PowerShell script ensures STIG WN11-CC-000326 is satisfied. PowerShell script block logging must be enabled on Windows 11.

.NOTES
    Author          : Khang Tran
    LinkedIn        : https://www.linkedin.com/in/khang-tran-622a44163/
    GitHub          : https://github.com/aktran321
    Date Created    : 2/20/2026
    Last Modified   : 2/20/2026
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN11-CC-000326

.TESTED ON
    Date(s) Tested  : 2/20/2026
    Tested By       : Khang Tran
    Systems Tested  : Windows 11 Pro
    PowerShell Ver. : 5.1.26100.7705

.USAGE
    Put any usage instructions here.
    Example syntax:
    PS C:\> .\WN11-CC-000326.ps1
#>
$path  = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging"
$name  = "EnableScriptBlockLogging"
$value = 1  # Enabled

# Create key if missing
if (-not (Test-Path $path)) {
    New-Item -Path $path -Force | Out-Null
}

# Set value
New-ItemProperty -Path $path -Name $name -PropertyType DWord -Value $value -Force | Out-Null

# Verify
(Get-ItemProperty -Path $path -Name $name).$name
