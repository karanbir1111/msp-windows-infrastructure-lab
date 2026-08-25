# Screenshot Evidence

Screenshots in this repository are selected as technical evidence. The goal is to prove configuration, validation, troubleshooting, and remediation — not to document every installation click.

## Phase 1 Evidence Set

The Phase 1 evidence demonstrates the progression from a standalone Windows Server to a functioning domain environment with DHCP, DNS, domain authentication, and Group Policy.

1. `01-dc01-server-installed.png` — verifies the Windows Server hostname `DC01`
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
- `04_After_unlocking.png` — before/after comparison showing `LockedOut` change from `True` to `False`
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

Together, the incident evidence follows the same lifecycle: **symptom → diagnosis → root cause → remediation → verification**.

## Repository Convention

Incident case-study documentation lives under `incidents/INC-XXX-.../README.md`.

Visual evidence lives separately under `screenshots/incidents/INC-XXX-.../`.

This keeps the repository easy to browse while allowing each case study to embed its screenshots directly.

## Security Rules

Never include passwords, product keys, API keys, personal email addresses, unrelated private information, or unrelated host files/browser tabs. Evidence should be sanitized before publication.
