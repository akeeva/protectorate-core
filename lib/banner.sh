#!/usr/bin/env bash
#
# -----------------------------------------------------------------------------
# Protectorate Core
# Module: banner.sh
#
# Description:
#   Generates login banners for Protectorate nodes
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
# Description...
#
banner_main() {
    _banner_render "${BANNER_DEFAULT}" || return 1
}

banner_random() {
    banner_main

    #TODO Add randomization when more banner files exist
}


