#!/bin/bash
PLAYER=$(cat /tmp/eww-active-player 2>/dev/null)
ARGS=()
[ -n "$PLAYER" ] && ARGS=(--player="$PLAYER")
POS=$(playerctl "${ARGS[@]}" position 2>/dev/null)
[ -z "$POS" ] && echo "0:00 / 0:00" && exit 0
POS_S=$(echo "$POS" | awk '{printf "%d", $1}')
LEN_S=$(cat /tmp/eww-song-length 2>/dev/null)
[ -z "$LEN_S" ] || [ "$LEN_S" -eq 0 ] 2>/dev/null && echo "0:00 / 0:00" && exit 0
printf "%d:%02d / %d:%02d\n" $((POS_S/60)) $((POS_S%60)) $((LEN_S/60)) $((LEN_S%60))
