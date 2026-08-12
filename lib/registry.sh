#!/usr/bin/env bash
#
# -----------------------------------------------------------------------------
# Protectorate Core
# Module: registry.sh
#
# Description:
#   Manages persistent Protectorate node identity and registry state.
#
# Responsibilities:
#   - Establish a persistent identity for the local Protectorate node.
#   - Provide the local node identifier to other Protectorate components.
#   - Manage persistent node registry state.
# -----------------------------------------------------------------------------

#==============================================================================
# Constants
#==============================================================================

readonly PROTECTORATE_STATE_DIR="/var/lib/protectorate"
readonly PROTECTORATE_NODE_ID_FILE="${PROTECTORATE_STATE_DIR}/node-id"

#==============================================================================
# Private Functions
#==============================================================================

##
# Validates a Protectorate node identifier.
#
# Arguments:
#   $1 - Node identifier to validate.
#
# Returns:
#   0 when the identifier is a valid UUID.
#   Non-zero otherwise.
#
_registry_valid_node_id() {
    local node_id="$1"

    [[ "$node_id" =~ ^[[:xdigit:]]{8}-[[:xdigit:]]{4}-[1-5][[:xdigit:]]{3}-[89abAB][[:xdigit:]]{3}-[[:xdigit:]]{12}$ ]]
}

##
# Creates a persistent identifier for the local Protectorate node.
#
# Returns:
#   0 then the node identifier exists or is created successfully.
#   Non-zero on failure.
#

_registry_ensure_node_id() {
    local node_id

    if [[ -s "$PROTECTORATE_NODE_ID_FILE" ]]; then
        node_id="$(< "$PROTECTORATE_NODE_ID_FILE")"

        _registry_valid_node_id "$node_id" || return 1

        return 0
    fi

    [[ -r /proc/sys/kernel/random/uuid ]] || return 1

    node_id="$(< /proc/sys/kernel/random/uuid)"
    _registry_valid_node_id "$node_id" || return 1

    install -d -m 0755 "$PROTECTORATE_STATE_DIR"

    printf '%s\n' "$node_id" > "$PROTECTORATE_NODE_ID_FILE"
    chmod 0644 "$PROTECTORATE_NODE_ID_FILE"
}

#==============================================================================
# Public Functions
#==============================================================================

##
# Returns the persistent identifier to the local Protectorate node.
#
# Output:
#   Prints the local node identifier to stdout.
#
# Returns:
#   0 on success.
#   Non-zero when the node identifier cannot be established or read.
#
registry_node_id() {
    _registry_ensure_node_id || return 1

    cat "$PROTECTORATE_NODE_ID_FILE"
}
