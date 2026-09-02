param (
    [Parameter(Mandatory = $true)]
    [string]$ComputerName,

    [string]$TargetOU = "OU=CORP-Workstations,DC=corp,DC=lab"
)

Import-Module ActiveDirectory

Write-Host ""
Write-Host "============================================"
Write-Host " Controlled GPO Scope Remediation"
Write-Host "============================================"
Write-Host ""

try {
    $Computer = Get-ADComputer -Identity $ComputerName -Properties DistinguishedName

    Write-Host "Current Computer Object"
    Write-Host "-----------------------"
    Write-Host "Computer Name       : $($Computer.Name)"
    Write-Host "Distinguished Name  : $($Computer.DistinguishedName)"

    Write-Host ""
    Write-Host "Expected Target OU"
    Write-Host "------------------"
    Write-Host $TargetOU

    if ($Computer.DistinguishedName -like "*$TargetOU") {
        Write-Host ""
        Write-Host "[INFO] Computer is already in the expected OU."
        Write-Host "No remediation required."
        exit
    }

    Write-Host ""
    Write-Host "[WARNING] Computer is outside expected GPO scope."
    Write-Host ""

    $Confirmation = Read-Host "Move '$ComputerName' to CORP-Workstations? Type YES to continue"

    if ($Confirmation -ne "YES") {
        Write-Host ""
        Write-Host "[CANCELLED] No Active Directory changes were made."
        exit
    }

    Move-ADObject -Identity $Computer.DistinguishedName -TargetPath $TargetOU
    Start-Sleep -Seconds 1

    $VerifiedComputer = Get-ADComputer -Identity $ComputerName -Properties DistinguishedName

    Write-Host ""
    Write-Host "Verification"
    Write-Host "------------"
    Write-Host "New Distinguished Name:"
    Write-Host $VerifiedComputer.DistinguishedName

    if ($VerifiedComputer.DistinguishedName -like "*$TargetOU") {
        Write-Host "[SUCCESS] Computer moved to expected workstation OU."
        Write-Host "[NEXT] Run gpupdate /force on the workstation and restart if required."
    }
    else {
        Write-Host "[FAILED] Computer is still outside expected OU."
    }
}
catch {
    Write-Host ""
    Write-Host "[ERROR] GPO scope remediation failed."
    Write-Host $_.Exception.Message
}
