$ErrorActionPreference = "SilentlyContinue"

Write-Host "=== Windows Optimization Verification ===" -ForegroundColor Cyan

# functions
function Test-Command ($cmd, $args) {
    Write-Host -NoNewline "Checking $cmd... "
    try {
        $out = & $cmd $args 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "OK ($($out | Select-Object -First 1))" -ForegroundColor Green
            return $true
        } else {
            Write-Host "FAILED" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "NOT FOUND" -ForegroundColor Red
        return $false
    }
}

# check tools
Test-Command "git" "--version"
Test-Command "code" "--version"
Test-Command "wt" "-v" # Windows Terminal

# check python
$pythonPath = "c:\Users\duboc\.pyenv\pyenv-win\versions\3.12.0\python.exe"
if (Test-Path $pythonPath) {
    Write-Host "Python 3.12.0 found at $pythonPath" -ForegroundColor Green
    & $pythonPath --version
} else {
    Write-Host "Python 3.12.0 NOT FOUND" -ForegroundColor Red
}

# check poetry
$poetryPath = "$env:APPDATA\Python\Scripts\poetry.exe" # Common location if installed via pip user
if (-not (Test-Path $poetryPath)) {
    $poetryPath = "$env:APPDATA\pypoetry\venv\Scripts\poetry.exe" # Script install location
}

if (Test-Path $poetryPath) {
    Write-Host "Poetry found at $poetryPath" -ForegroundColor Green
    & $poetryPath --version
} else {
    # check via python module
    $poetryCheck = & $pythonPath -m poetry --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Poetry found via module" -ForegroundColor Green
    } else {
        Write-Host "Poetry NOT FOUND" -ForegroundColor Red
    }
}

# check java
Test-Command "java" "-version"

# check android
$androidHome = "$env:LOCALAPPDATA\Android\Sdk"
if (Test-Path $androidHome) {
    Write-Host "Android SDK folder found at $androidHome" -ForegroundColor Green
} else {
     Write-Host "Android SDK folder NOT FOUND (Normal if Android Studio hasn't run yet)" -ForegroundColor Yellow
}

Write-Host "=== End Verification ===" -ForegroundColor Cyan
