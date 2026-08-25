# MSP Windows Infrastructure Troubleshooting & Automation Lab

A hands-on Windows infrastructure lab designed to simulate the type of work performed in a small MSP environment: building and supporting a Windows domain, validating core services, troubleshooting realistic incidents, documenting root cause, and identifying safe opportunities for PowerShell automation.

## Why This Project Exists

The goal is not simply to install Active Directory. The lab is built around a support workflow:

1. Establish a known-good Windows infrastructure baseline.
2. Validate each dependency independently: networking, DNS, DHCP, authentication, and Group Policy.
3. Introduce realistic user and infrastructure incidents.
4. Troubleshoot from symptoms to root cause rather than applying random fixes.
5. Verify the resolution from the end-user perspective.
6. Automate repetitive diagnostic/remediation steps only after the manual process is understood.

## Environment

- Oracle VirtualBox
- Windows Server 2025 Evaluation — `DC01`
- Windows 11 Enterprise Evaluation — `WIN11-01`
- Active Directory Domain Services (AD DS)
- DNS
- DHCP
- Group Policy
- Windows networking
- PowerShell for validation and later automation

## Lab Network

| Component | Configuration |
| --- | --- |
| Active Directory domain | `corp.lab` |
| Lab subnet | `10.10.10.0/24` |
| VirtualBox host-only adapter | `10.10.10.1` |
| Domain Controller / DNS / DHCP | `DC01` — `10.10.10.10` |
| Windows client | `WIN11-01` — DHCP |
| DHCP scope | `10.10.10.100-199` |
| Client DNS | `10.10.10.10` |

## Phase 1 — Healthy Infrastructure Baseline ✅

A functioning Windows domain environment has been built, validated, and preserved as a known-good baseline before incident simulation.

### Domain Controller and Core Services

`DC01` was configured with a static `10.10.10.10/24` address and promoted as the first domain controller for `corp.lab`. The server also hosts Active Directory-integrated DNS and the Windows DHCP service.

![DC01 AD DS and DNS](screenshots/03-ad-ds-dns-installed.png)

The `corp.lab` DNS zone is hosted on `DC01`, providing the name-resolution foundation required by Active Directory clients.

![corp.lab DNS zone](screenshots/04-corp-lab-dns-zone.png)

### Active Directory Organization

The directory was organized into purpose-specific OUs for users, workstations, servers, and security groups.

```text
corp.lab
├── CORP-Users
│   ├── Finance
│   ├── IT
│   └── Sales
├── CORP-Workstations
│   └── WIN11-01
├── CORP-Servers
└── CORP-Groups
    ├── GG-Finance
    ├── GG-IT
    └── GG-Sales
```

![Active Directory OU structure](screenshots/05-active-directory-ou-structure.png)

![Active Directory security groups](screenshots/06-ad-security-groups.png)

### DHCP and Client Network Configuration

Windows Server DHCP was authorized in Active Directory and configured with the workstation scope `10.10.10.100-199`.

![Windows DHCP scope](screenshots/07-dhcp-scope.png)

`WIN11-01` received its network configuration dynamically from `DC01`, including domain DNS.

![WIN11-01 DHCP and DNS configuration](screenshots/08-client-network-dhcp.png)

### Domain Join and Authentication

`WIN11-01` was joined to `corp.lab` and moved into `CORP-Workstations`.

![WIN11-01 domain joined](screenshots/09-win11-domain-joined.png)

Domain authentication was validated using the Finance test account `CORP\amorgan` against `\\DC01` with expected security-group membership.

![Domain user authentication](screenshots/10-domain-user-authentication.png)

### Group Policy

A workstation GPO named `CORP Workstation Security Baseline` was linked to `CORP-Workstations`.

![Workstation GPO configuration](screenshots/11-workstation-gpo.png)

`gpresult` confirmed the policy was applied from `DC01.corp.lab`, and a legal logon notice provided visible end-user verification.

![GPO verification](screenshots/12-gpo-verification.png)

![GPO logon notice](screenshots/13-gpo-logon-notice.png)

Healthy-state VirtualBox snapshots were created for both VMs before deliberate incident simulation.

## Phase 2 — MSP Incident Simulation 🔧

### INC-001 — Active Directory Account Lockout ✅

A Finance user was unable to sign in after repeated incorrect password attempts.

![Account lockout symptom](screenshots/incidents/INC-001-account-lockout/01-account-locked.png)

PowerShell confirmed the account was still enabled but had `LockedOut = True`, isolating the issue to the lockout state.

![PowerShell lockout diagnosis](screenshots/incidents/INC-001-account-lockout/02-powershell.png)

After remediation, the account state changed to unlocked and the user successfully authenticated again.

![Account state after unlock](screenshots/incidents/INC-001-account-lockout/04_After_unlocking.png)

![Successful login after remediation](screenshots/incidents/INC-001-account-lockout/03.png)

**Root cause:** the user exceeded the domain invalid-logon threshold.  
**Resolution:** manually unlock the account after validation.  
**Verification:** confirm `LockedOut = False` and successful sign-in.  
**Automation opportunity:** build a PowerShell user-diagnostic workflow for account state and controlled remediation.

