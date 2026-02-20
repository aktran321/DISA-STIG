<#
.SYNOPSIS
    This PowerShell script ensures STIG WN11-CC-000150 is satisfied. The user must be prompted for a password on resume from sleep (plugged in).

.NOTES
    Author          : Khang Tran
    LinkedIn        : https://www.linkedin.com/in/khang-tran-622a44163/
    GitHub          : https://github.com/aktran321
    Date Created    : 2/20/2026
    Last Modified   : 2/20/2026
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN11-CC-000150

.TESTED ON
    Date(s) Tested  : 2/20/2026
    Tested By       : Khang Tran
    Systems Tested  : Windows 11 Pro
    PowerShell Ver. : 5.1.26100.7705

.USAGE
    Put any usage instructions here.
    Example syntax:
    PS C:\> .\WN11-CC-000150.ps1
#>
# Require a password when computer wakes (plugged in)
# Sets policy to Enabled

$basePath = "HKLM:\SOFTWARE\Policies\Microsoft\Power\PowerSettings"
$subKey   = "0e796bdb-100d-47d6-a2d5-f7d2daa51f51"
$path     = Join-Path $basePath $subKey

$name  = "ACSettingIndex"
$value = 1  # Enabled

# Create key structure if missing
if (-not (Test-Path $path)) {
    New-Item -Path $path -Force | Out-Null
}

# Set policy value
New-ItemProperty -Path $path -Name $name -PropertyType DWord -Value $value -Force | Out-Null

# Verify
$current = (Get-ItemProperty -Path $path -Name $name -ErrorAction Stop).$name
"ACSettingIndex = $current (1 = Require password)"
