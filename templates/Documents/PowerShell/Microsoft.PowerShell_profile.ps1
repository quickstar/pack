function cup { Set-Location .. }
function cleanpwd { (Get-Location).Path }
function chome { Set-Location ~ }
function cgit { Set-Location d:\git }
function gs { git status }
function publicip { (Invoke-WebRequest -Uri 'ipinfo.io' -UseBasicParsing).Content | ConvertFrom-Json | Format-List }

$profileRealPath = (Get-Item $PROFILE).Target
$profileDirectory = Split-Path $profileRealPath -Parent
. "$profileDirectory\msteams-functions.ps1"

# Set all the aliases
Remove-Item Alias:pwd -Force
Set-Alias pwd cleanpwd
Set-Alias l Get-ChildItem -Option AllScope
Set-Alias ls Get-ChildItemColorFormatWide -Option AllScope
Set-Alias ll ls
Set-Alias .. cup
Set-Alias which Get-Command -ErrorAction SilentlyContinue
Set-Alias ~ chome -Option AllScope
Set-Alias vi vim
Set-Alias k kubectl
Set-Alias gg lazygit
Set-Alias reboot Restart-Computer

# Include this if you like a vim command line experience
Set-PSReadlineOption -EditMode vi -BellStyle None -ViModeIndicator Script -ViModeChangeHandler {
    if ($args[0] -eq 'Command') {
        # Set the cursor to a blinking block.
        Write-Host -NoNewLine "$([char]0x1b)[1 q"
    }
    else {
        # Set the cursor to a blinking line.
        Write-Host -NoNewLine "$([char]0x1b)[5 q"
    }
}

# With those bindings, up/down arrows will work like default if the command line is blank.
# If you have entered some text though, it will search the history for commands that start
# with the currently entered text.
Set-PSReadlineKeyHandler -Key UpArrow   -Function HistorySearchBackward
Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward

## This is now enabled by default: https://devblogs.microsoft.com/powershell/psreadline-2-2-6-enables-predictive-intellisense-by-default/
Set-PSReadLineOption -PredictionViewStyle ListView
# Set-PSReadLineOption -PredictionSource History

# This omits the output of an extra line break after each command
$Global:GetChildItemColorVerticalSpace = 0

if (Get-Command "zoxide" -errorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init --cmd cd powershell | Out-String) })
}

# Default the prompt to robbyrussell oh-my-posh theme
# Set-PoshPrompt -Theme robbyrussel
Invoke-Expression (&starship init powershell)

function Remove-CursorCodeFiles {
    [CmdletBinding()]
    param()

    # Get path to the target directory using environment variable
    $targetPath = Join-Path -Path $env:LOCALAPPDATA -ChildPath "Programs\cursor\resources\app\bin"
    
    # Use wildcard to match both files
    $codeFilesPattern = Join-Path -Path $targetPath -ChildPath "code*"
    
    try {
        # Remove matching files and return success message
        Remove-Item -Path $codeFilesPattern -Include "code", "code.cmd" -Force -ErrorAction Stop
        return "Successfully removed code files from $targetPath"
    }
    catch {
        return "Failed to remove code files: $_"
    }
}

