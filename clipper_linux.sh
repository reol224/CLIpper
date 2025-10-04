#!/bin/bash

# Linux System Scanner
# Collects comprehensive system information

VERSION="1.0.0"
SCRIPT_NAME="system-scanner"

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
    
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        print_info "OS Name" "$NAME"
        print_info "OS Version" "$VERSION"
        print_info "OS ID" "$ID"
        print_info "Version Codename" "${VERSION_CODENAME:-N/A}"
    fi
    
    print_info "Kernel" "$(uname -r)"
    print_info "Kernel Version" "$(uname -v)"
    print_info "Hostname" "$(hostname)"
    print_info "Uptime" "$(uptime -p 2>/dev/null || uptime)"
}

# Get architecture information
get_architecture() {
    print_header "ARCHITECTURE"
    
    print_info "Architecture" "$(uname -m)"
    print_info "Processor" "$(uname -p)"
    print_info "Hardware Platform" "$(uname -i 2>/dev/null || echo 'N/A')"
    
    if [ -f /proc/cpuinfo ]; then
        CPU_MODEL=$(grep "model name" /proc/cpuinfo | head -1 | cut -d ':' -f2 | xargs)
        [ -n "$CPU_MODEL" ] && print_info "CPU Model" "$CPU_MODEL"
    fi
}

# Get CPU information
get_cpu_info() {
    print_header "CPU INFORMATION"
    
    if [ -f /proc/cpuinfo ]; then
        PHYSICAL_CORES=$(grep "physical id" /proc/cpuinfo | sort -u | wc -l)
        LOGICAL_CORES=$(grep "processor" /proc/cpuinfo | wc -l)
        
        [ "$PHYSICAL_CORES" -eq 0 ] && PHYSICAL_CORES=1
        
        print_info "Physical Cores" "$PHYSICAL_CORES"
        print_info "Logical Cores" "$LOGICAL_CORES"
        print_info "Threads per Core" "$((LOGICAL_CORES / PHYSICAL_CORES))"
        
        if command_exists lscpu; then
            CPU_MHZ=$(lscpu | grep "CPU MHz" | awk '{print $3}')
            CPU_MAX=$(lscpu | grep "CPU max MHz" | awk '{print $4}')
            [ -n "$CPU_MHZ" ] && print_info "Current Speed" "${CPU_MHZ} MHz"
            [ -n "$CPU_MAX" ] && print_info "Max Speed" "${CPU_MAX} MHz"
        fi
    fi
    
    # CPU Usage
    if command_exists top; then
        CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1"%"}')
        print_info "CPU Usage" "$CPU_USAGE"
    fi
    
    # Load Average
    print_info "Load Average" "$(cat /proc/loadavg | awk '{print $1, $2, $3}')"
}

# Get memory information
get_memory_info() {
    print_header "MEMORY INFORMATION"
    
    if [ -f /proc/meminfo ]; then
        TOTAL_MEM=$(grep MemTotal /proc/meminfo | awk '{print $2}')
        FREE_MEM=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
        USED_MEM=$((TOTAL_MEM - FREE_MEM))
        
        print_info "Total Memory" "$(awk "BEGIN {printf \"%.2f GB\", $TOTAL_MEM/1024/1024}")"
        print_info "Used Memory" "$(awk "BEGIN {printf \"%.2f GB\", $USED_MEM/1024/1024}")"
        print_info "Free Memory" "$(awk "BEGIN {printf \"%.2f GB\", $FREE_MEM/1024/1024}")"
        print_info "Memory Usage" "$(awk "BEGIN {printf \"%.1f%%\", ($USED_MEM/$TOTAL_MEM)*100}")"
        
        # Swap information
        TOTAL_SWAP=$(grep SwapTotal /proc/meminfo | awk '{print $2}')
        FREE_SWAP=$(grep SwapFree /proc/meminfo | awk '{print $2}')
        
        if [ "$TOTAL_SWAP" -gt 0 ]; then
            USED_SWAP=$((TOTAL_SWAP - FREE_SWAP))
            print_info "Total Swap" "$(awk "BEGIN {printf \"%.2f GB\", $TOTAL_SWAP/1024/1024}")"
            print_info "Used Swap" "$(awk "BEGIN {printf \"%.2f GB\", $USED_SWAP/1024/1024}")"
        fi
    fi
}

