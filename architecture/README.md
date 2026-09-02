# Lab Architecture

## Logical Topology

```text
Windows 11 Host
└── Oracle VirtualBox
    └── Host-Only Network 10.10.10.0/24
        ├── DC01
        │   ├── Windows Server 2025 Evaluation
        │   ├── 10.10.10.10/24
        │   ├── Active Directory Domain Services
        │   ├── DNS
        │   ├── DHCP
        │   └── SMB / NTFS lab share
        │
        └── WIN11-01
            ├── Windows 11 Enterprise Evaluation
            ├── DHCP client
            ├── Domain member: corp.lab
            └── CORP-Workstations OU
```

## Core Dependencies

The lab is intentionally small so that each Windows infrastructure dependency can be isolated and tested independently.

```text
DHCP
  ↓
Valid IPv4 configuration
  ↓
Domain DNS
  ↓
AD service discovery
  ↓
Domain authentication
  ↓
Group Policy / authorization
```

A failure at one layer can therefore be tested against the layers below it. For example, successful connectivity to `10.10.10.10` combined with failed `DC01.corp.lab` resolution points toward DNS rather than general IP connectivity.

## Active Directory Design

Domain: `corp.lab`

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

The OU and security-group structure supports the incident simulations for Group Policy scoping and group-based file authorization.

## Network Design

| Component | Address / Configuration |
| --- | --- |
| Lab subnet | `10.10.10.0/24` |
| VirtualBox host-only adapter | `10.10.10.1` |
| DC01 | `10.10.10.10/24` static |
| WIN11-01 | DHCP |
| DHCP scope | `10.10.10.100-199` |
| Domain DNS | `10.10.10.10` |
| Default gateway | None, isolated lab |

## Design Purpose

This architecture is not intended to represent a large production network. It is a controlled support lab built to reproduce common MSP incidents, preserve a known-good baseline, and demonstrate structured troubleshooting, remediation, and PowerShell automation.

For the full build notes, see [`../documentation/phase-1-build.md`](../documentation/phase-1-build.md).
