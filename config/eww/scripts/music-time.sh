#!/bin/bash
PLAYER=$(cat /tmp/eww-active-player 2>/dev/null)
ARGS=()
[ -n "$PLAYER" ] && ARGS=(--player="$PLAYER")
POS=$(playerctl "${ARGS[@]}" position 2>/dev/null)
LEN=$(playerctl "${ARGS[@]}" metadata mpris:length 2>/dev/null)
[ -z "$POS" ] && echo "0:00 / 0:00" && exit 0
POS_S=$(echo "$POS" | awk '{printf "%d", $1}')
LEN_S=$(echo "$LEN" | awk '{printf "%d", $1/1000000}')
printf "%d:%02d / %d:%02d\n" $((POS_S/60)) $((POS_S%60)) $((LEN_S/60)) $((LEN_S%60))
