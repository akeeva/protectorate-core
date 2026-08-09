#!/usr/bin/env bash

#
# -----------------------------------------------------------------------------
# Protectorate Core
# Installer: install.sh
#
# Description:
# Installs Protectorate Core and configures shell integration for the node.
#
# Responsibilities:
# - Validate installer privileges and repository contents.
# - Install the Protectorate Core framework.
# - Select supported node-specific optional components.
# - Write node-specific component configuration.
# - Configure login and interactive shell integration.
# -----------------------------------------------------------------------------

set -euo pipefail

#==============================================================================
# Constants
#==============================================================================

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
    "assets/banners"
    "assets/config/protectorate.sh"
)

readonly OPTIONAL_FILES=(
    "lib/health.sh"
    "assets/config/nanorc"
    "README.md"
    "LICENSE"
    "docs"
)

#==============================================================================
# Installer State
#==============================================================================

health_display_selection="prompt"

#==============================================================================
# Output Functions
#==============================================================================

##
# Prints an informational installer message.
#
# Arguments:
# $1 - Message text.
#
# Side Effects:
# Writes formatted output to stdout.
#
info() {
    printf "[${COLOR_BLUE}INFO ${COLOR_RESET}] %s\n" "$1"
}

##
# Prints a successful installer operation message.
#
# Arguments:
# $1 - Message text.
#
# Side Effects:
# Writes formatted output to stdout.
#
success() {
    printf "[${COLOR_GREEN} OK ${COLOR_RESET}] %s\n" "$1"
}

##
# Prints an installer warning.
#
# Arguments:
# $1 - Warning text.
#
# Side Effects:
# Writes formatted output to stdout.
#
warn() {
    printf "[${COLOR_YELLOW} WARN ${COLOR_RESET}] %s\n" "$1"
}

##
# Prints an installer error.
#
# Arguments:
# $1 - Error text.
#
# Side Effects:
# Writes formatted output to stderr.
#
error() {
    printf "[${COLOR_RED} FAIL ${COLOR_RESET}] %s\n" "$1" >&2
}

#==============================================================================
# Private Functions
#==============================================================================

##
# Displays installer command-line help.
#
# Side Effects:
# Writes usage information to stdout.
#
show_help() {
    cat <<'EOF'
Usage: sudo ./install.sh [options]

Options:
--enable-health-display   Enable the optional cluster health display.
--disable-health-display  Disable the optional cluster health display.
-h, --help                Show this help text.
EOF
}

##
# Parses installer command-line arguments.
#
# Arguments:
# All arguments passed to install.sh.
#
# Returns:
# 0 when all arguments are valid.
# Non-zero when an unknown option is supplied.
#
# Side Effects:
# Updates the requested health display installation state.
# May display help text and terminate successfully when --help is supplied.
#
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

##
# Verifies that the installer is running with root privileges.
#
# Returns:
# 0 when running as root.
# Non-zero otherwise.
#
# Side Effects:
# Writes installer status messages.
#
require_root() {
    info "Checking root privileges..."

    if [[ $EUID -ne 0 ]]; then
        error "Installer must be run as root."
        return 1
    fi

    success "Running as root."
    return 0
}

##
# Verifies the Protectorate repository structure before installation.
#
# Required files and directories must exist for installation to continue.
# Missing optional files generate warnings but do not fail installation.
#
# Returns:
# 0 when all required repository contents are present.
# Non-zero when one or more required entries are missing.
#
# Side Effects:
# Writes verification results for required and optional repository contents.
#
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

##
# Determines whether the optional cluster health display should be enabled.
#
# Explicit command-line selections are preserved.
# Interactive installations prompt the operator when no selection was given.
# Noninteractive installations default to disabling the health display.
#
# Side Effects:
# Updates health_display_selection.
# May prompt for operator input.
#
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

    printf "Enable the optional cluster health display on this node? [y/N]: "
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

##
# Installs the Protectorate Core framework.
#
# The existing installation directory is removed before the current repository
# contents are copied into place.
#
# Side Effects:
# Removes and recreates INSTALL_DIR.
# Copies the current repository into INSTALL_DIR.
#
install_framework() {
    info "Installing Protectorate Core..."

    rm -rf "$INSTALL_DIR"
    mkdir -p "$INSTALL_DIR"

    cp -a . "$INSTALL_DIR"

    success "Installed to $INSTALL_DIR."
}

##
# Writes node-specific Protectorate component configuration.
#
# The generated configuration records whether the optional cluster health
# display should be loaded by Protectorate Core on this node.
#
# Side Effects:
# Creates the Protectorate configuration directory when necessary.
# Replaces COMPONENT_CONFIG.
#
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

##
# Installs the Protectorate login-shell loader.
#
# Side Effects:
# Installs the packaged profile loader into /etc/profile.d.
# Replaces an existing loader at PROFILE_LOADER.
#
install_profile_loader() {
    info "Installing login shell integration..."

    install -m 0644 \
        "assets/config/protectorate.sh" \
        "$PROFILE_LOADER"

    success "Installed $PROFILE_LOADER."
}

##
# Installs Protectorate integration for interactive Bash shells.
#
# The shell loader is appended only when the exact loader command is not
# already present in the system Bash configuration.
#
# Side Effects:
# May append the Protectorate shell loader block to BASHRC.
#
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

#==============================================================================
# Main
#==============================================================================

##
# Executes the Protectorate Core installation sequence.
#
# Arguments:
# All arguments passed to install.sh.
#
# Returns:
# 0 when installation completes successfully.
# Non-zero when argument parsing, privilege validation, or repository
# verification fails.
#
# Side Effects:
# Installs Protectorate Core and modifies system shell configuration.
#
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
