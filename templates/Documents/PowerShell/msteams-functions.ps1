function Get-TeamsPhoneNumberStatus {
    <#
    .SYNOPSIS
    Gets the detailed status of a specific Teams phone number.

    .DESCRIPTION
    Retrieves comprehensive information about a Teams phone number, including its assignment status,
    associated user details, and location information.

    .PARAMETER TelephoneNumber
    The phone number to check, in E.164 format (e.g., "+41315110135")

    .EXAMPLE
    Get-TeamsPhoneNumberStatus -TelephoneNumber "+41315110135"
    Returns the status for the specified phone number

    .EXAMPLE
    "+41315110135", "+41315110136" | Get-TeamsPhoneNumberStatus
    Checks status for multiple phone numbers using pipeline input
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$TelephoneNumber
    )

    if (!(Initialize-TeamsConnection)) {
        return
    }

    $numberAssignment = Get-CsPhoneNumberAssignment -TelephoneNumber $TelephoneNumber
    if (!$numberAssignment) {
        Write-Error "Phone number $TelephoneNumber not found"
        return
    }

    if ($numberAssignment.AssignedPstnTargetId) {
        $user = Get-CsOnlineUser -Identity $numberAssignment.AssignedPstnTargetId
        [PSCustomObject]@{
            TelephoneNumber = $numberAssignment.TelephoneNumber
            Status = $numberAssignment.PstnAssignmentStatus
            AssignedTo = $user.DisplayName
            UserPrincipalName = $user.UserPrincipalName
            EnterpriseVoiceEnabled = $user.EnterpriseVoiceEnabled
            NumberType = $numberAssignment.NumberType
            ActivationState = $numberAssignment.ActivationState
            Location = "$($numberAssignment.City), $($numberAssignment.IsoCountryCode)"
        }
    }
    else {
        [PSCustomObject]@{
            TelephoneNumber = $numberAssignment.TelephoneNumber
            Status = $numberAssignment.PstnAssignmentStatus
            AssignedTo = "Unassigned"
            UserPrincipalName = $null
            EnterpriseVoiceEnabled = $null
            NumberType = $numberAssignment.NumberType
            ActivationState = $numberAssignment.ActivationState
            Location = "$($numberAssignment.City), $($numberAssignment.IsoCountryCode)"
        }
    }
}

function Get-TeamsPhoneUser {
    <#
    .SYNOPSIS
    Lists all Teams users with phone numbers assigned.

    .DESCRIPTION
    Retrieves a detailed list of all users who have Teams phone numbers assigned,
    including their phone numbers and voice settings.

    .EXAMPLE
    Get-TeamsPhoneUser
    Lists all users with Teams phone numbers
    #>
    if (!(Initialize-TeamsConnection)) {
        return
    }

    Get-CsPhoneNumberAssignment | Select-Object @{
        Name = 'User'
        Expression = {Get-CsOnlineUser -Identity $_.AssignedPstnTargetId}
    }, TelephoneNumber, NumberType, ActivationState, AssignmentCategory | Select-Object @{
        Name = 'DisplayName'
        Expression = {$_.User.DisplayName}
    }, @{
        Name = 'UserPrincipalName'
        Expression = {$_.User.UserPrincipalName}
    }, @{
        Name = 'LineURI'
        Expression = {$_.User.LineURI}
    }, @{
        Name = 'EnterpriseVoiceEnabled'
        Expression = {$_.User.EnterpriseVoiceEnabled}
    }, TelephoneNumber, NumberType, ActivationState, AssignmentCategory | Format-List
}

function Get-TeamsUnassignedPhoneNumber {
    <#
    .SYNOPSIS
    Lists all unassigned Teams phone numbers.

    .DESCRIPTION
    Retrieves a list of all phone numbers in your Teams tenant that are currently not assigned to any user.

    .EXAMPLE
    Get-TeamsUnassignedPhoneNumber
    Lists all unassigned phone numbers with their details
    #>
    [CmdletBinding()]
    param()

    if (!(Initialize-TeamsConnection)) {
        return
    }

    Get-CsPhoneNumberAssignment | Where-Object { $_.PstnAssignmentStatus -eq "Unassigned" } | Select-Object TelephoneNumber, NumberType, ActivationState, City, IsoCountryCode
}

