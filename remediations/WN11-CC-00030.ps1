<#
.SYNOPSIS
    This PowerShell script ensures STIG WN11-CC-00030 is satisfied. Indexing of encrypted files must be turned off.

.NOTES
    Author          : Khang Tran
    LinkedIn        : https://www.linkedin.com/in/khang-tran-622a44163/
    GitHub          : https://github.com/aktran321
    Date Created    : 2/20/2026
    Last Modified   : 2/20/2026
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN11-CC-00030

.TESTED ON
    Date(s) Tested  : 2/20/2026
    Tested By       : Khang Tran
    Systems Tested  : Windows 11 Pro
    PowerShell Ver. : 5.1.26100.7705

.USAGE
    Put any usage instructions here.
    Example syntax:
    PS C:\> .\WN11-CC-00030.ps1
#>
# Disable: "Allow indexing of encrypted files"

$path  = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
$name  = "AllowIndexingEncryptedStoresOrItems"
$value = 0  # Disabled

# Create key if missing
if (-not (Test-Path $path)) {
    New-Item -Path $path -Force | Out-Null
}

# Set value (idempotent)
New-ItemProperty -Path $path -Name $name -PropertyType DWord -Value $value -Force | Out-Null

# Verify
$current = (Get-ItemProperty -Path $path -Name $name -ErrorAction Stop).$name
"AllowIndexingEncryptedStoresOrItems = $current (0 = Disabled)"
