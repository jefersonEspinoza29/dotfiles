#!/bin/bash
LAST_ART=""
LAST_PLAYER=""

while true; do
    PLAYER=$(cat /tmp/eww-active-player 2>/dev/null)
    ARGS=()
    [ -n "$PLAYER" ] && ARGS=(--player="$PLAYER")
    ART=$(playerctl "${ARGS[@]}" metadata mpris:artUrl 2>/dev/null | sed 's|file://||')

    if [ "$ART" != "$LAST_ART" ] || [ "$PLAYER" != "$LAST_PLAYER" ]; then
        LAST_ART="$ART"
        LAST_PLAYER="$PLAYER"
        if [ -n "$ART" ] && [ -f "$ART" ]; then
            eww update music-art-spin="$ART"
        else
            eww update music-art-spin=""
        fi
    fi

    sleep 2
done
