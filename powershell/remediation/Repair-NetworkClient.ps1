param (
    [string]$ExpectedDNSServer = "10.10.10.10"
)

Write-Host ""
Write-Host "============================================"
Write-Host " Controlled Network Client Remediation"
Write-Host "============================================"
Write-Host ""

try {
    $Adapter = Get-NetIPConfiguration |
        Where-Object { $_.NetAdapter.Status -eq "Up" } |
        Select-Object -First 1

    if (-not $Adapter) {
        Write-Host "[ERROR] No active network adapter found."
        exit
    }

    $InterfaceIndex = $Adapter.InterfaceIndex
    $InterfaceAlias = $Adapter.InterfaceAlias
    $IPv4 = $Adapter.IPv4Address.IPAddress
    $DHCPState = (Get-NetIPInterface -InterfaceIndex $InterfaceIndex -AddressFamily IPv4).Dhcp
    $DNSServers = (Get-DnsClientServerAddress -InterfaceIndex $InterfaceIndex -AddressFamily IPv4).ServerAddresses

    Write-Host "Current Network State"
    Write-Host "---------------------"

    [PSCustomObject]@{
        Interface   = $InterfaceAlias
        IPv4Address = $IPv4
        DHCP        = $DHCPState
        DNSServers  = ($DNSServers -join ", ")
    } | Format-List

    Write-Host ""
    Write-Host "Detected Conditions"
    Write-Host "-------------------"

    $APIPA = $false
    $DNSIssue = $false

    if ($IPv4 -like "169.254.*") {
        Write-Host "[WARNING] APIPA address detected."
        $APIPA = $true
    }

    if ($DNSServers -notcontains $ExpectedDNSServer) {
        Write-Host "[WARNING] Expected DNS server $ExpectedDNSServer is not configured."
        $DNSIssue = $true
    }

    if (-not $APIPA -and -not $DNSIssue) {
        Write-Host "[OK] No supported remediation is required."
        exit
    }

    Write-Host ""
    Write-Host "Available Remediation"
    Write-Host "---------------------"

    if ($DNSIssue) {
        Write-Host "1. Restore DNS to expected domain DNS server."
    }

    if ($APIPA) {
        Write-Host "2. Renew DHCP lease."
    }

    Write-Host ""
    $Confirmation = Read-Host "Type YES to continue with remediation"

    if ($Confirmation -ne "YES") {
        Write-Host ""
        Write-Host "[CANCELLED] No network changes were made."
        exit
    }

    Write-Host ""
    Write-Host "Applying remediation..."
    Write-Host ""

    if ($DNSIssue) {
        Set-DnsClientServerAddress -InterfaceIndex $InterfaceIndex -ServerAddresses $ExpectedDNSServer
        Write-Host "[ACTION] DNS server set to $ExpectedDNSServer."
    }

    if ($APIPA -and $DHCPState -eq "Enabled") {
        ipconfig /renew | Out-Null
        Write-Host "[ACTION] DHCP lease renewal requested."
    }

    Start-Sleep -Seconds 3

    $UpdatedAdapter = Get-NetIPConfiguration |
        Where-Object { $_.InterfaceIndex -eq $InterfaceIndex }

    $UpdatedIPv4 = $UpdatedAdapter.IPv4Address.IPAddress
    $UpdatedDNS = (Get-DnsClientServerAddress -InterfaceIndex $InterfaceIndex -AddressFamily IPv4).ServerAddresses

    Write-Host ""
    Write-Host "Verification"
    Write-Host "------------"
    Write-Host "IPv4 Address : $UpdatedIPv4"
    Write-Host "DNS Servers  : $($UpdatedDNS -join ', ')"

    if ($UpdatedIPv4 -notlike "169.254.*") {
        Write-Host "[OK] Valid IPv4 address detected."
    }
    else {
        Write-Host "[WARNING] Client still has an APIPA address."
    }

    if ($UpdatedDNS -contains $ExpectedDNSServer) {
        Write-Host "[OK] Expected DNS server is configured."
    }
    else {
        Write-Host "[WARNING] Expected DNS server is still missing."
    }
}
catch {
    Write-Host ""
    Write-Host "[ERROR] Network remediation failed."
    Write-Host $_.Exception.Message
}