# Get screen/display information
get_display_info() {
    print_header "DISPLAY INFORMATION"
    
    if [ -n "$DISPLAY" ] && command_exists xrandr; then
        RESOLUTION=$(xrandr 2>/dev/null | grep '*' | awk '{print $1}' | head -1)
        [ -n "$RESOLUTION" ] && print_info "Resolution" "$RESOLUTION"
        
        REFRESH=$(xrandr 2>/dev/null | grep '*' | awk '{print $2}' | head -1)
        [ -n "$REFRESH" ] && print_info "Refresh Rate" "$REFRESH"
    elif command_exists xdpyinfo; then
        DIM=$(xdpyinfo 2>/dev/null | grep dimensions | awk '{print $2}')
        [ -n "$DIM" ] && print_info "Display Dimensions" "$DIM"
    else
        print_info "Display" "No display detected or not available"
    fi
}

# Get battery information
get_battery_info() {
    print_header "BATTERY INFORMATION"
    
    BATTERY_FOUND=false
    
    # Check upower
    if command_exists upower; then
        BATTERY_PATH=$(upower -e | grep battery | head -1)
        if [ -n "$BATTERY_PATH" ]; then
            BATTERY_INFO=$(upower -i "$BATTERY_PATH")
            
            STATE=$(echo "$BATTERY_INFO" | grep "state" | awk '{print $2}')
            PERCENTAGE=$(echo "$BATTERY_INFO" | grep "percentage" | awk '{print $2}')
            TIME_TO=$(echo "$BATTERY_INFO" | grep "time to" | cut -d ':' -f2- | xargs)
            
            print_info "Status" "$STATE"
            print_info "Level" "$PERCENTAGE"
            [ -n "$TIME_TO" ] && print_info "Time Remaining" "$TIME_TO"
            
            BATTERY_FOUND=true
        fi
    fi
    
    # Check /sys/class/power_supply/
    if [ "$BATTERY_FOUND" = false ] && [ -d /sys/class/power_supply/ ]; then
        for battery in /sys/class/power_supply/BAT*; do
            if [ -d "$battery" ]; then
                [ -f "$battery/status" ] && print_info "Status" "$(cat "$battery/status")"
                [ -f "$battery/capacity" ] && print_info "Level" "$(cat "$battery/capacity")%"
                BATTERY_FOUND=true
                break
            fi
        done
    fi
    
    [ "$BATTERY_FOUND" = false ] && print_info "Battery" "No battery detected (Desktop or not available)"
}

