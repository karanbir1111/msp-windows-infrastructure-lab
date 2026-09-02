param (
    [Parameter(Mandatory = $true)]
    [string]$Username,

    [string]$RequiredGroup = "GG-Finance"
)

Import-Module ActiveDirectory

Write-Host ""
Write-Host "============================================"
Write-Host " Controlled File Access Remediation"
Write-Host "============================================"
Write-Host ""

try {
    $User = Get-ADUser -Identity $Username -Properties Enabled
    $Group = Get-ADGroup -Identity $RequiredGroup

    Write-Host "Requested Access Change"
    Write-Host "-----------------------"
    Write-Host "User          : $($User.SamAccountName)"
    Write-Host "Name          : $($User.Name)"
    Write-Host "Enabled       : $($User.Enabled)"
    Write-Host "Required Group: $($Group.Name)"

    if (-not $User.Enabled) {
        Write-Host ""
        Write-Host "[STOP] User account is disabled."
        Write-Host "No group membership change will be made."
        exit
    }

    $CurrentGroups = Get-ADPrincipalGroupMembership -Identity $Username |
        Select-Object -ExpandProperty Name

    if ($CurrentGroups -contains $RequiredGroup) {
        Write-Host ""
        Write-Host "[INFO] User is already a member of $RequiredGroup."
        Write-Host "No remediation required."
        exit
    }

    Write-Host ""
    Write-Host "[WARNING] User does not currently have the required access group."
    Write-Host ""

    $Confirmation = Read-Host "Add '$Username' to '$RequiredGroup'? Type YES to continue"

    if ($Confirmation -ne "YES") {
        Write-Host ""
        Write-Host "[CANCELLED] No Active Directory changes were made."
        exit
    }

    Add-ADGroupMember -Identity $RequiredGroup -Members $Username
    Start-Sleep -Seconds 1

    $VerifiedGroups = Get-ADPrincipalGroupMembership -Identity $Username |
        Select-Object -ExpandProperty Name

    Write-Host ""
    Write-Host "Verification"
    Write-Host "------------"

    if ($VerifiedGroups -contains $RequiredGroup) {
        Write-Host "[SUCCESS] User added to $RequiredGroup."
        Write-Host "[NEXT] User must sign out and sign back in to receive a new security token."
    }
    else {
        Write-Host "[FAILED] Group membership could not be verified."
    }
}
catch {
    Write-Host ""
    Write-Host "[ERROR] File access remediation failed."
    Write-Host $_.Exception.Message
}
