#!/usr/bin/env bash

#
# -----------------------------------------------------------------------------
# Protectorate Core
# Module: health.sh
#
# Description:
#   Displays cached health information for the Protectorate cluster.
#
# Responsibilities:
#   - Read the cached cluster health report.
#   - Determine whether the cached report is current.
#   - Aggregate health records into node-level status summaries.
#   - Render compact cluster health information in the Protectorate shell.
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
# Returns:
#   0 when the cache modification time can be determined.
#   Non-zero when the cache cannot be inspected.
#
# Output:
#   Prints the cache age in seconds to stdout.
#
_health_cache_age() {
    local modified_time
    local current_time

    modified_time="$(stat -c %Y "$HEALTH_CACHE_FILE" 2>/dev/null)" || return 1
    current_time="$(date +%s)"

    printf '%s\n' "$((current_time - modified_time))"
}

##
# Renders one generic health status line.
#
# Arguments:
#   $1 - Health status value.
#   $2 - Health item label.
#   $3 - Health item detail text.
#
# Side Effects:
#   Writes a formatted health status line to stdout.
#
_health_render_item() {
    local status="$1"
    local label="$2"
    local detail="$3"
    local status_color
    local state
    local remainder
    local state_color

    case "$status" in
        OK)
            status_color="$UI_BRIGHT_GREEN"
            ;;
        WARN)
            status_color="$UI_BRIGHT_YELLOW"
            ;;
        FAIL)
            status_color="$UI_BRIGHT_RED"
            ;;
        *)
            status_color="$UI_GRAY"
            ;;
    esac

    state="${detail%% · *}"

    if [[ "$detail" == *" · "* ]]; then
        remainder="${detail#* · }"
    else
        remainder=""
    fi

    case "$state" in
        Online)
            state_color="$UI_BRIGHT_GREEN"
            ;;
        Unreachable)
            state_color="$UI_BRIGHT_RED"
            ;;
        *)
            state_color="$UI_GRAY"
            ;;
    esac

    printf "%b%-6s%b %-18s " \
        "$status_color" \
        "$status" \
        "$UI_RESET" \
        "$label"

    if [[ -n "$remainder" ]]; then
        printf "%b%s%b · %s\n" \
            "$state_color" \
            "$state" \
            "$UI_RESET" \
            "$remainder"
    else
        printf "%b%s%b\n" \
            "$state_color" \
            "$detail" \
            "$UI_RESET"
    fi
}

##
# Returns the severity rank for a health status.
#
# The numeric rank is used when aggregating multiple health records into a
# single node-level status. Higher values represent greater severity.
#
# Arguments:
#   $1 - Health status value.
#
# Rankings:
#   OK            -> 1
#   WARN          -> 2
#   FAIL          -> 3
#   Other/unknown -> 0
#
# Output:
#   Prints the numeric severity rank to stdout.
#
_health_status_rank() {
    case "$1" in
        FAIL) printf '3\n' ;;
        WARN) printf '2\n' ;;
        OK)   printf '1\n' ;;
        *)    printf '0\n' ;;
    esac
}

##
# Renders one compact node-level health summary.
#
# Arguments:
#   $1 - Node display name.
#   $2 - Aggregated node health status.
#   $3 - Node connectivity state.
#   $4 - CPU utilization value.
#   $5 - Memory utilization value.
#   $6 - Root filesystem utilization value.
#
# Side Effects:
#   Writes a formatted node health summary to stdout.
#
_health_render_node() {
    local node="$1"
    local status="$2"
    local state="$3"
    local cpu="$4"
    local memory="$5"
    local disk="$6"
    local status_color
    local state_color

    case "$status" in
        OK)   status_color="$UI_BRIGHT_GREEN" ;;
        WARN) status_color="$UI_BRIGHT_YELLOW" ;;
        FAIL) status_color="$UI_BRIGHT_RED" ;;
        *)    status_color="$UI_GRAY" ;;
    esac

    case "$state" in
        Online)      state_color="$UI_BRIGHT_GREEN" ;;
        Unreachable) state_color="$UI_BRIGHT_RED" ;;
        *)           state_color="$UI_GRAY" ;;
    esac

    printf "%-12s %b%-5s%b %b%-12s%b CPU %-4s  Mem %-4s  Disk %-4s\n" \
        "$node" \
        "$status_color" \
        "$status" \
        "$UI_RESET" \
        "$state_color" \
        "$state" \
        "$UI_RESET" \
        "$cpu" \
        "$memory" \
        "$disk"
}

##
# Reads cached health records and renders one aggregated row per node.
#
# Node-level status is determined from the highest-severity record associated
# with each node. CPU, memory, and root filesystem utilization are extracted
# from their respective metric records. Missing metrics are displayed as "--".
#
# Side Effects:
#   Reads HEALTH_CACHE_FILE.
#   Writes compact node health summaries to stdout.
#
_health_render_cache() {
    local status
    local label
    local detail
    local node
    local metric
    local rank
    local current_rank

    declare -A node_status
    declare -A node_state
    declare -A node_cpu
    declare -A node_memory
    declare -A node_disk
    declare -a nodes

    while IFS=$'\t' read -r status label detail; do
        [[ -n "$status" ]] || continue
        [[ "$status" == \#* ]] && continue

        node="${label%% *}"

        if [[ -z "${node_status[$node]+x}" ]]; then
            nodes+=("$node")
            node_status["$node"]="OK"
            node_state["$node"]="Unknown"
            node_cpu["$node"]="--"
            node_memory["$node"]="--"
            node_disk["$node"]="--"
        fi

        if [[ "$label" == "$node" ]]; then
            node_state["$node"]="${detail%% · *}"

            rank="$(_health_status_rank "$status")"
            current_rank="$(_health_status_rank "${node_status[$node]}")"

            if ((rank > current_rank)); then
                node_status["$node"]="$status"
            fi
        else
            metric="${label#"$node "}"

            case "$metric" in
                CPU)
                    node_cpu["$node"]="${detail#CPU }"
                    node_cpu["$node"]="${node_cpu[$node]% used}"
                    ;;
                Memory)
                    node_memory["$node"]="${detail#Memory }"
                    node_memory["$node"]="${node_memory[$node]% used}"
                    ;;
                Disk)
                    node_disk["$node"]="${detail#Root filesystem }"
                    node_disk["$node"]="${node_disk[$node]% used}"
                    ;;
            esac

            rank="$(_health_status_rank "$status")"
            current_rank="$(_health_status_rank "${node_status[$node]}")"

            if ((rank > current_rank)); then
                node_status["$node"]="$status"
            fi
        fi
    done < "$HEALTH_CACHE_FILE"

    for node in "${nodes[@]}"; do
        _health_render_node \
            "$node" \
            "${node_status[$node]}" \
            "${node_state[$node]}" \
            "${node_cpu[$node]}" \
            "${node_memory[$node]}" \
            "${node_disk[$node]}"
    done
}

#==============================================================================
# Public Functions
#==============================================================================

##
# Displays the cached Protectorate cluster health summary.
#
# The cache must exist, be readable, and be no older than
# HEALTH_CACHE_MAX_AGE. Missing or stale cache data is reported as a monitoring
# warning instead of preventing the Protectorate shell from loading.
#
# Returns:
#    0 after rendering the cluster health summary or a monitoring warning.
#
# Side Effects:
#    Reads HEALTH_CACHE_FILE.
#    Writes the Cluster Health section to stdout.
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
