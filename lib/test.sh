#!/usr/bin/env bash
source ./ui.sh
source ./config.sh
source ./system.sh

ui_motd_header
system_show

ui_section "Project"

ui_item "Name" "$PROJECT_NAME"
ui_item "Organization" "$ORGANIZATION"
ui_item "Division" "$DIVISION"
