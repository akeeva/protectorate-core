#!/usr/bin/env bash
#
# -----------------------------------------------------------------------------
# Protectorate Core
# Module: system.sh
#
# Description:
#   Creates the system summary to display upon login
#
# Responsibilities:
#   - Gather System Data
#   - Render Data
# -----------------------------------------------------------------------------

#==============================================================================
# Constants
#==============================================================================

#==============================================================================
# Private Functions
#==============================================================================
_system_hostname(){
    hostname
    }

_system_kernel(){
    uname -r
}

_system_os() {
    . /etc/os-release
    echo "${PRETTY_NAME}"
}

_system_uptime() {
    uptime -p | sed 's/^up //'
}

_system_cpu() {
    grep -m1 'model name' /proc/cpuinfo | cut -d: -f2- | xargs
}

_system_memory() {
    free -h | awk '/^Mem:/ {print $3 " / " $2}'
}

_system_ip() {
    ip route get 1.1.1.1 2>/dev/null | awk '/src/ {print $7; exit}'
}

#==============================================================================
# Public Functions
#==============================================================================

##
# Description...
#

system_summary() {
    ui_section "System"
    ui_label "Hostname:" "$(_system_hostname)"
    ui_label "OS:" "$(_system_os)"
    ui_label "Kernel:" "$(_system_kernel)"
    ui_label "Uptime:" "$(_system_uptime)"
    ui_label "CPU:" "$(_system_cpu)"
    ui_label "Memory:" "$(_system_memory)"
    ui_label "IP:" "$(_system_ip)"
}
