#!/usr/bin/env bash
#
# -----------------------------------------------------------------------------
# Protectorate Core
# Module: banner.sh
#
# Description:
#   Generates login banners for Protectorate nodes.
#
# Responsibilities:
#   - Define banner asset locations.
#   - Render banner files to standard output.
#   - Provide the default banner interface.
# -----------------------------------------------------------------------------

#==============================================================================
# Constants
#==============================================================================
readonly BANNER_DIR="${ASSETS_DIR}/banners"
readonly BANNER_DEFAULT="${BANNER_DIR}/protectorate.ans"
readonly BANNER_MAINTENANCE="maintenance.ans"
readonly BANNER_HOLIDAY="holiday.ans"

#==============================================================================
# Private Functions
#==============================================================================

##
# Renders a banner file to standard output.
#
# Arguments:
#   $1 - Path to the banner file.
#
# Output:
#   Writes the banner contents to standard output.
#
# Returns:
#   0 on success.
#   Non-zero if the banner file cannot be read.
#
_banner_render() {
    local banner_file="$1"

    if [[ ! -r "${banner_file}" ]]; then
        printf 'Error: Unable to read banner file: %s\n' "${banner_file}" >&2
        return 1
    fi
    
    cat "${banner_file}"
}

#==============================================================================
# Public Functions
#==============================================================================

##
# Displays the default Protectorate banner.
#
# Output:
#   Writes the default banner to standard output.
#
# Returns:
#   0 on success.
#   Non-zero if the default banner cannot be rendered.
#
banner_main() {
    _banner_render "${BANNER_DEFAULT}" || return 1
}

##
# Displays a Protectorate banner.
#
# Currently delegates to banner_main() until multiple banner assets are
# available for random selection.
#
banner_random() {
    banner_main

    #TODO: Add randomization when more banner files exist.
}
