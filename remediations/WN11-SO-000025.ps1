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
# Rename the built-in Guest (SID ...-501) AND set Local Security Policy NewGuestName

$NewGuestName = "svc_guest_disabled"  # <-- change this

# --- 1) Rename the actual local account (SID ends with -501) ---
$guest = Get-LocalUser | Where-Object { $_.SID.Value -match '-501$' }
if (-not $guest) { throw "Built-in Guest account (SID -501) not found." }

if ($guest.Name -ne $NewGuestName) {
    # Ensure target name not already taken
    if (Get-LocalUser -Name $NewGuestName -ErrorAction SilentlyContinue) {
        throw "Target name '$NewGuestName' already exists."
    }
    Rename-LocalUser -Name $guest.Name -NewName $NewGuestName
}

# --- 2) Set the Local Security Policy so Tenable/GP UI reflects the rename ---
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

# Verify: show the -501 account name now
(Get-LocalUser | Where-Object { $_.SID.Value -match '-501$' }).Name
