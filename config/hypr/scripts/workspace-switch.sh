#!/bin/bash
# Cambia workspace relativo al monitor activo:
# eDP-2    → workspaces 1-9
# HDMI-A-1 → workspaces 10-18 (se mapean con Super+1-9)
WS=$1
MONITOR=$(hyprctl activeworkspace -j | jq -r '.monitor')

if [ "$MONITOR" = "HDMI-A-1" ]; then
    hyprctl dispatch workspace $((WS + 9))
else
    hyprctl dispatch workspace "$WS"
fi
