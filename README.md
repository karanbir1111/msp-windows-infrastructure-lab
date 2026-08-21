# MSP Windows Infrastructure Troubleshooting & Automation Lab

A hands-on Windows infrastructure lab designed to simulate common Managed Service Provider (MSP) support scenarios and develop structured troubleshooting, root-cause analysis, documentation, and PowerShell automation skills.

## Project Objective

Build a realistic Windows domain environment, establish a known-good baseline, deliberately introduce common infrastructure incidents, troubleshoot them manually, and then automate repetitive diagnostic and remediation steps with PowerShell.

## Planned Environment

- Windows Server 2025 Evaluation (`DC01`)
- Windows 11 Enterprise Evaluation (`WIN11-01`)
- Oracle VirtualBox
- Active Directory Domain Services (AD DS)
- DNS
- DHCP
- Group Policy
- PowerShell
- Windows networking

## Lab Network

| Component | Configuration |
| --- | --- |
| Domain | `corp.lab` |
| Network | `10.10.10.0/24` |
| VirtualBox Host Adapter | `10.10.10.1` |
| Domain Controller | `DC01` / `10.10.10.10` |
| Client | `WIN11-01` / DHCP |
| DHCP Pool | `10.10.10.100-199` |
| DNS Server | `10.10.10.10` |

## Project Phases

1. **Infrastructure Baseline** — Build a healthy Windows domain with AD DS, DNS, DHCP, Group Policy, and a domain-joined Windows 11 workstation.
2. **Incident Simulation** — Introduce realistic failures such as account lockouts, DNS failures, DHCP failures, GPO problems, and permission issues.
3. **Root-Cause Troubleshooting** — Diagnose each incident manually and document symptoms, investigation, root cause, resolution, and verification.
4. **PowerShell Diagnostics** — Automate repetitive diagnostic checks.
5. **Controlled Remediation** — Add safe, technician-approved remediation actions.
6. **Reporting** — Generate consistent incident/ticket-style troubleshooting reports.

## Repository Structure

- `architecture/` — Network and infrastructure diagrams
- `documentation/` — Build notes, configuration documentation, and troubleshooting methodology
- `incidents/` — Documented incident simulations and root-cause analyses
- `powershell/` — Diagnostic and remediation automation
- `screenshots/` — Evidence of configuration, troubleshooting, and verification

## Current Status

**Phase 1 — Infrastructure Baseline: In progress**

The initial goal is to establish and validate the healthy baseline before intentionally introducing failures or automating remediation.

## Security

This repository contains only lab configuration and sanitized evidence. Passwords, product keys, tokens, personal information, and other credentials must never be committed.