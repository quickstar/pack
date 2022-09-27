# Ensure git log uses correct encoding (german Umlaute)
$env:LC_ALL = 'C.UTF-8'

# Make sure the required modules are on path
Import-Module posh-git
Import-Module Get-ChildItemColor
Import-Module Terminal-Icons

# Disable posh-git prompt since starship takes care of this, only use it for tab-completion
$GitPromptSettings.EnableFileStatus = $false

function cup { Set-Location .. }
function cleanpwd { (Get-Location).Path }
function chome { Set-Location ~ }
function cgit { Set-Location $HOME\git }
function gs { git status }
function gh { git hist }

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

# Default the prompt to robbyrussell oh-my-posh theme
# Set-PoshPrompt -Theme robbyrussel
Invoke-Expression (&starship init powershell)

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
