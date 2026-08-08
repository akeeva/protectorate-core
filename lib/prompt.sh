#!/usr/bin/env bash
#
# -----------------------------------------------------------------------------
# Protectorate Core
# Module: prompt.sh
#
# Description:
#   Builds the Protectorate-themed interactive shell prompt.
#
# Responsibilities:
#   - Select prompt colors based on user privilege and command status.
#   - Build the Protectorate shell prompt.
#   - Register the prompt function with PROMPT_COMMAND.
# -----------------------------------------------------------------------------

source "${PROTECTORATE_ROOT}/lib/ui.sh"

#==============================================================================
# Private Functions
#==============================================================================

##
# Builds the interactive Protectorate shell prompt.
#
# Uses the previous command's exit status and the effective user ID to
# select the prompt arrow color before assigning PS1.
#
# Side Effects:
#   Updates the global PS1 variable.
#
_protectorate_prompt() {
    local exit_code=$?
    local arrow_color

    if (( EUID == 0 )); then
        # Root shell.
        if (( exit_code == 0 )); then
            arrow_color="${UI_PROMPT_ROOT_SUCCESS}"
        else
            arrow_color="${UI_PROMPT_ROOT_FAILURE}"
        fi
    else
        # Normal user.
        if (( exit_code == 0 )); then
            arrow_color="${UI_PROMPT_USER_SUCCESS}"
        else
            arrow_color="${UI_PROMPT_USER_FAILURE}"
        fi
    fi

    PS1="${UI_BRIGHT_MAGENTA}♦ ${UI_BRIGHT_WHITE}\u@\h ${UI_GRAY}\w ${arrow_color}>${UI_RESET} "
}

# Rebuild the prompt before each interactive command.
PROMPT_COMMAND=_protectorate_prompt
