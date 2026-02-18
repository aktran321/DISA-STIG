# DISA-STIG
This repository is for practice in implementing DISA STIG guidelines. Security Technical Implementation Guides (STIGs) are configuration standards developed by the Defense Information Systems Agency (DISA). They are designed to lockdown Department of Defence (DoD) systems, reduing cyber risks and ensuring compliance with federal requirements.

## Initial Setup
- Create a Windows 11 Virtual Machine (VM)
- Add custom sign in credentials
- Configure the VM's network security group to allow inbound traffic from the Private Tenable Scanner
![plugin checks](/disa-stig/vm-nsg-open.png)
- Connect to the VM and turn off Windows Firewall
![plugin checks](/disa-stig/firewall-off.png)

- Login to Tenable and configure an advanced scan for Windows 11
![plugin checks](/disa-stig/advanced-template-setup.png)
- add a Windows credential (same credentials used to create the VM)
- Make sure to enable all switches for the Credential Type Settings, as this allows the scanner to scan the VM thoroughly.
![plugin checks](/disa-stig/credential-switches.png)

- Add "DISA Microsoft Windows 11 STIG v2rf" in the compliance section
![plugin checks](/disa-stig/DISA-Win11.png)
- For faster scanning, uncheck all plugins except for "Windows Compliance Checks"
![plugin checks](/disa-stig/plugin-checks.png)

- Launch scan and notice numerous audit fails
![plugin checks](/disa-stig/audit-fails.png)

At this point, we can look through the flags and begin remediating the VM first manually, and then programmatically with PowerShell.
