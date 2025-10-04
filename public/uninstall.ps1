# CLIpper Uninstall Script for Windows
# Cross-platform System Management Tool
# https://aa6f8cd6-9526-49fe-9abe-c7500cf69a7c.canvases.tempo.build/

param(
    [switch]$Force,
    [switch]$Silent
)

# Colors for output
$Green = "Green"
$Red = "Red"
$Yellow = "Yellow"
$Blue = "Blue"

Write-Host "CLIpper Uninstall Script" -ForegroundColor $Red
Write-Host "Removing CLIpper from your system..." -ForegroundColor $Blue
Write-Host ""

# Confirm uninstall
function Confirm-Uninstall {
    if (-not $Silent) {
        Write-Host "⚠️  WARNING: This will completely remove CLIpper from your system." -ForegroundColor $Yellow
        Write-Host ""
        Write-Host "This will remove:"
        Write-Host "• CLIpper executable and directory"
        Write-Host "• Desktop and Start Menu shortcuts"
        Write-Host "• PATH configuration"
        Write-Host "• All CLIpper data and settings"
        Write-Host ""
        
        if (-not $Force) {
            $confirmation = Read-Host "Are you sure you want to continue? (y/N)"
            if ($confirmation -ne 'y' -and $confirmation -ne 'Y') {
                Write-Host "Uninstall cancelled." -ForegroundColor $Blue
                exit 0
            }
        }
        Write-Host ""
    }
}

# Remove CLIpper directory
function Remove-ClipperDirectory {
    $clipperPath = "$env:USERPROFILE\CLIpper"
    
    if (Test-Path $clipperPath) {
        try {
            Remove-Item -Recurse -Force $clipperPath
            Write-Host "✓ Removed CLIpper directory" -ForegroundColor $Green
        }
        catch {
            Write-Host "✗ Failed to remove CLIpper directory: $($_.Exception.Message)" -ForegroundColor $Red
        }
    } else {
        Write-Host "✓ CLIpper directory not found" -ForegroundColor $Green
    }
}

# Remove from PATH
function Remove-FromPath {
    try {
        $currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
        
        if ($currentPath -like "*CLIpper*") {
            # Remove CLIpper paths
            $newPath = $currentPath -replace ";?[^;]*CLIpper[^;]*", ""
            # Clean up any double semicolons
            $newPath = $newPath -replace ";;", ";"
            # Remove leading/trailing semicolons
            $newPath = $newPath.Trim(';')
            
            [Environment]::SetEnvironmentVariable("PATH", $newPath, "User")
            Write-Host "✓ Removed from PATH" -ForegroundColor $Green
        } else {
            Write-Host "✓ Not found in PATH" -ForegroundColor $Green
        }
    }
    catch {
        Write-Host "✗ Failed to remove from PATH: $($_.Exception.Message)" -ForegroundColor $Red
    }
}

# Remove desktop shortcut
function Remove-DesktopShortcut {
    $shortcutPath = "$env:USERPROFILE\Desktop\CLIpper.lnk"
    
    if (Test-Path $shortcutPath) {
        try {
            Remove-Item $shortcutPath -Force
            Write-Host "✓ Removed desktop shortcut" -ForegroundColor $Green
        }
        catch {
            Write-Host "✗ Failed to remove desktop shortcut: $($_.Exception.Message)" -ForegroundColor $Red
        }
    } else {
        Write-Host "✓ Desktop shortcut not found" -ForegroundColor $Green
    }
}

# Remove Start Menu entry
function Remove-StartMenuEntry {
    $startMenuPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\CLIpper.lnk"
    
    if (Test-Path $startMenuPath) {
        try {
            Remove-Item $startMenuPath -Force
            Write-Host "✓ Removed Start Menu entry" -ForegroundColor $Green
        }
        catch {
            Write-Host "✗ Failed to remove Start Menu entry: $($_.Exception.Message)" -ForegroundColor $Red
        }
    } else {
        Write-Host "✓ Start Menu entry not found" -ForegroundColor $Green
    }
}

# Remove registry entries (if any)
function Remove-RegistryEntries {
    try {
        # Remove any CLIpper-related registry entries
        $registryPaths = @(
            "HKCU:\Software\CLIpper",
            "HKLM:\Software\CLIpper"
        )
        
        foreach ($path in $registryPaths) {
            if (Test-Path $path) {
                Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue
                Write-Host "✓ Removed registry entries" -ForegroundColor $Green
            }
        }
    }
    catch {
        Write-Host "⚠ Could not remove registry entries: $($_.Exception.Message)" -ForegroundColor $Yellow
    }
}

# Verify uninstall
function Test-UninstallComplete {
    $clipperPath = "$env:USERPROFILE\CLIpper"
    $desktopShortcut = "$env:USERPROFILE\Desktop\CLIpper.lnk"
    $startMenuShortcut = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\CLIpper.lnk"
    
    $issues = @()
    
    if (Test-Path $clipperPath) {
        $issues += "CLIpper directory still exists"
    }
    
    if (Test-Path $desktopShortcut) {
        $issues += "Desktop shortcut still exists"
    }
    
    if (Test-Path $startMenuShortcut) {
        $issues += "Start Menu entry still exists"
    }
    
    $currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
    if ($currentPath -like "*CLIpper*") {
        $issues += "Still found in PATH"
    }
    
    if ($issues.Count -eq 0) {
        Write-Host "✓ Uninstall verification passed" -ForegroundColor $Green
        return $true
    } else {
        Write-Host "⚠ Uninstall verification found issues:" -ForegroundColor $Yellow
        foreach ($issue in $issues) {
            Write-Host "  • $issue" -ForegroundColor $Yellow
        }
        return $false
    }
}

# Main uninstall function
function Uninstall-CLIpper {
    Write-Host "Starting CLIpper uninstall..." -ForegroundColor $Blue
    Write-Host ""
    
    Confirm-Uninstall
    
    # Uninstall steps
    Remove-ClipperDirectory
    Remove-FromPath
    Remove-DesktopShortcut
    Remove-StartMenuEntry
    Remove-RegistryEntries
    
    Write-Host ""
    
    # Verify uninstall
    $success = Test-UninstallComplete
    
    Write-Host ""
    if ($success) {
        Write-Host "🗑️  CLIpper has been completely uninstalled!" -ForegroundColor $Green
    } else {
        Write-Host "⚠ CLIpper uninstall completed with some issues." -ForegroundColor $Yellow
        Write-Host "You may need to manually remove remaining files." -ForegroundColor $Yellow
    }
    
    Write-Host ""
    Write-Host "What was removed:" -ForegroundColor $Blue
    Write-Host "• CLIpper executable and all files"
    Write-Host "• Desktop and Start Menu shortcuts"
    Write-Host "• PATH configuration"
    Write-Host "• Registry entries and settings"
    Write-Host ""
    Write-Host "Please restart your PowerShell/Command Prompt for changes to take effect." -ForegroundColor $Yellow
    Write-Host ""
    Write-Host "Thank you for using CLIpper!" -ForegroundColor $Blue
}

# Run uninstall
Uninstall-CLIpper