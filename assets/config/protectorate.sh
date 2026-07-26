#!/usr/bin/env bash
#
# -----------------------------------------------------------------------------
# Protectorate Core
# Login Shell Integration
#
# Loads Protectorate Core and displays the welcome screen whenever a user
# begins an interactive login session.
# -----------------------------------------------------------------------------

# Do nothing for non-interactive login shells.
[[ $- == *i* ]] || return 0

# Load the Protectorate shell framework.
if [[ -r /etc/protectorate/lib/shell.sh ]]; then
    . /etc/protectorate/lib/shell.sh
fi

# Display the Protectorate login screen.
if [[ -x /etc/protectorate/bin/protectorate-login ]]; then
    /etc/protectorate/bin/protectorate-login
fi