Full case study: [`incidents/INC-001-account-lockout/README.md`](incidents/INC-001-account-lockout/README.md)

### INC-002 — DNS Misconfiguration / Name-Resolution Failure ✅

`WIN11-01` retained valid IP connectivity but was intentionally configured to use `8.8.8.8` instead of the Active Directory DNS server `10.10.10.10`.

![Wrong DNS configuration](screenshots/incidents/INC-002-dns-failure/01-wrong-dns-config.png)

The workstation could still reach `DC01` by IP, while `DC01.corp.lab` failed to resolve. This isolated the problem to DNS rather than general network connectivity.

![IP works while DNS fails](screenshots/incidents/INC-002-dns-failure/02-ip-works-name-fails.png)

An Active Directory LDAP SRV lookup also failed, demonstrating that the misconfiguration affected domain service discovery, not only host-name resolution.

![AD SRV lookup failure](screenshots/incidents/INC-002-dns-failure/03-ad-srv-lookup-fails.png)

DNS was restored to DHCP-provided configuration, the resolver cache was flushed, the lease was refreshed, and internal DNS resolution succeeded again.

![DNS restored and verified](screenshots/incidents/INC-002-dns-failure/04-dns-restored-verified.png)

**Root cause:** the client was using a public resolver that had no knowledge of the private `corp.lab` namespace.  
**Resolution:** restore DHCP-provided DNS (`10.10.10.10`) and refresh client DNS state.  
**Verification:** confirm internal host lookup and AD SRV discovery succeed.  
**Automation opportunity:** build a PowerShell network diagnostic that compares expected DNS configuration, tests DC reachability, resolves internal names, and checks AD SRV records.

Full case study: [`incidents/INC-002-dns-failure/README.md`](incidents/INC-002-dns-failure/README.md)

### INC-003 — DHCP Failure / APIPA ✅

`WIN11-01` was unable to obtain a DHCP lease after the `Corporate Workstations` scope on `DC01` was intentionally deactivated. Windows fell back to an APIPA address in the `169.254.0.0/16` range.

![APIPA address](screenshots/incidents/INC-003-dhcp-apipa/01-apipa-address.png)

The client remained configured for DHCP but could no longer reach the domain controller because it did not have a valid address on the `10.10.10.0/24` lab subnet.

![APIPA and failed DC connectivity](screenshots/incidents/INC-003-dhcp-apipa/02-apipa-no-dc-connectivity.png)

Server-side investigation identified the inactive DHCP scope as the root cause.

![Inactive DHCP scope](screenshots/incidents/INC-003-dhcp-apipa/03-dhcp-scope-inactive.png)

The scope was reactivated and the client lease was renewed. `WIN11-01` returned to a valid DHCP configuration and connectivity to `DC01` was restored.

![DHCP restored and verified](screenshots/incidents/INC-003-dhcp-apipa/04-dhcp-restored-verified.png)

**Root cause:** the Windows DHCP scope serving the workstation subnet was inactive.  
**Resolution:** reactivate the scope and renew the client DHCP lease.  
**Verification:** confirm a valid `10.10.10.x` lease and restored connectivity to `DC01`.  
**Automation opportunity:** build PowerShell diagnostics that detect APIPA, inspect DHCP/DNS configuration, test DC reachability, and check server-side DHCP scope state.

Full case study: [`incidents/INC-003-dhcp-apipa/README.md`](incidents/INC-003-dhcp-apipa/README.md)

## Project Roadmap

1. **Infrastructure Baseline** — ✅ Complete
2. **INC-001: AD Account Lockout** — ✅ Complete
3. **INC-002: DNS / Name Resolution Failure** — ✅ Complete
4. **INC-003: DHCP Failure / APIPA** — ✅ Complete
5. **INC-004: Group Policy Failure** — Next
6. **INC-005: File-Share / Permission Issue** — Planned
7. **PowerShell Diagnostics** — Planned
8. **Controlled Remediation** — Planned
9. **Ticket-Style Reporting / Knowledge Base** — Planned

## Repository Structure

```text
msp-windows-infrastructure-lab/
├── architecture/        # network and infrastructure diagrams
├── documentation/       # build notes and technical explanations
├── incidents/           # one README case study per incident
├── powershell/          # future diagnostics and remediation automation
└── screenshots/
    ├── phase-1 evidence
    └── incidents/       # visual evidence grouped by incident ID
```

Incident documentation and screenshot evidence are deliberately separated: `incidents/` explains the troubleshooting process, while `screenshots/incidents/` stores the visual evidence referenced by each case study.

## Documentation Philosophy

Every incident follows the same operational pattern:

**Problem → Symptoms → Investigation → Root Cause → Resolution → Verification → Automation Opportunity**

This keeps the repository focused on support engineering, root-cause analysis, and repeatable troubleshooting rather than documenting every installation click.

## Security

This repository contains only isolated lab configuration and sanitized evidence. Passwords, product keys, tokens, personal information, and unrelated host-system information are never committed.
