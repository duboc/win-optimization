# Windows Development Environment Optimization

This project contains a set of scripts and guides to automate the setup of a high-performance Windows development machine, specifically tailored for **Python** and **Android** development.

## 🚀 Quick Start
Run the automated installer in PowerShell (Administrator):
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; ./install_dev_env.ps1
```

## 🛠 Configuration Details

### 1. Core System Tools
- **Winget**: We use the native Windows Packet Manager (`winget`) for all installations. It is cleaner, faster, and easier to maintain than downloading `.exe` installers manually.
- **Windows Terminal**: Replaces the legacy `cmd.exe` console. It supports GPU acceleration, tabs, and modern fonts, essential for a good CLI experience.
- **PowerShell 7**: The modern, cross-platform version of PowerShell. It is faster and has better scripting capabilities than the built-in Windows PowerShell 5.1.

### 2. Python Ecosystem
We avoid installing Python directly from python.org to prevent "Dependency Hell".
- **pyenv-win**: A tool to manage multiple Python versions.
    - *Why?* Allows you to switch between Python 3.10, 3.11, and 3.12 per project without conflicts.
    - *Configuration*: Installed to `%USERPROFILE%\.pyenv`. Added to system PATH.
- **Poetry**: The modern standard for Python dependency management and packaging.
    - *Why?* Handles virtual environments automatically and resolves dependency conflicts better than `pip`.
    - *Configuration*: Installed isolated from the system Python.

### 3. Android Ecosystem
- **Microsoft OpenJDK 17**: The recommended Java Development Kit for modern Android development.
    - *Why?* Android Studio requires a compatible JDK. Microsoft's build is optimized for Windows.
- **Android Studio**: The official IDE.
    - *Configuration*: Managed via Winget. The installer handles the Android SDK and Emulator hypervisor (AEHD/HAXM).

### 4. System Optimizations (Crucial)
These are applied by the script to fix common Windows performance bottlenecks.

#### 🛡️ Windows Defender Exclusions
- **What**: Excludes `~/projects` from real-time antivirus scanning.
- **Why**: Antivirus software significantly slows down builds (e.g., Gradle builds, Python imports, node_modules) by scanning every file read/write. **This can improve build times by 2x-5x.**

#### 🔓 Developer Mode
- **What**: Enables the system to run sideloaded apps and use symbolic links (`ln -s`) without admin privileges.
- **Why**: Many dev tools (git, npm, yarn) rely on symlinks.

#### 🐧 WSL2 (Windows Subsystem for Linux)
- **What**: A real Linux kernel running inside Windows.
- **Why**: While this setup optimizes *Windows*, some Python/Backend tools still run best on Linux. We ensure WSL is installed so you have the best of both worlds.

#### 🧩 PowerToys
- **What**: A suite of utilities for power users.
- **Why**: Includes "FancyZones" for window management and "PowerRun" for quick launching workflow.

## 📂 File Structure
- `install_dev_env.ps1`: The main automation script. Reads linear instructions to install all components.
- `setup_guide.md`: A human-readable step-by-step guide if you prefer manual installation.
- `optimize_terminal.ps1`: Customizes PowerShell. **Note**: If the font installation fails, run `oh-my-posh font install meslo` manually.
- `setup_github_ssh.ps1`: Helper script to generate SSH keys and add them to your GitHub account.
- `verify_setup.ps1`: A script to validate that all tools are correctly installed and available in the PATH.
