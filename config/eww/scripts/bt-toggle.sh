#!/bin/bash
if eww active-windows | grep -q "bluetooth-widget"; then
    eww close bluetooth-widget
    eww close bt-overlay 2>/dev/null
else
    eww open bt-overlay
    eww open bluetooth-widget
fi
