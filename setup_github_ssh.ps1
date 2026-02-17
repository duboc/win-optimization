<#
.SYNOPSIS
    GitHub SSH Key Setup Script
.DESCRIPTION
    Generates an Ed25519 SSH key, starts the ssh-agent, adds the key, copies the public key to the clipboard, and opens GitHub settings.
#>

$ErrorActionPreference = "Stop"

Write-Host "=== GitHub SSH Setup ===" -ForegroundColor Cyan

# 1. Check/Install System Tools
if (-not (Get-Command ssh-keygen -ErrorAction SilentlyContinue)) {
    Write-Host "Installing OpenSSH..."
    Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0
}

# 2. Key Generation
$sshDir = "$env:USERPROFILE\.ssh"
if (-not (Test-Path $sshDir)) { New-Item -ItemType Directory -Force -Path $sshDir | Out-Null }
$keyPath = "$sshDir\id_ed25519"

if (Test-Path $keyPath) {
    Write-Warning "An SSH key already exists at $keyPath"
    $response = Read-Host "Do you want to overwrite it? (y/n)"
    if ($response -eq 'y') {
        Remove-Item $keyPath
        Remove-Item "$keyPath.pub"
    }
}

if (-not (Test-Path $keyPath)) {
    $email = Read-Host "Enter your GitHub email address (e.g., mail@example.com)"
    if (-not [string]::IsNullOrWhiteSpace($email)) {
        Write-Host "Generating SSH key..."
        & ssh-keygen -t ed25519 -C "$email" -f $keyPath
    } else {
        Write-Error "Email is required to generate a key."
        exit 1
    }
}

# 3. Configure SSH Agent
Write-Host "Configuring ssh-agent..."
# Ensure the service is not disabled (Admin might be required for this)
try {
    $service = Get-Service ssh-agent
    if ($service.Status -ne 'Running') {
        Set-Service ssh-agent -StartupType Manual
        Start-Service ssh-agent
    }
} catch {
    Write-Warning "Could not configure ssh-agent service automatically. Run as Administrator if this fails."
}

# 4. Add Key
Write-Host "Adding key to agent..."
& ssh-add $keyPath

# 5. Copy to Clipboard
if (Test-Path "$keyPath.pub") {
    Get-Content "$keyPath.pub" | Set-Clipboard
    Write-Host "Public key copied to clipboard!" -ForegroundColor Green
    
    # 6. Open GitHub
    Write-Host "Opening GitHub settings..."
    Start-Process "https://github.com/settings/ssh/new"
    
    Write-Host "Instructions:" -ForegroundColor Yellow
    Write-Host "1. Paste the key (Ctrl+V) into the 'Key' field on the GitHub page opened."
    Write-Host "2. Give it a title (e.g., 'Windows PC')."
    Write-Host "3. Click 'Add SSH key'."
    Write-Host "4. Test with: ssh -T git@github.com"
}
