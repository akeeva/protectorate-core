#!/usr/bin/env bash
#
# -----------------------------------------------------------------------------
# Protectorate Core
# Module: bootstrap.sh
#
# Description:
#   Protectorate Core Bootstrapper
#
# Responsibilities:
#   - Defines root filepath & assets location
# -----------------------------------------------------------------------------

#==============================================================================
# Include Guard
#==============================================================================

[[ -n "${_PROTECTORATE_BOOTSTRAP_LOADED:-}" ]] && return
readonly _PROTECTORATE_BOOTSTRAP_LOADED=1

#==============================================================================
# Constants
#==============================================================================
readonly PROTECTORATE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly ASSETS_DIR="${PROTECTORATE_ROOT}/assets"
