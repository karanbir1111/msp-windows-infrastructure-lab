# Screenshot Evidence

Screenshots in this project are evidence of configuration, troubleshooting, root-cause analysis, and verification — not a record of every installation click.

## Phase 1 Planned Evidence

1. `01-dc01-server-installed.png` — DC01 / Server Manager after installation and rename
2. `02-dc01-static-network.png` — DC01 static IPv4 and DNS configuration
3. `03-ad-ds-dns-installed.png` — Server Manager showing installed infrastructure roles
4. `04-corp-lab-dns-zone.png` — DNS Manager showing the `corp.lab` zone
5. `05-active-directory-ou-structure.png` — AD organizational-unit structure
6. `06-ad-users-and-groups.png` — Sanitized test users and security groups
7. `07-dhcp-scope.png` — DHCP scope configuration
8. `08-client-network-dhcp.png` — WIN11-01 DHCP/DNS configuration
9. `09-win11-domain-joined.png` — Domain-joined workstation evidence
10. `10-domain-user-authentication.png` — `whoami` / logon-server verification
11. `11-workstation-gpo.png` — GPO linked to workstation OU
12. `12-gpo-verification.png` — `gpresult` evidence of applied policy

## Security Rules

Never include:
- passwords
- product keys
- API keys/tokens
- personal email addresses
- private IP information unrelated to this isolated lab
- unrelated personal files or browser tabs

Later phases will prioritize before/after evidence for actual incidents and automated troubleshooting.