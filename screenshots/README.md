# Screenshot Evidence

Screenshots in this repository are selected as technical evidence. The goal is to prove configuration, validation, troubleshooting, and remediation, not to document every installation click.

## Phase 1 Evidence Set

The Phase 1 evidence demonstrates the progression from a standalone Windows Server to a functioning domain environment with DHCP, DNS, domain authentication, and Group Policy.

1. `01.png` — verifies the Windows Server hostname `DC01`
2. `02-dc01-static-network.png` — verifies static `10.10.10.10/24` addressing and DNS configuration
3. `03-ad-ds-dns-installed.png` — shows AD DS and DNS roles available on DC01
4. `04-corp-lab-dns-zone.png` — shows the AD-integrated `corp.lab` DNS zone
5. `05-active-directory-ou-structure.png` — shows the custom OU hierarchy for users, workstations, servers, and groups
6. `06-ad-security-groups.png` — shows `GG-Finance`, `GG-IT`, and `GG-Sales` Global Security groups
7. `07-dhcp-scope.png` — shows the active `10.10.10.100-199` Windows DHCP scope
8. `08-client-network-dhcp.png` — verifies that `WIN11-01` received its address and domain DNS configuration from `DC01`
9. `09-win11-domain-joined.png` — shows `WIN11-01` inside `CORP-Workstations`
10. `10-domain-user-authentication.png` — verifies `corp\amorgan`, logon server `\\DC01`, and expected group membership
11. `11-workstation-gpo.png` — shows the workstation Group Policy configuration
12. `12-gpo-verification.png` — confirms the workstation baseline GPO was applied from `DC01.corp.lab`
13. `13-gpo-logon-notice.png` — visible end-user verification of the enforced logon notice

## Phase 2 Incident Evidence

### INC-001 — Active Directory Account Lockout

Location: `screenshots/incidents/INC-001-account-lockout/`

- `01-account-locked.png` — end-user lockout message on `WIN11-01`
- `02-powershell.png` — PowerShell confirms `Enabled = True` and `LockedOut = True`
- `04_After_unlocking.png` — before / after comparison showing `LockedOut` change from `True` to `False`
- `03.png` — successful post-remediation login confirmed with `whoami = corp\amorgan`

### INC-002 — DNS Misconfiguration / Name-Resolution Failure

Location: `screenshots/incidents/INC-002-dns-failure/`

- `01-wrong-dns-config.png` — shows the client using `8.8.8.8` instead of the domain DNS server
- `02-ip-works-name-fails.png` — proves IP connectivity to `DC01` works while DNS resolution fails
- `03-ad-srv-lookup-fails.png` — demonstrates Active Directory SRV discovery failure
- `04-dns-restored-verified.png` — shows DNS restored to `10.10.10.10` with successful resolution

### INC-003 — DHCP Failure / APIPA

Location: `screenshots/incidents/INC-003-dhcp-apipa/`

- `01-apipa-address.png` — shows `WIN11-01` self-assigned an APIPA address after DHCP lease acquisition failed
- `02-apipa-no-dc-connectivity.png` — shows the APIPA state and loss of connectivity to `DC01`
- `03-dhcp-scope-inactive.png` — identifies the inactive `Corporate Workstations` scope on `DC01`
- `04-dhcp-restored-verified.png` — verifies a valid DHCP lease and restored connectivity after scope reactivation

### INC-004 — Group Policy Application Failure

Location: `screenshots/incidents/INC-004-gpo-failure/`

- `01-gpo-missing.png` — `gpresult` shows the expected workstation baseline is no longer applied
- `02-computer-in-wrong-ou.png` — identifies `WIN11-01` in the default `Computers` container instead of `CORP-Workstations`
- `03-gpo-restored.png` — confirms the workstation GPO applies again after the computer is returned to the correct OU and policy is refreshed

### INC-005 — File Share / NTFS Permission Failure

Location: `screenshots/incidents/INC-005-file-permissions/`

- `01-finance-access-denied.png` — user-facing access-denied symptom for the Finance share
- `02-finance-group-missing.png` — current user token does not contain `CORP\GG-Finance`
- `03-finance-ntfs-permissions.png` — server-side NTFS ACL used to authorize Finance access through the AD security group
- `04-finance-access-restored.png` — verifies successful access after group membership and the user's logon token are refreshed

Together, the incident evidence follows the same lifecycle: **symptom → diagnosis → root cause → remediation → verification**.

## Phase 3 PowerShell Diagnostic & Remediation Evidence

Location: `screenshots/powershell/`

### Active Directory Account Diagnostics and Remediation

- `01-ad-user-diagnostic-healthy.png` — healthy AD account diagnostic for `amorgan`
- `02-ad-user-diagnostic-lockout.png` — diagnostic correctly identifies `LockedOut = True`
- `03-controlled-unlock-confirmation.png` — remediation pauses for explicit technician confirmation before changing account state
- `04-controlled-unlock-success.png` — post-action verification confirms the account was successfully unlocked

### Network Diagnostics and Remediation

- `05-network-diagnostic-healthy.png` — healthy workstation DHCP, DNS, DC connectivity, host resolution, and AD SRV checks
- `06-network-diagnostic-dns-failure.png` — diagnostic isolates an incorrect client DNS configuration while IP connectivity remains available
- `07-network-diagnostic-apipa.png` — diagnostic detects APIPA and identifies likely DHCP lease failure
- `08-network-remediation-dns-confirmation.png` — technician confirmation required before changing client DNS configuration
- `09-network-remediation-dns-success.png` — verification confirms the expected domain DNS server after remediation
- `10-network-remediation-dhcp-success.png` — DHCP renewal restores a valid workstation address after the server-side scope is available again

### Group Policy Diagnostics and Remediation

- `11-gpo-diagnostic-healthy.png` — confirms the expected workstation GPO is applied and the computer object is in the correct OU
- `12-gpo-diagnostic-scope-failure.png` — identifies the workstation outside `CORP-Workstations` and the expected GPO missing
- `13-gpo-remediation-confirmation.png` — requires explicit technician confirmation before moving the AD computer object
- `14-gpo-remediation-success.png` — verifies `WIN11-01` was returned to the expected OU and identifies the required endpoint policy refresh

### File Access Diagnostics and Remediation

- `15-file-access-diagnostic-healthy.png` — correlates healthy `GG-Finance` membership, SMB share state, and NTFS authorization
- `16-file-access-diagnostic-group-missing.png` — identifies missing `GG-Finance` membership while the expected NTFS group authorization remains present
- `17-file-access-remediation-confirmation.png` — requires technician approval before restoring the user's AD security-group membership
- `18-file-access-remediation-success.png` — verifies membership restoration and identifies the need for a fresh user logon token

The PowerShell evidence follows a safe support-engineering pattern: **detect → diagnose → confirm → remediate → verify**.

## Repository Convention

Incident case-study documentation lives under `incidents/INC-XXX-.../README.md`.

Incident visual evidence lives under `screenshots/incidents/INC-XXX-.../`.

PowerShell diagnostic and remediation evidence lives under `screenshots/powershell/`.

PowerShell source code lives under `powershell/diagnostics/` and `powershell/remediation/`.

This keeps case-study documentation, implementation, and evidence separate while making each project phase easy to browse.

## Security Rules

Never include passwords, product keys, API keys, personal email addresses, unrelated private information, or unrelated host files / browser tabs. Evidence should be sanitized before publication.
