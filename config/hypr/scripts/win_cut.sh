#!/bin/bash
LOCK_FILE="/tmp/hypr_locked_windows"
ADDR=$(hyprctl activewindow -j | jq -r '.address // empty')

[ -z "$ADDR" ] && exit 1

if [ -f "$LOCK_FILE" ] && grep -q "^$ADDR$" "$LOCK_FILE"; then
    notify-send -u critical -i dialog-error "Hyprland" "Ventana bloqueada — no se puede cortar"
    exit 1
fi

echo "$ADDR" > /tmp/hypr_cut_window
notify-send -u low -i edit-cut "Hyprland" "Ventana cortada"
