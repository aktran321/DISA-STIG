# Debugging tricks in case Tenable scans stop working with your Azure VM.


### Making the VM "Visible" (OS Connectivity)
Windows Enterprise blocks pings and remote management by default. Run these in PowerShell (Admin) on the target VM:

1. Enable Ping (ICMP) - Crucial for Tenable to see the host is alive
```
Enable-NetFirewallRule -DisplayName "File and Printer Sharing (Echo Request - ICMPv4-In)"
```
2. Open SMB (Port 445) - Required for the scanner to log in
```
Enable-NetFirewallRule -DisplayGroup "File and Printer Sharing"
```
3. Open WMI (Port 135) - Required for reading STIG security settings
```
Enable-NetFirewallRule -DisplayGroup "Windows Management Instrumentation (WMI)"
```

### Unlocking Remote Audits (Permissions)

After disabling the windows Firewall and before running the scan, you may have to run the below PowerShell command AS AN ADMIN on your VM in order to enable remote administrative access by modifying the LocalAccountTokenFilterPolicy registry key. This command sets a registry key that allows local accounts (for example, labuser) to connect remotely with full administrative privileges without requiring elevation:

1. Allows Tenable to keep its admin rights when connecting over the network.
```
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "LocalAccountTokenFilterPolicy" -Value 1 -Type DWord -Force
```
2. Enable Remote Registry Service:
STIG audits cannot run if this service is stopped.
```
Set-Service -Name RemoteRegistry -StartupType Automatic
Start-Service -Name RemoteRegistry
```
Step 3: Fix "Restrictive" Tenable Policies
If the scan still takes 1 minute, the Tenable policy itself might be giving up too early.
Disable "Ping the remote host": In Discovery > Host Discovery, turn this OFF. This forces Tenable to try scanning even if it doesn't get a ping back.
