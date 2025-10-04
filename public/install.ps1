# CLIpper Installation Script for Windows
# Cross-platform System Management Tool
# https://aa6f8cd6-9526-49fe-9abe-c7500cf69a7c.canvases.tempo.build/

param(
    [switch]$Force,
    [string]$InstallPath = "$env:USERPROFILE\CLIpper"
)

# Colors for output
$Green = "Green"
$Red = "Red"
$Yellow = "Yellow"
$Blue = "Blue"

# CLIpper version
$ClipperVersion = "1.0.0"
$BaseUrl = "https://aa6f8cd6-9526-49fe-9abe-c7500cf69a7c.canvases.tempo.build"

Write-Host "CLIpper Installation Script v$ClipperVersion" -ForegroundColor $Green
Write-Host "Cross-platform System Management Tool" -ForegroundColor $Blue
Write-Host ""

# Check if running as Administrator
function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Create installation directory
function New-InstallDirectory {
    Write-Host "Creating installation directory..." -ForegroundColor $Blue
    if (!(Test-Path $InstallPath)) {
        New-Item -ItemType Directory -Force -Path $InstallPath | Out-Null
        Write-Host "✓ Created directory: $InstallPath" -ForegroundColor $Green
    } else {
        Write-Host "✓ Directory exists: $InstallPath" -ForegroundColor $Green
    }
}

# Download CLIpper executable
function Get-ClipperExecutable {
    Write-Host "Downloading CLIpper executable..." -ForegroundColor $Blue
    
    $downloadUrl = "$BaseUrl/clipper-windows.exe"
    $outputPath = "$InstallPath\clipper.exe"
    
    try {
        # Use TLS 1.2
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        
        Invoke-WebRequest -Uri $downloadUrl -OutFile $outputPath -UseBasicParsing
        Write-Host "✓ Downloaded CLIpper executable" -ForegroundColor $Green
        
        # Verify file exists and has size
        $fileInfo = Get-Item $outputPath
        if ($fileInfo.Length -gt 0) {
            Write-Host "✓ File size: $([math]::Round($fileInfo.Length / 1MB, 2)) MB" -ForegroundColor $Green
        } else {
            throw "Downloaded file is empty"
        }
    }
    catch {
        Write-Host "✗ Failed to download CLIpper: $($_.Exception.Message)" -ForegroundColor $Red
        Write-Host "Please check your internet connection and try again." -ForegroundColor $Yellow
        exit 1
    }
}

# Add CLIpper to PATH
function Add-ToPath {
    Write-Host "Adding CLIpper to PATH..." -ForegroundColor $Blue
    
    $currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
    
    if ($currentPath -notlike "*$InstallPath*") {
        $newPath = "$currentPath;$InstallPath"
        [Environment]::SetEnvironmentVariable("PATH", $newPath, "User")
        Write-Host "✓ Added to user PATH" -ForegroundColor $Green
    } else {
        Write-Host "✓ Already in PATH" -ForegroundColor $Green
    }
}

# Create desktop shortcut
function New-DesktopShortcut {
    Write-Host "Creating desktop shortcut..." -ForegroundColor $Blue
    
    try {
        $shell = New-Object -ComObject WScript.Shell
        $shortcutPath = "$env:USERPROFILE\Desktop\CLIpper.lnk"
        $shortcut = $shell.CreateShortcut($shortcutPath)
        $shortcut.TargetPath = "$InstallPath\clipper.exe"
        $shortcut.WorkingDirectory = $InstallPath
        $shortcut.Description = "CLIpper - System Management Tool"
        $shortcut.Save()
        Write-Host "✓ Created desktop shortcut" -ForegroundColor $Green
    }
    catch {
        Write-Host "⚠ Could not create desktop shortcut: $($_.Exception.Message)" -ForegroundColor $Yellow
    }
}

# Create Start Menu entry
function New-StartMenuEntry {
    Write-Host "Creating Start Menu entry..." -ForegroundColor $Blue
    
    try {
        $startMenuPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs"
        $shell = New-Object -ComObject WScript.Shell
        $shortcutPath = "$startMenuPath\CLIpper.lnk"
        $shortcut = $shell.CreateShortcut($shortcutPath)
        $shortcut.TargetPath = "$InstallPath\clipper.exe"
        $shortcut.WorkingDirectory = $InstallPath
        $shortcut.Description = "CLIpper - System Management Tool"
        $shortcut.Save()
        Write-Host "✓ Created Start Menu entry" -ForegroundColor $Green
    }
    catch {
        Write-Host "⚠ Could not create Start Menu entry: $($_.Exception.Message)" -ForegroundColor $Yellow
    }
}

# Verify installation
function Test-Installation {
    Write-Host "Verifying installation..." -ForegroundColor $Blue
    
    $clipperPath = "$InstallPath\clipper.exe"
    if (Test-Path $clipperPath) {
        Write-Host "✓ CLIpper executable found" -ForegroundColor $Green
        
        # Test if it's in PATH
        try {
            $env:PATH = [Environment]::GetEnvironmentVariable("PATH", "User") + ";" + [Environment]::GetEnvironmentVariable("PATH", "Machine")
            $pathTest = Get-Command clipper -ErrorAction SilentlyContinue
            if ($pathTest) {
                Write-Host "✓ CLIpper is accessible from PATH" -ForegroundColor $Green
            } else {
                Write-Host "⚠ CLIpper not yet in PATH (restart terminal)" -ForegroundColor $Yellow
            }
        }
        catch {
            Write-Host "⚠ PATH verification failed" -ForegroundColor $Yellow
        }
    } else {
        Write-Host "✗ CLIpper executable not found" -ForegroundColor $Red
        exit 1
    }
}

# Main installation function
function Install-CLIpper {
    Write-Host "Starting CLIpper installation..." -ForegroundColor $Blue
    Write-Host "Install path: $InstallPath" -ForegroundColor $Blue
    Write-Host ""
    
    # Check administrator privileges
    if (Test-Administrator) {
        Write-Host "✓ Running with Administrator privileges" -ForegroundColor $Green
    } else {
        Write-Host "⚠ Not running as Administrator" -ForegroundColor $Yellow
        Write-Host "Some features may require elevated privileges" -ForegroundColor $Yellow
    }
    Write-Host ""
    
    # Installation steps
    New-InstallDirectory
    Get-ClipperExecutable
    Add-ToPath
    New-DesktopShortcut
    New-StartMenuEntry
    Test-Installation
    
    Write-Host ""
    Write-Host "🎉 CLIpper installation completed successfully!" -ForegroundColor $Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor $Blue
    Write-Host "1. Restart your PowerShell/Command Prompt" -ForegroundColor $Yellow
    Write-Host "2. Type: clipper --help" -ForegroundColor $Yellow
    Write-Host "3. Run: clipper --scan (system analysis)" -ForegroundColor $Yellow
    Write-Host "4. Run: clipper --optimize (performance boost)" -ForegroundColor $Yellow
    Write-Host ""
    Write-Host "Documentation: $BaseUrl/docs" -ForegroundColor $Blue
    Write-Host "Support: $BaseUrl/support" -ForegroundColor $Blue
    Write-Host ""
    Write-Host "Thank you for installing CLIpper!" -ForegroundColor $Green
}

# Run installation
Install-CLIpper