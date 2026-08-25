# Incident Case Studies

This directory contains realistic MSP-style Windows infrastructure incidents introduced after the healthy Phase 1 baseline was established.

Each case study follows the same operational structure:

**Problem → Symptoms → Investigation → Root Cause → Resolution → Verification → Automation Opportunity**

## Completed Incidents

### INC-001 — Active Directory Account Lockout ✅

A Finance user was unable to sign in after exceeding the domain invalid-logon threshold. The incident demonstrates account-state diagnosis, manual Active Directory remediation, and end-user verification.

Case study: [`INC-001-account-lockout/README.md`](INC-001-account-lockout/README.md)

### INC-002 — DNS Misconfiguration / Name-Resolution Failure ✅

A domain workstation retained IP connectivity to `DC01` but could not resolve internal names because its DNS client was pointed to a public resolver. The incident demonstrates fault-domain isolation, Active Directory DNS dependencies, SRV-record validation, remediation, and verification.

Case study: [`INC-002-dns-failure/README.md`](INC-002-dns-failure/README.md)

### INC-003 — DHCP Failure / APIPA ✅

A DHCP-enabled workstation failed to obtain a lease after its server-side scope was deactivated and fell back to a `169.254.x.x` APIPA address. The incident demonstrates DHCP troubleshooting, APIPA interpretation, server-side root-cause analysis, lease recovery, and connectivity verification.

Case study: [`INC-003-dhcp-apipa/README.md`](INC-003-dhcp-apipa/README.md)

### INC-004 — Group Policy Application Failure ✅

A domain-joined workstation stopped receiving its expected security baseline because its computer object was moved outside the OU to which the GPO was linked. The incident demonstrates `gpresult` analysis, OU/GPO scope troubleshooting, Active Directory object placement, remediation, and endpoint verification.

Case study: [`INC-004-gpo-failure/README.md`](INC-004-gpo-failure/README.md)

## Planned Incidents

- INC-005 — File-share / group-permission issue
- Windows service or connectivity incident

## Evidence Convention

Incident documentation is stored here under `incidents/INC-XXX-.../`.

Screenshots are stored separately under `screenshots/incidents/INC-XXX-.../` and embedded into the corresponding case study.

This separation keeps troubleshooting documentation readable while maintaining a clean evidence library.
