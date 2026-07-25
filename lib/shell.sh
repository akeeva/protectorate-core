#!/usr/bin/env bash
#
# -----------------------------------------------------------------------------
# Protectorate Core
# Module: shell.sh
#
# Description:
#   Entry point for the Protectorate shell framework.
#
# Responsibilities:
#   - Initialize the Protectorate shell environment.
#   - Prevent duplicate framework initialization.
# -----------------------------------------------------------------------------

#==============================================================================
# Include Guard
#==============================================================================

[[ -n "${PROTECTORATE_SHELL_MODULE_LOADED:-}" ]] && return 0
readonly PROTECTORATE_SHELL_MODULE_LOADED=1

#==============================================================================
# Constants
#==============================================================================

_PROTECTORATE_BOOTSTRAP="$(
    cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 &&
    pwd
)/bootstrap.sh"

readonly _PROTECTORATE_BOOTSTRAP

#==============================================================================
# Private Functions
#==============================================================================

_shell_initialized() {
    [[ -n "${PROTECTORATE_SHELL_LOADED:-}" ]]
}

#==============================================================================
# Public Functions
#==============================================================================

##
# Initialize the Protectorate shell framework.
#
protectorate_shell_init() {
    if _shell_initialized; then
        return 0
    fi

    if [[ ! -f "$_PROTECTORATE_BOOTSTRAP" ]]; then
        printf '%s\n' \
            "Protectorate Core: bootstrap module not found: $_PROTECTORATE_BOOTSTRAP" >&2
        return 1
    fi
    

    source "$_PROTECTORATE_BOOTSTRAP" || return 1
    
    readonly PROTECTORATE_SHELL_LOADED=1
}

protectorate_shell_init
