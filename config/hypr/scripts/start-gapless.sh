#!/bin/bash
# Si no está corriendo, iniciarlo (windowrule lo manda a special:g4music)
if ! pgrep -x g4music > /dev/null; then
    g4music &
    sleep 1
fi
hyprctl dispatch togglespecialworkspace g4music
