# Phase 1 Build Notes

## Objective

Build a known-good Windows infrastructure baseline that can be used for repeatable MSP-style incident simulation and troubleshooting.

## Environment

- Host virtualization: Oracle VirtualBox
- Domain controller: `DC01`
- Client workstation: `WIN11-01`
- Active Directory domain: `corp.lab`
- Lab subnet: `10.10.10.0/24`

## Domain Controller

`DC01` was configured with:

- static IPv4 address `10.10.10.10/24`
- Active Directory Domain Services
- Active Directory-integrated DNS
- Windows DHCP
- no default gateway in the isolated host-only lab

## Active Directory Structure

```text
corp.lab
├── CORP-Users
│   ├── Finance
│   ├── IT
│   └── Sales
├── CORP-Workstations
├── CORP-Servers
└── CORP-Groups
```

Security groups:

- `GG-Finance`
- `GG-IT`
- `GG-Sales`

Test users:

- Alex Morgan — `amorgan` — Finance
- Jordan Lee — `jlee` — IT
- Taylor Smith — `tsmith` — Sales

## DHCP

The `Corporate Workstations` scope provides:

- address range `10.10.10.100-199`
- subnet mask `255.255.255.0`
- DNS server `10.10.10.10`
- DNS suffix `corp.lab`

No router option is required because this is an isolated host-only lab.

## Windows Client

`WIN11-01` was configured as a DHCP client and joined to `corp.lab`.

Healthy-state validation included:

- valid `10.10.10.x` DHCP address
- DHCP server `10.10.10.10`
- DNS server `10.10.10.10`
- successful domain join
- successful domain-user authentication
- successful communication with `DC01`

## Group Policy

A workstation GPO named `CORP Workstation Security Baseline` was linked to `CORP-Workstations`.

The policy includes a legal logon notice:

- title: `CORP Authorized Access`
- message: `This system is for authorized CORP users only.`

`gpresult` was used to verify that the policy was applied from `DC01.corp.lab`.

## File Authorization Baseline

A Finance share was later used for authorization troubleshooting:

- server path: `C:\Shares\Finance`
- UNC path: `\\DC01\Finance`
- departmental authorization group: `GG-Finance`

The design intentionally uses group-based NTFS authorization rather than assigning access directly to individual users.

## Known-Good Snapshot

Healthy-state VirtualBox snapshots were created before deliberate fault injection. This provided a stable recovery point for incident simulation.

## Why the Baseline Matters

The incident phase depends on a known-good environment. By validating DHCP, DNS, domain authentication, Group Policy, and authorization first, each deliberate fault can be isolated against an expected state instead of troubleshooting an unknown build.

For the incident case studies, see [`../incidents/README.md`](../incidents/README.md).

For the completed PowerShell automation, see [`../powershell/README.md`](../powershell/README.md).
