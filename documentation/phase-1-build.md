# Phase 1 — Infrastructure Baseline

## Objective

Build and verify a known-good Windows domain environment before introducing troubleshooting scenarios or automation. The baseline is intentionally simple enough to understand end to end, but realistic enough to support Active Directory, DNS, DHCP, Group Policy, authentication, access-control, and automation scenarios.

## Final Environment

### DC01 — Domain Controller

- Operating system: Windows Server 2025 Evaluation (Desktop Experience)
- Hostname: `DC01`
- IPv4: `10.10.10.10/24`
- DNS client: `10.10.10.10`
- Roles:
  - Active Directory Domain Services
  - DNS Server
  - DHCP Server
- Active Directory domain: `corp.lab`

### WIN11-01 — Domain Workstation

- Operating system: Windows 11 Enterprise Evaluation
- Hostname: `WIN11-01`
- IPv4 configuration: DHCP
- Domain membership: `corp.lab`
- Computer OU: `CORP-Workstations`

## Virtual Network

The VMs communicate over a VirtualBox host-only network using `10.10.10.0/24`. VirtualBox's own DHCP service was disabled so the only DHCP authority in the lab is the Windows Server DHCP service on `DC01`.

| Device / Service | Address / Configuration |
| --- | --- |
| VirtualBox host adapter | `10.10.10.1` |
| DC01 | `10.10.10.10` |
| DHCP pool | `10.10.10.100-199` |
| WIN11-01 observed lease | `10.10.10.100` |
| DNS supplied to clients | `10.10.10.10` |
| DNS suffix | `corp.lab` |

## Active Directory Design

```text
corp.lab
├── CORP-Users
│   ├── Finance
│   │   └── Alex Morgan (amorgan)
│   ├── IT
│   │   └── Jordan Lee (jlee)
│   └── Sales
│       └── Taylor Smith (tsmith)
├── CORP-Workstations
│   └── WIN11-01
├── CORP-Servers
└── CORP-Groups
    ├── GG-Finance
    ├── GG-IT
    └── GG-Sales
```

The OU design separates users, workstations, servers, and security groups so later policies and troubleshooting can be scoped cleanly. Department Global Security groups provide a foundation for future file-share and authorization scenarios.

## DNS

`DC01` hosts an Active Directory-integrated `corp.lab` DNS zone. DNS resolution was validated from the Windows client before the workstation was joined to the domain. This matters because Active Directory clients depend heavily on DNS to locate domain controllers and related services.

## DHCP

The Windows DHCP role was installed and authorized in Active Directory. A workstation scope was created for `10.10.10.100-199`.

The client evidence confirms that `WIN11-01` automatically received:

```text
Host Name:       WIN11-01
DNS Suffix:      corp.lab
DHCP Enabled:    Yes
IPv4 Address:    10.10.10.100
Subnet Mask:     255.255.255.0
DHCP Server:     10.10.10.10
DNS Server:      10.10.10.10
```

This validates that Windows Server, rather than VirtualBox, is providing the workstation's network configuration.

## Domain Join and Authentication

`WIN11-01` was joined to `corp.lab` and its computer account moved into `CORP-Workstations`.

Authentication was validated with the Finance user `CORP\amorgan`. `whoami` returned `corp\amorgan`, `%LOGONSERVER%` returned `\\DC01`, and `CORP\GG-Finance` appeared in the user's security-group token.

Together these checks prove more than a successful domain join: they demonstrate that the workstation is authenticating against the domain controller and receiving the expected authorization group membership.

## Group Policy

A computer GPO named `CORP Workstation Security Baseline` was created and linked to `CORP-Workstations`.

A legal logon notice was configured as a visible test policy:

- Title: `CORP Authorized Access`
- Message: `This system is for authorized CORP users only.`

`gpresult /scope computer /r` confirmed that:

- `WIN11-01` resides in `OU=CORP-Workstations,DC=corp,DC=lab`
- Group Policy was applied from `DC01.corp.lab`
- `CORP Workstation Security Baseline` was listed under Applied Group Policy Objects

The logon notice then provided a visible end-user confirmation that the policy was actually enforced.

## Validation Checklist

- [x] VirtualBox installed
- [x] Host-only lab network created
- [x] VirtualBox DHCP disabled on lab network
- [x] DC01 installed
- [x] DC01 renamed
- [x] DC01 configured as `10.10.10.10/24`
- [x] AD DS installed
- [x] `corp.lab` forest/domain created
- [x] DNS validated
- [x] Organizational Units created
- [x] Test users and Global Security groups created
- [x] DHCP installed and authorized
- [x] DHCP scope `10.10.10.100-199` created
- [x] WIN11-01 installed
- [x] WIN11-01 received DHCP configuration from DC01
- [x] WIN11-01 received `10.10.10.10` as DNS server
- [x] DNS resolution validated from WIN11-01
- [x] WIN11-01 joined to `corp.lab`
- [x] WIN11-01 moved into `CORP-Workstations`
- [x] Domain-user authentication verified
- [x] Security-group membership verified
- [x] Workstation GPO created and linked
- [x] GPO application verified with `gpresult`
- [x] Logon notice enforcement verified
- [x] Healthy baseline snapshots created for both VMs

## Baseline Result

Phase 1 is complete. The environment now provides a known-good reference state for realistic support incidents. VirtualBox snapshots were taken before Phase 2 so faults can be introduced deliberately and the lab can always be restored to a verified working configuration.

## Documentation Rule

Configuration is only marked complete after it has been implemented and independently verified. Later incident documentation follows the same standard: performing a remediation is not considered resolution until the original user-facing problem has also been retested successfully.