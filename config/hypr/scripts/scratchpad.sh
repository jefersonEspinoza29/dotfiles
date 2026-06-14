#!/bin/bash
WS=$(hyprctl activewindow -j | jq -r '.workspace.name // empty')

[ -z "$WS" ] && exit 0

if [[ "$WS" == special* ]]; then
    REGULAR_WS=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .activeWorkspace.id')
    hyprctl dispatch movetoworkspace "$REGULAR_WS"
else
    hyprctl dispatch movetoworkspacesilent special:scratch
fi
