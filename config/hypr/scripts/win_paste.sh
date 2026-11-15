#!/bin/bash
CUT_FILE="/tmp/hypr_cut_window"

[ ! -f "$CUT_FILE" ] && exit 1

ADDR=$(cat "$CUT_FILE")
[ -z "$ADDR" ] && exit 1

TARGET_WS=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .activeWorkspace.id')

hyprctl dispatch "hl.dsp.window.move({ workspace = ${TARGET_WS}, follow = false, window = \"address:${ADDR}\" })"
hyprctl dispatch "hl.dsp.focus({ window = \"address:${ADDR}\" })"
rm -f "$CUT_FILE"
notify-send -u low -i edit-paste "Hyprland" "Ventana pegada"
