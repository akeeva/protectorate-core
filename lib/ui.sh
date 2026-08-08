#!/usr/bin/env bash
#
# -----------------------------------------------------------------------------
# Protectorate Core
# Module: ui.sh
#
# Description:
#   Provides shared terminal user interface primitives and color definitions.
#
# Responsibilities:
#   - Define ANSI color constants.
#   - Define prompt color constants.
#   - Define shared terminal separators.
#   - Render reusable terminal UI elements.
# -----------------------------------------------------------------------------

#==============================================================================
# Include Guard
#==============================================================================

[[ -n "${_PROTECTORATE_UI_LOADED:-}" ]] && return
readonly _PROTECTORATE_UI_LOADED=1

#==============================================================================
# Constants
#==============================================================================

#------------------------------------------------------------------------------
# ANSI Colors
#------------------------------------------------------------------------------

# Reset
readonly UI_RESET="\033[0m"

# Black / Gray
readonly UI_GRAY="\033[0;90m"

# Red
readonly UI_RED="\033[0;31m"
readonly UI_BRIGHT_RED="\033[1;31m"

# Green
readonly UI_GREEN="\033[0;32m"
readonly UI_BRIGHT_GREEN="\033[1;32m"

# Yellow
readonly UI_YELLOW="\033[0;33m"
readonly UI_BRIGHT_YELLOW="\033[1;33m"

# Blue
readonly UI_BLUE="\033[0;34m"
readonly UI_BRIGHT_BLUE="\033[1;34m"

# Magenta
readonly UI_MAGENTA="\033[0;35m"
readonly UI_BRIGHT_MAGENTA="\033[1;35m"

# Cyan
readonly UI_CYAN="\033[0;36m"
readonly UI_BRIGHT_CYAN="\033[1;36m"

# White
readonly UI_WHITE="\033[0;37m"
readonly UI_BRIGHT_WHITE="\033[1;37m"

#------------------------------------------------------------------------------
# Protectorate Prompt Colors
#------------------------------------------------------------------------------

readonly UI_PROMPT_USER_SUCCESS="${UI_BRIGHT_BLUE}"
readonly UI_PROMPT_USER_FAILURE="${UI_BRIGHT_RED}"

readonly UI_PROMPT_ROOT_SUCCESS="${UI_BRIGHT_YELLOW}"
readonly UI_PROMPT_ROOT_FAILURE="${UI_BRIGHT_MAGENTA}"

#------------------------------------------------------------------------------
# Separators
#------------------------------------------------------------------------------

readonly UI_LINE_HEAVY="════════════════════════════════════════════════════"
readonly UI_LINE_LIGHT="────────────────────────────────────────────────────"

#==============================================================================
# Public Functions
#==============================================================================

##
# Displays a titled UI section with a separator line.
#
# Arguments:
#   $1 - Section title.
#
# Output:
#   Writes the formatted section header to standard output.
#
ui_section() {
    printf "%b%s%b\n" "${UI_BRIGHT_MAGENTA}" "$1" "${UI_RESET}"
    printf "%b%s%b\n" "${UI_GRAY}" "$UI_LINE_LIGHT" "${UI_RESET}"
}

##
# Displays a UI item using the standard item label width.
#
# Arguments:
#   $1 - Item label.
#   $2 - Item value.
#
# Output:
#   Writes the formatted item to standard output.
#
ui_item() {
    printf "%-18s %s\n" "$1" "$2"
}

##
# Displays a compact UI label and value pair.
#
# Arguments:
#   $1 - Label.
#   $2 - Value.
#
# Output:
#   Writes the formatted label and value to standard output.
#
ui_label() {
    printf "%-10s %s\n" "$1" "$2"
}
