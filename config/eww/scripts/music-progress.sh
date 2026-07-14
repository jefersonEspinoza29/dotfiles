#!/bin/bash
PLAYER=$(cat /tmp/eww-active-player 2>/dev/null)
ARGS=()
[ -n "$PLAYER" ] && ARGS=(--player="$PLAYER")
POS=$(playerctl "${ARGS[@]}" position 2>/dev/null) || { echo "0"; exit 0; }
[ -z "$POS" ] && echo "0" && exit 0
LEN_S=$(cat /tmp/eww-song-length 2>/dev/null)
[ -z "$LEN_S" ] || [ "$LEN_S" -eq 0 ] 2>/dev/null && echo "0" && exit 0
awk "BEGIN { if($LEN_S>0) printf \"%d\", ($POS/$LEN_S)*100; else print 0 }"
