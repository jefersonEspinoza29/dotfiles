#!/bin/bash

# Guardar estado de eww antes de recargar
MUSIC_OPEN=$(eww active-windows 2>/dev/null | grep -c "music-widget")

# Recargar Hyprland
hyprctl reload

# Reiniciar Waybar
pkill waybar
sleep 0.3
waybar &

# Reiniciar swaync
pkill swaync
sleep 0.3
swaync &

# Reiniciar EWW
pkill -f "music-monitor.sh" 2>/dev/null
pkill -f "cava.sh" 2>/dev/null
pkill -f "art-spin.sh" 2>/dev/null
eww kill
sleep 0.3
eww daemon

# Reabrir widgets que estaban abiertos
if [ "$MUSIC_OPEN" -gt 0 ]; then
    sleep 0.2
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

notify-send -u low -i dialog-information "Hyprland" "Config recargada"
