#!/bin/bash
PLAYER=$(cat /tmp/eww-active-player 2>/dev/null)
ARGS=()
[ -n "$PLAYER" ] && ARGS=(--player="$PLAYER")
POS=$(playerctl "${ARGS[@]}" position 2>/dev/null) || { echo "0"; exit 0; }
LEN=$(playerctl "${ARGS[@]}" metadata mpris:length 2>/dev/null) || { echo "0"; exit 0; }
[ -z "$POS" ] || [ -z "$LEN" ] && echo "0" && exit 0
awk "BEGIN { l=$LEN; p=$POS*1000000; if(l>0) printf \"%d\", (p/l)*100; else print 0 }"
