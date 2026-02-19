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
    Last Modified   : 2/18/2026
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN11-SO-000220

.TESTED ON
    Date(s) Tested  : 2/18/2026
    Tested By       : Khang Tran
    Systems Tested  : Windows 11 Pro
    PowerShell Ver. : 5.1.26100.7705

.USAGE
    Put any usage instructions here.
    Example syntax:
    PS C:\> .\WN11-SO-000220.ps1
#>


# WN11-SO-000220 - Minimum session security for NTLM SSP based (secure RPC) servers
# Requires: NTLMMinServerSec = 0x20080000

# Must run as Administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Run as Administrator." -ForegroundColor Red
    exit 1
}

$RegPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0"
$ValueName = "NTLMMinServerSec"
$DesiredValue = 0x20080000  # 537395200

# Create key if missing
if (-not (Test-Path $RegPath)) {
    New-Item -Path $RegPath -Force | Out-Null
}

# Set required value
New-ItemProperty -Path $RegPath -Name $ValueName -PropertyType DWord -Value $DesiredValue -Force | Out-Null

# Show result
$current = (Get-ItemProperty -Path $RegPath -Name $ValueName).$ValueName
Write-Host "NTLMMinServerSec is now set to: 0x$('{0:X8}' -f $current) ($current)" -ForegroundColor Green
