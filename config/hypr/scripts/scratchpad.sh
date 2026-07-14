#!/bin/bash
ACTIVE=$(hyprctl activewindow -j)
WS=$(echo "$ACTIVE" | jq -r '.workspace.name // empty')
ADDR=$(echo "$ACTIVE" | jq -r '.address // empty')

[ -z "$ADDR" ] && exit 0

if [ "$WS" = "special:scratch" ]; then
    # Sacar al workspace activo del monitor con foco
    TARGET=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .activeWorkspace.id')
    hyprctl dispatch movetoworkspacesilent "${TARGET},address:${ADDR}"
else
    hyprctl dispatch movetoworkspacesilent special:scratch,address:${ADDR}
fi
