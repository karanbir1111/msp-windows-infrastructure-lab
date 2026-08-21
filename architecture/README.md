# Architecture

This directory contains architecture and network diagrams for the MSP Windows Infrastructure Lab.

## Phase 1 Target

```text
Windows 11 Home Host
        |
    VirtualBox
        |
Host-Only Network: 10.10.10.0/24
        |
   +----+------------------+
   |                       |
 DC01                   WIN11-01
10.10.10.10                DHCP
   |
   +-- Active Directory Domain Services
   +-- DNS
   +-- DHCP
   +-- Group Policy

Domain: corp.lab
```

A polished architecture diagram will be added after the Phase 1 environment has been validated.