param (
    [string]$DomainController = "DC01.corp.lab",
    [string]$DomainControllerIP = "10.10.10.10",
    [string]$ExpectedDNSServer = "10.10.10.10",
    [string]$DomainName = "corp.lab"
)

Write-Host ""
Write-Host "============================================"
Write-Host " Windows Network & AD Diagnostic"
Write-Host "============================================"
Write-Host ""

try {
    $Adapter = Get-NetIPConfiguration |
        Where-Object {
            $_.IPv4Address -and
            $_.NetAdapter.Status -eq "Up"
        } |
        Select-Object -First 1

    if (-not $Adapter) {
        Write-Host "[ERROR] No active IPv4 network adapter found."
        exit
    }

    $IPv4 = $Adapter.IPv4Address.IPAddress
    $DHCPEnabled = (Get-NetIPInterface -InterfaceIndex $Adapter.InterfaceIndex -AddressFamily IPv4).Dhcp
    $DNSServers = (Get-DnsClientServerAddress -InterfaceIndex $Adapter.InterfaceIndex -AddressFamily IPv4).ServerAddresses

    Write-Host "Client Network Configuration"
    Write-Host "----------------------------"

    [PSCustomObject]@{
        Interface   = $Adapter.InterfaceAlias
        IPv4Address = $IPv4
        DHCP        = $DHCPEnabled
        DNSServers  = ($DNSServers -join ", ")
    } | Format-List

    Write-Host ""
    Write-Host "Diagnostic Checks"
    Write-Host "-----------------"

    if ($IPv4 -like "169.254.*") {
        Write-Host "[WARNING] APIPA address detected."
        Write-Host "          DHCP lease acquisition may have failed."
    }
    else {
        Write-Host "[OK] Client has a non-APIPA IPv4 address."
    }

    if ($DHCPEnabled -eq "Enabled") {
        Write-Host "[OK] DHCP is enabled on the active adapter."
    }
    else {
        Write-Host "[INFO] DHCP is not enabled on the active adapter."
    }

    if ($DNSServers -contains $ExpectedDNSServer) {
        Write-Host "[OK] Expected domain DNS server is configured."
    }
    else {
        Write-Host "[WARNING] Expected DNS server $ExpectedDNSServer is not configured."
        Write-Host "          Active Directory name resolution may fail."
    }

    Write-Host ""
    Write-Host "Connectivity Tests"
    Write-Host "------------------"

    try {
        $PingResult = Test-Connection -ComputerName $DomainControllerIP -Count 1 -Quiet -ErrorAction Stop

        if ($PingResult) {
            Write-Host "[OK] Domain controller reachable by IP: $DomainControllerIP"
        }
        else {
            Write-Host "[WARNING] Domain controller is not reachable by IP."
        }
    }
    catch {
        Write-Host "[WARNING] Domain controller is not reachable by IP."
    }

    try {
        $HostLookup = Resolve-DnsName $DomainController -ErrorAction Stop
        if ($HostLookup) {
            Write-Host "[OK] Internal DNS lookup succeeded: $DomainController"
        }
    }
    catch {
        Write-Host "[WARNING] Internal DNS lookup failed: $DomainController"
    }

    try {
        $SrvRecord = "_ldap._tcp.dc._msdcs.$DomainName"
        $SRVLookup = Resolve-DnsName -Name $SrvRecord -Type SRV -ErrorAction Stop

        if ($SRVLookup) {
            Write-Host "[OK] Active Directory LDAP SRV lookup succeeded."
        }
    }
    catch {
        Write-Host "[WARNING] Active Directory LDAP SRV lookup failed."
    }

    Write-Host ""
    Write-Host "Diagnostic Summary"
    Write-Host "------------------"

    if ($IPv4 -like "169.254.*") {
        Write-Host "[LIKELY ISSUE] DHCP failure / APIPA detected."
    }
    elseif ($DNSServers -notcontains $ExpectedDNSServer) {
        Write-Host "[LIKELY ISSUE] DNS configuration does not match domain requirements."
    }
    else {
        Write-Host "[OK] No obvious DHCP or DNS configuration issue detected."
    }
}
catch {
    Write-Host ""
    Write-Host "[ERROR] Network diagnostic failed."
    Write-Host $_.Exception.Message
}
