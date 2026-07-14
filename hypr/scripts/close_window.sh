#!/bin/bash
LOCK_FILE="/tmp/hypr_locked_windows"
ADDR=$(hyprctl activewindow -j | jq -r '.address')

if [ -f "$LOCK_FILE" ] && grep -q "^$ADDR$" "$LOCK_FILE"; then
    notify-send -u critical -i dialog-error "Hyprland" "Ventana bloqueada — no se puede cerrar"
else
    hyprctl dispatch killactive
fi
