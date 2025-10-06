#!/bin/bash

# CLIpper - macOS System Scanner
# Collects comprehensive system information

VERSION="1.0.0"
SCRIPT_NAME="CLIpper"
INSTALL_PATH="/usr/local/bin/clipper"
GITHUB_RAW_URL="https://raw.githubusercontent.com/reol224/CLIpper/main/public/clipper_macos.sh"
GITHUB_API_URL="https://api.github.com/repos/reol224/CLIpper/commits?path=public/clipper_macos.sh&per_page=1"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Helper function to print section headers
print_header() {
    echo -e "\n${BOLD}${BLUE}═══════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}${CYAN}$1${NC}"
    echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════${NC}\n"
}

# Helper function to print key-value pairs
print_info() {
    printf "${GREEN}%-25s${NC}: %s\n" "$1" "$2"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Get OS information
get_os_info() {
    print_header "OPERATING SYSTEM INFORMATION"
    
    print_info "OS Name" "$(sw_vers -productName)"
    print_info "OS Version" "$(sw_vers -productVersion)"
    print_info "OS Build" "$(sw_vers -buildVersion)"
    print_info "Kernel" "$(uname -r)"
    print_info "Hostname" "$(hostname)"
    print_info "Uptime" "$(uptime | awk -F'up ' '{print $2}' | awk -F',' '{print $1}')"
}

# Get architecture information
get_architecture() {
    print_header "ARCHITECTURE"
    
    print_info "Architecture" "$(uname -m)"
    print_info "Processor" "$(uname -p)"
    
    CPU_BRAND=$(sysctl -n machdep.cpu.brand_string 2>/dev/null)
    [ -n "$CPU_BRAND" ] && print_info "CPU Model" "$CPU_BRAND"
}

# Get CPU information
get_cpu_info() {
    print_header "CPU INFORMATION"
    
    PHYSICAL_CORES=$(sysctl -n hw.physicalcpu 2>/dev/null)
    LOGICAL_CORES=$(sysctl -n hw.logicalcpu 2>/dev/null)
    CPU_FREQ=$(sysctl -n hw.cpufrequency 2>/dev/null)
    
    [ -n "$PHYSICAL_CORES" ] && print_info "Physical Cores" "$PHYSICAL_CORES"
    [ -n "$LOGICAL_CORES" ] && print_info "Logical Cores" "$LOGICAL_CORES"
    [ -n "$CPU_FREQ" ] && print_info "CPU Frequency" "$((CPU_FREQ / 1000000)) MHz"
    
    # CPU Usage
    CPU_USAGE=$(ps -A -o %cpu | awk '{s+=$1} END {print s "%"}')
    print_info "CPU Usage" "$CPU_USAGE"
    
    # Load Average
    print_info "Load Average" "$(sysctl -n vm.loadavg | tr -d '{}')"
}

# Get memory information
get_memory_info() {
    print_header "MEMORY INFORMATION"
    
    TOTAL_MEM=$(sysctl -n hw.memsize 2>/dev/null)
    
    if [ -n "$TOTAL_MEM" ]; then
        TOTAL_GB=$(awk "BEGIN {printf \"%.2f GB\", $TOTAL_MEM/1024/1024/1024}")
        print_info "Total Memory" "$TOTAL_GB"
    fi
    
    # Memory pressure
    if command_exists vm_stat; then
        VM_STAT=$(vm_stat)
        FREE_PAGES=$(echo "$VM_STAT" | grep "Pages free" | awk '{print $3}' | tr -d '.')
        ACTIVE_PAGES=$(echo "$VM_STAT" | grep "Pages active" | awk '{print $3}' | tr -d '.')
        INACTIVE_PAGES=$(echo "$VM_STAT" | grep "Pages inactive" | awk '{print $3}' | tr -d '.')
        WIRED_PAGES=$(echo "$VM_STAT" | grep "Pages wired" | awk '{print $4}' | tr -d '.')
        
        PAGE_SIZE=4096
        FREE_MEM=$(awk "BEGIN {printf \"%.2f GB\", ($FREE_PAGES * $PAGE_SIZE)/1024/1024/1024}")
        USED_MEM=$(awk "BEGIN {printf \"%.2f GB\", (($ACTIVE_PAGES + $INACTIVE_PAGES + $WIRED_PAGES) * $PAGE_SIZE)/1024/1024/1024}")
        
        print_info "Used Memory" "$USED_MEM"
        print_info "Free Memory" "$FREE_MEM"
    fi
}

# Get display information
get_display_info() {
    print_header "DISPLAY INFORMATION"
    
    if command_exists system_profiler; then
        DISPLAY_INFO=$(system_profiler SPDisplaysDataType 2>/dev/null | grep "Resolution")
        if [ -n "$DISPLAY_INFO" ]; then
            echo "$DISPLAY_INFO" | while read -r line; do
                echo "  $line"
            done
        else
            print_info "Display" "Information not available"
        fi
    fi
}

# Get battery information
get_battery_info() {
    print_header "BATTERY INFORMATION"
    
    if command_exists pmset; then
        BATTERY_INFO=$(pmset -g batt 2>/dev/null)
        
        if echo "$BATTERY_INFO" | grep -q "Battery"; then
            PERCENTAGE=$(echo "$BATTERY_INFO" | grep -o '[0-9]*%' | head -1)
            STATUS=$(echo "$BATTERY_INFO" | grep -o 'charging\|discharging\|charged' | head -1)
            TIME=$(echo "$BATTERY_INFO" | grep -o '[0-9:]*\sremaining' | head -1)
            
            [ -n "$PERCENTAGE" ] && print_info "Level" "$PERCENTAGE"
            [ -n "$STATUS" ] && print_info "Status" "$STATUS"
            [ -n "$TIME" ] && print_info "Time Remaining" "$TIME"
        else
            print_info "Battery" "No battery detected (Desktop)"
        fi
    fi
}

# Get network information
get_network_info() {
    print_header "NETWORK INFORMATION"
    
    # Active interfaces
    ACTIVE_IF=$(ifconfig | grep "^[a-z]" | cut -d: -f1)
    for iface in $ACTIVE_IF; do
        STATUS=$(ifconfig "$iface" | grep "status:" | awk '{print $2}')
        if [ "$STATUS" = "active" ]; then
            IP_ADDR=$(ifconfig "$iface" | grep "inet " | grep -v "127.0.0.1" | awk '{print $2}')
            if [ -n "$IP_ADDR" ]; then
                print_info "Interface $iface" "Active - $IP_ADDR"
            fi
        fi
    done
    
    # Check internet connectivity
    if ping -c 1 -W 2000 8.8.8.8 >/dev/null 2>&1; then
        print_info "Internet" "Connected"
        
        # Measure latency
        LATENCY=$(ping -c 4 8.8.8.8 2>/dev/null | tail -1 | awk -F '/' '{print $5}')
        [ -n "$LATENCY" ] && print_info "Avg Latency" "${LATENCY} ms"
    else
        print_info "Internet" "Disconnected"
    fi
    
    # DNS servers
    DNS_SERVERS=$(scutil --dns 2>/dev/null | grep "nameserver\[0\]" | awk '{print $3}' | head -3 | tr '\n' ', ' | sed 's/,$//')
    [ -n "$DNS_SERVERS" ] && print_info "DNS Servers" "$DNS_SERVERS"
}

# Get storage information
get_storage_info() {
    print_header "STORAGE INFORMATION"
    
    df -h | grep "^/dev/" | while read -r line; do
        DEVICE=$(echo "$line" | awk '{print $1}')
        SIZE=$(echo "$line" | awk '{print $2}')
        USED=$(echo "$line" | awk '{print $3}')
        AVAIL=$(echo "$line" | awk '{print $4}')
        PERCENT=$(echo "$line" | awk '{print $5}')
        MOUNT=$(echo "$line" | awk '{print $9}')
        
        echo -e "\n${CYAN}$DEVICE${NC} mounted on ${YELLOW}$MOUNT${NC}"
        print_info "  Size" "$SIZE"
        print_info "  Used" "$USED ($PERCENT)"
        print_info "  Available" "$AVAIL"
    done
}

# Get timezone information
get_timezone_info() {
    print_header "TIMEZONE & LOCALE"
    
    print_info "Current Time" "$(date '+%Y-%m-%d %H:%M:%S %Z')"
    print_info "Timezone" "$(systemsetup -gettimezone 2>/dev/null | cut -d ':' -f2 | xargs)"
    print_info "System Language" "${LANG:-N/A}"
}

# Get performance metrics
get_performance_info() {
    print_header "PERFORMANCE METRICS"
    
    # Process count
    PROCESS_COUNT=$(ps aux | wc -l | xargs)
    print_info "Running Processes" "$PROCESS_COUNT"
    
    # Top processes by CPU
    echo -e "\n${CYAN}Top 5 Processes by CPU:${NC}"
    ps aux | sort -rk 3 | head -n 6 | tail -n 5 | awk '{printf "  %-30s %5s%%  %s\n", $11, $3, $2}'
    
    # Top processes by Memory
    echo -e "\n${CYAN}Top 5 Processes by Memory:${NC}"
    ps aux | sort -rk 4 | head -n 6 | tail -n 5 | awk '{printf "  %-30s %5s%%  %s\n", $11, $4, $2}'
    
    # System boot time
    BOOT_TIME=$(sysctl -n kern.boottime | awk '{print $4}' | tr -d ',')
    if [ -n "$BOOT_TIME" ]; then
        BOOT_DATE=$(date -r "$BOOT_TIME" '+%Y-%m-%d %H:%M:%S')
        print_info "Last Boot" "$BOOT_DATE"
    fi
}

# Get additional system info
get_system_details() {
    print_header "ADDITIONAL SYSTEM INFORMATION"
    
    # Logged in users
    USERS=$(who | awk '{print $1}' | sort -u | tr '\n' ', ' | sed 's/,$//')
    print_info "Logged In Users" "$USERS"
    
    # Shell
    print_info "Current Shell" "$SHELL"
    
    # User info
    print_info "Current User" "$(whoami)"
    print_info "Home Directory" "$HOME"
    
    # System limits
    if command_exists ulimit; then
        print_info "Max Open Files" "$(ulimit -n)"
        print_info "Max User Processes" "$(ulimit -u)"
    fi
}

# Security audit
security_audit() {
    print_header "SECURITY AUDIT"
    
    local issues_found=0
    
    # 1. Firewall status
    echo -e "${CYAN}Checking Firewall status...${NC}"
    if command_exists /usr/libexec/ApplicationFirewall/socketfilterfw; then
        FW_STATUS=$(sudo /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate 2>/dev/null | awk '{print $3}')
        if [ "$FW_STATUS" = "enabled." ]; then
            echo -e "  ${GREEN}✓ Firewall is enabled${NC}"
        else
            echo -e "  ${RED}✗ Firewall is disabled${NC}"
            issues_found=$((issues_found + 1))
        fi
    fi
    
    # 2. Gatekeeper status
    echo -e "\n${CYAN}Checking Gatekeeper status...${NC}"
    if command_exists spctl; then
        GK_STATUS=$(spctl --status 2>/dev/null)
        if echo "$GK_STATUS" | grep -q "enabled"; then
            echo -e "  ${GREEN}✓ Gatekeeper is enabled${NC}"
        else
            echo -e "  ${YELLOW}⚠ Gatekeeper is disabled${NC}"
        fi
    fi
    
    # 3. FileVault status
    echo -e "\n${CYAN}Checking FileVault encryption...${NC}"
    if command_exists fdesetup; then
        FV_STATUS=$(fdesetup status 2>/dev/null)
        if echo "$FV_STATUS" | grep -q "On"; then
            echo -e "  ${GREEN}✓ FileVault is enabled${NC}"
        else
            echo -e "  ${YELLOW}⚠ FileVault is disabled${NC}"
        fi
    fi
    
    # 4. System Integrity Protection
    echo -e "\n${CYAN}Checking System Integrity Protection...${NC}"
    if command_exists csrutil; then
        SIP_STATUS=$(csrutil status 2>/dev/null)
        if echo "$SIP_STATUS" | grep -q "enabled"; then
            echo -e "  ${GREEN}✓ SIP is enabled${NC}"
        else
            echo -e "  ${YELLOW}⚠ SIP is disabled${NC}"
        fi
    fi
    
    # 5. Software updates
    echo -e "\n${CYAN}Checking for software updates...${NC}"
    if command_exists softwareupdate; then
        UPDATES=$(softwareupdate -l 2>/dev/null | grep -c "recommended")
        if [ "$UPDATES" -gt 0 ]; then
            echo -e "  ${YELLOW}⚠ $UPDATES update(s) available${NC}"
        else
            echo -e "  ${GREEN}✓ System is up to date${NC}"
        fi
    fi
    
    # 6. Open ports
    echo -e "\n${CYAN}Checking open network ports...${NC}"
    if command_exists lsof; then
        LISTENING_PORTS=$(lsof -iTCP -sTCP:LISTEN -n -P 2>/dev/null | wc -l | xargs)
        echo -e "  ${YELLOW}⚠ $LISTENING_PORTS listening ports found${NC}"
        echo ""
        lsof -iTCP -sTCP:LISTEN -n -P 2>/dev/null | head -10
    fi
    
    # 7. Admin users
    echo -e "\n${CYAN}Checking administrator accounts...${NC}"
    ADMIN_USERS=$(dscl . -read /Groups/admin GroupMembership 2>/dev/null | cut -d ':' -f2)
    if [ -n "$ADMIN_USERS" ]; then
        echo "  Administrator users:$ADMIN_USERS"
    fi
    
    # 8. Automatic login
    echo -e "\n${CYAN}Checking automatic login...${NC}"
    AUTO_LOGIN=$(defaults read /Library/Preferences/com.apple.loginwindow autoLoginUser 2>/dev/null)
    if [ -z "$AUTO_LOGIN" ]; then
        echo -e "  ${GREEN}✓ Automatic login is disabled${NC}"
    else
        echo -e "  ${YELLOW}⚠ Automatic login is enabled for: $AUTO_LOGIN${NC}"
    fi
    
    # 9. Screen saver password
    echo -e "\n${CYAN}Checking screen saver security...${NC}"
    SCREEN_LOCK=$(defaults read com.apple.screensaver askForPassword 2>/dev/null)
    if [ "$SCREEN_LOCK" = "1" ]; then
        echo -e "  ${GREEN}✓ Screen saver requires password${NC}"
    else
        echo -e "  ${YELLOW}⚠ Screen saver does not require password${NC}"
    fi
    
    # Summary
    echo -e "\n${BOLD}${BLUE}═══════════════════════════════════════════════════${NC}"
    if [ "$issues_found" -eq 0 ]; then
        echo -e "${BOLD}${GREEN}Security Audit Complete: No critical issues found${NC}"
    elif [ "$issues_found" -le 2 ]; then
        echo -e "${BOLD}${YELLOW}Security Audit Complete: $issues_found issue(s) found${NC}"
    else
        echo -e "${BOLD}${RED}Security Audit Complete: $issues_found issue(s) found${NC}"
    fi
    echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════${NC}\n"
    
    echo -e "${CYAN}Note: Some checks require sudo privileges for complete results${NC}\n"
}

# Clean system
clean_system() {
    print_header "SYSTEM CLEANUP"
    
    echo -e "${YELLOW}This will help you clean temporary files and caches${NC}"
    echo -e "${YELLOW}You will be asked before each cleanup operation${NC}\n"
    
    # 1. User cache
    echo -e "${CYAN}User Cache:${NC}"
    if [ -d "$HOME/Library/Caches" ]; then
        cache_size=$(du -sh "$HOME/Library/Caches" 2>/dev/null | awk '{print $1}')
        cache_count=$(find "$HOME/Library/Caches" -type f 2>/dev/null | wc -l | xargs)
        echo "  Location: $HOME/Library/Caches"
        echo "  Size: $cache_size"
        echo "  Files: $cache_count"
        read -p "  Clean user cache? [y/N]: " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "$HOME/Library/Caches/"*
            echo -e "  ${GREEN}✓ User cache cleaned${NC}"
        else
            echo -e "  ${YELLOW}✗ Skipped${NC}"
        fi
    fi
    
    # 2. System logs
    echo -e "\n${CYAN}System Logs:${NC}"
    if [ -d "$HOME/Library/Logs" ]; then
        log_size=$(du -sh "$HOME/Library/Logs" 2>/dev/null | awk '{print $1}')
        echo "  Location: $HOME/Library/Logs"
        echo "  Size: $log_size"
        read -p "  Clean user logs? [y/N]: " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "$HOME/Library/Logs/"*
            echo -e "  ${GREEN}✓ User logs cleaned${NC}"
        else
            echo -e "  ${YELLOW}✗ Skipped${NC}"
        fi
    fi
    
    # 3. Trash
    echo -e "\n${CYAN}Trash:${NC}"
    if [ -d "$HOME/.Trash" ]; then
        trash_size=$(du -sh "$HOME/.Trash" 2>/dev/null | awk '{print $1}')
        trash_count=$(find "$HOME/.Trash" -type f 2>/dev/null | wc -l | xargs)
        echo "  Location: $HOME/.Trash"
        echo "  Size: $trash_size"
        echo "  Files: $trash_count"
        read -p "  Empty trash? [y/N]: " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "$HOME/.Trash/"*
            echo -e "  ${GREEN}✓ Trash emptied${NC}"
        else
            echo -e "  ${YELLOW}✗ Skipped${NC}"
        fi
    fi
    
    # 4. Downloads folder old files
    echo -e "\n${CYAN}Old Downloads (30+ days):${NC}"
    if [ -d "$HOME/Downloads" ]; then
        old_downloads=$(find "$HOME/Downloads" -type f -mtime +30 2>/dev/null | wc -l | xargs)
        if [ "$old_downloads" -gt 0 ]; then
            echo "  Files older than 30 days: $old_downloads"
            read -p "  Delete old downloads? [y/N]: " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                find "$HOME/Downloads" -type f -mtime +30 -delete 2>/dev/null
                echo -e "  ${GREEN}✓ Old downloads cleaned${NC}"
            else
                echo -e "  ${YELLOW}✗ Skipped${NC}"
            fi
        else
            echo "  No old downloads found"
        fi
    fi
    
    # 5. Browser caches
    echo -e "\n${CYAN}Browser Caches:${NC}"
    
    # Safari
    if [ -d "$HOME/Library/Caches/com.apple.Safari" ]; then
        safari_size=$(du -sh "$HOME/Library/Caches/com.apple.Safari" 2>/dev/null | awk '{print $1}')
        echo "  Safari cache size: $safari_size"
        read -p "  Clean Safari cache? [y/N]: " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "$HOME/Library/Caches/com.apple.Safari/"*
            echo -e "  ${GREEN}✓ Safari cache cleaned${NC}"
        else
            echo -e "  ${YELLOW}✗ Skipped${NC}"
        fi
    fi
    
    # Chrome
    if [ -d "$HOME/Library/Caches/Google/Chrome" ]; then
        chrome_size=$(du -sh "$HOME/Library/Caches/Google/Chrome" 2>/dev/null | awk '{print $1}')
        echo "  Chrome cache size: $chrome_size"
        read -p "  Clean Chrome cache? (will close Chrome) [y/N]: " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            pkill -9 "Google Chrome" 2>/dev/null
            rm -rf "$HOME/Library/Caches/Google/Chrome/"*
            echo -e "  ${GREEN}✓ Chrome cache cleaned${NC}"
        else
            echo -e "  ${YELLOW}✗ Skipped${NC}"
        fi
    fi
    
    # Firefox
    if [ -d "$HOME/Library/Caches/Firefox" ]; then
        firefox_size=$(du -sh "$HOME/Library/Caches/Firefox" 2>/dev/null | awk '{print $1}')
        echo "  Firefox cache size: $firefox_size"
        read -p "  Clean Firefox cache? (will close Firefox) [y/N]: " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            pkill -9 firefox 2>/dev/null
            rm -rf "$HOME/Library/Caches/Firefox/"*
            echo -e "  ${GREEN}✓ Firefox cache cleaned${NC}"
        else
            echo -e "  ${YELLOW}✗ Skipped${NC}"
        fi
    fi
    
    # 6. Xcode derived data (for developers)
    if [ -d "$HOME/Library/Developer/Xcode/DerivedData" ]; then
        echo -e "\n${CYAN}Xcode Derived Data:${NC}"
        xcode_size=$(du -sh "$HOME/Library/Developer/Xcode/DerivedData" 2>/dev/null | awk '{print $1}')
        echo "  Size: $xcode_size"
        read -p "  Clean Xcode derived data? [y/N]: " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "$HOME/Library/Developer/Xcode/DerivedData/"*
            echo -e "  ${GREEN}✓ Xcode derived data cleaned${NC}"
        else
            echo -e "  ${YELLOW}✗ Skipped${NC}"
        fi
    fi
    
    # 7. Homebrew cache (if installed)
    if command_exists brew; then
        echo -e "\n${CYAN}Homebrew Cache:${NC}"
        brew_cache=$(du -sh "$(brew --cache)" 2>/dev/null | awk '{print $1}')
        echo "  Size: $brew_cache"
        read -p "  Clean Homebrew cache? [y/N]: " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            brew cleanup -s 2>/dev/null
            echo -e "  ${GREEN}✓ Homebrew cache cleaned${NC}"
        else
            echo -e "  ${YELLOW}✗ Skipped${NC}"
        fi
    fi
    
    echo -e "\n${BOLD}${GREEN}✓ Cleanup process complete!${NC}\n"
}

# Check for updates
check_updates() {
    print_header "CHECKING FOR UPDATES"
    
    echo -e "${CYAN}Current version: ${BOLD}$VERSION${NC}"
    echo -e "${CYAN}Checking GitHub repository...${NC}\n"
    
    # Check if curl is available
    if ! command_exists curl; then
        echo -e "${RED}Error: curl is required to check for updates${NC}"
        echo "Please install curl and try again"
        return 1
    fi
    
    # Download the latest script to temporary location
    TEMP_SCRIPT=$(mktemp)
    
    curl -fsSL "$GITHUB_RAW_URL" -o "$TEMP_SCRIPT" 2>/dev/null
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}Error: Failed to download script from GitHub${NC}"
        echo "Please check your internet connection and try again"
        rm -f "$TEMP_SCRIPT"
        return 1
    fi
    
    # Extract version from downloaded script
    REMOTE_VERSION=$(grep "^VERSION=" "$TEMP_SCRIPT" | head -1 | cut -d'"' -f2)
    
    if [ -z "$REMOTE_VERSION" ]; then
        echo -e "${RED}Error: Could not determine remote version${NC}"
        rm -f "$TEMP_SCRIPT"
        return 1
    fi
    
    echo -e "${CYAN}Latest version: ${BOLD}$REMOTE_VERSION${NC}\n"
    
    # Compare versions
    if [ "$VERSION" = "$REMOTE_VERSION" ]; then
        echo -e "${GREEN}✓ You are running the latest version!${NC}\n"
        rm -f "$TEMP_SCRIPT"
        return 0
    fi
    
    echo -e "${YELLOW}⚠ A new version is available!${NC}"
    echo -e "  Current: $VERSION"
    echo -e "  Latest:  $REMOTE_VERSION\n"
    
    # Get last commit info
    COMMIT_INFO=$(curl -fsSL "$GITHUB_API_URL" 2>/dev/null | grep -m1 '"message"' | cut -d'"' -f4)
    if [ -n "$COMMIT_INFO" ]; then
        echo -e "${CYAN}Latest changes:${NC}"
        echo -e "  $COMMIT_INFO\n"
    fi
    
    read -p "Would you like to update now? [y/N]: " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Update cancelled${NC}\n"
        rm -f "$TEMP_SCRIPT"
        return 0
    fi
    
    # Perform update
    echo -e "\n${CYAN}Updating script...${NC}\n"
    
    # Update VERSION in the downloaded script to match remote version
    sed -i '' "s/^VERSION=\".*\"/VERSION=\"$REMOTE_VERSION\"/" "$TEMP_SCRIPT"
    
    # Determine script location
    SCRIPT_PATH="$0"
    
    # If script is installed system-wide, need sudo
    if [ -f "$INSTALL_PATH" ] && [ "$SCRIPT_PATH" = "$INSTALL_PATH" ]; then
        if [ "$EUID" -ne 0 ]; then
            echo -e "${YELLOW}System-wide installation detected, sudo required${NC}"
            sudo cp "$TEMP_SCRIPT" "$INSTALL_PATH"
            sudo chmod +x "$INSTALL_PATH"
        else
            cp "$TEMP_SCRIPT" "$INSTALL_PATH"
            chmod +x "$INSTALL_PATH"
        fi
        echo -e "${GREEN}✓ Updated system-wide installation: $INSTALL_PATH${NC}"
    else
        # Update current script
        cp "$TEMP_SCRIPT" "$SCRIPT_PATH"
        chmod +x "$SCRIPT_PATH"
        echo -e "${GREEN}✓ Updated script: $SCRIPT_PATH${NC}"
    fi
    
    rm -f "$TEMP_SCRIPT"
    
    echo -e "\n${BOLD}${GREEN}✓ Update completed successfully!${NC}"
    echo -e "${CYAN}Version $VERSION → $REMOTE_VERSION${NC}\n"
    echo -e "Please restart the script to use the new version.\n"
}

