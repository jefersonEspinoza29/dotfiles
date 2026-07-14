#!/bin/bash
# Si no está corriendo, iniciarlo (windowrule lo manda a special:g4music)
if ! pgrep -x g4music > /dev/null; then
    g4music &
    sleep 1
else
    # Si está corriendo pero cayó en el scratchpad, recuperarlo
    WS=$(hyprctl clients -j | jq -r '.[] | select(.class == "com.github.neithern.g4music") | .workspace.name')
    if [ "$WS" = "special:scratch" ]; then
        hyprctl dispatch movetoworkspacesilent "special:g4music,class:com.github.neithern.g4music"
    fi
fi
hyprctl dispatch togglespecialworkspace g4music
