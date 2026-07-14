#!/bin/bash

if eww active-windows | grep -q "audio-widget"; then
    eww close audio-widget
    eww close audio-overlay 2>/dev/null
else
    eww open audio-overlay
    eww open audio-widget
    ~/.config/eww/scripts/autoclose-widget.sh audio-widget audio-overlay 15
fi