## --------------------------------------------------------------- ##
##  Some handy functions which makes all day work more enjoyable   ##
## --------------------------------------------------------------- ##
function AddTo-Path {
    param ( 
        [string]$PathToAdd,
        [Parameter(Mandatory = $true)][ValidateSet('System', 'User')][string]$UserType
    )
    $PathType = 'Path'

    if ($UserType -eq "System" ) { $RegPropertyLocation = 'HKLM:\System\CurrentControlSet\Control\Session Manager\Environment' }
    if ($UserType -eq "User"   ) { $RegPropertyLocation = 'HKCU:\Environment' } # also note: Registry::HKEY_LOCAL_MACHINE\ format

    $PathOld = (Get-ItemProperty -Path $RegPropertyLocation -Name $PathType).$PathType
    "`n$UserType $PathType Before:`n$PathOld`n"
    $PathArray = $PathOld -Split ";" -replace "\\+$", ""

    if ($PathArray -notcontains $PathToAdd) {
        "$UserType $PathType Now:"   # ; sleep -Milliseconds 100   # Might need pause to prevent text being after Path output(!)
        $PathNew = "$PathOld;$PathToAdd"
        Set-ItemProperty -Path $RegPropertyLocation -Name $PathType -Value $PathNew
        Get-ItemProperty -Path $RegPropertyLocation -Name $PathType | select -ExpandProperty $PathType
        if ($PathType -eq "Path") { $env:Path += ";$PathToAdd" }                  # Add to Path also for this current session
        if ($PathType -eq "PSModulePath") { $env:PSModulePath += ";$PathToAdd" }  # Add to PSModulePath also for this current session
        "`n$PathToAdd has been added to the $UserType $PathType"
    }
    else {
        "'$PathToAdd' is already in the $UserType $PathType. Nothing to do."
    }
}
function Cleanup-Path {
    param ( 
        [Parameter(Mandatory = $true)][ValidateSet('System', 'User')][string]$UserType
    )
    $PathType = 'Path'

    # Cleanup-Path System Path
    if ($UserType -eq "System" ) { $RegPropertyLocation = 'HKLM:\System\CurrentControlSet\Control\Session Manager\Environment' }
    if ($UserType -eq "User"   ) { $RegPropertyLocation = 'HKCU:\Environment' } # also note: Registry::HKEY_LOCAL_MACHINE\ format

    $PathOld = (Get-ItemProperty -Path $RegPropertyLocation -Name $PathType).$PathType
    "`n$UserType $PathType Before:`n$PathOld`n"
    $PathArray = ($PathOld -Split ";" -replace "\\+$", "" | Sort-Object -Unique | Where-Object { $_ })
	
    $distinctPath = ($PathArray -join ';')
    "`n$UserType $PathType After:`n$distinctPath`n"
    Set-ItemProperty -Path $RegPropertyLocation -Name $PathType -Value $distinctPath

    $env:path = ($env:path -Split ";" -replace "\\+$", "" | Sort-Object -Unique | Where-Object { $_ }) -join ';'
}

function Load-PoshGit {
    if (Get-Module posh-git) {
        return  # Already loaded, do nothing
    }

    Write-Verbose "Loading posh-git module..."

    # Try to find the highest version of posh-git installed
    $poshGitModule = Get-Module posh-git -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1
    if ($poshGitModule) {
        $poshGitModule | Import-Module
    }
    # If you keep a local copy in src\posh-git.psd1:
    elseif (Test-Path -LiteralPath ($modulePath = Join-Path (Split-Path $MyInvocation.MyCommand.Path -Parent) (Join-Path src 'posh-git.psd1'))) {
        Import-Module $modulePath
    }

    # Disable posh-git prompt so that starship takes care of the prompt
    # (posh-git must already be imported before setting $GitPromptSettings)
    $Global:GitPromptSettings.EnableFileStatus = $false
}

# Create a timer that fires once after ~1 second
$timer = New-Object System.Timers.Timer
$timer.Interval = 1000  # 1000 ms = 1 second
$timer.AutoReset = $false  # Only fire once

# Register an event for when the timer Elapses
Register-ObjectEvent -InputObject $timer -EventName Elapsed -Action {
    # Safely stop the timer so it doesn't fire again
    $timer.Stop()

    # Ensure git log uses correct encoding (german Umlaute)
    $env:LC_ALL = 'C.UTF-8'
    Import-Module Terminal-Icons
    Load-PoshGit

    # Import the Chocolatey Profile that contains the necessary code to enable
    # tab-completions to function for `choco`.
    $ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
    if (Test-Path($ChocolateyProfile)) {
        Import-Module "$ChocolateyProfile"
    }
} | Out-Null

# Start the timer
$timer.Start()

## --------------------------- ##
##  Additional Autocompleters  ##
## --------------------------- ##
Register-ArgumentCompleter -Native -CommandName winget -ScriptBlock {
	param($wordToComplete, $commandAst, $cursorPosition)
	[Console]::InputEncoding = [Console]::OutputEncoding = $OutputEncoding = [System.Text.Utf8Encoding]::new()
	$Local:word = $wordToComplete.Replace('"', '""')
	$Local:ast = $commandAst.ToString().Replace('"', '""')
	winget complete --word="$Local:word" --commandline "$Local:ast" --position $cursorPosition | ForEach-Object {
		[System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
	}
}
