# Incident Case Studies

This folder contains five MSP-style Windows support incidents built from a healthy `corp.lab` baseline.

Each case study follows the same operational structure:

**problem → symptoms → investigation → root cause → resolution → verification → automation / prevention notes**

## Completed Incidents

### INC-001 — Active Directory Account Lockout ✅

A Finance user was locked out after repeated invalid password attempts. The incident demonstrates account-state validation, lockout diagnosis, manual remediation, and post-fix authentication verification.

Case study: [`INC-001-account-lockout/README.md`](INC-001-account-lockout/README.md)

Automation:
- [`../powershell/diagnostics/Get-ADUserDiagnostic.ps1`](../powershell/diagnostics/Get-ADUserDiagnostic.ps1)
- [`../powershell/remediation/Unlock-ADUserSafe.ps1`](../powershell/remediation/Unlock-ADUserSafe.ps1)

### INC-002 — DNS Misconfiguration / Name-Resolution Failure ✅

The workstation retained IP connectivity while internal Active Directory name resolution and SRV discovery failed because the client was configured with the wrong DNS server.

Case study: [`INC-002-dns-failure/README.md`](INC-002-dns-failure/README.md)

Automation:
- [`../powershell/diagnostics/Get-NetworkDiagnostics.ps1`](../powershell/diagnostics/Get-NetworkDiagnostics.ps1)
- [`../powershell/remediation/Repair-NetworkClient.ps1`](../powershell/remediation/Repair-NetworkClient.ps1)

### INC-003 — DHCP Failure / APIPA ✅

The Windows DHCP scope was deliberately deactivated, causing the workstation to self-assign an APIPA address and lose domain-controller connectivity.

Case study: [`INC-003-dhcp-apipa/README.md`](INC-003-dhcp-apipa/README.md)

Automation:
- [`../powershell/diagnostics/Get-NetworkDiagnostics.ps1`](../powershell/diagnostics/Get-NetworkDiagnostics.ps1)
- [`../powershell/remediation/Repair-NetworkClient.ps1`](../powershell/remediation/Repair-NetworkClient.ps1)

### INC-004 — Group Policy Application Failure ✅

A workstation remained domain-joined but stopped receiving the expected workstation baseline after its computer object was moved outside the GPO-linked OU.

Case study: [`INC-004-gpo-failure/README.md`](INC-004-gpo-failure/README.md)

Automation:
- [`../powershell/diagnostics/Get-GPODiagnostic.ps1`](../powershell/diagnostics/Get-GPODiagnostic.ps1)
- [`../powershell/remediation/Repair-GPOComputerScope.ps1`](../powershell/remediation/Repair-GPOComputerScope.ps1)

### INC-005 — File Share / NTFS Permission Failure ✅

A Finance user could reach the file server but could not access the Finance share after losing the AD security-group membership required by the NTFS authorization model.

Case study: [`INC-005-file-permissions/README.md`](INC-005-file-permissions/README.md)

Automation:
- [`../powershell/diagnostics/Get-FileAccessDiagnostic.ps1`](../powershell/diagnostics/Get-FileAccessDiagnostic.ps1)
- [`../powershell/remediation/Repair-FileAccessGroup.ps1`](../powershell/remediation/Repair-FileAccessGroup.ps1)

## Ticket / Knowledge Base Standard

The case studies are intended to model documentation that can be handed to another technician. A reusable ticket and knowledge-base template is available here:

[`../documentation/TICKET-TEMPLATE.md`](../documentation/TICKET-TEMPLATE.md)

The template captures business impact, symptoms, environment, investigation, root cause, resolution, verification, and automation / prevention notes.

## Evidence

Incident screenshots are stored separately under:

```text
screenshots/incidents/
```

PowerShell diagnostic and controlled remediation evidence is stored under:

```text
screenshots/powershell/
```

See [`../screenshots/README.md`](../screenshots/README.md) for the complete evidence index.

## Project Status

All five incident case studies, PowerShell diagnostics, controlled remediation workflows, and ticket-style documentation are complete.
