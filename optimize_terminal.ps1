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
    
    # Explicitly pick the non-DZ version to match the "MesloLGL Nerd Font" name in settings
    $fontFile = Get-ChildItem -Path $fontDir -Filter "MesloLGLNerdFont-Regular.ttf" | Select-Object -First 1
    
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

# 5. Configure Profile (All Hosts)
$profilePath = $PROFILE.CurrentUserAllHosts
if (-not (Test-Path $profilePath)) {
    if (-not (Test-Path (Split-Path $profilePath))) {
        New-Item -ItemType Directory -Path (Split-Path $profilePath) -Force | Out-Null
    }
    New-Item -Type File -Path $profilePath -Force | Out-Null
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

Add-Content -Path $profilePath -Value $profileConfig

# 6. Configure Windows Terminal Settings (Auto-set Font)
Write-Host "Configuring Windows Terminal Fonts..."
try {
    $settingsPath = Get-ChildItem "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal*\LocalState\settings.json" | Select-Object -First 1 -ExpandProperty FullName
    
    if ($settingsPath -and (Test-Path $settingsPath)) {
        $json = Get-Content $settingsPath -Raw | ConvertFrom-Json
        
        # Ensure hierarchy exists
        if (-not $json.profiles) { $json | Add-Member -MemberType NoteProperty -Name "profiles" -Value @{} }
        if (-not $json.profiles.defaults) { $json.profiles | Add-Member -MemberType NoteProperty -Name "defaults" -Value @{} }
        
        # Set Font
        $fontObj = @{ face = "MesloLGL Nerd Font" }
        $json.profiles.defaults | Add-Member -MemberType NoteProperty -Name "font" -Value $fontObj -Force
        
        # Save back
        $json | ConvertTo-Json -Depth 10 | Set-Content $settingsPath
        Write-Host "Windows Terminal settings updated! Font set to 'MesloLGL Nerd Font'." -ForegroundColor Green
    }
    else {
        Write-Warning "Could not find Windows Terminal settings.json. Please set font manually."
    }
}
catch {
    Write-Warning "Failed to update Windows Terminal settings safely: $_"
}

Write-Host "=== Customization Complete! ===" -ForegroundColor Green
Write-Host "1. Restart Windows Terminal."
Write-Host "2. Enjoy your new shell!"
