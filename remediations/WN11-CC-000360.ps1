<#
.SYNOPSIS
    This PowerShell script ensures STIG WN11-CC-000360 is satisfied. The Windows Remote Management (WinRM) client must not use Digest authentication.

.NOTES
    Author          : Khang Tran
    LinkedIn        : https://www.linkedin.com/in/khang-tran-622a44163/
    GitHub          : https://github.com/aktran321
    Date Created    : 2/20/2026
    Last Modified   : 2/20/2026
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN11-CC-000360

.TESTED ON
    Date(s) Tested  : 2/20/2026
    Tested By       : Khang Tran
    Systems Tested  : Windows 11 Pro
    PowerShell Ver. : 5.1.26100.7705

.USAGE
    Put any usage instructions here.
    Example syntax:
    PS C:\> .\WN11-CC-000360.ps1
#>
# Disallow Digest authentication (WinRM Client) = Enabled
# GPO/ADMX mapping: HKLM\SOFTWARE\Policies\Microsoft\Windows\WinRM\Client\AllowDigest = 0

$path  = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WinRM\Client"
$name  = "AllowDigest"
$value = 0  # 0 = Digest disabled (policy Enabled)

# Create key if missing
if (-not (Test-Path $path)) {
    New-Item -Path $path -Force | Out-Null
}

# Set the DWORD (idempotent)
New-ItemProperty -Path $path -Name $name -PropertyType DWord -Value $value -Force | Out-Null

# Verify (prints hex + decimal)
$current = (Get-ItemProperty -Path $path -Name $name -ErrorAction Stop).$name
"OK: {0}\{1} = 0x{2:X8} ({3})" -f $path, $name, [uint32]$current, [uint32]$current
