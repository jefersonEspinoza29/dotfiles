#!/bin/bash
LOCK_FILE="/tmp/hypr_locked_windows"
ADDR=$(hyprctl activewindow -j | jq -r '.address')

if [ "$ADDR" = "null" ] || [ -z "$ADDR" ]; then
    exit 1
fi

touch "$LOCK_FILE"

if grep -q "^$ADDR$" "$LOCK_FILE"; then
    sed -i "/^$ADDR$/d" "$LOCK_FILE"
    notify-send -u low -i dialog-information "Hyprland" "Ventana desbloqueada"
else
    echo "$ADDR" >> "$LOCK_FILE"
    notify-send -u normal -i dialog-warning "Hyprland" "Ventana bloqueada"
fi
