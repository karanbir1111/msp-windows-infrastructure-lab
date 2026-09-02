# MSP Ticket / Knowledge Base Template

Use this template to document incidents in a consistent service-desk format.

## Ticket Summary

- **Ticket ID:**
- **Client / User:**
- **System / Device:**
- **Priority:**
- **Business Impact:**
- **Reported Symptom:**

## Environment

Document the systems and services involved, for example:

- Windows workstation / server
- Active Directory domain
- DNS / DHCP
- Group Policy
- Microsoft 365 / Entra ID
- Network segment, VLAN, firewall, or VPN where relevant
- File share / NTFS permissions

## Investigation

Record the troubleshooting process in the order it was performed.

1. Confirm the user-visible symptom.
2. Establish whether the issue is isolated to one user, device, service, or site.
3. Validate dependencies independently.
4. Record commands, tools, logs, and configuration checks used.
5. Compare actual state with the known-good or expected state.
6. Identify the root cause before making a change.

## Root Cause

State the technical cause in one clear sentence.

## Resolution

Document the exact remediation performed, including any configuration changes, account actions, policy refreshes, lease renewals, or permission changes.

## Verification

Confirm the fix from both the technical and end-user perspectives where possible.

- Expected service or configuration is restored.
- Relevant diagnostic check succeeds.
- User can complete the original task.
- No unrelated configuration was changed.

## Automation / Prevention Notes

Document whether the incident has a safe automation opportunity.

- **Read-only diagnostic:**
- **Controlled remediation:**
- **Technician confirmation required:** Yes / No
- **Potential preventive action:**

## Knowledge Base Summary

Write a short reusable summary another technician could use without repeating the full investigation.
