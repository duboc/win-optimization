# Windows Developer Setup Guide

This guide describes how to replicate the Python and Android development environment implementation.

## Prerequisites
- Windows 10/11 (Recent builds recommended)
- Administrator privileges
- Internet connection

## 1. Automated Installation (Recommended)
You can use the provided PowerShell script `install_dev_env.ps1` to automate most of these steps.
1. Open PowerShell as Administrator.
2. Run: `Set-ExecutionPolicy Bypass -Scope Process`
3. Run: `./install_dev_env.ps1`

## 2. Manual Installation Steps

### Core Tools (Winget)
The most reliable way to install tools on modern Windows is via `winget`.
```powershell
# Essential Tools
winget install -e --id Git.Git
winget install -e --id Microsoft.VisualStudioCode
winget install -e --id Microsoft.WindowsTerminal
winget install -e --id Microsoft.PowerShell
```

### Python Environment
1. **Pyenv for Windows**:
   ```powershell
   Invoke-WebRequest -UseBasicParsing -Uri "https://raw.githubusercontent.com/pyenv-win/pyenv-win/master/pyenv-win/install-pyenv-win.ps1" -OutFile "./install-pyenv-win.ps1"; &"./install-pyenv-win.ps1"
   ```
2. **Environment Variables**:
   Ensure `pyenv` is in your PATH (the installer usually handles this, but a restart is required).
3. **Install Python**:
   ```powershell
   pyenv install 3.12.0
   pyenv global 3.12.0
   ```
4. **Poetry** (Dependency Management):
   ```powershell
   (Invoke-WebRequest -Uri https://install.python-poetry.org -UseBasicParsing).Content | python -
   ```

### Android Environment
1. **Java JDK 17** (Required for Android):
   ```powershell
   winget install -e --id Microsoft.OpenJDK.17
   ```
2. **Android Studio**:
   ```powershell
   winget install -e --id Google.AndroidStudio
   ```
   *After install, launch Android Studio to complete the SDK setup wizard.*

### VS Code Extensions
Run these commands in your terminal to install recommended extensions:
```powershell
code --install-extension ms-python.python
code --install-extension ms-python.vscode-pylance
code --install-extension tamasfe.even-better-toml
```

### Terminal Customization (For Linux Users)
To make PowerShell feel more like Zsh/Bash (with theming and aliases):
1. Run the customization script:
   ```powershell
   ./optimize_terminal.ps1
   ```
2. Restart Windows Terminal. The font and theme should now be active.

### GitHub SSH Setup
To authenticate with GitHub securely without passwords:
1. Run the provided helper script:
   ```powershell
   ./setup_github_ssh.ps1
   ```
2. Follow the prompts to generate a key and copy it to your clipboard.
3. The script will open GitHub. Paste your key and save.
4. Verify by running: `ssh -T git@github.com`

### System Optimizations
1. **Developer Mode**: Enables easier testing and symbolic links.
   ```powershell
   reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" /t REG_DWORD /f /v "AllowDevelopmentWithoutDevLicense" /d "1"
   ```
2. **Windows Defender Exclusions**:
   **Crucial for performance.** Exclude your project folders from real-time scanning to speed up builds (Python/Android/Gradle).
   ```powershell
   Add-MpPreference -ExclusionPath "C:\Users\YOUR_USER\projects"
   ```
3. **PowerToys**:
   Installs utilities like FancyZones, PowerRun, and ColorPicker.
   ```powershell
   winget install -e --id Microsoft.PowerToys
   ```
4. **WSL2 (Windows Subsystem for Linux)**:
   Recommended for Python backend development.
   ```powershell
   wsl --install
   ```

## 3. Verification
Run the following checks in a **new** terminal window:
```powershell
git --version
python --version
poetry --version
java -version
```
