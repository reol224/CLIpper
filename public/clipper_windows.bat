@echo off
setlocal enabledelayedexpansion

:: Windows System Scanner
:: Collects comprehensive system information

set "VERSION=1.0.0"
set "SCRIPT_NAME=Windows System Scanner"

:: Check for admin privileges
net session >nul 2>&1
if %errorLevel% == 0 (
    set "IS_ADMIN=1"
) else (
    set "IS_ADMIN=0"
)

:: Parse command line arguments
if "%1"=="" goto show_usage
if /I "%1"=="--scan" goto full_scan
if /I "%1"=="--scan-quick" goto quick_scan
if /I "%1"=="--hardware" goto hardware_info
if /I "%1"=="--network" goto network_info
if /I "%1"=="--performance" goto performance_info
if /I "%1"=="--security" goto security_audit
if /I "%1"=="--clean" goto clean_system
if /I "%1"=="--export" goto export_json
if /I "%1"=="--help" goto show_usage
if /I "%1"=="-h" goto show_usage
if /I "%1"=="--version" goto show_version
if /I "%1"=="-v" goto show_version
goto show_usage

:show_version
echo %SCRIPT_NAME% v%VERSION%
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

echo [33mWARNING: This will clean temporary files and caches[0m
echo.
set /p confirm="Do you want to continue? (Y/N): "
if /I not "%confirm%"=="Y" goto end

echo.
echo [36mCleaning Windows Temp files...[0m
del /s /q %TEMP%\*.* >nul 2>&1
del /s /q %WINDIR%\Temp\*.* >nul 2>&1
echo [32m- Temp files cleaned[0m

echo.
echo [36mCleaning Recycle Bin...[0m
if %IS_ADMIN%==1 (
    rd /s /q C:\$Recycle.Bin >nul 2>&1
    echo [32m- Recycle Bin emptied[0m
) else (
    echo [33m! Requires Administrator privileges[0m
)

echo.
echo [36mCleaning Windows Update Cache...[0m
if %IS_ADMIN%==1 (
    net stop wuauserv >nul 2>&1
    del /s /q %WINDIR%\SoftwareDistribution\Download\*.* >nul 2>&1
    net start wuauserv >nul 2>&1
    echo [32m- Windows Update cache cleaned[0m
) else (
    echo [33m! Requires Administrator privileges[0m
)

echo.
echo [36mCleaning Prefetch...[0m
if %IS_ADMIN%==1 (
    del /s /q %WINDIR%\Prefetch\*.* >nul 2>&1
    echo [32m- Prefetch cleaned[0m
) else (
    echo [33m! Requires Administrator privileges[0m
)

echo.
echo [36mCleaning DNS Cache...[0m
ipconfig /flushdns >nul 2>&1
echo [32m- DNS cache flushed[0m

echo.
echo [36mCleaning Browser Caches...[0m
:: Chrome
if exist "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache" (
    rd /s /q "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache" >nul 2>&1
    echo [32m- Chrome cache cleaned[0m
)
:: Edge
if exist "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache" (
    rd /s /q "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache" >nul 2>&1
    echo [32m- Edge cache cleaned[0m
)
:: Firefox
if exist "%LOCALAPPDATA%\Mozilla\Firefox\Profiles" (
    for /d %%i in ("%LOCALAPPDATA%\Mozilla\Firefox\Profiles\*") do (
        rd /s /q "%%i\cache2" >nul 2>&1
    )
    echo [32m- Firefox cache cleaned[0m
)

echo.
echo [36mRunning Disk Cleanup...[0m
if %IS_ADMIN%==1 (
    cleanmgr /sagerun:1 >nul 2>&1
    echo [32m- Disk cleanup initiated[0m
) else (
    echo [33m! Requires Administrator privileges[0m
)

echo.
echo [32m===============================================================================[0m
echo [32m Cleanup Complete![0m
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

:end
endlocal
exit /b 0