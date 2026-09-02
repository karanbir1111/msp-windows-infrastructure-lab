param (
    [Parameter(Mandatory = $true)]
    [string]$Username
)

Import-Module ActiveDirectory

Write-Host ""
Write-Host "============================================"
Write-Host " Active Directory User Diagnostic"
Write-Host "============================================"
Write-Host ""

try {
    $User = Get-ADUser -Identity $Username -Properties Enabled, LockedOut, PasswordExpired, PasswordLastSet, LastBadPasswordAttempt, LastLogonDate, MemberOf, DistinguishedName

    Write-Host "User Information"
    Write-Host "----------------"

    [PSCustomObject]@{
        Username               = $User.SamAccountName
        Name                   = $User.Name
        Enabled                = $User.Enabled
        LockedOut              = $User.LockedOut
        PasswordExpired        = $User.PasswordExpired
        PasswordLastSet        = $User.PasswordLastSet
        LastBadPasswordAttempt = $User.LastBadPasswordAttempt
        LastLogonDate          = $User.LastLogonDate
        DistinguishedName      = $User.DistinguishedName
    } | Format-List

    Write-Host ""
    Write-Host "Security Group Membership"
    Write-Host "-------------------------"

    $Groups = Get-ADPrincipalGroupMembership -Identity $Username |
        Select-Object -ExpandProperty Name |
        Sort-Object

    if ($Groups) {
        $Groups | ForEach-Object { Write-Host "- $_" }
    }
    else {
        Write-Host "No group memberships found."
    }

    Write-Host ""
    Write-Host "Diagnostic Summary"
    Write-Host "------------------"

    if (-not $User.Enabled) {
        Write-Host "[WARNING] Account is disabled."
    }
    elseif ($User.LockedOut) {
        Write-Host "[WARNING] Account is locked out."
    }
    elseif ($User.PasswordExpired) {
        Write-Host "[WARNING] Password is expired."
    }
    else {
        Write-Host "[OK] No obvious account-state issue detected."
    }
}
catch {
    Write-Host ""
    Write-Host "[ERROR] Unable to retrieve user information."
    Write-Host $_.Exception.Message
}
