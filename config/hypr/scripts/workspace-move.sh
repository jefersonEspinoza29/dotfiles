#!/bin/bash
# Mueve ventana activa al workspace relativo al monitor activo
WS=$1
MONITOR=$(hyprctl activeworkspace -j | jq -r '.monitor')

if [ "$MONITOR" = "HDMI-A-1" ]; then
    hyprctl dispatch movetoworkspace $((WS + 9))
else
    hyprctl dispatch movetoworkspace "$WS"
fi
