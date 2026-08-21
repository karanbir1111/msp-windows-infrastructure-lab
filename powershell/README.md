# PowerShell Automation

PowerShell automation will be added only after the corresponding task or incident has first been understood and validated manually.

## Planned Automation Areas

### Diagnostics
- Active Directory user/account status
- DNS resolution and client configuration
- DHCP/IP configuration indicators
- Domain-controller connectivity
- Group Policy result collection
- Windows service status
- Basic network connectivity

### Controlled Remediation
Potential remediation actions will require technician confirmation where changes affect users or system configuration.

Examples may include:
- Unlocking an approved AD user account
- Refreshing Group Policy
- Restarting an approved Windows service
- Renewing DHCP configuration

### Reporting
The project will ultimately generate consistent diagnostic output suitable for inclusion in an MSP-style ticket or knowledge-base entry.

> Automation is not intended to replace troubleshooting. It is intended to make known, repetitive diagnostic and remediation workflows faster and more consistent.