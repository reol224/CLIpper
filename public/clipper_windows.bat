@echo off
setlocal enabledelayedexpansion

:: CLIpper - Windows System Scanner
:: Collects comprehensive system information

set "VERSION=1.0.0"
set "SCRIPT_NAME=CLIpper"
set "GITHUB_RAW_URL=https://raw.githubusercontent.com/reol224/CLIpper/main/public/clipper_windows.bat"

:: Enable ANSI color support for Windows 10/11
for /f "tokens=4-5 delims=. " %%i in ('ver') do set VERSION_NUM=%%i.%%j
if "%VERSION_NUM%" geq "10.0" (
    :: Enable ANSI escape sequences
    reg add HKCU\Console /v VirtualTerminalLevel /t REG_DWORD /d 1 /f >nul 2>&1
)

:: Color definitions for Windows
set "RED=echo."
set "GREEN=echo."
set "YELLOW=echo."
set "BLUE=echo."
set "CYAN=echo."
set "WHITE=echo."
set "RESET=echo."

:: Check for admin privileges
net session >nul 2>&1
if %errorLevel% == 0 (
    set "IS_ADMIN=1"
) else (
    set "IS_ADMIN=0"
)

:: Parse command line arguments
if "%1"=="" goto auto_check_and_menu
if /I "%1"=="--scan" goto full_scan
if /I "%1"=="--scan-quick" goto quick_scan
if /I "%1"=="--hardware" goto hardware_info
if /I "%1"=="--network" goto network_info
if /I "%1"=="--performance" goto performance_info
if /I "%1"=="--security" goto security_audit
if /I "%1"=="--clean" goto clean_system
if /I "%1"=="--update" goto check_updates
if /I "%1"=="--menu" goto show_menu
if /I "%1"=="--install" goto install_script
if /I "%1"=="--uninstall" goto uninstall_script
if /I "%1"=="--export" goto export_json
if /I "%1"=="--help" goto show_usage
if /I "%1"=="-h" goto show_usage
if /I "%1"=="--version" goto show_version
if /I "%1"=="-v" goto show_version
goto show_usage

:auto_check_and_menu
call :auto_update_check
goto show_menu

:show_version
echo %SCRIPT_NAME% v%VERSION%
echo GitHub: https://github.com/reol224/CLIpper
goto end

:show_usage
echo.
echo ===============================================================================
echo    %SCRIPT_NAME% v%VERSION%
echo ===============================================================================
echo.
echo DESCRIPTION:
echo    Comprehensive system monitoring, analysis, and maintenance tool for Windows.
echo    Collects real-time hardware, software, network, and security information.
echo.
echo USAGE:
echo    %~nx0 [OPTIONS]
echo.
echo SCANNING OPTIONS:
echo    --scan              Run complete system scan
echo    --scan-quick        Run quick scan (basic info only)
echo    --hardware          Show only hardware information
echo    --network           Show only network information
echo    --performance       Show only performance metrics
echo    --security          Run security audit
echo.
echo MAINTENANCE OPTIONS:
echo    --clean             Clean system (cache, temp files, logs)
echo    --update            Check for updates and update script
echo    --menu              Show interactive menu
echo    --install           Install system-wide (requires Administrator)
echo    --uninstall         Uninstall from system (requires Administrator)
echo    --export [FILE]     Export scan results to text file
echo.
echo INFORMATION OPTIONS:
echo    --help, -h          Show this help message
echo    --version, -v       Show version information
echo.
echo EXAMPLES:
echo    %~nx0 --scan                    # Full system scan
echo    %~nx0 --scan-quick              # Quick overview
echo    %~nx0 --hardware                # Hardware info only
echo    %~nx0 --security                # Security audit
echo    %~nx0 --clean                   # System cleanup
echo    %~nx0 --update                  # Check for updates
echo.
echo NOTES:
echo    - Some operations require Administrator privileges
echo    - Run as Administrator for complete results
echo    - Current Admin Status: 
if %IS_ADMIN%==1 (
    echo      [ADMIN] Full access available
) else (
    echo      [USER] Limited access - run as Administrator for full features
)
echo.
goto end

