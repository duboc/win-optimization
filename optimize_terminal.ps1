<#
.SYNOPSIS
    Make PowerShell feel like Linux (Zsh/Bash)
.DESCRIPTION
    Installs:
    1. Oh My Posh (Theming engine)
    2. Meslo LGM Nerd Font (Required for icons)
    3. Terminal-Icons (Folder/File icons)
    4. PSReadLine (Autosuggestions)
    5. Configures 'ls', 'grep', 'touch', etc. aliases.
#>

$ErrorActionPreference = "Stop"

Write-Host "=== Linuxifying PowerShell ===" -ForegroundColor Cyan

# 1. Install Oh My Posh
if (-not (Get-Command oh-my-posh -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Oh My Posh..."
    winget install JanDeDobbeleer.OhMyPosh -s winget --accept-source-agreements --accept-package-agreements
}

# 2. Install Nerd Font (Meslo) via Zip (More reliable)
$fontZip = "$env:TEMP\Meslo.zip"
$fontDir = "$env:TEMP\MesloFont"
$fontUrl = "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Meslo.zip"

Write-Host "Downloading Meslo Nerd Font... (This might take a moment)"
try {
    Invoke-WebRequest -Uri $fontUrl -OutFile $fontZip
    
    Write-Host "Extracting font..."
    Expand-Archive -Path $fontZip -DestinationPath $fontDir -Force
    
    $fontFile = Get-ChildItem -Path $fontDir -Filter "*MesloLG*NerdFont-Regular.ttf" | Select-Object -First 1
    
    if ($fontFile) {
        Write-Host "Installing $($fontFile.Name)..."
        $shell = New-Object -ComObject Shell.Application
        $fontsFolder = $shell.Namespace(0x14) # 0x14 = Fonts
        $fontsFolder.CopyHere($fontFile.FullName)
        Write-Host "Font installed successfully!" -ForegroundColor Green
    }
    else {
        Write-Error "Could not find the specific font file in the extracted archive."
    }
}
catch {
    Write-Warning "Font installation failed. You may need to run 'oh-my-posh font install meslo' manually."
    Write-Warning "Error: $_"
}

# Cleanup
Remove-Item $fontZip -ErrorAction SilentlyContinue
Remove-Item $fontDir -Recurse -ErrorAction SilentlyContinue

# 3. Install Terminal-Icons Module
Write-Host "Installing Terminal-Icons module..."
Install-Module -Name Terminal-Icons -Repository PSGallery -Force -SkipPublisherCheck -Scope CurrentUser

# 5. Configure Profile
if (-not (Test-Path $PROFILE)) {
    New-Item -Type File -Path $PROFILE -Force
}

$profileConfig = @"
# Import Modules
Import-Module Terminal-Icons

# Oh My Posh Theme (Linux-like)
oh-my-posh init pwsh --config 'https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/tokyonight_storm.omp.json' | Invoke-Expression

# Aliases & Functions (Linux Feel)
function grep { Select-String -Pattern `$args }
function touch { New-Item -ItemType File -Name `$args -Force }
function df { Get-PSDrive -PSProvider FileSystem }
function sudo { Start-Process powershell -Verb RunAs -ArgumentList `"-NoExit -Command `$args`" }
Set-Alias ll Get-ChildItem -Option AllScope

# Navigation
function .. { Set-Location .. }
function ... { Set-Location ..\.. }

# PSReadLine (Autosuggestions like Fish shell)
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -EditMode Windows
"@

Add-Content -Path $PROFILE -Value $profileConfig

Write-Host "=== Customization Complete! ===" -ForegroundColor Green
Write-Host "1. Restart Windows Terminal."
Write-Host "2. Go to Settings -> Profiles -> Defaults -> Appearance."
Write-Host "3. Set 'Font face' to 'MesloLGL Nerd Font'."
Write-Host "4. Enjoy your new shell!"
