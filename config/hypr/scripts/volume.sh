#!/bin/bash

case "$1" in
  up)   wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+ ;;
  down) wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- ;;
  mute) wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle ;;
esac

RAW=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)
VOL=$(echo "$RAW" | awk '{printf "%d", $2 * 100}')
MUTED=$(echo "$RAW" | grep -c "MUTED")

if [ "$MUTED" -gt 0 ]; then
  ICON="󰖁"
  VOL=0
elif [ "$VOL" -ge 70 ]; then
  ICON="󰕾"
elif [ "$VOL" -ge 30 ]; then
  ICON="󰖀"
else
  ICON="󰕿"
fi

eww update osd-value="$VOL" osd-icon="$ICON"

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
