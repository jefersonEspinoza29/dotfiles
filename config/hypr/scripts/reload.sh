#!/bin/bash

# Guardar estado de eww music-widget antes de recargar
MUSIC_OPEN=$(eww active-windows 2>/dev/null | grep -c "music-widget")

# Recargar Hyprland
hyprctl reload

# Reiniciar Waybar
pkill waybar
sleep 0.3
waybar &

# Reiniciar EWW
eww kill
sleep 0.3
eww daemon

# Reabrir music-widget solo si estaba abierto
if [ "$MUSIC_OPEN" -gt 0 ]; then
    sleep 0.2
    eww open music-widget
fi

notify-send -u low -i dialog-information "Hyprland" "Config recargada"
