#!/bin/bash

MUSIC_OPEN=$(eww active-windows 2>/dev/null | grep -c "music-widget")

pkill -f "music-monitor.sh" 2>/dev/null
pkill -f "cava.sh" 2>/dev/null
pkill -f "art-spin.sh" 2>/dev/null
eww kill 2>/dev/null
sleep 0.8
eww daemon &

# Esperar hasta que el daemon responda (max 3s)
for i in $(seq 1 12); do
    eww ping 2>/dev/null && break
    sleep 0.25
done

if [ "$MUSIC_OPEN" -gt 0 ]; then
    eww open music-widget
    systemd-run --user --no-block bash ~/.config/eww/scripts/music-monitor.sh
fi

eww open system-widget
(
    CPU=$(bash ~/.config/eww/scripts/cpu-usage.sh)
    eww update cpu-value="$CPU"
    RAM=$(bash ~/.config/eww/scripts/ram-usage.sh)
    INFO=$(bash ~/.config/eww/scripts/ram-info.sh)
    eww update ram-value="$RAM" ram-info="$INFO"
) &
