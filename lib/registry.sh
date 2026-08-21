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
readonly PROTECTORATE_REGISTRY_FILE="${PROTECTORATE_STATE_DIR}/registry.json"
readonly PROTECTORATE_REGISTRY_VERSION=1

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
    local uuid_regex

    uuid_regex='^[[:xdigit:]]{8}-[[:xdigit:]]{4}-'
    uuid_regex+='[1-5][[:xdigit:]]{3}-'
    uuid_regex+='[89abAB][[:xdigit:]]{3}-'
    uuid_regex+='[[:xdigit:]]{12}$'

    [[ "$node_id" =~ $uuid_regex ]]
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

##
# Creates the persistent Protectorate node registry when it does not exist.
#
# Returns:
#   0 when the registry exists or is created successfully.
#   Non-zero on failure.
#
_registry_ensure_registry() {
    local temp_file

    command -v jq >/dev/null 2>&1 || return 1

    [[ -s "$PROTECTORATE_REGISTRY_FILE" ]] && {
        jq -e \
            --argjson version "$PROTECTORATE_REGISTRY_VERSION" \
            '.version == $version and (.nodes | type == "object")' \
            "$PROTECTORATE_REGISTRY_FILE" >/dev/null
        return
    }

    install -d -m 0755 "$PROTECTORATE_STATE_DIR" || return 1

    temp_file="$(mktemp "${PROTECTORATE_STATE_DIR}/.registry.json.XXXXXX")" || return 1

    if ! jq -n \
        --argjson version "$PROTECTORATE_REGISTRY_VERSION" \
        '{version: $version, nodes: {}}' > "$temp_file"; then
        rm -f -- "$temp_file"
        return 1
    fi

    if ! chmod 0644 "$temp_file"; then
        rm -f -- "$temp_file"
        return 1
    fi

    if ! mv -f -- "$temp_file" "$PROTECTORATE_REGISTRY_FILE"; then
        rm -f -- "$temp_file"
        return 1
    fi

}

#==============================================================================
# Public Functions
#==============================================================================

##
# Initializes persistent Protectorate registry state.
#
# Returns:
#   0 when local node identity and registry state are available.
#   Non-zero on failure.
#
registry_init() {
    _registry_ensure_node_id || return 1
    _registry_ensure_registry || return 1
}

