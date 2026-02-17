<#
.SYNOPSIS
    Automated Development Environment Installer for Windows
.DESCRIPTION
    Installs Git, VS Code, Windows Terminal, Python (via pyenv), Poetry, Java JDK, and Android Studio.
#>

$ErrorActionPreference = "Stop"

function Install-WingetPackage {
    param([string]$Id)
    Write-Host "Installing $Id..." -ForegroundColor Cyan
    winget install -e --id $Id --accept-source-agreements --accept-package-agreements
}

# 1. Core Tools
Write-Host "=== Installing Core Tools ===" -ForegroundColor Green
Install-WingetPackage "Git.Git"
Install-WingetPackage "Microsoft.VisualStudioCode"
Install-WingetPackage "Microsoft.WindowsTerminal"
Install-WingetPackage "Microsoft.PowerShell"

# 2. Python Setup
Write-Host "=== Setting up Python ===" -ForegroundColor Green
# Pyenv-win setup
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
Invoke-WebRequest -UseBasicParsing -Uri "https://raw.githubusercontent.com/pyenv-win/pyenv-win/master/pyenv-win/install-pyenv-win.ps1" -OutFile "$env:TEMP\install-pyenv-win.ps1"
& "$env:TEMP\install-pyenv-win.ps1"

# Reload Environment Variables (Mock reload without restart)
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Install Python 3.12 via pyenv
$pyenv = "$env:USERPROFILE\.pyenv\pyenv-win\bin\pyenv.bat"
if (Test-Path $pyenv) {
    & $pyenv install 3.12.0
    & $pyenv global 3.12.0
} else {
    Write-Warning "Pyenv executable not found at expected path. Please restart terminal."
}

# Install Poetry
Write-Host "Installing Poetry..."
$poetryInstaller = "https://install.python-poetry.org"
(Invoke-WebRequest -Uri $poetryInstaller -UseBasicParsing).Content | python -

# 3. Android Setup
Write-Host "=== Setting up Android ===" -ForegroundColor Green
Install-WingetPackage "Microsoft.OpenJDK.17"
Install-WingetPackage "Google.AndroidStudio"

# 4. System Optimizations
Write-Host "=== Applying Windows Optimizations ===" -ForegroundColor Green

# Enable Developer Mode
Write-Host "Enabling Developer Mode..."
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" /t REG_DWORD /f /v "AllowDevelopmentWithoutDevLicense" /d "1"

# Install PowerToys (Productivity Tools)
Install-WingetPackage "Microsoft.PowerToys"

# Windows Defender Exclusion for Projects (Improves Build Speed)
$projectDir = "$env:USERPROFILE\projects"
if (-not (Test-Path $projectDir)) { New-Item -ItemType Directory -Force -Path $projectDir | Out-Null }
Write-Host "Adding Defender Exclusion for $projectDir (Improves build performance)..."
if (Get-Command "Add-MpPreference" -ErrorAction SilentlyContinue) {
    Add-MpPreference -ExclusionPath $projectDir
}

# Ensure WSL2 is installed
Write-Host "Checking WSL2 status..."
if (-not (Get-Command "wsl" -ErrorAction SilentlyContinue)) {
    Write-Host "Installing WSL2..."
    wsl --install
} else {
    Write-Host "WSL is already installed."
}

Write-Host "=== Installation Complete! ===" -ForegroundColor Cyan
Write-Host "Please restart your computer to ensure all changes take effect." -ForegroundColor Yellow
