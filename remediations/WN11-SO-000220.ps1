<#
.SYNOPSIS
    WN11-SO-000220 requires Windows 11 to enforce strong minimum security for NTLM-based server sessions by requiring NTLMv2
    session security and 128-bit encryption. This reduces the risk of weaker NTLM connections being abused or downgraded during
    network authentication and secure RPC communications.

.NOTES
    Author          : Khang Tran
    LinkedIn        : https://www.linkedin.com/in/khang-tran-622a44163/
    GitHub          : https://github.com/aktran321
    Date Created    : 2/18/2026
    Last Modified   : 2/20/2026
    Version         : 2.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN11-SO-000220

.TESTED ON
    Date(s) Tested  : 2/20/2026
    Tested By       : Khang Tran
    Systems Tested  : Windows 11 Pro
    PowerShell Ver. : 5.1.26100.7705

.USAGE
    Put any usage instructions here.
    Example syntax:
    PS C:\> .\WN11-SO-000220.ps1
#>
# Must run as Administrator
# WN11-SO-000220 "check both boxes" equivalent
$path = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0"
$name = "NTLMMinServerSec"
$value = 0x20080000  # Require NTLMv2 + Require 128-bit

# Create key if missing
if (-not (Test-Path $path)) { New-Item -Path $path -Force | Out-Null }

# Set the DWORD (idempotent)
New-ItemProperty -Path $path -Name $name -PropertyType DWord -Value $value -Force | Out-Null

# Verify
$current = (Get-ItemProperty -Path $path -Name $name).$name
"{0}\{1} = 0x{2:X8} ({3})" -f $path, $name, $current, $current
