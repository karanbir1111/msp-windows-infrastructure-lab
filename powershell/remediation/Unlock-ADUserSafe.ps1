param (
    [Parameter(Mandatory = $true)]
    [string]$Username
)

Import-Module ActiveDirectory

Write-Host ""
Write-Host "============================================"
Write-Host " Safe Active Directory Account Unlock"
Write-Host "============================================"
Write-Host ""

try {
    $User = Get-ADUser -Identity $Username -Properties Enabled, LockedOut, PasswordExpired, LastBadPasswordAttempt, DistinguishedName

    Write-Host "Current Account State"
    Write-Host "---------------------"

    [PSCustomObject]@{
        Username               = $User.SamAccountName
        Name                   = $User.Name
        Enabled                = $User.Enabled
        LockedOut              = $User.LockedOut
        PasswordExpired        = $User.PasswordExpired
        LastBadPasswordAttempt = $User.LastBadPasswordAttempt
        DistinguishedName      = $User.DistinguishedName
    } | Format-List

    if (-not $User.Enabled) {
        Write-Host "[STOP] Account is disabled. Unlock will not be attempted."
        exit
    }

    if (-not $User.LockedOut) {
        Write-Host "[INFO] Account is not currently locked."
        Write-Host "No remediation required."
        exit
    }

    Write-Host ""
    Write-Host "[WARNING] Account is currently locked out."
    Write-Host ""

    $Confirmation = Read-Host "Unlock account '$Username'? Type YES to continue"

    if ($Confirmation -ne "YES") {
        Write-Host ""
        Write-Host "[CANCELLED] No changes were made."
        exit
    }

    Write-Host ""
    Write-Host "Attempting remediation..."

    Unlock-ADAccount -Identity $Username
    Start-Sleep -Seconds 1

    $VerifiedUser = Get-ADUser -Identity $Username -Properties LockedOut

    Write-Host ""
    Write-Host "Verification"
    Write-Host "------------"

    if ($VerifiedUser.LockedOut -eq $false) {
        Write-Host "[SUCCESS] Account unlocked successfully."
        Write-Host "LockedOut = False"
    }
    else {
        Write-Host "[FAILED] Account still appears locked."
        Write-Host "Escalate for further investigation."
    }
}
catch {
    Write-Host ""
    Write-Host "[ERROR] Unable to complete account remediation."
    Write-Host $_.Exception.Message
}
