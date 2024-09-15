function logAction ($msg) {
    Write-Host $msg -ForegroundColor Blue
}
function logError ($msg) {
    Write-Host $msg -ForegroundColor Red
}
function logInfo ($msg) {
    Write-Host $msg -ForegroundColor Yellow
}
function logSuccess ($msg) {
    Write-Host $msg -ForegroundColor Green
}
function logWarning ($msg) {
    Write-Host $msg -ForegroundColor Magenta
}
function CheckForElevatedPriviledges () {  
    $user = [Security.Principal.WindowsIdentity]::GetCurrent();
    if (!(New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
        logError "Error: This script requires elevated priviledges"
        exit
    }
}

CheckForElevatedPriviledges

$USER_RC_PATH=$HOME
$PATH_TO_PACK = ($ENV:USERPROFILE + "\.vim\pack")

Install-Module -AllowClobber Get-ChildItemColor -Force -Scope AllUsers
Install-Module Posh-Git -Force -Scope AllUsers
Install-Module -Name Terminal-Icons -Repository PSGallery
Install-Module PSReadLine -AllowPrerelease -Force

$files = @(".vimrc", ".ideavimrc", ".config\starship.toml", ".config\alacritty\alacritty.yml")

$SOURCE="${PATH_TO_PACK}\templates\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
New-Item -ItemType SymbolicLink -Force -Path $PROFILE -Target $SOURCE

Foreach ($file in $files) {
	$SOURCE="${PATH_TO_PACK}\templates\${file}"
	$DEST="${USER_RC_PATH}\${file}"
	$DESTPATH=(Split-Path -Path $DEST)
	mkdir "${DESTPATH}" -ea 0 | Out-Null
	New-Item -ItemType SymbolicLink -Force -Path $DEST -Target $SOURCE
}
