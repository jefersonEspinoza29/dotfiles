#!/bin/bash
ACTIVE=$(hyprctl activewindow -j)
WS=$(echo "$ACTIVE" | jq -r '.workspace.name // empty')
ADDR=$(echo "$ACTIVE" | jq -r '.address // empty')

[ -z "$ADDR" ] && exit 0

if [ "$WS" = "special:scratch" ]; then
    # Sacar al workspace activo del monitor con foco
    TARGET=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .activeWorkspace.id')
    hyprctl dispatch "hl.dsp.window.move({ workspace = ${TARGET}, follow = false, window = \"address:${ADDR}\" })"
else
    hyprctl dispatch "hl.dsp.window.move({ workspace = \"special:scratch\", follow = false, window = \"address:${ADDR}\" })"
fi