# Auto-update on startup (silent check)
auto_update_check() {
    # Only check if curl available and online
    if command_exists curl; then
        # Quick connectivity check
        if ping -c 1 -W 1000 8.8.8.8 >/dev/null 2>&1; then
            TEMP_SCRIPT=$(mktemp)
            
            curl -fsSL "$GITHUB_RAW_URL" -o "$TEMP_SCRIPT" 2>/dev/null
            
            if [ $? -eq 0 ]; then
                REMOTE_VERSION=$(grep "^VERSION=" "$TEMP_SCRIPT" | head -1 | cut -d'"' -f2)
                
                if [ -n "$REMOTE_VERSION" ] && [ "$VERSION" != "$REMOTE_VERSION" ]; then
                    echo -e "${YELLOW}⚠ Update available: v$VERSION → v$REMOTE_VERSION${NC}"
                    echo -e "  Run: ${CYAN}$0 --update${NC} to update\n"
                fi
            fi
            
            rm -f "$TEMP_SCRIPT"
        fi
    fi
}

# Install script globally
install_script() {
    echo -e "${BOLD}${CYAN}Installing CLIpper...${NC}\n"
    
    if [ "$EUID" -ne 0 ]; then
        echo -e "${RED}Error: Installation requires sudo/root privileges${NC}"
        echo "Please run: curl -fsSL <URL> | sudo bash -s -- --install"
        exit 1
    fi
    
    cp "$0" "$INSTALL_PATH" 2>/dev/null
    chmod +x "$INSTALL_PATH"
    
    echo -e "${GREEN}✓ Installed to: $INSTALL_PATH${NC}"
    echo -e "${GREEN}✓ You can now run: ${BOLD}clipper${NC}"
    echo -e "\nAvailable commands:"
    echo -e "  ${CYAN}clipper --scan${NC}        - Full system scan"
    echo -e "  ${CYAN}clipper --clean${NC}       - Clean system"
    echo -e "  ${CYAN}clipper --security${NC}    - Security audit"
    echo -e "  ${CYAN}clipper --update${NC}      - Check for updates"
    echo -e "  ${CYAN}clipper --menu${NC}        - Interactive menu"
    echo -e "  ${CYAN}clipper --help${NC}        - Show help"
    echo ""
}

