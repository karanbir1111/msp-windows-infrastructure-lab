# Phase 1 — Infrastructure Baseline

## Objective

Establish a known-good Windows domain environment before introducing troubleshooting scenarios or automation.

## Planned Components

### DC01
- Windows Server 2025 Evaluation (Desktop Experience)
- Hostname: `DC01`
- Static IPv4: `10.10.10.10/24`
- DNS: `10.10.10.10`
- Roles: AD DS, DNS, DHCP

### WIN11-01
- Windows 11 Enterprise Evaluation
- Hostname: `WIN11-01`
- IPv4: DHCP
- DNS supplied by DHCP: `10.10.10.10`
- Domain membership: `corp.lab`

## Active Directory Design

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

Planned security groups:
- `GG-Finance`
- `GG-IT`
- `GG-Sales`

## Validation Checklist

- [ ] VirtualBox installed
- [ ] Host-only lab network created
- [ ] VirtualBox DHCP disabled on lab network
- [ ] DC01 installed
- [ ] DC01 renamed
- [ ] DC01 configured as `10.10.10.10/24`
- [ ] AD DS installed
- [ ] `corp.lab` forest/domain created
- [ ] DNS validated
- [ ] Organizational Units created
- [ ] Test users and security groups created
- [ ] DHCP installed and authorized
- [ ] DHCP scope `10.10.10.100-199` created
- [ ] WIN11-01 installed
- [ ] WIN11-01 receives DHCP configuration
- [ ] DNS resolution verified from WIN11-01
- [ ] WIN11-01 joined to `corp.lab`
- [ ] Domain-user authentication verified
- [ ] Workstation GPO created and applied
- [ ] Healthy baseline snapshot created

## Documentation Rule

Configuration is documented only after it has been successfully implemented and verified. Failures encountered during the build may later be converted into incident case studies when they demonstrate meaningful troubleshooting.