:print_header
echo.
echo ===============================================================================
echo  %~1
echo ===============================================================================
echo.
goto :eof

:full_scan
call :auto_update_check
call :print_header "STARTING COMPLETE SYSTEM SCAN"
call :os_info
call :architecture_info
call :cpu_info
call :memory_info
call :display_info
call :battery_info
call :network_info
call :storage_info
call :timezone_info
call :performance_info
call :system_details
echo.
echo --- Scan Complete! ---
echo.
goto end

:quick_scan
call :print_header "QUICK SYSTEM SCAN"
call :os_info
call :cpu_info
call :memory_info
call :storage_info
echo.
echo --- Quick Scan Complete! ---
echo.
goto end

:hardware_info
call :print_header "HARDWARE INFORMATION"
call :os_info
call :architecture_info
call :cpu_info
call :memory_info
call :display_info
goto end

:network_info
call :print_header "NETWORK INFORMATION"
call :network_details
goto end

:performance_info
call :print_header "PERFORMANCE METRICS"
call :performance_details
goto end

:: Operating System Information
:os_info
echo.
echo --- Operating System Information ---
echo.
systeminfo | findstr /B /C:"OS Name" /C:"OS Version" /C:"OS Manufacturer" /C:"OS Configuration" /C:"OS Build Type" /C:"System Boot Time" /C:"System Manufacturer" /C:"System Model"
goto :eof

:: Architecture Information
:architecture_info
echo.
echo --- Architecture ---
echo.
systeminfo | findstr /B /C:"System Type" /C:"Processor(s)"
wmic cpu get Name,Architecture,AddressWidth /format:list | findstr /V "^$"
goto :eof

:: CPU Information
:cpu_info
echo.
echo --- CPU Information ---
echo.
wmic cpu get Name,NumberOfCores,NumberOfLogicalProcessors,MaxClockSpeed,CurrentClockSpeed,LoadPercentage /format:list | findstr /V "^$"
echo.
echo Load Average:
wmic cpu get loadpercentage /value
goto :eof

:: Memory Information
:memory_info
echo.
echo --- Memory Information ---
echo.
systeminfo | findstr /B /C:"Total Physical Memory" /C:"Available Physical Memory"
wmic OS get FreePhysicalMemory,TotalVisibleMemorySize /format:list | findstr /V "^$"
wmic ComputerSystem get TotalPhysicalMemory /format:list | findstr /V "^$"
echo.
echo Virtual Memory:
systeminfo | findstr /B /C:"Virtual Memory"
goto :eof

:: Display Information
:display_info
echo.
echo --- Display Information ---
echo.
wmic path Win32_VideoController get Name,CurrentHorizontalResolution,CurrentVerticalResolution,CurrentRefreshRate /format:list | findstr /V "^$"
goto :eof

:: Battery Information
:battery_info
echo.
echo --- Battery Information ---
echo.
WMIC Path Win32_Battery Get BatteryStatus,EstimatedChargeRemaining,EstimatedRunTime /format:list 2>nul | findstr /V "^$"
if %errorLevel% neq 0 (
    echo No battery detected ^(Desktop or battery info not available^)
)
goto :eof

:: Network Information
:network_details
echo.
echo --- Network Information ---
echo.
echo Active Network Adapters:
wmic nic where "NetEnabled=true" get Name,Speed,MACAddress /format:list | findstr /V "^$"
echo.
echo IP Configuration:
ipconfig | findstr /C:"IPv4" /C:"Subnet" /C:"Default Gateway" /C:"Adapter"
echo.
echo Network Statistics:
netstat -e
echo.
echo Internet Connectivity:
ping -n 2 8.8.8.8 | findstr /C:"Reply" /C:"Lost"
goto :eof

