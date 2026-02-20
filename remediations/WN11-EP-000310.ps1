<#
.SYNOPSIS
    This PowerShell script ensures STIG WN11-EP-000310 is satisfied. Windows 11 Kernel (Direct Memory Access) DMA Protection must be enabled.

.NOTES
    Author          : Khang Tran
    LinkedIn        : https://www.linkedin.com/in/khang-tran-622a44163/
    GitHub          : https://github.com/aktran321
    Date Created    : 2/20/2026
    Last Modified   : 2/20/2026
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN11-EP-000310

.TESTED ON
    Date(s) Tested  : 2/20/2026
    Tested By       : Khang Tran
    Systems Tested  : Windows 11 Pro
    PowerShell Ver. : 5.1.26100.7705

.USAGE
    Put any usage instructions here.
    Example syntax:
    PS C:\> .\WN11-EP-000310.ps1

    Then run:
    Get-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Kernel DMA Protection" |
Select-Object DmaGuardEnumerationPolicy

If it prints 0, you’ve applied Enabled: Block All.
#>
# Enable: "Enumeration policy for external devices incompatible with Kernel DMA Protection"
# Set Enumeration Policy to: Block All (0)

$path  = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Kernel DMA Protection"
$name  = "DmaGuardEnumerationPolicy"
$value = 0  # 0=Block all, 1=Only after log in (default), 2=Allow all

# Create key if missing
if (-not (Test-Path $path)) {
    New-Item -Path $path -Force | Out-Null
}

# Set value (idempotent)
New-ItemProperty -Path $path -Name $name -PropertyType DWord -Value $value -Force | Out-Null

# Verify
$current = (Get-ItemProperty -Path $path -Name $name -ErrorAction Stop).$name
"OK: $name = $current (0=BlockAll,1=PostLogin,2=AllowAll)"
