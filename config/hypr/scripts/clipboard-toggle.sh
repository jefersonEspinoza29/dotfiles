#!/bin/bash
# Activa/desactiva el historial del portapapeles (cliphist)
PATTERN='^wl-paste --type text/plain --watch cliphist'

if pkill -f "$PATTERN"; then
    notify-send -u low -i edit-paste "Portapapeles" "Historial desactivado"
else
    setsid -f wl-paste --type text/plain --watch cliphist -max-items 7 store
    notify-send -u low -i edit-paste "Portapapeles" "Historial activado"
fi
