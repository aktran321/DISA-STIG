<#
.SYNOPSIS
    This PowerShell script ensures STIG WN11-SO-000025 is satisfied. The built-in Guest account must be renamed.

.NOTES
    Author          : Khang Tran
    LinkedIn        : https://www.linkedin.com/in/khang-tran-622a44163/
    GitHub          : https://github.com/aktran321
    Date Created    : 2/21/2026
    Last Modified   : 2/22/2026
    Version         : 2.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN11-SO-000025

.TESTED ON
    Date(s) Tested  : 2/22/2026
    Tested By       : Khang Tran
    Systems Tested  : Windows 11 Pro
    PowerShell Ver. : 5.1.26100.7705

.USAGE
    Put any usage instructions here.
    Example syntax:
    PS C:\> .\WN11-SO-000025.ps1
#>
<#
.SYNOPSIS
  WN11-SO-000025 - The built-in Guest account must be renamed.

.DESCRIPTION
  Renames the local built-in Guest account (SID ending in -501) to a non-obvious name.
  Uses Rename-LocalUser if available; otherwise falls back to ADSI (WinNT provider).
  Updates local security policy display name via secedit (NewGuestName).

.REQUIRES
  Run as Administrator
#>

# ---------------------------
# Admin check
# ---------------------------
$IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
          ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $IsAdmin) {
  Write-Host "ERROR: Run this script in an elevated (Administrator) PowerShell session." -ForegroundColor Red
  exit 1
}

# ---------------------------
# Choose new name
# ---------------------------
$NewGuestName = "newwwname"   # <-- change this

# ---------------------------
# Find built-in Guest by SID (-501)
# ---------------------------
$acct = Get-CimInstance Win32_UserAccount -Filter "LocalAccount=True" |
        Where-Object { $_.SID -match '-501$' } |
        Select-Object -First 1

if (-not $acct) { throw "Built-in Guest account (SID -501) not found." }

$oldName = $acct.Name
Write-Host "Found built-in Guest: $oldName (SID $($acct.SID))"

if ($oldName -eq $NewGuestName) {
  Write-Host "No change needed: already named '$NewGuestName'." -ForegroundColor Yellow
} else {

  # Prevent collisions
  $nameTaken = Get-CimInstance Win32_UserAccount -Filter "LocalAccount=True" |
               Where-Object { $_.Name -ieq $NewGuestName } |
               Select-Object -First 1
  if ($nameTaken) { throw "Target name '$NewGuestName' already exists. Pick a different name." }

  $renamed = $false

  # ---------------------------
  # Method 1: Rename-LocalUser (if module is available)
  # ---------------------------
  if (Get-Command Rename-LocalUser -ErrorAction SilentlyContinue) {
    try {
      Rename-LocalUser -Name $oldName -NewName $NewGuestName
      $renamed = $true
      Write-Host "Renamed using Rename-LocalUser." -ForegroundColor Green
    } catch {
      Write-Host "Rename-LocalUser failed, falling back... $($_.Exception.Message)" -ForegroundColor Yellow
    }
  }

  # ---------------------------
  # Method 2: ADSI WinNT provider (works broadly)
  # ---------------------------
  if (-not $renamed) {
    try {
      $computer = $env:COMPUTERNAME
      $user = [ADSI]"WinNT://$computer/$oldName,user"
      $user.psbase.Rename($NewGuestName)
      $user.psbase.CommitChanges()
      $renamed = $true
      Write-Host "Renamed using ADSI (WinNT provider)." -ForegroundColor Green
    } catch {
      throw "Failed to rename Guest account using ADSI. $($_.Exception.Message)"
    }
  }
}

# ---------------------------
# Update Local Security Policy label (Accounts: Rename guest account)
# ---------------------------
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

# ---------------------------
# Verify
# ---------------------------
$new = (Get-CimInstance Win32_UserAccount -Filter "LocalAccount=True" |
        Where-Object { $_.SID -match '-501$' } |
        Select-Object -ExpandProperty Name)

Write-Host "Now built-in Guest (-501) is named: $new" -ForegroundColor Cyan

if ($new -ne $NewGuestName) {
  Write-Host "WARNING: Rename did not take effect. Reboot and re-check, or confirm no domain policy is reverting it." -ForegroundColor Yellow
  exit 2
}

Write-Host "SUCCESS: WN11-SO-000025 satisfied (Guest renamed)." -ForegroundColor Green
exit 0
