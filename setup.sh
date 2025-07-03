#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Detect OS and architecture
detect_platform() {
    local os=$(uname -s | tr '[:upper:]' '[:lower:]')
    local arch=$(uname -m)
    
    case $os in
        linux*)
            OS="Linux"
            ;;
        darwin*)
            OS="Darwin"
            ;;
        *)
            log_error "Unsupported operating system: $os"
            exit 1
            ;;
    esac
    
    case $arch in
        x86_64|amd64)
            ARCH="x86_64"
            ;;
        arm64|aarch64)
            ARCH="arm64"
            ;;
        *)
            log_error "Unsupported architecture: $arch"
            exit 1
            ;;
    esac
    
    log_info "Detected platform: $OS-$ARCH"
}

# Get latest version from GitHub releases
get_latest_version() {
    log_info "Fetching latest version from GitHub releases..."
    
    local api_url="https://api.github.com/repos/PraveenGongada/catalyst/releases/latest"
    local auth_header=""
    
    if [[ -n "$INPUT_GITHUB_TOKEN" ]]; then
        auth_header="Authorization: token $INPUT_GITHUB_TOKEN"
    fi
    
    if command -v curl >/dev/null 2>&1; then
        if [[ -n "$auth_header" ]]; then
            LATEST_VERSION=$(curl -s -H "$auth_header" "$api_url" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
        else
            LATEST_VERSION=$(curl -s "$api_url" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
        fi
    else
        log_error "curl is required but not installed"
        exit 1
    fi
    
    if [[ -z "$LATEST_VERSION" ]]; then
        log_error "Failed to fetch latest version"
        exit 1
    fi
    
    log_info "Latest version: $LATEST_VERSION"
}

# Download and install Catalyst
download_catalyst() {
    local version="$1"
    local download_url="https://github.com/PraveenGongada/catalyst/releases/download/${version}/catalyst_${OS}_${ARCH}.tar.gz"
    local temp_dir=$(mktemp -d)
    local binary_dir="$HOME/.local/bin"
    
    log_info "Downloading Catalyst from: $download_url"
    
    # Create binary directory if it doesn't exist
    mkdir -p "$binary_dir"
    
    # Download the release
    if ! curl -fsSL "$download_url" -o "$temp_dir/catalyst.tar.gz"; then
        log_error "Failed to download Catalyst from $download_url"
        exit 1
    fi
    
    # Extract the binary
    if ! tar -xzf "$temp_dir/catalyst.tar.gz" -C "$temp_dir"; then
        log_error "Failed to extract Catalyst archive"
        exit 1
    fi
    
    # Move binary to destination
    if ! mv "$temp_dir/catalyst" "$binary_dir/catalyst"; then
        log_error "Failed to install Catalyst binary"
        exit 1
    fi
    
    # Make it executable
    chmod +x "$binary_dir/catalyst"
    
    # Add to PATH
    echo "$binary_dir" >> $GITHUB_PATH
    
    # Clean up
    rm -rf "$temp_dir"
    
    log_success "Catalyst installed successfully to $binary_dir/catalyst"
    
    # Set outputs
    echo "version=$version" >> $GITHUB_OUTPUT
    echo "path=$binary_dir/catalyst" >> $GITHUB_OUTPUT
}

# Verify installation
verify_installation() {
    log_info "Verifying Catalyst installation..."
    
    if command -v catalyst >/dev/null 2>&1; then
        local installed_version=$(catalyst -version | head -n1)
        log_success "Catalyst verification successful: $installed_version"
    else
        log_error "Catalyst verification failed - binary not found in PATH"
        exit 1
    fi
}

# Main setup function
setup_catalyst() {
    log_info "Starting Catalyst setup..."
    
    # Detect platform
    detect_platform
    
    # Determine version to install
    local version_to_install="$INPUT_VERSION"
    if [[ "$version_to_install" == "latest" ]] || [[ -z "$version_to_install" ]]; then
        get_latest_version
        version_to_install="$LATEST_VERSION"
    fi
    
    log_info "Installing Catalyst version: $version_to_install"
    
    # Download and install
    download_catalyst "$version_to_install"
    
    verify_installation
    
    log_success "Catalyst setup completed successfully!"
}

# Only run if script is executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_catalyst
fi