:: Storage Information
:storage_info
echo.
echo --- Storage Information ---
echo.
wmic logicaldisk get DeviceID,FileSystem,Size,FreeSpace,VolumeName /format:list | findstr /V "^$"
echo.
echo Disk Performance:
wmic diskdrive get Model,Size,Status,InterfaceType /format:list | findstr /V "^$"
goto :eof

:: Timezone Information
:timezone_info
echo.
echo --- Timezone ^& Locale ---
echo.
echo Current Time:
echo %DATE% %TIME%
systeminfo | findstr /B /C:"System Locale" /C:"Input Locale" /C:"Time Zone"
goto :eof

:: Performance Information
:performance_details
echo.
echo --- Performance Metrics ---
echo.
echo Process Count:
tasklist | find /C /V ""
echo.
echo Top Processes by Memory:
wmic process get Name,WorkingSetSize /format:csv | sort /R | findstr /V "^," | findstr /V "Node,Name" | more +1
echo.
echo System Uptime:
systeminfo | findstr /B /C:"System Boot Time"
goto :eof

:: System Details
:system_details
echo.
echo --- Additional System Information ---
echo.
echo Logged in Users:
query user 2>nul
if %errorLevel% neq 0 (
    echo Current User: %USERNAME%
)
echo.
echo Environment:
echo Computer Name: %COMPUTERNAME%
echo User Name: %USERNAME%
echo User Domain: %USERDOMAIN%
echo User Profile: %USERPROFILE%
echo.
echo Windows Directory: %WINDIR%
echo System Drive: %SYSTEMDRIVE%
echo Program Files: %PROGRAMFILES%
goto :eof

:: Security Audit
:security_audit
call :print_header "SECURITY AUDIT"

set /a issues_found=0

echo.
echo Checking Windows Firewall status...
netsh advfirewall show allprofiles state | findstr /C:"State"
echo.

echo Checking Windows Defender status...
if %IS_ADMIN%==1 (
    powershell -Command "Get-MpComputerStatus | Select-Object AntivirusEnabled,RealTimeProtectionEnabled,IoavProtectionEnabled,OnAccessProtectionEnabled | Format-List"
) else (
    echo ! Requires Administrator privileges for full results
)
echo.

echo Checking User Account Control...
reg query HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v EnableLUA 2>nul | findstr /C:"EnableLUA"
echo.

echo Checking Windows Update status...
if %IS_ADMIN%==1 (
    powershell -Command "Get-HotFix | Select-Object -Last 5 | Format-Table -AutoSize"
) else (
    echo ! Requires Administrator privileges
)
echo.

echo Checking Administrator accounts...
net localgroup Administrators
echo.

echo Checking shared folders...
net share
echo.

echo Checking running services...
echo Services Count:
sc query type= service state= all | find /C "SERVICE_NAME"
echo.

echo Checking open ports...
netstat -ano | findstr /C:"LISTENING"
echo.

echo Checking failed login attempts...
if %IS_ADMIN%==1 (
    powershell -Command "Get-EventLog -LogName Security -InstanceId 4625 -Newest 10 -ErrorAction SilentlyContinue | Select-Object TimeGenerated,Message | Format-List" 2>nul
    if !errorLevel! neq 0 (
        echo No recent failed login attempts found
    )
) else (
    echo ! Requires Administrator privileges
)
echo.

echo Checking BitLocker status...
if %IS_ADMIN%==1 (
    manage-bde -status 2>nul
    if !errorLevel! neq 0 (
        echo BitLocker information not available
    )
) else (
    echo ! Requires Administrator privileges
)
echo.

echo Checking autorun programs...
if %IS_ADMIN%==1 (
    wmic startup get Caption,Command,Location /format:list | findstr /V "^$"
) else (
    reg query HKCU\Software\Microsoft\Windows\CurrentVersion\Run 2>nul
)
echo.

