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
8. `08-client-network-dhcp.png` — verifies that `WIN11-01` received `10.10.10.100` from DHCP server `10.10.10.10`, uses DNS `10.10.10.10`, and received the `corp.lab` DNS suffix
9. `09-win11-domain-joined.png` — shows `WIN11-01` inside `CORP-Workstations`
10. `10-domain-user-authentication.png` — verifies `corp\amorgan`, logon server `\\DC01`, and `CORP\GG-Finance` membership
11. `11-workstation-gpo.png` — shows the workstation Group Policy configuration
12. `12-gpo-verification.png` — `gpresult` confirms the workstation baseline GPO was applied from `DC01.corp.lab`
13. `13-gpo-logon-notice.png` — visible end-user verification of the enforced logon notice

## Why `08-client-network-dhcp.png` Matters

This screenshot provides an important end-to-end validation point. Rather than manually assigning the client configuration, the workstation received it from the Windows Server DHCP service:

```text
WIN11-01
  IPv4:       10.10.10.100
  DHCP:       10.10.10.10
  DNS:        10.10.10.10
  DNS suffix: corp.lab
```

That proves the Windows Server DHCP scope and options are functioning and gives the client the DNS configuration required for Active Directory operations.

## Phase 2 Evidence Standard

Incident screenshots will be grouped by incident and will normally include only:

1. **Symptom / failed state**
2. **Diagnostic evidence / root cause**
3. **Post-remediation verification**

This keeps the repository readable and makes each incident understandable to someone reviewing the project without access to the lab.

## Security Rules

Never include:
- passwords
- product keys
- API keys or tokens
- personal email addresses
- private information unrelated to the isolated lab
- unrelated host files, browser tabs, or account information

Evidence should be sanitized before publication.