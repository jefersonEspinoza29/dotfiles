#!/bin/bash
if eww active-windows | grep -q "wifi-widget"; then
    eww close wifi-widget
    eww close wifi-overlay 2>/dev/null
else
    eww open wifi-overlay
    eww open wifi-widget
fi