echo ===============================================================================
if %issues_found% leq 3 (
    echo Security Audit Complete: System appears secure
) else (
    echo Security Audit Complete: Review findings above
)
echo ===============================================================================
echo.
echo Note: Run as Administrator for complete security audit
echo.
goto end

:: Clean System
:clean_system
call :print_header "SYSTEM CLEANUP"

echo This will help you clean temporary files and caches
echo You will be asked before each cleanup operation
echo.

:: 1. Windows Temp files
echo Windows Temp Files:
for /f %%A in ('dir /b /s %TEMP% 2^>nul ^| find /c /v ""') do set temp_count=%%A
echo   User Temp: %TEMP%
echo   Files found: %temp_count%
set /p clean_temp="Clean Windows Temp files? (Y/N): "
if /I "%clean_temp%"=="Y" (
    del /s /q %TEMP%\*.* >nul 2>&1
    del /s /q %WINDIR%\Temp\*.* >nul 2>&1
    echo   - Temp files cleaned
) else (
    echo   - Skipped
)

:: 2. Recycle Bin
echo.
echo Recycle Bin:
if %IS_ADMIN%==1 (
    set /p clean_recycle="Empty Recycle Bin? (Y/N): "
    if /I "!clean_recycle!"=="Y" (
        rd /s /q C:\$Recycle.Bin >nul 2>&1
        echo   - Recycle Bin emptied
    ) else (
        echo   - Skipped
    )
) else (
    echo   ! Requires Administrator privileges
)

:: 3. Windows Update Cache
echo.
echo Windows Update Cache:
if %IS_ADMIN%==1 (
    if exist "%WINDIR%\SoftwareDistribution\Download" (
        for /f %%A in ('dir /b /s "%WINDIR%\SoftwareDistribution\Download" 2^>nul ^| find /c /v ""') do set update_count=%%A
        echo   Location: %WINDIR%\SoftwareDistribution\Download
        echo   Files found: !update_count!
    )
    set /p clean_update="Clean Windows Update cache? (Y/N): "
    if /I "!clean_update!"=="Y" (
        net stop wuauserv >nul 2>&1
        del /s /q %WINDIR%\SoftwareDistribution\Download\*.* >nul 2>&1
        net start wuauserv >nul 2>&1
        echo   - Windows Update cache cleaned
    ) else (
        echo   - Skipped
    )
) else (
    echo   ! Requires Administrator privileges
)

:: 4. Prefetch
echo.
echo Prefetch Files:
if %IS_ADMIN%==1 (
    if exist "%WINDIR%\Prefetch" (
        for /f %%A in ('dir /b "%WINDIR%\Prefetch\*.pf" 2^>nul ^| find /c /v ""') do set prefetch_count=%%A
        echo   Location: %WINDIR%\Prefetch
        echo   Files found: !prefetch_count!
    )
    set /p clean_prefetch="Clean Prefetch files? (Y/N): "
    if /I "!clean_prefetch!"=="Y" (
        del /s /q %WINDIR%\Prefetch\*.* >nul 2>&1
        echo   - Prefetch cleaned
    ) else (
        echo   - Skipped
    )
) else (
    echo   ! Requires Administrator privileges
)

:: 5. DNS Cache
echo.
echo DNS Cache:
set /p clean_dns="Flush DNS cache? (Y/N): "
if /I "%clean_dns%"=="Y" (
    ipconfig /flushdns >nul 2>&1
    echo   - DNS cache flushed
) else (
    echo   - Skipped
)

:: 6. Browser Caches
echo.
echo Browser Caches:

:: Chrome
if exist "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache" (
    for /f %%A in ('dir /b /s "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache" 2^>nul ^| find /c /v ""') do set chrome_count=%%A
    echo   Chrome cache files: !chrome_count!
    set /p clean_chrome="Clean Chrome cache? (Y/N): "
    if /I "!clean_chrome!"=="Y" (
        taskkill /F /IM chrome.exe >nul 2>&1
        rd /s /q "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache" >nul 2>&1
        echo   - Chrome cache cleaned
    ) else (
        echo   - Skipped
    )
)

