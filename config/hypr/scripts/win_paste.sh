#!/bin/bash
CUT_FILE="/tmp/hypr_cut_window"

[ ! -f "$CUT_FILE" ] && exit 1

ADDR=$(cat "$CUT_FILE")
[ -z "$ADDR" ] && exit 1

TARGET_WS=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .activeWorkspace.id')

hyprctl dispatch movetoworkspacesilent "${TARGET_WS},address:${ADDR}"
hyprctl dispatch focuswindow "address:${ADDR}"
rm -f "$CUT_FILE"
notify-send -u low -i edit-paste "Hyprland" "Ventana pegada"
