#!/usr/bin/env bash

#
# -----------------------------------------------------------------------------
# Protectorate Core
# Module: config.sh
#
# Description:
# Defines shared Protectorate Core configuration values.
#
# Responsibilities:
#   - Define project identity and version information.
#   - Define organization metadata.
#   - Define shared asset locations.
#   - Define the local node identity.
# -----------------------------------------------------------------------------

readonly ASSETS_DIR="${PROTECTORATE_ROOT}/assets"

readonly PROJECT_NAME="Protectorate Core"
readonly PROJECT_VERSION="0.1.0"
readonly PROJECT_CODENAME="Foundation"

readonly ORGANIZATION="The Protectorate"
readonly DIVISION="Infrastructure Division"

NODE_NAME="$(hostname)" || return 1

readonly NODE_NAME

export ASSETS_DIR