# Interactive menu
show_menu() {
    while true; do
        clear
        echo -e "${BOLD}${BLUE}╔════════════════════════════════════════════════════╗${NC}"
        echo -e "${BOLD}${BLUE}║${NC}           ${BOLD}${CYAN}CLIpper${NC} ${BOLD}${BLUE}v$VERSION${NC}                    ${BOLD}${BLUE}║${NC}"
        echo -e "${BOLD}${BLUE}╚════════════════════════════════════════════════════╝${NC}\n"
        
        echo -e "${BOLD}SYSTEM INFORMATION:${NC}"
        echo -e "  ${GREEN}1)${NC} Full System Scan"
        echo -e "  ${GREEN}2)${NC} Quick Scan"
        echo -e "  ${GREEN}3)${NC} Hardware Info Only"
        echo -e "  ${GREEN}4)${NC} Network Info Only"
        echo -e "  ${GREEN}5)${NC} Performance Metrics"
        
        echo -e "\n${BOLD}MAINTENANCE:${NC}"
        echo -e "  ${YELLOW}6)${NC} Clean System (Cache & Temp Files)"
        echo -e "  ${YELLOW}7)${NC} Security Audit"
        echo -e "  ${YELLOW}8)${NC} Export Scan to File"
        
        echo -e "\n${BOLD}OTHER:${NC}"
        echo -e "  ${CYAN}9)${NC} Check for Updates"
        echo -e "  ${CYAN}10)${NC} About / Help"
        echo -e "  ${RED}11)${NC} Exit"
        
        echo -e "\n${BOLD}Select an option [1-11]:${NC} "
        read -r choice
        
        case $choice in
            1)
                clear
                get_os_info
                get_architecture
                get_cpu_info
                get_memory_info
                get_display_info
                get_battery_info
                get_network_info
                get_storage_info
                get_timezone_info
                get_performance_info
                get_system_details
                echo -e "\n${BOLD}${GREEN}✓ Scan Complete!${NC}"
                read -p "Press Enter to continue..."
                ;;
            2)
                clear
                get_os_info
                get_cpu_info
                get_memory_info
                get_storage_info
                echo -e "\n${BOLD}${GREEN}✓ Quick Scan Complete!${NC}"
                read -p "Press Enter to continue..."
                ;;
            3)
                clear
                get_os_info
                get_architecture
                get_cpu_info
                get_memory_info
                get_display_info
                read -p "Press Enter to continue..."
                ;;
            4)
                clear
                get_network_info
                read -p "Press Enter to continue..."
                ;;
            5)
                clear
                get_performance_info
                read -p "Press Enter to continue..."
                ;;
            6)
                clear
                clean_system
                read -p "Press Enter to continue..."
                ;;
            7)
                clear
                security_audit
                read -p "Press Enter to continue..."
                ;;
            8)
                clear
                echo -e "${CYAN}Enter filename (or press Enter for default):${NC} "
                read -r filename
                export_json "$filename"
                read -p "Press Enter to continue..."
                ;;
            9)
                clear
                check_updates
                read -p "Press Enter to continue..."
                ;;
            10)
                clear
                show_usage
                read -p "Press Enter to continue..."
                ;;
            11)
                echo -e "\n${GREEN}Thanks for using macOS System Scanner!${NC}\n"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid option. Please try again.${NC}"
                sleep 1
                ;;
        esac
    done
}

