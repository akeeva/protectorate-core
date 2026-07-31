#!/usr/bin/env bash
#
# -----------------------------------------------------------------------------
# Protectorate Core
# Module: health.sh
#
# Description:
#   Displays cached health information for the cluster.
#
# Responsibilities:
#   - Read the cached lab health report.
#   - Determine whether the report is current.
#   - Render the lab health summary on the login screen.
# -----------------------------------------------------------------------------

#==============================================================================
# Include Guard
#==============================================================================

[[ -n "${_PROTECTORATE_HEALTH_LOADED:-}" ]] && return
readonly _PROTECTORATE_HEALTH_LOADED=1

#==============================================================================
# Constants
#==============================================================================

readonly HEALTH_CACHE_FILE="/var/cache/protectorate/health.tsv"
readonly HEALTH_CACHE_MAX_AGE=300

#==============================================================================
# Private Functions
#==============================================================================

##
# Returns the age of the health cache in seconds.
#
_health_cache_age() {
    local modified_time
    local current_time

    modified_time="$(stat -c %Y "$HEALTH_CACHE_FILE" 2>/dev/null)" || return 1
    current_time="$(date +%s)"

    printf '%s\n' "$((current_time - modified_time))"
}

##
# Renders one health status line.
#
_health_render_item() {
    local status="$1"
    local label="$2"
    local detail="$3"
    local color

    case "$status" in
        OK)
            color="$UI_BRIGHT_GREEN"
            ;;
        WARN)
            color="$UI_BRIGHT_YELLOW"
            ;;
        FAIL)
            color="$UI_BRIGHT_RED"
            ;;
        *)
            color="$UI_GRAY"
            ;;
    esac

    printf "%b%-6s%b %-18s %s\n" \
        "$color" \
        "$status" \
        "$UI_RESET" \
        "$label" \
        "$detail"
}

##
# Reads and renders health records from the cache.
#
_health_render_cache() {
    local status
    local label
    local detail

    while IFS=$'\t' read -r status label detail; do
        [[ -n "$status" ]] || continue
        [[ "$status" == \#* ]] && continue

        _health_render_item "$status" "$label" "$detail"
    done < "$HEALTH_CACHE_FILE"
}

#==============================================================================
# Public Functions
#==============================================================================

##
# Displays the cached Protectorate lab health summary.
#
health_summary() {
    local cache_age

    ui_section "Cluster Health"

    if [[ ! -r "$HEALTH_CACHE_FILE" ]]; then
        _health_render_item \
            "WARN" \
            "Monitoring" \
            "Health cache not yet available"
        return
    fi

    cache_age="$(_health_cache_age)" || {
        _health_render_item \
            "WARN" \
            "Monitoring" \
            "Unable to determine cache age"
        return
    }

    if ((cache_age > HEALTH_CACHE_MAX_AGE)); then
        _health_render_item \
            "WARN" \
            "Monitoring" \
            "Health cache is stale (${cache_age}s old)"
        return
    fi

    _health_render_cache
}
