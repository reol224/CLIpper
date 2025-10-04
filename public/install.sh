#!/bin/bash

# CLIpper Installation Script
# Cross-platform System Management Tool
# https://aa6f8cd6-9526-49fe-9abe-c7500cf69a7c.canvases.tempo.build/

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# CLIpper version
CLIPPER_VERSION="1.0.0"
BASE_URL="https://aa6f8cd6-9526-49fe-9abe-c7500cf69a7c.canvases.tempo.build"

echo -e "${GREEN}CLIpper Installation Script v${CLIPPER_VERSION}${NC}"
echo -e "${BLUE}Cross-platform System Management Tool${NC}"
echo ""

# Detect OS and architecture
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
    elif [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "msys" ]]; then
        OS="windows"
    else
        echo -e "${RED}Error: Unsupported operating system: $OSTYPE${NC}"
        exit 1
    fi
}

detect_arch() {
    ARCH=$(uname -m)
    case $ARCH in
        x86_64)
            ARCH="amd64"
            ;;
        aarch64|arm64)
            ARCH="arm64"
            ;;
        armv7l)
            ARCH="armv7"
            ;;
        *)
            echo -e "${RED}Error: Unsupported architecture: $ARCH${NC}"
            exit 1
            ;;
    esac
}

# Check if running as root (for Linux)
check_permissions() {
    if [[ "$OS" == "linux" ]] && [[ $EUID -ne 0 ]]; then
        echo -e "${YELLOW}This script requires sudo privileges for Linux installation.${NC}"
        echo "Please run: curl -fsSL ${BASE_URL}/install.sh | sudo bash"
        exit 1
    fi
}

# Install for macOS
install_macos() {
    echo -e "${BLUE}Installing CLIpper for macOS...${NC}"
    
    # Create installation directory
    INSTALL_DIR="$HOME/Applications/CLIpper"
    mkdir -p "$INSTALL_DIR"
    
    # Download CLIpper
    echo "Downloading CLIpper..."
    DOWNLOAD_URL="${BASE_URL}/clipper-macos.tar.gz"
    curl -L "$DOWNLOAD_URL" -o /tmp/clipper.tar.gz
    
    # Extract
    echo "Extracting CLIpper..."
    tar -xzf /tmp/clipper.tar.gz -C "$INSTALL_DIR"
    
    # Make executable
    chmod +x "$INSTALL_DIR/clipper"
    
    # Add to PATH
    echo "Configuring PATH..."
    SHELL_RC=""
    if [[ -f "$HOME/.zshrc" ]]; then
        SHELL_RC="$HOME/.zshrc"
    elif [[ -f "$HOME/.bash_profile" ]]; then
        SHELL_RC="$HOME/.bash_profile"
    else
        SHELL_RC="$HOME/.zshrc"
        touch "$SHELL_RC"
    fi
    
    if ! grep -q "CLIpper" "$SHELL_RC"; then
        echo 'export PATH="$HOME/Applications/CLIpper:$PATH"' >> "$SHELL_RC"
    fi
    
    # Create symlink if possible
    if [[ -w "/usr/local/bin" ]]; then
        ln -sf "$INSTALL_DIR/clipper" /usr/local/bin/clipper
    fi
    
    # Cleanup
    rm -f /tmp/clipper.tar.gz
    
    echo -e "${GREEN}✅ CLIpper installed successfully!${NC}"
    echo -e "${YELLOW}Restart your terminal or run: source $SHELL_RC${NC}"
    echo -e "${YELLOW}Then type: clipper --help${NC}"
}

# Install for Linux
install_linux() {
    echo -e "${BLUE}Installing CLIpper for Linux...${NC}"
    
    # Download CLIpper
    echo "Downloading CLIpper..."
    DOWNLOAD_URL="${BASE_URL}/clipper-linux-${ARCH}.tar.gz"
    curl -L "$DOWNLOAD_URL" -o /tmp/clipper.tar.gz
    
    # Install to /usr/local/bin
    echo "Installing to /usr/local/bin..."
    tar -xzf /tmp/clipper.tar.gz -C /usr/local/bin
    chmod +x /usr/local/bin/clipper
    
    # Create desktop entry
    DESKTOP_DIR="$HOME/.local/share/applications"
    mkdir -p "$DESKTOP_DIR"
    
    cat > "$DESKTOP_DIR/clipper.desktop" << EOF
[Desktop Entry]
Name=CLIpper
Comment=Cross-platform System Management Tool
Exec=/usr/local/bin/clipper
Icon=utilities-system-monitor
Terminal=true
Type=Application
Categories=System;Utility;
EOF
    
    # Cleanup
    rm -f /tmp/clipper.tar.gz
    
    echo -e "${GREEN}✅ CLIpper installed successfully!${NC}"
    echo -e "${YELLOW}Type: clipper --help${NC}"
}

# Main installation function
main() {
    echo "Detecting system..."
    detect_os
    detect_arch
    
    echo -e "OS: ${BLUE}$OS${NC}"
    echo -e "Architecture: ${BLUE}$ARCH${NC}"
    echo ""
    
    case $OS in
        macos)
            install_macos
            ;;
        linux)
            check_permissions
            install_linux
            ;;
        windows)
            echo -e "${RED}Error: This script is for Unix-like systems.${NC}"
            echo -e "${YELLOW}For Windows, use PowerShell:${NC}"
            echo "irm ${BASE_URL}/install.ps1 | iex"
            exit 1
            ;;
        *)
            echo -e "${RED}Error: Unsupported OS: $OS${NC}"
            exit 1
            ;;
    esac
    
    echo ""
    echo -e "${GREEN}🎉 Installation complete!${NC}"
    echo ""
    echo -e "${BLUE}Next steps:${NC}"
    echo "1. Run: clipper --help"
    echo "2. Run: clipper --scan (system analysis)"
    echo "3. Run: clipper --optimize (performance boost)"
    echo ""
    echo -e "${BLUE}Documentation:${NC} ${BASE_URL}/docs"
    echo -e "${BLUE}Support:${NC} ${BASE_URL}/support"
}

# Run main function
main "$@"