# INC-001 — Active Directory Account Lockout

## Ticket Summary

**User:** Alex Morgan  
**Username:** `amorgan`  
**Department:** Finance  
**Workstation:** `WIN11-01`  
**Domain:** `corp.lab`  
**Reported issue:** User is unable to sign in after multiple unsuccessful password attempts.

## Business Impact

The affected user cannot authenticate to the domain workstation and therefore cannot access their normal Windows session or domain resources.

## Environment

- Domain Controller: `DC01.corp.lab` / `10.10.10.10`
- Client: `WIN11-01`
- Identity provider: Active Directory Domain Services
- User OU: `CORP-Users/Finance`
- Security group: `GG-Finance`

## Troubleshooting Approach

The incident was approached from the symptom outward rather than assuming the account itself was the problem.

### 1. Validate the workstation path

Before modifying the user account, the workstation's basic infrastructure dependencies were considered:

- valid DHCP configuration,
- connectivity to `DC01`,
- DNS resolution through the domain DNS server, and
- domain-controller availability.

The healthy Phase 1 baseline had already established that the workstation could communicate with and authenticate against `DC01`.

### 2. Inspect the Active Directory account

The Finance user was checked in Active Directory to determine whether the account was:

- nonexistent,
- disabled,
- expired,
- password-expired, or
- locked out.

The account remained **enabled**, but its **LockedOut** state was true. This distinction is important: an enabled account can still be prevented from authenticating because of the domain's account-lockout policy.

## Root Cause

`amorgan` exceeded the configured invalid-logon threshold after repeated incorrect password attempts. Active Directory therefore locked the account as designed.

## Resolution

After confirming the cause, the account was manually unlocked in Active Directory Users and Computers.

The first incident is intentionally remediated through the GUI so the underlying administrative process is understood before the same workflow is automated with PowerShell.

## Verification

The resolution is not considered complete simply because the account was unlocked. Verification requires confirming both:

1. the Active Directory account no longer reports a locked state; and
2. Alex can successfully authenticate again from `WIN11-01` using the correct credentials.

Final before/after screenshots will be added to this incident directory as the evidence set is finalized.

## Automation Opportunity

This incident exposes a repeatable service-desk workflow that is well suited to PowerShell diagnostics.

A future user-diagnostic command could accept a username and return a concise summary such as:

```text
User:           Alex Morgan
Username:       amorgan
Department:     Finance
Enabled:        True
Locked Out:     True
Password State: Valid
Groups:         GG-Finance

Diagnosis: Active Directory account is locked.
Recommended action: Verify user identity and unlock the account.
```

Controlled remediation could then offer an explicit technician-approved unlock action rather than automatically changing account state.

## Skills Demonstrated

- Active Directory user administration
- Account-lockout policy behavior
- Authentication troubleshooting
- Differentiating disabled vs. locked account states
- Structured root-cause analysis
- Manual remediation
- End-user verification
- Identification of a safe PowerShell automation opportunity