function Get-TeamsVoiceRoutingPolicyAssignment {
    <#
    .SYNOPSIS
    Lists all users with voice routing policies assigned.

    .DESCRIPTION
    Retrieves a list of all users who have Teams voice routing policies assigned,
    showing their current phone numbers and voice settings.

    .EXAMPLE
    Get-TeamsVoiceRoutingPolicyAssignment
    Lists all users with voice routing policies
    #>
    [CmdletBinding()]
    param()

    if (!(Initialize-TeamsConnection)) {
        return
    }

    Get-CsOnlineUser | Where-Object {$_.OnlineVoiceRoutingPolicy -ne $null} | Select-Object @{
        Name = 'DisplayName'
        Expression = {$_.DisplayName}
    }, @{
        Name = 'UserPrincipalName'
        Expression = {$_.UserPrincipalName}
    }, @{
        Name = 'VoiceRoutingPolicy'
        Expression = {$_.OnlineVoiceRoutingPolicy}
    }, @{
        Name = 'PhoneNumber'
        Expression = {$_.LineUri}
    }, @{
        Name = 'EnterpriseVoiceEnabled'
        Expression = {$_.EnterpriseVoiceEnabled}
    } | Format-Table -AutoSize
}

function Initialize-TeamsConnection {
    <#
    .SYNOPSIS
    Ensures Teams PowerShell module is available and connected.

    .DESCRIPTION
    Checks if the MicrosoftTeams module is installed and imported,
    and ensures there is an active connection to Teams. Will attempt
    to connect if not already connected.

    .EXAMPLE
    Initialize-TeamsConnection
    Initializes Teams connection if needed
    #>
    # Check if MicrosoftTeams module is installed
    if (!(Get-Module -ListAvailable -Name MicrosoftTeams)) {
        Write-Error "MicrosoftTeams module is not installed. Please install it using: Install-Module -Name MicrosoftTeams"
        return $false
    }

    # Check if MicrosoftTeams module is imported
    if (!(Get-Module -Name MicrosoftTeams)) {
        try {
            Import-Module MicrosoftTeams
            Write-Verbose "MicrosoftTeams module imported successfully"
        }
        catch {
            Write-Error "Failed to import MicrosoftTeams module: $_"
            return $false
        }
    }

    # Check if connected to Teams and try to connect if not
    try {
        $null = Get-CsOnlineUser -ResultSize 1
        return $true
    }
    catch {
        Write-Host "Not connected to Teams. Attempting to connect..."
        try {
            Connect-MicrosoftTeams
            return $true
        }
        catch {
            Write-Error "Failed to connect to Microsoft Teams: $_"
            return $false
        }
    }
}

function Remove-TeamsPhoneNumber {
    <#
    .SYNOPSIS
    Removes a Teams phone number assignment and optionally the number itself.

    .DESCRIPTION
    Removes a phone number assignment from a user and also removes the voice routing policy.
    If the number becomes unassigned, it can also be removed from the tenant completely.

    .PARAMETER TelephoneNumber
    The phone number to remove, in E.164 format (e.g., "+41315110135")

    .EXAMPLE
    Remove-TeamsPhoneNumber -TelephoneNumber "+41315110135"
    Removes the number assignment and the number if it becomes unassigned
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$TelephoneNumber
    )

    if (!(Initialize-TeamsConnection)) {
        return
    }

    # Get current number assignment status
    $numberAssignment = Get-CsPhoneNumberAssignment -TelephoneNumber $TelephoneNumber
    if (!$numberAssignment) {
        Write-Error "Phone number $TelephoneNumber not found"
        return
    }

    # If number is assigned to a user, remove the assignment first
    if ($numberAssignment.AssignedPstnTargetId) {
        $userId = $numberAssignment.AssignedPstnTargetId
        Write-Verbose "Removing assignment from user $userId"
        try {
            Remove-CsPhoneNumberAssignment -Identity $userId -RemoveAll
            Grant-CsOnlineVoiceRoutingPolicy -Identity $userId -PolicyName $null
            Write-Host "Successfully removed number assignment and voice routing policy from user"
            
            # Get fresh status after removal
            $numberAssignment = Get-CsPhoneNumberAssignment -TelephoneNumber $TelephoneNumber
            Write-Verbose "Updated status after removal: $($numberAssignment.PstnAssignmentStatus)"
        }
        catch {
            Write-Error "Failed to remove number assignment: $_"
            return
        }
    }

    # Now check if we still need to remove the unassigned number
    if ($numberAssignment.PstnAssignmentStatus -eq "Unassigned") {
        Write-Verbose "Removing unassigned number $TelephoneNumber"
        try {
            Remove-CsOnlineTelephoneNumber -TelephoneNumber $TelephoneNumber
            Write-Host "Successfully removed phone number $TelephoneNumber"
        }
        catch {
            Write-Error "Failed to remove phone number: $_"
            return
        }
    }
}

