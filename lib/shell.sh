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

##
# Reports whether the Protectorate shell framework is already initialized.
#
# Returns:
#   0 if the shell framework has already been initialized.
#   Non-zero otherwise.
#
_shell_initialized() {
    [[ -n "${PROTECTORATE_SHELL_LOADED:-}" ]]
}

#==============================================================================
# Public Functions
#==============================================================================

##
# Initializes the Protectorate shell framework.
#
# Loads the bootstrap module once and marks the shell framework initialized.
# Repeated calls return successfully without performing initialization again.
#
# Returns:
#   0 on success or when already initialized.
#   Non-zero if the bootstrap module cannot be found or loaded.
#
# Side Effects:
#   Sources the Protectorate bootstrap module.
#   Defines PROTECTORATE_SHELL_LOADED as a readonly global.
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

# Initialize the framework when this entry-point module is sourced.
protectorate_shell_init
