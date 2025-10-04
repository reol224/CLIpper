#!/bin/bash

# CLIpper Uninstall Script
# Cross-platform System Management Tool
# https://aa6f8cd6-9526-49fe-9abe-c7500cf69a7c.canvases.tempo.build/

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${RED}CLIpper Uninstall Script${NC}"
echo -e "${BLUE}Removing CLIpper from your system...${NC}"
echo ""

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
    else
        echo -e "${RED}Error: Unsupported operating system: $OSTYPE${NC}"
        exit 1
    fi
}

# Confirm uninstall
confirm_uninstall() {
    echo -e "${YELLOW}⚠️  WARNING: This will completely remove CLIpper from your system.${NC}"
    echo ""
    echo "This will remove:"
    echo "• CLIpper executable"
    echo "• Desktop shortcuts"
    echo "• PATH configuration"
    echo "• All CLIpper data and settings"
    echo ""
    read -p "Are you sure you want to continue? (y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}Uninstall cancelled.${NC}"
        exit 0
    fi
    echo ""
}

# Uninstall for macOS
uninstall_macos() {
    echo -e "${BLUE}Uninstalling CLIpper from macOS...${NC}"
    
    # Remove CLIpper directory
    if [[ -d "$HOME/Applications/CLIpper" ]]; then
        rm -rf "$HOME/Applications/CLIpper"
        echo -e "${GREEN}✓ Removed CLIpper directory${NC}"
    fi
    
    # Remove from shell configuration files
    for shell_rc in "$HOME/.zshrc" "$HOME/.bash_profile" "$HOME/.bashrc"; do
        if [[ -f "$shell_rc" ]]; then
            # Create backup
            cp "$shell_rc" "$shell_rc.bak.$(date +%Y%m%d_%H%M%S)"
            # Remove CLIpper PATH entries
            sed -i.tmp '/CLIpper/d' "$shell_rc" 2>/dev/null || true
            rm -f "$shell_rc.tmp"
            echo -e "${GREEN}✓ Cleaned $shell_rc${NC}"
        fi
    done
    
    # Remove symlink
    if [[ -L "/usr/local/bin/clipper" ]]; then
        rm -f /usr/local/bin/clipper
        echo -e "${GREEN}✓ Removed symlink${NC}"
    fi
    
    # Remove from Homebrew if installed
    if command -v brew >/dev/null 2>&1; then
        brew uninstall clipper 2>/dev/null || true
        echo -e "${GREEN}✓ Removed from Homebrew${NC}"
    fi
}

# Uninstall for Linux
uninstall_linux() {
    echo -e "${BLUE}Uninstalling CLIpper from Linux...${NC}"
    
    # Remove executable
    if [[ -f "/usr/local/bin/clipper" ]]; then
        if [[ $EUID -eq 0 ]]; then
            rm -f /usr/local/bin/clipper
            echo -e "${GREEN}✓ Removed executable${NC}"
        else
            sudo rm -f /usr/local/bin/clipper
            echo -e "${GREEN}✓ Removed executable${NC}"
        fi
    fi
    
    # Remove desktop entry
    if [[ -f "$HOME/.local/share/applications/clipper.desktop" ]]; then
        rm -f "$HOME/.local/share/applications/clipper.desktop"
        echo -e "${GREEN}✓ Removed desktop entry${NC}"
    fi
    
    # Remove from package managers
    if command -v apt >/dev/null 2>&1; then
        sudo apt remove clipper -y 2>/dev/null || true
        echo -e "${GREEN}✓ Removed from apt${NC}"
    fi
    
    if command -v yum >/dev/null 2>&1; then
        sudo yum remove clipper -y 2>/dev/null || true
        echo -e "${GREEN}✓ Removed from yum${NC}"
    fi
    
    if command -v pacman >/dev/null 2>&1; then
        sudo pacman -R clipper --noconfirm 2>/dev/null || true
        echo -e "${GREEN}✓ Removed from pacman${NC}"
    fi
    
    # Remove config directories
    rm -rf "$HOME/.config/clipper" 2>/dev/null || true
    rm -rf "$HOME/.local/share/clipper" 2>/dev/null || true
    echo -e "${GREEN}✓ Removed configuration files${NC}"
}

# Main uninstall function
main() {
    detect_os
    confirm_uninstall
    
    echo -e "OS: ${BLUE}$OS${NC}"
    echo ""
    
    case $OS in
        macos)
            uninstall_macos
            ;;
        linux)
            uninstall_linux
            ;;
        *)
            echo -e "${RED}Error: Unsupported OS: $OS${NC}"
            exit 1
            ;;
    esac
    
    echo ""
    echo -e "${GREEN}🗑️  CLIpper has been completely uninstalled!${NC}"
    echo ""
    echo -e "${BLUE}What was removed:${NC}"
    echo "• CLIpper executable and all files"
    echo "• Desktop shortcuts and menu entries"
    echo "• PATH configuration"
    echo "• Configuration and data files"
    echo ""
    echo -e "${YELLOW}Please restart your terminal for changes to take effect.${NC}"
    echo ""
    echo -e "${BLUE}Thank you for using CLIpper!${NC}"
}

# Run main function
main "$@"