:: Edge
if exist "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache" (
    for /f %%A in ('dir /b /s "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache" 2^>nul ^| find /c /v ""') do set edge_count=%%A
    echo   Edge cache files: !edge_count!
    set /p clean_edge="Clean Edge cache? (Y/N): "
    if /I "!clean_edge!"=="Y" (
        taskkill /F /IM msedge.exe >nul 2>&1
        rd /s /q "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache" >nul 2>&1
        echo   - Edge cache cleaned
    ) else (
        echo   - Skipped
    )
)

:: Firefox
if exist "%LOCALAPPDATA%\Mozilla\Firefox\Profiles" (
    echo   Firefox profiles found
    set /p clean_firefox="Clean Firefox cache? (Y/N): "
    if /I "!clean_firefox!"=="Y" (
        taskkill /F /IM firefox.exe >nul 2>&1
        for /d %%i in ("%LOCALAPPDATA%\Mozilla\Firefox\Profiles\*") do (
            rd /s /q "%%i\cache2" >nul 2>&1
        )
        echo   - Firefox cache cleaned
    ) else (
        echo   - Skipped
    )
)

:: 7. Thumbnail Cache
echo.
echo Thumbnail Cache:
if exist "%LOCALAPPDATA%\Microsoft\Windows\Explorer" (
    for /f %%A in ('dir /b "%LOCALAPPDATA%\Microsoft\Windows\Explorer\thumbcache_*.db" 2^>nul ^| find /c /v ""') do set thumb_count=%%A
    echo   Thumbnail cache files: !thumb_count!
    set /p clean_thumbs="Clean thumbnail cache? (Y/N): "
    if /I "!clean_thumbs!"=="Y" (
        del /f /q "%LOCALAPPDATA%\Microsoft\Windows\Explorer\thumbcache_*.db" >nul 2>&1
        echo   - Thumbnail cache cleaned
    ) else (
        echo   - Skipped
    )
)

:: 8. Disk Cleanup
echo.
echo Windows Disk Cleanup:
if %IS_ADMIN%==1 (
    set /p run_cleanmgr="Run Windows Disk Cleanup utility? (Y/N): "
    if /I "!run_cleanmgr!"=="Y" (
        cleanmgr /sagerun:1 >nul 2>&1
        echo   - Disk cleanup initiated
    ) else (
        echo   - Skipped
    )
) else (
    echo   ! Requires Administrator privileges
)

echo.
echo ===============================================================================
echo  Cleanup Process Complete!
echo ===============================================================================
echo.
goto end

:: Export to JSON/Text
:export_json
set "output_file=system_scan_%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%%time:~6,2%.txt"
set "output_file=%output_file: =0%"
if not "%2"=="" set "output_file=%2"

echo Exporting scan results to: %output_file%
echo.

(
echo ===============================================================================
echo Windows System Scan Report
echo Generated: %DATE% %TIME%
echo ===============================================================================
echo.
call :os_info
call :architecture_info
call :cpu_info
call :memory_info
call :storage_info
call :network_details
) > "%output_file%"

echo Export complete: %output_file%
echo.
goto end

:: Check for updates
:check_updates
echo.
echo ===============================================================================
echo  CHECKING FOR UPDATES
echo ===============================================================================
echo.

echo Current version: %VERSION%
echo Checking GitHub repository...
echo.

:: Check if PowerShell is available
where powershell >nul 2>&1
if %errorLevel% neq 0 (
    echo Error: PowerShell is required to check for updates
    goto end
)

:: Download latest script to temp location
set "TEMP_SCRIPT=%TEMP%\clipper_windows_temp.bat"

echo Downloading latest version...
powershell -Command "try { Invoke-WebRequest -Uri '%GITHUB_RAW_URL%' -OutFile '%TEMP_SCRIPT%' -UseBasicParsing } catch { exit 1 }" >nul 2>&1