# Get network information
get_network_info() {
    print_header "NETWORK INFORMATION"
    
    # Active interfaces
    if command_exists ip; then
        ACTIVE_IF=$(ip -o link show | awk -F': ' '{print $2}' | grep -v lo)
        for iface in $ACTIVE_IF; do
            STATUS=$(ip link show "$iface" | grep -o "state [A-Z]*" | awk '{print $2}')
            if [ "$STATUS" = "UP" ]; then
                IP_ADDR=$(ip -4 addr show "$iface" | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
                print_info "Interface $iface" "UP - $IP_ADDR"
            fi
        done
    fi
    
    # Check internet connectivity
    if ping -c 1 -W 2 8.8.8.8 >/dev/null 2>&1; then
        print_info "Internet" "Connected"
        
        # Measure latency
        LATENCY=$(ping -c 4 8.8.8.8 2>/dev/null | tail -1 | awk -F '/' '{print $5}')
        [ -n "$LATENCY" ] && print_info "Avg Latency" "${LATENCY} ms"
    else
        print_info "Internet" "Disconnected"
    fi
    
    # Network speed test (if speedtest-cli is available)
    if command_exists speedtest-cli; then
        echo -e "\n${YELLOW}Running speed test (this may take a moment)...${NC}"
        SPEED_TEST=$(speedtest-cli --simple 2>/dev/null)
        if [ $? -eq 0 ]; then
            echo "$SPEED_TEST" | while read -r line; do
                print_info "$(echo $line | cut -d ':' -f1)" "$(echo $line | cut -d ':' -f2 | xargs)"
            done
        fi
    fi
}

# Get storage information
get_storage_info() {
    print_header "STORAGE INFORMATION"
    
    df -h --output=source,fstype,size,used,avail,pcent,target 2>/dev/null | grep -E '^/dev/' | while read -r line; do
        DEVICE=$(echo "$line" | awk '{print $1}')
        FSTYPE=$(echo "$line" | awk '{print $2}')
        SIZE=$(echo "$line" | awk '{print $3}')
        USED=$(echo "$line" | awk '{print $4}')
        AVAIL=$(echo "$line" | awk '{print $5}')
        PERCENT=$(echo "$line" | awk '{print $6}')
        MOUNT=$(echo "$line" | awk '{print $7}')
        
        echo -e "\n${CYAN}$DEVICE${NC} mounted on ${YELLOW}$MOUNT${NC}"
        print_info "  Type" "$FSTYPE"
        print_info "  Size" "$SIZE"
        print_info "  Used" "$USED ($PERCENT)"
        print_info "  Available" "$AVAIL"
    done
    
    # Disk I/O stats
    if command_exists iostat; then
        echo -e "\n${CYAN}Disk I/O Statistics:${NC}"
        iostat -d -h | tail -n +4 | head -n 5
    fi
}

# Get timezone information
get_timezone_info() {
    print_header "TIMEZONE & LOCALE"
    
    print_info "Current Time" "$(date '+%Y-%m-%d %H:%M:%S %Z')"
    print_info "Timezone" "$(timedatectl show -p Timezone --value 2>/dev/null || cat /etc/timezone 2>/dev/null || echo 'N/A')"
    print_info "System Language" "${LANG:-N/A}"
    print_info "LC_ALL" "${LC_ALL:-Not set}"
}

# Get performance metrics
get_performance_info() {
    print_header "PERFORMANCE METRICS"
    
    # Process count
    PROCESS_COUNT=$(ps aux | wc -l)
    print_info "Running Processes" "$PROCESS_COUNT"
    
    # Top processes by CPU
    echo -e "\n${CYAN}Top 5 Processes by CPU:${NC}"
    ps aux --sort=-%cpu | head -n 6 | tail -n 5 | awk '{printf "  %-20s %5s%%  %s\n", $11, $3, $2}'
    
    # Top processes by Memory
    echo -e "\n${CYAN}Top 5 Processes by Memory:${NC}"
    ps aux --sort=-%mem | head -n 6 | tail -n 5 | awk '{printf "  %-20s %5s%%  %s\n", $11, $4, $2}'
    
    # System boot time
    if command_exists who; then
        BOOT_TIME=$(who -b | awk '{print $3, $4}')
        print_info "Last Boot" "$BOOT_TIME"
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

# Export to JSON
export_json() {
    local output_file="${1:-system_scan_$(date +%Y%m%d_%H%M%S).json}"
    
    echo "{" > "$output_file"
    echo "  \"scan_time\": \"$(date -Iseconds)\"," >> "$output_file"
    echo "  \"hostname\": \"$(hostname)\"," >> "$output_file"
    echo "  \"kernel\": \"$(uname -r)\"," >> "$output_file"
    echo "  \"architecture\": \"$(uname -m)\"," >> "$output_file"
    
    # Add more fields as needed
    
    echo "}" >> "$output_file"
    
    echo -e "\n${GREEN}✓ Scan results exported to: ${output_file}${NC}"
}

# Clean system (cache, temp files, logs)
clean_system() {
    print_header "SYSTEM CLEANUP"
    
    local total_freed=0
    local requires_sudo=false
    
    # Check if running as root
    if [ "$EUID" -ne 0 ]; then
        requires_sudo=true
        echo -e "${YELLOW}Note: Some cleanup operations require sudo privileges${NC}\n"
    fi
    
    # 1. Package manager cache
    echo -e "${CYAN}Cleaning package manager cache...${NC}"
    if command_exists apt-get; then
        if [ "$requires_sudo" = true ]; then
            echo "  → apt cache (requires sudo): sudo apt-get clean && sudo apt-get autoclean"
            read -p "  Run apt cleanup? [y/N]: " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                sudo apt-get clean
                sudo apt-get autoclean
                echo -e "  ${GREEN}✓ APT cache cleaned${NC}"
            fi
        else
            apt-get clean
            apt-get autoclean
            echo -e "  ${GREEN}✓ APT cache cleaned${NC}"
        fi
    elif command_exists dnf; then
        if [ "$requires_sudo" = true ]; then
            sudo dnf clean all
        else
            dnf clean all
        fi
        echo -e "  ${GREEN}✓ DNF cache cleaned${NC}"
    elif command_exists yum; then
        if [ "$requires_sudo" = true ]; then
            sudo yum clean all
        else
            yum clean all
        fi
        echo -e "  ${GREEN}✓ YUM cache cleaned${NC}"
    elif command_exists pacman; then
        if [ "$requires_sudo" = true ]; then
            sudo pacman -Sc --noconfirm
        else
            pacman -Sc --noconfirm
        fi
        echo -e "  ${GREEN}✓ Pacman cache cleaned${NC}"
    fi
    
    # 2. User cache
    echo -e "\n${CYAN}Cleaning user cache...${NC}"
    if [ -d "$HOME/.cache" ]; then
        cache_size=$(du -sh "$HOME/.cache" 2>/dev/null | awk '{print $1}')
        echo "  Current cache size: $cache_size"
        read -p "  Clean user cache ($HOME/.cache)? [y/N]: " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "$HOME/.cache/"*
            echo -e "  ${GREEN}✓ User cache cleaned${NC}"
        fi
    fi
    
    # 3. Temporary files
    echo -e "\n${CYAN}Cleaning temporary files...${NC}"
    if [ -d /tmp ]; then
        tmp_size=$(du -sh /tmp 2>/dev/null | awk '{print $1}')
        echo "  /tmp size: $tmp_size"
        if [ "$requires_sudo" = true ]; then
            read -p "  Clean /tmp? (requires sudo) [y/N]: " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                sudo find /tmp -type f -atime +7 -delete 2>/dev/null
                echo -e "  ${GREEN}✓ Old temp files cleaned${NC}"
            fi
        else
            find /tmp -type f -atime +7 -delete 2>/dev/null
            echo -e "  ${GREEN}✓ Old temp files cleaned${NC}"
        fi
    fi
    
    # 4. Journal logs
    echo -e "\n${CYAN}Cleaning system logs...${NC}"
    if command_exists journalctl; then
        journal_size=$(journalctl --disk-usage 2>/dev/null | grep -oP '\d+\.\d+[GM]' | head -1)
        echo "  Journal size: $journal_size"
        if [ "$requires_sudo" = true ]; then
            read -p "  Clean journal logs older than 7 days? (requires sudo) [y/N]: " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                sudo journalctl --vacuum-time=7d
                echo -e "  ${GREEN}✓ Journal logs cleaned${NC}"
            fi
        else
            journalctl --vacuum-time=7d
            echo -e "  ${GREEN}✓ Journal logs cleaned${NC}"
        fi
    fi
    
    # 5. Thumbnail cache
    echo -e "\n${CYAN}Cleaning thumbnail cache...${NC}"
    if [ -d "$HOME/.thumbnails" ]; then
        thumb_size=$(du -sh "$HOME/.thumbnails" 2>/dev/null | awk '{print $1}')
        echo "  Thumbnail cache size: $thumb_size"
        read -p "  Clean thumbnail cache? [y/N]: " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "$HOME/.thumbnails/"*
            echo -e "  ${GREEN}✓ Thumbnail cache cleaned${NC}"
        fi
    fi
    
    if [ -d "$HOME/.cache/thumbnails" ]; then
        thumb_size=$(du -sh "$HOME/.cache/thumbnails" 2>/dev/null | awk '{print $1}')
        echo "  Thumbnail cache size: $thumb_size"
        read -p "  Clean thumbnail cache? [y/N]: " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "$HOME/.cache/thumbnails/"*
            echo -e "  ${GREEN}✓ Thumbnail cache cleaned${NC}"
        fi
    fi
    
    # 6. Trash
    echo -e "\n${CYAN}Cleaning trash...${NC}"
    if [ -d "$HOME/.local/share/Trash" ]; then
        trash_size=$(du -sh "$HOME/.local/share/Trash" 2>/dev/null | awk '{print $1}')
        echo "  Trash size: $trash_size"
        read -p "  Empty trash? [y/N]: " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "$HOME/.local/share/Trash/"*
            echo -e "  ${GREEN}✓ Trash emptied${NC}"
        fi
    fi
    
    # 7. Old kernels (Debian/Ubuntu)
    if command_exists dpkg && [ "$requires_sudo" = true ]; then
        echo -e "\n${CYAN}Checking for old kernels...${NC}"
        OLD_KERNELS=$(dpkg --list | grep linux-image | awk '{print $2}' | grep -v "$(uname -r)" | wc -l)
        if [ "$OLD_KERNELS" -gt 0 ]; then
            echo "  Found $OLD_KERNELS old kernel(s)"
            read -p "  Remove old kernels? (requires sudo) [y/N]: " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                sudo apt-get autoremove --purge -y
                echo -e "  ${GREEN}✓ Old kernels removed${NC}"
            fi
        else
            echo "  No old kernels to remove"
        fi
    fi
    
    # 8. Browser cache (optional)
    echo -e "\n${CYAN}Browser caches (optional):${NC}"
    
    # Firefox
    if [ -d "$HOME/.mozilla/firefox" ]; then
        ff_size=$(du -sh "$HOME/.mozilla/firefox" 2>/dev/null | awk '{print $1}')
        echo "  Firefox cache size: $ff_size"
        read -p "  Clean Firefox cache? [y/N]: " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "$HOME/.mozilla/firefox/"*"/cache2"
            rm -rf "$HOME/.cache/mozilla/firefox"
            echo -e "  ${GREEN}✓ Firefox cache cleaned${NC}"
        fi
    fi
    
    # Chrome/Chromium
    if [ -d "$HOME/.cache/google-chrome" ]; then
        chrome_size=$(du -sh "$HOME/.cache/google-chrome" 2>/dev/null | awk '{print $1}')
        echo "  Chrome cache size: $chrome_size"
        read -p "  Clean Chrome cache? [y/N]: " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "$HOME/.cache/google-chrome"
            echo -e "  ${GREEN}✓ Chrome cache cleaned${NC}"
        fi
    fi
    
    if [ -d "$HOME/.cache/chromium" ]; then
        chromium_size=$(du -sh "$HOME/.cache/chromium" 2>/dev/null | awk '{print $1}')
        echo "  Chromium cache size: $chromium_size"
        read -p "  Clean Chromium cache? [y/N]: " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "$HOME/.cache/chromium"
            echo -e "  ${GREEN}✓ Chromium cache cleaned${NC}"
        fi
    fi
    
    # 9. Orphaned packages
    if command_exists apt-get; then
        echo -e "\n${CYAN}Checking for orphaned packages...${NC}"
        ORPHANED=$(apt-get autoremove --dry-run 2>/dev/null | grep -Po '^\d+(?= upgraded)')
        if [ -n "$ORPHANED" ] && [ "$ORPHANED" -gt 0 ]; then
            echo "  Found orphaned packages"
            read -p "  Remove orphaned packages? (requires sudo) [y/N]: " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                sudo apt-get autoremove -y
                echo -e "  ${GREEN}✓ Orphaned packages removed${NC}"
            fi
        fi
    fi
    
    echo -e "\n${BOLD}${GREEN}✓ Cleanup process complete!${NC}\n"
}

# Show usage
show_usage() {
    cat << EOF
${BOLD}${CYAN}$SCRIPT_NAME${NC} - Linux System Scanner v$VERSION

${BOLD}USAGE:${NC}
    $0 [OPTIONS]

${BOLD}OPTIONS:${NC}
    --scan              Run complete system scan
    --scan-quick        Run quick scan (basic info only)
    --export [FILE]     Export results to JSON file
    --hardware          Show only hardware information
    --network           Show only network information
    --performance       Show only performance metrics
    --clean             Clean system (cache, temp files, logs)
    --help, -h          Show this help message
    --version, -v       Show version information

${BOLD}EXAMPLES:${NC}
    $0 --scan                    # Full system scan
    $0 --scan --export           # Scan and export to JSON
    $0 --hardware                # Show hardware info only
    $0 --network                 # Show network info only
    $0 --clean                   # Clean system files

EOF
}

# Main function
main() {
    case "$1" in
        --scan)
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
        --clean)
            clean_system
            ;;
        --export)
            export_json "$2"
            ;;
        --version|-v)
            echo "$SCRIPT_NAME v$VERSION"
            ;;
        --help|-h|*)
            show_usage
            ;;
    esac
}

# Run main function
main "$@"