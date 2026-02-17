<#
.SYNOPSIS
    Make PowerShell feel like Linux (Zsh/Bash) - Text Only Version
.DESCRIPTION
    Installs:
    1. Oh My Posh (Theming engine) with 'robbyrussell' theme (Text based, no Nerd Fonts needed)
    2. PSReadLine (Autosuggestions)
    3. Configures 'ls', 'grep', 'touch', etc. aliases.
#>

$ErrorActionPreference = "Stop"

Write-Host "=== Linuxifying PowerShell (Text Only) ===" -ForegroundColor Cyan

# 1. Install Oh My Posh
if (-not (Get-Command oh-my-posh -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Oh My Posh..."
    winget install JanDeDobbeleer.OhMyPosh -s winget --accept-source-agreements --accept-package-agreements
}

# 2. Configure Profile (All Hosts)
$profilePath = $PROFILE.CurrentUserAllHosts
# Ensure directory exists
if (-not (Test-Path (Split-Path $profilePath))) {
    New-Item -ItemType Directory -Path (Split-Path $profilePath) -Force | Out-Null
}

$profileConfig = @"
# Oh My Posh Theme (RobbyRussell - Zsh style, text only)
oh-my-posh init pwsh --config 'https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/robbyrussell.omp.json' | Invoke-Expression

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

Set-Content -Path $profilePath -Value $profileConfig -Force

Write-Host "=== Customization Complete! ===" -ForegroundColor Green
Write-Host "1. Restart Windows Terminal."
Write-Host "2. You should now have a Linux-like text prompt."
