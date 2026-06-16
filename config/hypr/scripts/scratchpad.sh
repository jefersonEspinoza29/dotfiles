#!/bin/bash
ACTIVE=$(hyprctl activewindow -j)
WS=$(echo "$ACTIVE" | jq -r '.workspace.name // empty')
CLASS=$(echo "$ACTIVE" | jq -r '.class // empty')

[ -z "$WS" ] && exit 0

# g4music tiene su propio special workspace, no mezclarlo con scratch
[ "$CLASS" = "com.github.neithern.g4music" ] && exit 0

if [[ "$WS" == special* ]]; then
    REGULAR_WS=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .activeWorkspace.id')
    hyprctl dispatch movetoworkspace "$REGULAR_WS"
else
    hyprctl dispatch movetoworkspacesilent special:scratch
fi
