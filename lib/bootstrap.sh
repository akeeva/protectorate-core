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
#   - Discover the project root.
#   - Validate the installation.
#   - Load library modules.
#   # Initialize loaded modules. (Temporarily Disabled)
# -----------------------------------------------------------------------------

#==============================================================================
# Constants
#==============================================================================


[[ -n "${PROTECTORATE_INITIALIZED:-}" ]] && return 0
readonly PROTECTORATE_INITIALIZED=1

readonly PROTECTORATE_ROOT="$(
    cd "$(dirname "${BASH_SOURCE[0]}")/.." >/dev/null 2>&1 &&
    pwd
)"

readonly PROTECTORATE_SHELL_INIT_VERSION="0.1.0"

export PROTECTORATE_ROOT

#==============================================================================
# Private Functions
#==============================================================================

##
# Loads a library module.
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
# Performs shell initialization.
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

#    for module in "${modules[@]}"; do
#        "${module}_initialize"
#    done

}

#==============================================================================
# Public Functions
#==============================================================================

##
# Initializes Protectorate Core
#
shell_initialize() {
    if [[ ! -d "${PROTECTORATE_ROOT}/lib" ]]; then
        echo "Protectorate Core: invalid installation." >&2
        return 1
    fi

    _initialize
}

shell_initialize
