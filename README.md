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

### 1. Domain Controller and Core Services

`DC01` was configured with a static `10.10.10.10/24` address and promoted as the first domain controller for `corp.lab`. The server also hosts Active Directory-integrated DNS and the Windows DHCP service.

![DC01 AD DS and DNS](screenshots/03-ad-ds-dns-installed.png)

The `corp.lab` DNS zone is hosted on `DC01`, providing the name-resolution foundation required by Active Directory clients.

![corp.lab DNS zone](screenshots/04-corp-lab-dns-zone.png)

### 2. Active Directory Organization

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

Departmental Global Security groups were created to support authorization, future file-share permissions, and incident scenarios.

![Active Directory security groups](screenshots/06-ad-security-groups.png)

### 3. DHCP and Client Network Configuration

Windows Server DHCP was authorized in Active Directory and configured with the workstation scope `10.10.10.100-199`.

![Windows DHCP scope](screenshots/07-dhcp-scope.png)

`WIN11-01` then received its configuration dynamically from `DC01`, rather than being manually assigned:

- IPv4 address: `10.10.10.100`
- Subnet mask: `255.255.255.0`
- DHCP server: `10.10.10.10`
- DNS server: `10.10.10.10`
- DNS suffix: `corp.lab`

![WIN11-01 DHCP and DNS configuration](screenshots/08-client-network-dhcp.png)

This is an important validation point because it proves that the Windows DHCP service is providing the client configuration required for domain communication and DNS-based Active Directory discovery.

### 4. Domain Join and Authentication

`WIN11-01` was joined to `corp.lab` and moved into the `CORP-Workstations` OU.

![WIN11-01 domain joined](screenshots/09-win11-domain-joined.png)

Domain authentication was then validated using the Finance test account `CORP\amorgan`. The workstation authenticated against `\\DC01`, and the user's `CORP\GG-Finance` membership appeared in the Windows security token.

![Domain user authentication](screenshots/10-domain-user-authentication.png)

This demonstrates not only a successful domain join, but also working domain authentication and expected authorization-group membership.

### 5. Group Policy

A workstation GPO named `CORP Workstation Security Baseline` was configured and linked to `CORP-Workstations`.

![Workstation GPO configuration](screenshots/11-workstation-gpo.png)

`gpresult /scope computer /r` confirmed that the policy was applied to `WIN11-01` from `DC01.corp.lab`.

![GPO verification](screenshots/12-gpo-verification.png)

A legal logon notice provided visible end-user confirmation that the Group Policy setting was actually enforced.

![GPO logon notice](screenshots/13-gpo-logon-notice.png)

### 6. Recovery Baseline

Healthy-state VirtualBox snapshots were created for both VMs after AD DS, DNS, DHCP, domain authentication, and Group Policy were verified. This allows later troubleshooting scenarios to be introduced safely while preserving a known-good recovery point.

## Phase 2 — MSP Incident Simulation 🔧

Phase 2 uses realistic support tickets to practice structured troubleshooting from symptom to root cause.

### INC-001 — Active Directory Account Lockout

The first incident simulates a Finance user being unable to sign in after repeated invalid password attempts. The workflow includes:

- confirming workstation connectivity and domain reachability,
- checking the user's Active Directory state,
- distinguishing an enabled account from a locked account,
- manually unlocking the user after validation,
- verifying successful authentication from `WIN11-01`, and
- identifying the workflow as a future PowerShell diagnostic/remediation opportunity.

The incident documentation is being maintained under `incidents/INC-001-account-lockout/`. Supporting incident screenshots will be added once the before/after evidence set is finalized.

## Project Roadmap

1. **Infrastructure Baseline** — ✅ Complete
2. **Incident Simulation** — 🔧 In progress
3. **Root-Cause Documentation** — 🔧 In progress
4. **PowerShell Diagnostics** — Planned
5. **Controlled Remediation** — Planned
6. **Ticket-Style Reporting / Knowledge Base** — Planned

## Repository Structure

- `architecture/` — network and infrastructure diagrams
- `documentation/` — build notes and technical explanations
- `incidents/` — incident tickets, investigation, root cause, resolution, and verification
- `powershell/` — diagnostic and remediation automation developed from proven manual workflows
- `screenshots/` — sanitized visual evidence of configuration and troubleshooting

## Documentation Philosophy

Every incident follows the same operational pattern:

**Problem → Symptoms → Investigation → Root Cause → Resolution → Verification → Automation Opportunity**

This keeps the repository focused on support engineering and troubleshooting rather than documenting every installation click.

## Security

This repository contains only isolated lab configuration and sanitized evidence. Passwords, product keys, tokens, personal information, and unrelated host-system information are never committed.