##
# Registers or updates a Protectorate node.
#
# Arguments:
#   $1 - Persistent node identifier.
#   $2 - Node name.
#   $3 - Node address.
#   $4 - Discovery source.
#
# Returns:
#   0 when the node is registered successfully.
#   Non-zero on failure.
#
registry_register_node() {
    local node_id="$1"
    local name="$2"
    local address="$3"
    local source="$4"
    local temp_file

    [[ $# -eq 4 ]] || return 1
    _registry_valid_node_id "$node_id" || return 1
    [[ -n "$name" ]] || return 1
    [[ -n "$address" ]] || return 1
    [[ -n "$source" ]] || return 1

    _registry_ensure_registry || return 1

    temp_file="$(mktemp \
        "${PROTECTORATE_STATE_DIR}/.registry.json.XXXXXX")" || return 1

    if ! jq \
        --arg node_id "$node_id" \
        --arg name "$name" \
        --arg address "$address" \
        --arg source "$source" \
        '.nodes[$node_id] = {
            name: $name,
            address: $address,
            source: $source
        }' \
        "$PROTECTORATE_REGISTRY_FILE" > "$temp_file"; then
        rm -f -- "$temp_file"
        return 1
    fi

    if ! chmod 0644 "$temp_file"; then
        rm -f -- "$temp_file"
        return 1
    fi

    if ! mv -f -- \
        "$temp_file" "$PROTECTORATE_REGISTRY_FILE"; then
        rm -f -- "$temp_file"
        return 1
    fi
}

##
# Lists registered Protectorate nodes.
#
# Output:
#   Prints one tab-separated node per line:
#   identifier, name, address, source.
#
# Returns:
#   0 on success.
#   Non-zero when registry state is unavailable or invalid.
#
registry_nodes() {
    _registry_ensure_registry || return 1

    jq -r '
        .nodes
        | to_entries
        | sort_by(.key)[]
        | [.key, .value.name, .value.address, .value.source]
        | @tsv
    ' "$PROTECTORATE_REGISTRY_FILE"
}

##
# Lists Protectorate nodes assigned a specific role.
#
# Arguments:
#   $1 - Role name.
#
# Output:
#   Prints one tab-separated node per line:
#   identifier, name, address, source.
#
# Returns:
#   0 on success.
#   Non-zero when registry state is unavailable or invalid.
#
registry_nodes_by_role() {
    local role="$1"

    [[ $# -eq 1 ]] || return 1
    [[ -n "$role" ]] || return 1

    _registry_ensure_registry || return 1

    jq -r \
        --arg role "$role" '
        .nodes
        | to_entries
        | map(
            select(
                ((.value.roles // []) | index($role)) != null
            )
        )
        | sort_by(.key)[]
        | [.key, .value.name, .value.address, .value.source]
        | @tsv
    ' "$PROTECTORATE_REGISTRY_FILE"
}

##
# Assigns a role to a registered Protectorate node.
#
# Arguments:
#   $1 - Node identifier.
#   $2 - Role name.
#
# Returns:
#   0 on success.
#   Non-zero when arguments or registry state are invalid.
registry_assign_role() {
    local node_id="$1"
    local role="$2"
    local temp_file

    [[ $# -eq 2 ]] || return 1
    _registry_valid_node_id "$node_id" || return 1
    [[ -n "$role" ]] || return 1

    _registry_ensure_registry || return 1

    jq -e \
        --arg node_id "$node_id" \
        '.nodes[$node_id] != null' \
        "$PROTECTORATE_REGISTRY_FILE" >/dev/null || return 1

    temp_file=$(mktemp "${PROTECTORATE_REGISTRY_FILE}.XXXXXX") || return 1

    if ! jq \
        --arg node_id "$node_id" \
        --arg role "$role" '
        .nodes[$node_id].roles =
            (
                (.nodes[$node_id].roles // [])
                + [$role]
                | unique
            )
        ' "$PROTECTORATE_REGISTRY_FILE" > "$temp_file"; then
        rm -f "$temp_file"
        return 1
    fi

    chmod 0644 "$temp_file" || {
        rm -f "$temp_file"
        return 1
    }

    mv "$temp_file" "$PROTECTORATE_REGISTRY_FILE"
}

##
# Removes a role from a registered Protectorate node.
#
# Arguments:
#   $1 - Node identifier.
#   $2 - Role name.
#
# Returns:
#   0 on success.
#   Non-zero when arguments or registry state are invalid.
#
registry_remove_role() {
    local node_id="$1"
    local role="$2"
    local temp_file

    [[ $# -eq 2 ]] || return 1
    _registry_valid_node_id "$node_id" || return 1
    [[ -n "$role" ]] || return 1

    _registry_ensure_registry || return 1

    jq -e \
        --arg node_id "$node_id" \
        '.nodes[$node_id] != null' \
        "$PROTECTORATE_REGISTRY_FILE" >/dev/null || return 1

    temp_file=$(mktemp "${PROTECTORATE_REGISTRY_FILE}.XXXXXX") || return 1

    if ! jq \
        --arg node_id "$node_id" \
        --arg role "$role" '
        .nodes[$node_id].roles =
            (
                (.nodes[$node_id].roles // [])
                | map(select(. != $role))
            )
        ' "$PROTECTORATE_REGISTRY_FILE" > "$temp_file"; then
        rm -f "$temp_file"
        return 1
    fi

    chmod 0644 "$temp_file" || {
        rm -f "$temp_file"
        return 1
    }

    mv "$temp_file" "$PROTECTORATE_REGISTRY_FILE"
}

##
# Assigns a role exclusively to one Protectorate node.
#
# The role is removed from all other nodes before being assigned
# to the requested node.
#
# Arguments:
#   $1 - Node identifier.
#   $2 - Role name
#
# Returns:
#   0 on success.
#   Non-zero when arguments or registry state are invalid.
#
registry_assign_unique_role() {
    local node_id=$1
    local role=$2
    local temp_file

    [[ $# -eq 2 ]] || return 1
    _registry_valid_node_id "$node_id" || return 1
    [[ -n "$role" ]] || return 1

    _registry_ensure_registry || return 1

    jq -e \
        --arg node_id "$node_id" \
        '.nodes[$node_id] != null' \
        "$PROTECTORATE_REGISTRY_FILE" >/dev/null || return 1

    temp_file=$(mktemp "${PROTECTORATE_REGISTRY_FILE}.XXXXXX") || return 1

    if ! jq -e \
        --arg node_id "$node_id" \
        --arg role "$role" '
        .nodes |= with_entries(
            .value.roles =
                (
                    (.value.roles // [])
                    | map(select(. != $role))
                )
        )
        |
        .nodes[$node_id].roles =
            (
                ((.nodes[$node_id].roles // []) + [$role])
                | unique
            )        ' "$PROTECTORATE_REGISTRY_FILE" > "$temp_file"; then
        rm -f "$temp_file"
        return 1
    fi

    chmod 0644 "$temp_file" || {
        rm -f "$temp_file"
        return 1
    }

    mv "$temp_file" "$PROTECTORATE_REGISTRY_FILE"
}

##
# Determines whether a node is present in the Protectorate Registry.
#
# Arguments:
#   $1 - Node identifier.
#
# Returns:
#   0 if the node is registered.
#   1 otherwise.
#
registry_node_exists() {
    [[ $# -eq 1 ]] || return 1

    local node_id="$1"

    _registry_valid_node_id "$node_id" || return 1
    _registry_ensure_registry || return 1

    jq -e \
        --arg node_id "$node_id" \
        '.nodes | has($node_id)' \
        "$PROTECTORATE_REGISTRY_FILE" \
        >/dev/null
}

##
# Returns the persistent identifier for the local Protectorate node.
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
