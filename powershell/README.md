# PowerShell Diagnostics & Controlled Remediation

This phase converts the troubleshooting patterns from the five manual incident case studies into reusable support tooling.

The design follows a simple service-desk principle:

**detect → diagnose → confirm → remediate → verify**

Read-only diagnostics are separated from configuration-changing remediation scripts. Remediation scripts validate the target state, stop when no change is required, and require technician confirmation before making supported changes.

## Repository Structure

```text
powershell/
├── diagnostics/
│   ├── Get-ADUserDiagnostic.ps1
│   ├── Get-NetworkDiagnostics.ps1
│   ├── Get-GPODiagnostic.ps1
│   └── Get-FileAccessDiagnostic.ps1
└── remediation/
    ├── Unlock-ADUserSafe.ps1
    ├── Repair-NetworkClient.ps1
    ├── Repair-GPOComputerScope.ps1
    └── Repair-FileAccessGroup.ps1
```

## Diagnostics

### Get-ADUserDiagnostic.ps1

Supports INC-001 by collecting account state and group membership for an Active Directory user.

Checks include:

- enabled / disabled state
- lockout state
- password expiration
- password and bad-password timestamps
- last logon information
- distinguished name
- security-group membership

Example:

```powershell
.\Get-ADUserDiagnostic.ps1 -Username amorgan
```

### Get-NetworkDiagnostics.ps1

Supports INC-002 and INC-003 by checking workstation IP, DHCP, DNS, domain-controller reachability, internal name resolution, and Active Directory SRV discovery.

The script identifies common client-side conditions such as:

- APIPA addressing
- missing or incorrect domain DNS
- failed DC connectivity
- failed internal host lookup
- failed LDAP SRV lookup

Example:

```powershell
.\Get-NetworkDiagnostics.ps1
```

### Get-GPODiagnostic.ps1

Supports INC-004 by comparing workstation Group Policy results and the computer object's Active Directory location with the expected management scope.

The script distinguishes between:

- a computer object outside the expected OU
- an expected GPO missing despite correct OU placement
- a healthy GPO scope and application state

Example:

```powershell
.\Get-GPODiagnostic.ps1
```

### Get-FileAccessDiagnostic.ps1

Supports INC-005 by correlating Active Directory group membership, SMB share existence / permissions, and NTFS authorization.

Example:

```powershell
.\Get-FileAccessDiagnostic.ps1 -Username amorgan
```

The default lab model expects `amorgan` to receive Finance access through `GG-Finance` rather than an individual NTFS assignment.

## Controlled Remediation

### Unlock-ADUserSafe.ps1

Validates that the account exists, is enabled, and is actually locked before asking the technician to approve the unlock. The script then rechecks `LockedOut` to verify the action.

```powershell
.\Unlock-ADUserSafe.ps1 -Username amorgan
```

### Repair-NetworkClient.ps1

Handles supported client-side DNS and DHCP recovery. It identifies the detected condition, requires confirmation, applies the supported change, and reports the post-change IP and DNS state.

```powershell
.\Repair-NetworkClient.ps1
```

The script intentionally does not reactivate a server-side DHCP scope automatically. Higher-impact server changes remain separate administrative actions.

### Repair-GPOComputerScope.ps1

Runs on the domain controller and restores a workstation computer object to the expected `CORP-Workstations` OU after explicit technician confirmation.

```powershell
.\Repair-GPOComputerScope.ps1 -ComputerName WIN11-01
```

After the AD object is moved, the workstation still requires Group Policy refresh and normal endpoint verification.

### Repair-FileAccessGroup.ps1

Restores the expected group-based authorization path by adding an approved user back to the required AD security group after confirmation.

```powershell
.\Repair-FileAccessGroup.ps1 -Username amorgan
```

The script explicitly reminds the technician that the user must establish a fresh logon session so the new group membership is included in the user's security token.

## Safety Model

The remediation scripts are deliberately narrow. They do not attempt broad automatic repair or silently alter unrelated configuration.

Common safeguards include:

- validate the target object or adapter first
- report the current state before changing it
- stop when remediation is unnecessary
- require explicit `YES` confirmation for supported changes
- re-query the system after the action
- return a clear success, warning, cancellation, or failure result

This is intended to model controlled MSP support automation rather than one-click configuration changes.

## Evidence

Execution evidence is stored under:

```text
screenshots/powershell/
```

The evidence set includes healthy diagnostics, reproduced failures, technician confirmation prompts, and post-remediation verification for Active Directory, networking, Group Policy, and file authorization.

See [`../screenshots/README.md`](../screenshots/README.md) for the evidence index.

## Ticket / Knowledge Base Workflow

The same output can be summarized into a consistent MSP ticket format:

**business impact → symptoms → investigation → root cause → resolution → verification → automation / prevention notes**

A reusable template is available at [`../documentation/TICKET-TEMPLATE.md`](../documentation/TICKET-TEMPLATE.md).

Automation in this lab does not replace troubleshooting. It codifies troubleshooting paths that were first reproduced, diagnosed, remediated, and verified manually.
