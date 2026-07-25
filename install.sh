#!/usr/bin/env bash

set -euo pipefail

readonly INSTALL_DIR="/etc/protectorate"
readonly PROFILE_LOADER="/etc/profile.d/protectorate.sh"
readonly BASHRC="/etc/bash.bashrc"
readonly SHELL_LOADER='[ -r /etc/protectorate/lib/shell.sh ] && . /etc/protectorate/lib/shell.sh'

readonly COLOR_RED='\033[0;31m'
readonly COLOR_GREEN='\033[0;32m'
readonly COLOR_YELLOW='\033[1;33m'
readonly COLOR_BLUE='\033[0;34m'
readonly COLOR_RESET='\033[0m'

readonly REQUIRED_FILES=(
    "lib/banner.sh"
    "lib/bootstrap.sh"
    "lib/config.sh"
    "lib/prompt.sh"
    "lib/shell.sh"
    "lib/system.sh"
    "lib/ui.sh"
    "bin/protectorate-login"
)

readonly OPTIONAL_FILES=(
    "README.md"
    "LICENSE"
    "assets"
    "docs"
)

info () {
    printf "[${COLOR_BLUE}INFO ${COLOR_RESET}] %s\n" "$1"
}

success() {
    printf "[${COLOR_GREEN} OK ${COLOR_RESET}] %s\n" "$1"
}

warn() {
    printf "[${COLOR_YELLOW} WARN ${COLOR_RESET}] %s\n" "$1"
}

error() {
    printf "[${COLOR_RED} FAIL ${COLOR_RESET}] %s\n" "$1" >&2
}

require_root() {
    info "Checking root privileges..."

    if [[ $EUID -ne 0 ]]; then
        error "Installer must be run as root."
        return 1
    fi

    success "Running as root."
    return 0
}

verify_repository() {
    info "Verifying Protectorate repository..."

    local failed=false

    for file in "${REQUIRED_FILES[@]}"; do
        if [[ -e "$file" ]]; then
            success "$file"
        else
            error "$file (required)"
            failed=true
        fi
    done

    for file in "${OPTIONAL_FILES[@]}"; do
        if [[ -e "$file" ]]; then
            success "$file"
        else
            warn "$file (optional"
        fi
    done

    if $failed; then
        error "Repository verification failed."
        return 1
    fi
    
    success "Repository verified."
}

install_framework() {
    info "Installing Protectorate Core..."

    rm -rf "$INSTALL_DIR"
    mkdir -p "$INSTALL_DIR"

    cp -a . "$INSTALL_DIR"

    success "Installed to $INSTALL_DIR."
}

install_profile_loader() {
    info "Installing login shell integration..."

    cat > "$PROFILE_LOADER" <<EOF
#!/usr/bin/env bash
$SHELL_LOADER
EOF

    chmod 644 "$PROFILE_LOADER"

    success "Installed $PROFILE_LOADER."
}

install_bash_loader() {
    info "Installing interactive shell integration..."

    if grep -Fxq "$SHELL_LOADER" "$BASHRC"; then
        success "Shell loader already present."
        return
    fi

    {
        echo
        echo "# BEGIN Protectorate Core"
        echo "$SHELL_LOADER"
        echo "# END Protectorate Core"
    } >> "$BASHRC"

    success "Shell loader installed."
}

main() {
    require_root || return 1
    verify_repository || return 1
    
    install_framework
    install_profile_loader
    install_bash_loader
}

main "$@"
exit $?
