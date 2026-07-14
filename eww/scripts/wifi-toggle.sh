#!/bin/bash
if eww active-windows | grep -q "wifi-widget"; then
    eww close wifi-widget
    eww close wifi-overlay 2>/dev/null
else
    eww open wifi-overlay
    eww open wifi-widget
    ~/.config/eww/scripts/autoclose-widget.sh wifi-widget wifi-overlay 15
fi
