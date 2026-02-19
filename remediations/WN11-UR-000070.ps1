<#
.SYNOPSIS
    This PowerShell script ensures that we deny access to this computer from the network. This denies access from higher privileged domain accounts and 
    unauthenticated access on all systems. Attackers commonly try to compromise high privileged domain accounts and move laterally to take over other workstations.

.NOTES
    Author          : Khang Tran
    LinkedIn        : https://www.linkedin.com/in/khang-tran-622a44163/
    GitHub          : https://github.com/aktran321
    Date Created    : 2/18/2026
    Last Modified   : 2/18/2026
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN11-UR-000070

.TESTED ON
    Date(s) Tested  : 2/18/2026
    Tested By       : Khang Tran
    Systems Tested  : Windows 11 Pro
    PowerShell Ver. : 5.1.26100.7705

.USAGE
    Put any usage instructions here.
    Example syntax:
    PS C:\> .\WN11-UR-000070.ps1
#>


# Run as Administrator
$inf = "$env:TEMP\apply.inf"
$db  = "$env:TEMP\secedit.sdb"
$right = 'SeDenyNetworkLogonRight'

# Always required
$guests = '*S-1-5-32-546'   # Builtin\Guests

# Detect domain join
$cs = Get-CimInstance Win32_ComputerSystem
$domainJoined = [bool]$cs.PartOfDomain

if ($domainJoined) {
    # Get domain SID and build SIDs for DA/EA
    $domainSid = (Get-CimInstance Win32_UserAccount -Filter "LocalAccount=False" |
        Select-Object -First 1 -ExpandProperty SID) -replace '-\d+$',''

    $domainAdmins     = "*$domainSid-512"
    $enterpriseAdmins = "*$domainSid-519"
    $localAccount     = '*S-1-5-113'   # Local account group

    $value = "$guests,$domainAdmins,$enterpriseAdmins,$localAccount"
} else {
    $value = $guests
}

@"
[Unicode]
Unicode=yes
[Version]
signature="`$CHICAGO`$"
Revision=1
[Privilege Rights]
$right = $value
"@ | Set-Content -Path $inf -Encoding Unicode

secedit /configure /db $db /cfg $inf /areas USER_RIGHTS /quiet
gpupdate /target:computer /force | Out-Null

Write-Host "Done: Set '$right' to: $value" -ForegroundColor Green