if %errorLevel% neq 0 (
    echo Error: Failed to download script from GitHub
    echo Please check your internet connection and try again
    goto end
)

:: Extract version from downloaded script
for /f "tokens=2 delims==" %%A in ('findstr /B "set \"VERSION=" "%TEMP_SCRIPT%"') do (
    set "REMOTE_VERSION=%%A"
)
set "REMOTE_VERSION=%REMOTE_VERSION:"=%"

if "%REMOTE_VERSION%"=="" (
    echo Error: Could not determine remote version
    del "%TEMP_SCRIPT%" >nul 2>&1
    goto end
)

echo Latest version: %REMOTE_VERSION%
echo.

:: Compare versions
if "%VERSION%"=="%REMOTE_VERSION%" (
    echo You are running the latest version!
    echo.
    del "%TEMP_SCRIPT%" >nul 2>&1
    goto end
)

echo A new version is available!
echo   Current: %VERSION%
echo   Latest:  %REMOTE_VERSION%
echo.

set /p update_confirm="Would you like to update now? (Y/N): "
if /I not "%update_confirm%"=="Y" (
    echo Update cancelled
    echo.
    del "%TEMP_SCRIPT%" >nul 2>&1
    goto end
)

:: Perform update
echo.
echo Updating script...
echo.

:: Replace current script
copy /Y "%TEMP_SCRIPT%" "%~f0" >nul 2>&1
if %errorLevel% equ 0 (
    echo Updated script: %~f0
    echo.
    echo Update completed successfully!
    echo Version %VERSION% - %REMOTE_VERSION%
    echo.
    echo Please restart the script to use the new version.
    echo.
) else (
    echo Error: Failed to update script
    echo You may need to run as Administrator
    echo.
)

del "%TEMP_SCRIPT%" >nul 2>&1
goto end

:: Auto-update check (silent)
:auto_update_check
where powershell >nul 2>&1
if %errorLevel% neq 0 goto :eof

ping -n 1 -w 1000 8.8.8.8 >nul 2>&1
if %errorLevel% neq 0 goto :eof

set "TEMP_CHECK=%TEMP%\clipper_check.bat"
powershell -Command "try { Invoke-WebRequest -Uri '%GITHUB_RAW_URL%' -OutFile '%TEMP_CHECK%' -UseBasicParsing -TimeoutSec 3 } catch { exit 1 }" >nul 2>&1

if %errorLevel% neq 0 (
    del "%TEMP_CHECK%" >nul 2>&1
    goto :eof
)

for /f "tokens=2 delims==" %%A in ('findstr /B "set \"VERSION=" "%TEMP_CHECK%"') do (
    set "CHECK_VERSION=%%A"
)
set "CHECK_VERSION=%CHECK_VERSION:"=%"

if not "%VERSION%"=="%CHECK_VERSION%" (
    if not "%CHECK_VERSION%"=="" (
        echo Update available: v%VERSION% - v%CHECK_VERSION%
        echo   Run: %~nx0 --update to update
        echo.
    )
)

del "%TEMP_CHECK%" >nul 2>&1
goto :eof

:: Interactive Menu
:show_menu
cls
echo.
echo ╔════════════════════════════════════════════════════╗
echo ║           CLIpper v%VERSION%                    ║
echo ╚════════════════════════════════════════════════════╝
echo.
echo SYSTEM INFORMATION:
echo   1) Full System Scan
echo   2) Quick Scan
echo   3) Hardware Info Only
echo   4) Network Info Only
echo   5) Performance Metrics
echo.
echo MAINTENANCE:
echo   6) Clean System (Cache ^& Temp Files)
echo   7) Security Audit
echo   8) Export Scan to File
echo.
echo OTHER:
echo   9) Check for Updates
echo   10) About / Help
echo   11) Exit
echo.
set /p menu_choice="Select an option [1-11]: "

