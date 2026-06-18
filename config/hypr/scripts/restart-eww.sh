#!/bin/bash

MUSIC_OPEN=$(eww active-windows 2>/dev/null | grep -c "music-widget")
SYSTEM_OPEN=$(eww active-windows 2>/dev/null | grep -c "system-widget")

pkill -f "music-monitor.sh" 2>/dev/null
pkill -f "cava.sh" 2>/dev/null
pkill -f "art-spin.sh" 2>/dev/null
eww kill 2>/dev/null
sleep 0.8
eww daemon &
sleep 0.5

if [ "$MUSIC_OPEN" -gt 0 ]; then
    eww open music-widget
    systemd-run --user --no-block bash ~/.config/eww/scripts/music-monitor.sh
fi

if [ "$SYSTEM_OPEN" -gt 0 ]; then
    eww open system-widget
fi
