param (
    [Parameter(Mandatory = $true)]
    [string]$Username,

    [string]$RequiredGroup = "GG-Finance",
    [string]$ShareName = "Finance",
    [string]$FolderPath = "C:\Shares\Finance"
)

Import-Module ActiveDirectory

Write-Host ""
Write-Host "============================================"
Write-Host " File Share Access Diagnostic"
Write-Host "============================================"
Write-Host ""

try {
    Write-Host "User Information"
    Write-Host "----------------"

    $User = Get-ADUser -Identity $Username -Properties Enabled, DistinguishedName

    Write-Host "Username : $($User.SamAccountName)"
    Write-Host "Name     : $($User.Name)"
    Write-Host "Enabled  : $($User.Enabled)"

    Write-Host ""
    Write-Host "AD Group Membership"
    Write-Host "-------------------"

    $Groups = Get-ADPrincipalGroupMembership -Identity $Username |
        Select-Object -ExpandProperty Name

    if ($Groups -contains $RequiredGroup) {
        Write-Host "[OK] User is a member of $RequiredGroup."
        $GroupMembershipOK = $true
    }
    else {
        Write-Host "[WARNING] User is NOT a member of $RequiredGroup."
        $GroupMembershipOK = $false
    }

    Write-Host ""
    Write-Host "SMB Share Check"
    Write-Host "---------------"

    try {
        $Share = Get-SmbShare -Name $ShareName -ErrorAction Stop
        Write-Host "[OK] SMB share exists: \\$env:COMPUTERNAME\$ShareName"
        Write-Host "Path : $($Share.Path)"

        $ShareAccess = Get-SmbShareAccess -Name $ShareName -ErrorAction Stop

        Write-Host ""
        Write-Host "Share Permissions"
        Write-Host "-----------------"

        $ShareAccess |
            Select-Object AccountName, AccessControlType, AccessRight |
            Format-Table -AutoSize
    }
    catch {
        Write-Host "[WARNING] SMB share '$ShareName' was not found."
    }

    Write-Host ""
    Write-Host "NTFS Permission Check"
    Write-Host "---------------------"

    if (Test-Path $FolderPath) {
        $ACL = Get-Acl $FolderPath

        $RelevantRules = $ACL.Access |
            Where-Object { $_.IdentityReference -match $RequiredGroup }

        if ($RelevantRules) {
            Write-Host "[OK] NTFS ACL contains $RequiredGroup."

            $RelevantRules |
                Select-Object IdentityReference, FileSystemRights, AccessControlType, IsInherited |
                Format-Table -AutoSize

            $NTFSGroupPresent = $true
        }
        else {
            Write-Host "[WARNING] NTFS ACL does not contain $RequiredGroup."
            $NTFSGroupPresent = $false
        }
    }
    else {
        Write-Host "[ERROR] Folder path does not exist: $FolderPath"
        $NTFSGroupPresent = $false
    }

    Write-Host ""
    Write-Host "Diagnostic Summary"
    Write-Host "------------------"

    if (-not $User.Enabled) {
        Write-Host "[LIKELY ISSUE] User account is disabled."
    }
    elseif (-not $GroupMembershipOK -and $NTFSGroupPresent) {
        Write-Host "[LIKELY ISSUE] User lacks the AD group required by the NTFS authorization model."
    }
    elseif ($GroupMembershipOK -and -not $NTFSGroupPresent) {
        Write-Host "[LIKELY ISSUE] User has expected group membership, but the folder ACL does not authorize that group."
    }
    elseif ($GroupMembershipOK -and $NTFSGroupPresent) {
        Write-Host "[OK] AD group membership and expected NTFS authorization appear correct."
        Write-Host "[INFO] If access still fails, investigate the user's current logon token and share permissions."
    }
    else {
        Write-Host "[WARNING] Multiple authorization conditions require investigation."
    }
}
catch {
    Write-Host ""
    Write-Host "[ERROR] File access diagnostic failed."
    Write-Host $_.Exception.Message
}
