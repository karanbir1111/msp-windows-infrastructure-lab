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

A functioning domain environment has been built and validated.

### Windows Server / Domain Controller

`DC01` was configured with a static `10.10.10.10/24` address and promoted as the first domain controller for `corp.lab`. AD-integrated DNS is hosted on the same server.

### Active Directory Structure

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

Test users were created in department-specific OUs and assigned to corresponding Global Security groups. This provides a realistic foundation for later access-control and troubleshooting scenarios.

### DHCP and DNS Validation

Windows Server DHCP was authorized in Active Directory and configured with the `10.10.10.100-199` workstation scope. `WIN11-01` successfully received:

- IPv4 address: `10.10.10.100`
- Subnet mask: `255.255.255.0`
- DHCP server: `10.10.10.10`
- DNS server: `10.10.10.10`
- DNS suffix: `corp.lab`

This validates the full client network-configuration path from the Windows DHCP service to the workstation.

### Domain Authentication

`WIN11-01` was joined to `corp.lab` and moved into `CORP-Workstations`. Domain authentication was validated using the Finance test account `CORP\amorgan`; the workstation authenticated against `\\DC01` and the user's `GG-Finance` group membership appeared in the Windows access token.

### Group Policy

A workstation GPO named `CORP Workstation Security Baseline` was linked to `CORP-Workstations`. `gpresult` confirmed that the policy was received from `DC01.corp.lab`, and an interactive logon notice provided a visible verification that the policy was enforced on `WIN11-01`.

### Recovery Baseline

Healthy-state VirtualBox snapshots were created for both VMs before beginning incident simulation. This preserves a known-good recovery point while allowing faults to be introduced safely.

## Phase 2 — MSP Incident Simulation 🔧

Phase 2 uses realistic support tickets to practice structured root-cause troubleshooting.

### INC-001 — Active Directory Account Lockout

The first incident simulates a Finance user being unable to sign in after repeated invalid password attempts. The workflow includes:

- confirming workstation connectivity and domain reachability,
- checking the user's Active Directory state,
- distinguishing an enabled account from a locked account,
- manually unlocking the user after validation,
- verifying successful authentication from `WIN11-01`, and
- identifying the workflow as a future PowerShell diagnostic/remediation opportunity.

Detailed incident evidence will be added as the screenshots are finalized.

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
- `screenshots/` — sanitized evidence of configuration and troubleshooting

## Documentation Philosophy

Every incident is documented using the same operational pattern:

**Problem → Symptoms → Investigation → Root Cause → Resolution → Verification → Automation Opportunity**

This keeps the repository focused on support engineering and troubleshooting rather than screenshots of installation wizards.

## Security

This repository contains only isolated lab configuration and sanitized evidence. Passwords, product keys, tokens, personal information, and unrelated host-system information are never committed.