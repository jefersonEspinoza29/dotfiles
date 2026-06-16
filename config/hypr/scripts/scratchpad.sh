#!/bin/bash
SCRATCH_FILE="/tmp/scratchpad-origin-ws"

ACTIVE=$(hyprctl activewindow -j)
WS=$(echo "$ACTIVE" | jq -r '.workspace.name // empty')
CLASS=$(echo "$ACTIVE" | jq -r '.class // empty')

[ "$CLASS" = "com.github.neithern.g4music" ] && exit 0

# ¿Hay una ventana oculta en scratch?
SCRATCH_WIN=$(hyprctl clients -j | jq -r '[.[] | select(.workspace.name == "special:scratch")] | first | .address // empty')

if [ -n "$SCRATCH_WIN" ]; then
    # Restaurar al workspace original guardado
    ORIGIN=$(cat "$SCRATCH_FILE" 2>/dev/null)
    TARGET=${ORIGIN:-$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .activeWorkspace.id')}
    hyprctl dispatch movetoworkspacesilent "${TARGET},address:${SCRATCH_WIN}"
    rm -f "$SCRATCH_FILE"
else
    # Ocultar ventana activa: guardar workspace y mandar a scratch
    [ -z "$WS" ] && exit 0
    echo "$WS" > "$SCRATCH_FILE"
    hyprctl dispatch movetoworkspacesilent special:scratch
fi