function Set-TeamsPhoneNumber {
    <#
    .SYNOPSIS
    Assigns a Teams phone number to a user.

    .DESCRIPTION
    Assigns a phone number to a Teams user and configures the necessary voice routing policy.
    If the number is currently assigned to another user, it will be removed from that user first.

    .PARAMETER TelephoneNumber
    The phone number to assign, in E.164 format (e.g., "+41315110135")

    .PARAMETER Identity
    The user's identity (typically their UPN, e.g., "user@domain.com")

    .PARAMETER VoiceRoutingPolicy
    The voice routing policy to assign (defaults to "sipcall")

    .EXAMPLE
    Set-TeamsPhoneNumber -TelephoneNumber "+41315110135" -Identity "user@domain.com"
    Assigns the specified number to the user with default voice routing policy

    .EXAMPLE
    Set-TeamsPhoneNumber -TelephoneNumber "+41315110135" -Identity "user@domain.com" -VoiceRoutingPolicy "custom-policy"
    Assigns the number with a custom voice routing policy
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$TelephoneNumber,
        
        [Parameter(Mandatory = $true)]
        [string]$Identity,

        [Parameter(Mandatory = $false)]
        [string]$VoiceRoutingPolicy = "sipcall"  # Default policy name
    )

    if (!(Initialize-TeamsConnection)) {
        return
    }

    # Get current number assignment status
    $numberAssignment = Get-CsPhoneNumberAssignment -TelephoneNumber $TelephoneNumber
    if (!$numberAssignment) {
        Write-Error "Phone number $TelephoneNumber not found"
        return
    }

    # If number is currently assigned to someone else, remove that assignment first
    if ($numberAssignment.AssignedPstnTargetId -and $numberAssignment.AssignedPstnTargetId -ne $Identity) {
        Write-Verbose "Removing current assignment from user $($numberAssignment.AssignedPstnTargetId)"
        try {
            Remove-CsPhoneNumberAssignment -Identity $numberAssignment.AssignedPstnTargetId -RemoveAll
            Grant-CsOnlineVoiceRoutingPolicy -Identity $numberAssignment.AssignedPstnTargetId -PolicyName $null
            Write-Host "Successfully removed previous number assignment and voice routing policy"
        }
        catch {
            Write-Error "Failed to remove previous number assignment: $_"
            return
        }
    }

    # Assign number to new user
    try {
        Set-CsPhoneNumberAssignment -Identity $Identity -PhoneNumber $TelephoneNumber -PhoneNumberType DirectRouting
        Write-Host "Successfully assigned $TelephoneNumber to $Identity"

        # Set voice routing policy
        Grant-CsOnlineVoiceRoutingPolicy -Identity $Identity -PolicyName $VoiceRoutingPolicy
        Write-Host "Successfully assigned voice routing policy '$VoiceRoutingPolicy' to $Identity"
    }
    catch {
        Write-Error "Failed to configure phone settings: $_"
    }
}

#endregion
