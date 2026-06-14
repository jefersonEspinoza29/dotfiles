#!/bin/bash

case "$1" in
  up)   brillo -q -A 10 ;;
  down) brillo -q -U 10 ;;
esac

BRIGHT=$(brillo -G | awk '{printf "%d", $1}')

if [ "$BRIGHT" -ge 70 ]; then
  ICON="󰃠"
elif [ "$BRIGHT" -ge 30 ]; then
  ICON="󰃟"
else
  ICON="󰃞"
fi

eww update osd-value="$BRIGHT" osd-icon="$ICON"

# Solo abrir si no está ya visible (evita parpadeo)
eww active-windows 2>/dev/null | grep -q "osd" || eww open osd

# Guardar timestamp y reiniciar timer
TS=$(date +%s%N)
echo "$TS" > /tmp/eww-osd-ts

if [ -f /tmp/eww-osd-timer.pid ]; then
  kill "$(cat /tmp/eww-osd-timer.pid)" 2>/dev/null
fi

(sleep 2; [ "$(cat /tmp/eww-osd-ts 2>/dev/null)" = "$TS" ] && eww close osd) &
echo $! > /tmp/eww-osd-timer.pid