# Uninstall script
uninstall_script() {
    if [ "$EUID" -ne 0 ]; then
        echo -e "${RED}Error: Uninstallation requires sudo privileges${NC}"
        exit 1
    fi
    
    if [ -f "$INSTALL_PATH" ]; then
        rm "$INSTALL_PATH"
        echo -e "${GREEN}✓ System Scanner uninstalled${NC}"
    else
        echo -e "${YELLOW}System Scanner is not installed${NC}"
    fi
}

# Export to JSON/Text
export_json() {
    set "output_file=system_scan_$(date +%Y%m%d_%H%M%S).txt"
    if [ -n "$1" ]; then
        output_file="$1"
    fi

    echo "Exporting scan results to: $output_file"
    echo

    {
        echo "==============================================================================="
        echo "macOS System Scan Report"
        echo "Generated: $(date)"
        echo "==============================================================================="
        echo
        get_os_info
        get_architecture
        get_cpu_info
        get_memory_info
        get_storage_info
        get_network_info
    } > "$output_file"

    echo -e "${GREEN}✓ Export complete: $output_file${NC}"
    echo
}

# Show usage
show_usage() {
    cat << EOF
${BOLD}${CYAN}macOS System Scanner${NC} - v$VERSION

${BOLD}${GREEN}DESCRIPTION:${NC}
    Comprehensive system monitoring, analysis, and maintenance tool for macOS.
    Collects real-time hardware, software, network, and security information.

${BOLD}${GREEN}USAGE:${NC}
    $0 [OPTIONS]

${BOLD}${GREEN}SCANNING OPTIONS:${NC}
    ${CYAN}--scan${NC}              Run complete system scan
    ${CYAN}--scan-quick${NC}        Run quick scan (basic info only)
    ${CYAN}--hardware${NC}          Show only hardware information
    ${CYAN}--network${NC}           Show only network information
    ${CYAN}--performance${NC}       Show only performance metrics
    ${CYAN}--security${NC}          Run security audit

${BOLD}${GREEN}MAINTENANCE OPTIONS:${NC}
    ${CYAN}--clean${NC}             Clean system (cache, temp files, logs)
    ${CYAN}--update${NC}            Check for updates and update script
    ${CYAN}--menu${NC}              Show interactive menu
    ${CYAN}--export [FILE]${NC}     Export results to text file
    ${CYAN}--install${NC}           Install system-wide (requires sudo)
    ${CYAN}--uninstall${NC}         Uninstall from system (requires sudo)

${BOLD}${GREEN}INFORMATION OPTIONS:${NC}
    ${CYAN}--help, -h${NC}          Show this help message
    ${CYAN}--version, -v${NC}       Show version information

${BOLD}${GREEN}EXAMPLES:${NC}
    ${YELLOW}# Full system scan${NC}
    $0 --scan
    
    ${YELLOW}# Security audit${NC}
    $0 --security
    
    ${YELLOW}# Clean system${NC}
    $0 --clean
    
    ${YELLOW}# Check for updates${NC}
    $0 --update
    
    ${YELLOW}# Interactive menu${NC}
    $0 --menu
    
    ${YELLOW}# Install system-wide${NC}
    curl -fsSL https://raw.githubusercontent.com/reol224/CLIpper/main/public/clipper_macos.sh | sudo bash -s -- --install

${BOLD}${GREEN}REQUIREMENTS:${NC}
    - macOS 10.10 or later
    - Some operations may require sudo privileges
    - curl is required for update functionality

${BOLD}${GREEN}AUTHOR:${NC}
    macOS System Scanner v$VERSION
    GitHub: https://github.com/reol224/CLIpper

EOF
}

