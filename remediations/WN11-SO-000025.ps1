<#
.SYNOPSIS
    This PowerShell script ensures STIG WN11-SO-000025 is satisfied. The built-in Guest account must be renamed.

.NOTES
    Author          : Khang Tran
    LinkedIn        : https://www.linkedin.com/in/khang-tran-622a44163/
    GitHub          : https://github.com/aktran321
    Date Created    : 2/21/2026
    Last Modified   : 2/21/2026
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN11-SO-000025

.TESTED ON
    Date(s) Tested  : 2/21/2026
    Tested By       : Khang Tran
    Systems Tested  : Windows 11 Pro
    PowerShell Ver. : 5.1.26100.7705

.USAGE
    Put any usage instructions here.
    Example syntax:
    PS C:\> .\WN11-SO-000025.ps1
#>
# WN11-SO-000025 - Rename built-in Guest account (SID ...-501)
# Works without Get-LocalUser

$NewGuestName = "svc_guest_disabled"   # <-- change to your desired non-obvious name

# Find built-in Guest by SID ending in -501
$acct = Get-CimInstance Win32_UserAccount -Filter "LocalAccount=True" |
        Where-Object { $_.SID -match '-501$' } |
        Select-Object -First 1

if (-not $acct) { throw "Built-in Guest account (SID -501) not found." }

$oldName = $acct.Name
Write-Host "Found Guest account: $oldName (SID $($acct.SID))"

# Rename the account (NET works even when LocalAccounts module is missing)
cmd.exe /c "net user `"$oldName`" `"$NewGuestName`""

# Update Local Security Policy label so 'Accounts: Rename guest account' matches
$inf = @"
[Unicode]
Unicode=yes
[Version]
signature="\$CHICAGO\$"
Revision=1
[System Access]
NewGuestName=$NewGuestName
"@

$cfg = Join-Path $env:TEMP "WN11-SO-000025.inf"
$db  = Join-Path $env:TEMP "secedit.sdb"
$inf | Set-Content -Path $cfg -Encoding Unicode
secedit /configure /db $db /cfg $cfg /areas SECURITYPOLICY | Out-Null

# Verify
$new = (Get-CimInstance Win32_UserAccount -Filter "LocalAccount=True" | Where-Object { $_.SID -match '-501$' }).Name
Write-Host "Now Guest (-501) is named: $new"
