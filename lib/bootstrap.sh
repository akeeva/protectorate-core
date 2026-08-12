#!/usr/bin/env bash
#
# -----------------------------------------------------------------------------
# Protectorate Core
# Module: bootstrap.sh
#
# Description:
#   Initializes the Protectorate Core shell environment.
#
# Responsibilities:
#   - Discover the Protectorate installation root.
#   - Validate the installation structure.
#   - Load required library modules.
#   - Load optional components when enabled.
# -----------------------------------------------------------------------------

#==============================================================================
# Constants
#==============================================================================

[[ -n "${PROTECTORATE_INITIALIZED:-}" ]] && return 0
readonly PROTECTORATE_INITIALIZED=1

PROTECTORATE_ROOT="$(
    cd "$(dirname "${BASH_SOURCE[0]}")/.." >/dev/null 2>&1 &&
    pwd
)" || return 1

readonly PROTECTORATE_ROOT

readonly PROTECTORATE_SHELL_INIT_VERSION="0.1.0"

export PROTECTORATE_ROOT

#==============================================================================
# Private Functions
#==============================================================================

##
# Loads a Protectorate library module.
#
# Arguments:
#   $1 - Module name without the .sh extension.
#
# Returns:
#   0 when the module is loaded successfully.
#   Non-zero if the module file does not exist or cannot be sourced.
#
# Side Effects:
#   Sources the requested module into the current shell.
#
_load_module() {
    local module="$1"
    local file="${PROTECTORATE_ROOT}/lib/${module}.sh"

    [[ -f "$file" ]] || {
        echo "Missing module: ${module}" >&2
        return 1
    }

    source "$file"
}

##
# Loads the configured Protectorate Core modules.
#
# Reads the optional component configuration, builds the module load list,
# and loads each enabled module in dependency order.
#
# Returns:
#   0 when all enabled modules are loaded successfully.
#   Non-zero if a module cannot be loaded.
#
# Side Effects:
#   May source the component configuration file.
#   Sources each enabled Protectorate module.
#
_initialize() {
    local component_config="${PROTECTORATE_ROOT}/config/components.conf"

    if [[ -r "$component_config" ]]; then
        source "$component_config"
    fi

    local modules=(
        config
        ui
        banner
        system
        prompt
    )

    if [[ "${PROTECTORATE_HEALTH_DISPLAY:-disabled}" == "enabled" ]]; then
        modules+=(health)
    fi

    local module

    for module in "${modules[@]}"; do
        _load_module "${module}"
    done
}

#==============================================================================
# Public Functions
#==============================================================================

##
# Initializes Protectorate Core.
#
# Verifies the installation structure before loading the configured
# Protectorate modules.
#
# Returns:
#   0 on successful initialization.
#   Non-zero if the installation is invalid or initialization fails.
#
shell_initialize() {
    if [[ ! -d "${PROTECTORATE_ROOT}/lib" ]]; then
        echo "Protectorate Core: invalid installation." >&2
        return 1
    fi

    _initialize
}

# Initialize Protectorate Core when the bootstrap module is sourced.
shell_initialize