# Main function
main() {
    # If no arguments, show menu
    if [ $# -eq 0 ]; then
        auto_update_check
        show_menu
        exit 0
    fi
    
    case "$1" in
        --install)
            install_script
            ;;
        --uninstall)
            uninstall_script
            ;;
        --update)
            check_updates
            ;;
        --menu)
            auto_update_check
            show_menu
            ;;
        --scan)
            auto_update_check
            echo -e "${BOLD}${GREEN}Starting Complete System Scan...${NC}"
            get_os_info
            get_architecture
            get_cpu_info
            get_memory_info
            get_display_info
            get_battery_info
            get_network_info
            get_storage_info
            get_timezone_info
            get_performance_info
            get_system_details
            echo -e "\n${BOLD}${GREEN}✓ Scan Complete!${NC}\n"
            
            if [ "$2" = "--export" ]; then
                export_json "$3"
            fi
            ;;
        --scan-quick)
            get_os_info
            get_cpu_info
            get_memory_info
            get_storage_info
            ;;
        --hardware)
            get_os_info
            get_architecture
            get_cpu_info
            get_memory_info
            get_display_info
            ;;
        --network)
            get_network_info
            ;;
        --performance)
            get_performance_info
            ;;
        --security)
            security_audit
            ;;
        --clean)
            clean_system
            ;;
        --export)
            export_json "$2"
            ;;
        --version|-v)
            echo "$SCRIPT_NAME v$VERSION"
            echo "GitHub: https://github.com/reol224/CLIpper"
            ;;
        --help|-h|*)
            show_usage
            ;;
    esac
}

# Run main function
main "$@"