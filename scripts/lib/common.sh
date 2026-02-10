#!/bin/sh
# Common functions for all scripts

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    printf "${GREEN}[INFO]${NC} %s\n" "$1"
}

log_error() {
    printf "${RED}[ERROR]${NC} %s\n" "$1" >&2
}

log_warn() {
    printf "${YELLOW}[WARN]${NC} %s\n" "$1"
}

log_success() {
    printf "${GREEN}[✓]${NC} %s\n" "$1"
}

log_step() {
    printf "${BLUE}[→]${NC} %s\n" "$1"
}

# Detect OS
detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$ID"
    else
        echo "unknown"
    fi
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if running as root
is_root() {
    [ "$(id -u)" -eq 0 ]
}

# Get dotfiles directory
get_dotfiles_dir() {
    if [ -n "$DOTFILES" ]; then
        echo "$DOTFILES"
    elif [ -d "$HOME/dot" ]; then
        echo "$HOME/dot"
    elif [ -d "$HOME/dotfiles" ]; then
        echo "$HOME/dotfiles"
    else
        echo "$HOME/dot"
    fi
}

# Safe symlink - creates parent dir if needed
safe_symlink() {
    local source="$1"
    local target="$2"

    if [ ! -e "$source" ]; then
        log_error "Source does not exist: $source"
        return 1
    fi

    # Create parent directory if it doesn't exist
    local target_dir
    target_dir="$(dirname "$target")"
    mkdir -p "$target_dir"

    # Remove existing file/symlink if it exists
    if [ -e "$target" ] || [ -L "$target" ]; then
        rm -f "$target"
    fi

    ln -sfn "$source" "$target"
    log_success "Linked: $target -> $source"
}

# Check if sudo is needed
needs_sudo() {
    if is_root; then
        echo ""
    else
        echo "sudo"
    fi
}
