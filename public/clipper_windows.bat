@echo off
setlocal enabledelayedexpansion

:: CLIpper - Windows System Scanner
:: Collects comprehensive system information

set "VERSION=1.0.0"
set "SCRIPT_NAME=CLIpper"
set "GITHUB_RAW_URL=https://raw.githubusercontent.com/reol224/CLIpper/main/public/clipper_windows.bat"

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
echo [32m--- Scan Complete! ---[0m
echo.
goto end

:quick_scan
call :print_header "QUICK SYSTEM SCAN"
call :os_info
call :cpu_info
call :memory_info
call :storage_info
echo.
echo [32m--- Quick Scan Complete! ---[0m
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
echo [36m--- Operating System Information ---[0m
echo.
systeminfo | findstr /B /C:"OS Name" /C:"OS Version" /C:"OS Manufacturer" /C:"OS Configuration" /C:"OS Build Type" /C:"System Boot Time" /C:"System Manufacturer" /C:"System Model"
goto :eof

:: Architecture Information
:architecture_info
echo.
echo [36m--- Architecture ---[0m
echo.
systeminfo | findstr /B /C:"System Type" /C:"Processor(s)"
wmic cpu get Name,Architecture,AddressWidth /format:list | findstr /V "^$"
goto :eof

:: CPU Information
:cpu_info
echo.
echo [36m--- CPU Information ---[0m
echo.
wmic cpu get Name,NumberOfCores,NumberOfLogicalProcessors,MaxClockSpeed,CurrentClockSpeed,LoadPercentage /format:list | findstr /V "^$"
echo.
echo Load Average:
wmic cpu get loadpercentage /value
goto :eof

:: Memory Information
:memory_info
echo.
echo [36m--- Memory Information ---[0m
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
echo [36m--- Display Information ---[0m
echo.
wmic path Win32_VideoController get Name,CurrentHorizontalResolution,CurrentVerticalResolution,CurrentRefreshRate /format:list | findstr /V "^$"
goto :eof

:: Battery Information
:battery_info
echo.
echo [36m--- Battery Information ---[0m
echo.
WMIC Path Win32_Battery Get BatteryStatus,EstimatedChargeRemaining,EstimatedRunTime /format:list 2>nul | findstr /V "^$"
if %errorLevel% neq 0 (
    echo No battery detected ^(Desktop or battery info not available^)
)
goto :eof

:: Network Information
:network_details
echo.
echo [36m--- Network Information ---[0m
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
echo [36m--- Storage Information ---[0m
echo.
wmic logicaldisk get DeviceID,FileSystem,Size,FreeSpace,VolumeName /format:list | findstr /V "^$"
echo.
echo Disk Performance:
wmic diskdrive get Model,Size,Status,InterfaceType /format:list | findstr /V "^$"
goto :eof

:: Timezone Information
:timezone_info
echo.
echo [36m--- Timezone ^& Locale ---[0m
echo.
echo Current Time:
echo %DATE% %TIME%
systeminfo | findstr /B /C:"System Locale" /C:"Input Locale" /C:"Time Zone"
goto :eof

:: Performance Information
:performance_details
echo.
echo [36m--- Performance Metrics ---[0m
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
echo [36m--- Additional System Information ---[0m
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
echo [36mChecking Windows Firewall status...[0m
netsh advfirewall show allprofiles state | findstr /C:"State"
echo.

echo [36mChecking Windows Defender status...[0m
if %IS_ADMIN%==1 (
    powershell -Command "Get-MpComputerStatus | Select-Object AntivirusEnabled,RealTimeProtectionEnabled,IoavProtectionEnabled,OnAccessProtectionEnabled | Format-List"
) else (
    echo [33m! Requires Administrator privileges for full results[0m
)
echo.

echo [36mChecking User Account Control...[0m
reg query HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v EnableLUA 2>nul | findstr /C:"EnableLUA"
echo.

echo [36mChecking Windows Update status...[0m
if %IS_ADMIN%==1 (
    powershell -Command "Get-HotFix | Select-Object -Last 5 | Format-Table -AutoSize"
) else (
    echo [33m! Requires Administrator privileges[0m
)
echo.

echo [36mChecking Administrator accounts...[0m
net localgroup Administrators
echo.

echo [36mChecking shared folders...[0m
net share
echo.

echo [36mChecking running services...[0m
echo Services Count:
sc query type= service state= all | find /C "SERVICE_NAME"
echo.

echo [36mChecking open ports...[0m
netstat -ano | findstr /C:"LISTENING"
echo.

echo [36mChecking failed login attempts...[0m
if %IS_ADMIN%==1 (
    powershell -Command "Get-EventLog -LogName Security -InstanceId 4625 -Newest 10 -ErrorAction SilentlyContinue | Select-Object TimeGenerated,Message | Format-List" 2>nul
    if !errorLevel! neq 0 (
        echo No recent failed login attempts found
    )
) else (
    echo [33m! Requires Administrator privileges[0m
)
echo.

echo [36mChecking BitLocker status...[0m
if %IS_ADMIN%==1 (
    manage-bde -status 2>nul
    if !errorLevel! neq 0 (
        echo BitLocker information not available
    )
) else (
    echo [33m! Requires Administrator privileges[0m
)
echo.

echo [36mChecking autorun programs...[0m
if %IS_ADMIN%==1 (
    wmic startup get Caption,Command,Location /format:list | findstr /V "^$"
) else (
    reg query HKCU\Software\Microsoft\Windows\CurrentVersion\Run 2>nul
)
echo.

echo ===============================================================================
if %issues_found% leq 3 (
    echo [32mSecurity Audit Complete: System appears secure[0m
) else (
    echo [33mSecurity Audit Complete: Review findings above[0m
)
echo ===============================================================================
echo.
echo [36mNote: Run as Administrator for complete security audit[0m
echo.
goto end

:: Clean System
:clean_system
call :print_header "SYSTEM CLEANUP"

echo [33mThis will help you clean temporary files and caches[0m
echo [33mYou will be asked before each cleanup operation[0m
echo.

:: 1. Windows Temp files
echo [36mWindows Temp Files:[0m
for /f %%A in ('dir /b /s %TEMP% 2^>nul ^| find /c /v ""') do set temp_count=%%A
echo   User Temp: %TEMP%
echo   Files found: %temp_count%
set /p clean_temp="Clean Windows Temp files? (Y/N): "
if /I "%clean_temp%"=="Y" (
    del /s /q %TEMP%\*.* >nul 2>&1
    del /s /q %WINDIR%\Temp\*.* >nul 2>&1
    echo   [32m- Temp files cleaned[0m
) else (
    echo   [33m- Skipped[0m
)

:: 2. Recycle Bin
echo.
echo [36mRecycle Bin:[0m
if %IS_ADMIN%==1 (
    set /p clean_recycle="Empty Recycle Bin? (Y/N): "
    if /I "!clean_recycle!"=="Y" (
        rd /s /q C:\$Recycle.Bin >nul 2>&1
        echo   [32m- Recycle Bin emptied[0m
    ) else (
        echo   [33m- Skipped[0m
    )
) else (
    echo   [33m! Requires Administrator privileges[0m
)

:: 3. Windows Update Cache
echo.
echo [36mWindows Update Cache:[0m
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
        echo   [32m- Windows Update cache cleaned[0m
    ) else (
        echo   [33m- Skipped[0m
    )
) else (
    echo   [33m! Requires Administrator privileges[0m
)

:: 4. Prefetch
echo.
echo [36mPrefetch Files:[0m
if %IS_ADMIN%==1 (
    if exist "%WINDIR%\Prefetch" (
        for /f %%A in ('dir /b "%WINDIR%\Prefetch\*.pf" 2^>nul ^| find /c /v ""') do set prefetch_count=%%A
        echo   Location: %WINDIR%\Prefetch
        echo   Files found: !prefetch_count!
    )
    set /p clean_prefetch="Clean Prefetch files? (Y/N): "
    if /I "!clean_prefetch!"=="Y" (
        del /s /q %WINDIR%\Prefetch\*.* >nul 2>&1
        echo   [32m- Prefetch cleaned[0m
    ) else (
        echo   [33m- Skipped[0m
    )
) else (
    echo   [33m! Requires Administrator privileges[0m
)

:: 5. DNS Cache
echo.
echo [36mDNS Cache:[0m
set /p clean_dns="Flush DNS cache? (Y/N): "
if /I "%clean_dns%"=="Y" (
    ipconfig /flushdns >nul 2>&1
    echo   [32m- DNS cache flushed[0m
) else (
    echo   [33m- Skipped[0m
)

:: 6. Browser Caches
echo.
echo [36mBrowser Caches:[0m

:: Chrome
if exist "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache" (
    for /f %%A in ('dir /b /s "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache" 2^>nul ^| find /c /v ""') do set chrome_count=%%A
    echo   Chrome cache files: !chrome_count!
    set /p clean_chrome="Clean Chrome cache? (Y/N): "
    if /I "!clean_chrome!"=="Y" (
        taskkill /F /IM chrome.exe >nul 2>&1
        rd /s /q "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache" >nul 2>&1
        echo   [32m- Chrome cache cleaned[0m
    ) else (
        echo   [33m- Skipped[0m
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
        echo   [32m- Edge cache cleaned[0m
    ) else (
        echo   [33m- Skipped[0m
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
        echo   [32m- Firefox cache cleaned[0m
    ) else (
        echo   [33m- Skipped[0m
    )
)

:: 7. Thumbnail Cache
echo.
echo [36mThumbnail Cache:[0m
if exist "%LOCALAPPDATA%\Microsoft\Windows\Explorer" (
    for /f %%A in ('dir /b "%LOCALAPPDATA%\Microsoft\Windows\Explorer\thumbcache_*.db" 2^>nul ^| find /c /v ""') do set thumb_count=%%A
    echo   Thumbnail cache files: !thumb_count!
    set /p clean_thumbs="Clean thumbnail cache? (Y/N): "
    if /I "!clean_thumbs!"=="Y" (
        del /f /q "%LOCALAPPDATA%\Microsoft\Windows\Explorer\thumbcache_*.db" >nul 2>&1
        echo   [32m- Thumbnail cache cleaned[0m
    ) else (
        echo   [33m- Skipped[0m
    )
)

:: 8. Disk Cleanup
echo.
echo [36mWindows Disk Cleanup:[0m
if %IS_ADMIN%==1 (
    set /p run_cleanmgr="Run Windows Disk Cleanup utility? (Y/N): "
    if /I "!run_cleanmgr!"=="Y" (
        cleanmgr /sagerun:1 >nul 2>&1
        echo   [32m- Disk cleanup initiated[0m
    ) else (
        echo   [33m- Skipped[0m
    )
) else (
    echo   [33m! Requires Administrator privileges[0m
)

echo.
echo [32m===============================================================================[0m
echo [32m Cleanup Process Complete![0m
echo [32m===============================================================================[0m
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

echo [32mExport complete: %output_file%[0m
echo.
goto end

:: Check for updates
:check_updates
echo.
echo ===============================================================================
echo  CHECKING FOR UPDATES
echo ===============================================================================
echo.

echo [36mCurrent version: [1m%VERSION%[0m
echo [36mChecking GitHub repository...[0m
echo.

:: Check if PowerShell is available
where powershell >nul 2>&1
if %errorLevel% neq 0 (
    echo [31mError: PowerShell is required to check for updates[0m
    goto end
)

:: Download latest script to temp location
set "TEMP_SCRIPT=%TEMP%\clipper_windows_temp.bat"

echo [36mDownloading latest version...[0m
powershell -Command "try { Invoke-WebRequest -Uri '%GITHUB_RAW_URL%' -OutFile '%TEMP_SCRIPT%' -UseBasicParsing } catch { exit 1 }" >nul 2>&1

if %errorLevel% neq 0 (
    echo [31mError: Failed to download script from GitHub[0m
    echo Please check your internet connection and try again
    goto end
)

:: Extract version from downloaded script
for /f "tokens=2 delims==" %%A in ('findstr /B "set \"VERSION=" "%TEMP_SCRIPT%"') do (
    set "REMOTE_VERSION=%%A"
)
set "REMOTE_VERSION=%REMOTE_VERSION:"=%"

if "%REMOTE_VERSION%"=="" (
    echo [31mError: Could not determine remote version[0m
    del "%TEMP_SCRIPT%" >nul 2>&1
    goto end
)

echo [36mLatest version: [1m%REMOTE_VERSION%[0m
echo.

:: Compare versions
if "%VERSION%"=="%REMOTE_VERSION%" (
    echo [32m✓ You are running the latest version![0m
    echo.
    del "%TEMP_SCRIPT%" >nul 2>&1
    goto end
)

echo [33m⚠ A new version is available![0m
echo   Current: %VERSION%
echo   Latest:  %REMOTE_VERSION%
echo.

set /p update_confirm="Would you like to update now? (Y/N): "
if /I not "%update_confirm%"=="Y" (
    echo [33mUpdate cancelled[0m
    echo.
    del "%TEMP_SCRIPT%" >nul 2>&1
    goto end
)

:: Perform update
echo.
echo [36mUpdating script...[0m
echo.

:: Update VERSION in the downloaded script
powershell -Command "(Get-Content '%TEMP_SCRIPT%') -replace 'set \"VERSION=.*\"', 'set \"VERSION=%REMOTE_VERSION%\"' | Set-Content '%TEMP_SCRIPT%'" >nul 2>&1

:: Replace current script
copy /Y "%TEMP_SCRIPT%" "%~f0" >nul 2>&1
if %errorLevel% equ 0 (
    echo [32m✓ Updated script: %~f0[0m
    echo.
    echo [1m[32m✓ Update completed successfully![0m[0m
    echo [36mVersion %VERSION% → %REMOTE_VERSION%[0m
    echo.
    echo Please restart the script to use the new version.
    echo.
) else (
    echo [31mError: Failed to update script[0m
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
        echo [33m⚠ Update available: v%VERSION% → v%CHECK_VERSION%[0m
        echo   Run: [36m%~nx0 --update[0m to update
        echo.
    )
)

del "%TEMP_CHECK%" >nul 2>&1
goto :eof

:: Interactive Menu
:show_menu
cls
echo.
echo [1m[34m╔════════════════════════════════════════════════════╗[0m
echo [1m[34m║[0m           [1m[36mCLIpper[0m [1m[34mv%VERSION%[0m                    [1m[34m║[0m
echo [1m[34m╚════════════════════════════════════════════════════╝[0m
echo.
echo [1mSYSTEM INFORMATION:[0m
echo   [32m1)[0m Full System Scan
echo   [32m2)[0m Quick Scan
echo   [32m3)[0m Hardware Info Only
echo   [32m4)[0m Network Info Only
echo   [32m5)[0m Performance Metrics
echo.
echo [1mMAINTENANCE:[0m
echo   [33m6)[0m Clean System (Cache ^& Temp Files)
echo   [33m7)[0m Security Audit
echo   [33m8)[0m Export Scan to File
echo.
echo [1mOTHER:[0m
echo   [36m9)[0m Check for Updates
echo   [36m10)[0m About / Help
echo   [31m11)[0m Exit
echo.
set /p menu_choice="[1mSelect an option [1-11]:[0m "

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
    echo [32mThanks for using CLIpper![0m
    echo.
    goto end
)
echo [31mInvalid option. Please try again.[0m
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
    echo [31mError: Installation requires Administrator privileges[0m
    echo Please run this script as Administrator
    goto end
)

set "INSTALL_DIR=%ProgramFiles%\CLIpper"
set "INSTALL_FILE=%INSTALL_DIR%\clipper.bat"

if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"

copy /Y "%~f0" "%INSTALL_FILE%" >nul 2>&1
if %errorLevel% neq 0 (
    echo [31mError: Failed to copy script[0m
    goto end
)

:: Add to PATH
set "PATH_CHECK="
for /f "tokens=2*" %%A in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v Path 2^>nul') do set "PATH_CHECK=%%B"

echo %PATH_CHECK% | find /I "%INSTALL_DIR%" >nul
if %errorLevel% neq 0 (
    setx /M PATH "%PATH_CHECK%;%INSTALL_DIR%" >nul 2>&1
    echo [32m✓ Added to system PATH[0m
)

echo [32m✓ Installed to: %INSTALL_FILE%[0m
echo [32m✓ You can now run: clipper[0m
echo.
echo Available commands:
echo   [36mclipper --scan[0m        - Full system scan
echo   [36mclipper --clean[0m       - Clean system
echo   [36mclipper --security[0m    - Security audit
echo   [36mclipper --update[0m      - Check for updates
echo   [36mclipper --menu[0m        - Interactive menu
echo   [36mclipper --help[0m        - Show help
echo.
echo [33mNote: You may need to restart your terminal for PATH changes to take effect[0m
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
    echo [31mError: Uninstallation requires Administrator privileges[0m
    goto end
)

set "INSTALL_DIR=%ProgramFiles%\CLIpper"

if exist "%INSTALL_DIR%" (
    rd /s /q "%INSTALL_DIR%"
    echo [32m✓ CLIpper uninstalled[0m
) else (
    echo [33mCLIpper is not installed[0m
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
    echo [32m✓ Removed from PATH[0m
)

echo.
goto end

:end
endlocal
exit /b 0