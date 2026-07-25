#!/usr/bin/env bash
#
# -----------------------------------------------------------------------------
# Protectorate Core
# Module: prompt.sh
#
# Description:
#   Modify the shell prompt to use Protectorate Core themed format
#
# -----------------------------------------------------------------------------

source "${PROTECTORATE_ROOT}/lib/ui.sh"

#==============================================================================
# Private Functions
#==============================================================================

_protectorate_prompt() {
    local exit_code=$?
    local arrow_color

    if (( EUID == 0 )); then
        # Root Shell
        if (( exit_code == 0 )); then
            arrow_color="${UI_PROMPT_ROOT_SUCCESS}"
        else
            arrow_color="${UI_PROMPT_ROOT_FAILURE}"
        fi
    else
        # Normal User
        if (( exit_code == 0 )); then
            arrow_color="${UI_PROMPT_USER_SUCCESS}"
        else
            arrow_color="${UI_PROMPT_USER_FAILURE}"
        fi
    fi

    PS1="${UI_BRIGHT_MAGENTA}♦ ${UI_BRIGHT_WHITE}\u@\h ${UI_GRAY}\w ${arrow_color}>${UI_RESET} "
}

PROMPT_COMMAND=_protectorate_prompt