if "%menu_choice%"=="1" (
    cls
    call :full_scan
    pause
    goto show_menu
)
if "%menu_choice%"=="2" (
    cls
    call :quick_scan
    pause
    goto show_menu
)
if "%menu_choice%"=="3" (
    cls
    call :hardware_info
    pause
    goto show_menu
)
if "%menu_choice%"=="4" (
    cls
    call :network_details
    pause
    goto show_menu
)
if "%menu_choice%"=="5" (
    cls
    call :performance_details
    pause
    goto show_menu
)
if "%menu_choice%"=="6" (
    cls
    call :clean_system
    pause
    goto show_menu
)
if "%menu_choice%"=="7" (
    cls
    call :security_audit
    pause
    goto show_menu
)
if "%menu_choice%"=="8" (
    cls
    set /p export_file="Enter filename (or press Enter for default): "
    call :export_json !export_file!
    pause
    goto show_menu
)
if "%menu_choice%"=="9" (
    cls
    call :check_updates
    pause
    goto show_menu
)
if "%menu_choice%"=="10" (
    cls
    call :show_usage
    pause
    goto show_menu
)
if "%menu_choice%"=="11" (
    echo.
    echo Thanks for using CLIpper!
    echo.
    goto end
)
echo Invalid option. Please try again.
timeout /t 2 >nul
goto show_menu

:: Install script
:install_script
echo.
echo ===============================================================================
echo  INSTALLING CLIpper
echo ===============================================================================
echo.

if %IS_ADMIN%==0 (
    echo Error: Installation requires Administrator privileges
    echo Please run this script as Administrator
    goto end
)

set "INSTALL_DIR=%ProgramFiles%\CLIpper"
set "INSTALL_FILE=%INSTALL_DIR%\clipper.bat"

if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"

copy /Y "%~f0" "%INSTALL_FILE%" >nul 2>&1
if %errorLevel% neq 0 (
    echo Error: Failed to copy script
    goto end
)

:: Add to PATH
set "PATH_CHECK="
for /f "tokens=2*" %%A in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v Path 2^>nul') do set "PATH_CHECK=%%B"

echo %PATH_CHECK% | find /I "%INSTALL_DIR%" >nul
if %errorLevel% neq 0 (
    setx /M PATH "%PATH_CHECK%;%INSTALL_DIR%" >nul 2>&1
    echo Added to system PATH
)

echo Installed to: %INSTALL_FILE%
echo You can now run: clipper
echo.
echo Available commands:
echo   clipper --scan        - Full system scan
echo   clipper --clean       - Clean system
echo   clipper --security    - Security audit
echo   clipper --update      - Check for updates
echo   clipper --menu        - Interactive menu
echo   clipper --help        - Show help
echo.
echo Note: You may need to restart your terminal for PATH changes to take effect
echo.
goto end

:: Uninstall script
:uninstall_script
echo.
echo ===============================================================================
echo  UNINSTALLING CLIpper
echo ===============================================================================
echo.

if %IS_ADMIN%==0 (
    echo Error: Uninstallation requires Administrator privileges
    goto end
)

set "INSTALL_DIR=%ProgramFiles%\CLIpper"

if exist "%INSTALL_DIR%" (
    rd /s /q "%INSTALL_DIR%"
    echo CLIpper uninstalled
) else (
    echo CLIpper is not installed
)

:: Remove from PATH (optional)
echo.
set /p remove_path="Remove from system PATH? (Y/N): "
if /I "%remove_path%"=="Y" (
    for /f "tokens=2*" %%A in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v Path 2^>nul') do (
        set "CURRENT_PATH=%%B"
    )
    set "NEW_PATH=!CURRENT_PATH:%INSTALL_DIR%;=!"
    setx /M PATH "!NEW_PATH!" >nul 2>&1
    echo Removed from PATH
)

echo.
goto end

:end
endlocal
exit /b 0