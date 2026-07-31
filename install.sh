#!/usr/bin/env bash

set -euo pipefail

readonly INSTALL_DIR="/etc/protectorate"
readonly PROFILE_LOADER="/etc/profile.d/protectorate.sh"
readonly BASHRC="/etc/bash.bashrc"
readonly SHELL_LOADER='[ -r /etc/protectorate/lib/shell.sh ] && . /etc/protectorate/lib/shell.sh'
readonly COMPONENT_CONFIG="$INSTALL_DIR/config/components.conf"

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
    "lib/health.sh"
    "README.md"
    "LICENSE"
    "assets"
    "docs"
)

health_display_selection="prompt"

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

show_help() {
    cat <<'EOF'
Usage: sudo ./install.sh [options]

Options:
  --enable-health-display   Enable the optional cluster health display.
  --disable-health-display  Disable the optional cluster health display.
  -h, --help                Show this help text.
EOF
}

parse_arguments() {
    while (($# > 0)); do
        case "$1" in
            --enable-health-display)
                health_display_selection="enabled"
                ;;
            --disable-health-display)
                health_display_selection="disabled"
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                error "Unknown option: $1"
                show_help >&2
                return 1
                ;;
        esac

        shift
    done
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
            warn "$file (optional)"
        fi
    done

    if $failed; then
        error "Repository verification failed."
        return 1
    fi
    
    success "Repository verified."
}

select_optional_components() {
    if [[ "$health_display_selection" != "prompt" ]]; then
        return
    fi

    if [[ ! -t 0 ]]; then
        health_display_selection="disabled"
        warn "Noninteractive installation detected; health display disabled."
        return
    fi

    local reply

    printf "Enable the optional health display on this node? [y/N]: "
    read -r reply

    case "$reply" in
        y|Y|yes|YES)
            health_display_selection="enabled"
            ;;
        *)
            health_display_selection="disabled"
            ;;
    esac
}

install_framework() {
    info "Installing Protectorate Core..."

    rm -rf "$INSTALL_DIR"
    mkdir -p "$INSTALL_DIR"

    cp -a . "$INSTALL_DIR"

    success "Installed to $INSTALL_DIR."
}

install_component_config() {
    info "Writing component configuration..."

    install -d -m 0755 "$(dirname "$COMPONENT_CONFIG")"

    cat > "$COMPONENT_CONFIG" <<EOF
#!/usr/bin/env bash

# Node-specific Protectorate Core component settings.
PROTECTORATE_HEALTH_DISPLAY=${health_display_selection}
EOF

    chmod 0644 "$COMPONENT_CONFIG"

    success "Health display: $health_display_selection"
}

install_profile_loader() {
    info "Installing login shell integration..."

    install -m 0644 \
        "assets/config/protectorate.sh" \
        "$PROFILE_LOADER"
        
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
    parse_arguments "$@" || return 1
    require_root || return 1
    verify_repository || return 1
    select_optional_components
    
    install_framework
    install_component_config
    install_profile_loader
    install_bash_loader
}

main "$@"
exit $?
