#!/usr/bin/env bash
#
# -----------------------------------------------------------------------------
# Protectorate Core
# Module: system.sh
#
# Description:
#   Collects system information for the Protectorate login summary.
#
# Responsibilities:
#   - Collect operating system and host information.
#   - Collect basic system resource information.
#   - Provide formatted values for the system summary.
# -----------------------------------------------------------------------------

#==============================================================================
# Constants
#==============================================================================

#==============================================================================
# Private Functions
#==============================================================================

##
# Returns the system hostname.
#
_system_hostname() {
    hostname
    }

##
# Returns the running kernel release.
#
_system_kernel() {
    uname -r
}

##
# Returns the operating system's human-readable name.
#
_system_os() {
    . /etc/os-release
    printf '%s\n' "$PRETTY_NAME"
}

##
# Returns the system uptime in a human-readable format.
#
_system_uptime() {
    uptime -p | sed 's/^up //'
}

##
# Returns the model name of the first detected CPU.
#
_system_cpu() {
    grep -m1 'model name' /proc/cpuinfo | cut -d: -f2- | xargs
}

##
# Returns current and total system memory in human-readable units.
#
_system_memory() {
    free -h | awk '/^Mem:/ {print $3 " / " $2}'
}

##
# Returns the source IP address used for the default network path.
#
_system_ip() {
    ip route get 1.1.1.1 2>/dev/null |
        awk '/src/ {print $7; exit}'
}

#==============================================================================
# Public Functions
#==============================================================================

##
# Displays the Protectorate system summary.
#
# Output:
#   Writes formatted system information to standard output.
#
# Returns:
#   The status of the final UI rendering operation.
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
