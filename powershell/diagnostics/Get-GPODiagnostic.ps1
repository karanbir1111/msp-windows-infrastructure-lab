param (
    [string]$ExpectedGPO = "CORP Workstation Security Baseline",
    [string]$ExpectedOU = "OU=CORP-Workstations,DC=corp,DC=lab"
)

Write-Host ""
Write-Host "============================================"
Write-Host " Group Policy Diagnostic"
Write-Host "============================================"
Write-Host ""

try {
    $ComputerName = $env:COMPUTERNAME

    Write-Host "Computer Information"
    Write-Host "--------------------"
    Write-Host "Computer Name : $ComputerName"

    $ComputerSystem = Get-CimInstance Win32_ComputerSystem
    Write-Host "Domain        : $($ComputerSystem.Domain)"
    Write-Host "Domain Joined : $($ComputerSystem.PartOfDomain)"

    Write-Host ""
    Write-Host "Group Policy Check"
    Write-Host "------------------"

    $GPResult = gpresult /scope computer /r

    if ($GPResult -match [regex]::Escape($ExpectedGPO)) {
        Write-Host "[OK] Expected GPO is applied: $ExpectedGPO"
        $GPOApplied = $true
    }
    else {
        Write-Host "[WARNING] Expected GPO is NOT applied: $ExpectedGPO"
        $GPOApplied = $false
    }

    Write-Host ""
    Write-Host "Active Directory Location"
    Write-Host "-------------------------"

    try {
        $ComputerDN = ([ADSISearcher]"(&(objectCategory=computer)(name=$ComputerName))").FindOne().Properties.distinguishedname

        if ($ComputerDN) {
            $ComputerDN = $ComputerDN[0]
            Write-Host "Distinguished Name:"
            Write-Host $ComputerDN

            if ($ComputerDN -like "*$ExpectedOU") {
                Write-Host "[OK] Computer is located in the expected workstation OU."
                $OUCorrect = $true
            }
            else {
                Write-Host "[WARNING] Computer is NOT located in the expected workstation OU."
                $OUCorrect = $false
            }
        }
        else {
            Write-Host "[WARNING] Unable to locate computer object in Active Directory."
            $OUCorrect = $false
        }
    }
    catch {
        Write-Host "[WARNING] Unable to query computer location in Active Directory."
        $OUCorrect = $false
    }

    Write-Host ""
    Write-Host "Diagnostic Summary"
    Write-Host "------------------"

    if (-not $OUCorrect) {
        Write-Host "[LIKELY ISSUE] Computer object may be outside expected GPO scope."
    }
    elseif (-not $GPOApplied) {
        Write-Host "[LIKELY ISSUE] Computer is in the expected OU, but GPO is not applied."
        Write-Host "               Investigate security filtering, WMI filtering, replication, or policy processing."
    }
    else {
        Write-Host "[OK] GPO scope and application appear healthy."
    }
}
catch {
    Write-Host ""
    Write-Host "[ERROR] Group Policy diagnostic failed."
    Write-Host $_.Exception.Message
}
