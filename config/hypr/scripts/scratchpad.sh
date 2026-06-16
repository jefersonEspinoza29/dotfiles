#!/bin/bash
ACTIVE=$(hyprctl activewindow -j)
WS=$(echo "$ACTIVE" | jq -r '.workspace.name // empty')
CLASS=$(echo "$ACTIVE" | jq -r '.class // empty')

# g4music tiene su propio special workspace
[ "$CLASS" = "com.github.neithern.g4music" ] && exit 0

if [[ "$WS" == "special:scratch" ]]; then
    # Ventana activa está en scratch → sacarla al workspace actual
    REGULAR_WS=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .activeWorkspace.id')
    hyprctl dispatch movetoworkspace "$REGULAR_WS"
else
    # ¿Hay ventanas en scratch? → mostrar/ocultar con toggle
    SCRATCH_WINS=$(hyprctl clients -j | jq '[.[] | select(.workspace.name == "special:scratch")] | length')
    if [ "$SCRATCH_WINS" -gt 0 ]; then
        hyprctl dispatch togglespecialworkspace scratch
    else
        # Scratch vacío → meter la ventana activa
        [ -z "$WS" ] && exit 0
        hyprctl dispatch movetoworkspacesilent special:scratch
    fi
fi
