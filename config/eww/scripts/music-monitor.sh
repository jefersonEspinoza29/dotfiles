#!/bin/bash
LAST_STATUS=""
LAST_TITLE=""
LAST_PLAYER=""

eww open music-widget 2>/dev/null
sleep 0.4

start_helpers() {
    pkill -f "cava.sh" 2>/dev/null
    pkill -f "art-spin.sh" 2>/dev/null
    bash ~/.config/eww/scripts/cava.sh &
    bash ~/.config/eww/scripts/art-spin.sh &
}

# Devuelve el mejor reproductor: prefiere Playing sobre Paused
get_active_player() {
    local playing="" paused=""
    while IFS= read -r p; do
        [ "$p" = "playerctld" ] && continue
        local s
        s=$(playerctl --player="$p" status 2>/dev/null)
        [ "$s" = "Playing" ] && [ -z "$playing" ] && playing="$p"
        [ "$s" = "Paused"  ] && [ -z "$paused"  ] && paused="$p"
    done < <(playerctl -l 2>/dev/null)
    local best="${playing:-$paused}"
    echo "$best" > /tmp/eww-active-player
    echo "$best"
}

while true; do
    PLAYER=$(get_active_player)

    if [ -n "$PLAYER" ]; then
        STATUS=$(playerctl --player="$PLAYER" status 2>/dev/null)

        if [ "$STATUS" = "Playing" ] || [ "$STATUS" = "Paused" ]; then
            if [ "$LAST_STATUS" != "active" ]; then
                start_helpers
                LAST_STATUS="active"
                LAST_TITLE=""
                LAST_PLAYER=""
            fi

            TITLE=$(playerctl --player="$PLAYER" metadata --format '{{title}}' 2>/dev/null)
            # Forzar actualización si cambió el reproductor O el título
            if [ "$TITLE" != "$LAST_TITLE" ] || [ "$PLAYER" != "$LAST_PLAYER" ]; then
                ARTIST=$(playerctl --player="$PLAYER" metadata --format '{{artist}}' 2>/dev/null)
                ART=$(playerctl --player="$PLAYER" metadata mpris:artUrl 2>/dev/null | sed 's|file://||')
                eww update \
                    music-title="${TITLE:-Sin música}" \
                    music-artist="${ARTIST:- }" \
                    music-status="$STATUS"
                if [ -n "$ART" ] && [ -f "$ART" ]; then
                    eww update music-art-spin="$ART"
                else
                    eww update music-art-spin=""
                fi
                LAST_TITLE="$TITLE"
                LAST_PLAYER="$PLAYER"
            else
                eww update music-status="$STATUS"
            fi
        else
            if [ "$LAST_STATUS" = "active" ]; then
                pkill -f "cava.sh" 2>/dev/null
                pkill -f "art-spin.sh" 2>/dev/null
                eww update music-title="Sin música" music-artist=" " music-status="Stopped" music-art-spin=""
                LAST_STATUS="inactive"
                LAST_TITLE=""
                LAST_PLAYER=""
                rm -f /tmp/eww-active-player
            elif [ "$LAST_STATUS" = "" ]; then
                LAST_STATUS="inactive"
            fi
        fi
    else
        rm -f /tmp/eww-active-player
        if [ "$LAST_STATUS" = "active" ]; then
            pkill -f "cava.sh" 2>/dev/null
            pkill -f "art-spin.sh" 2>/dev/null
            eww update music-title="Sin música" music-artist=" " music-status="Stopped" music-art-spin=""
            LAST_STATUS="inactive"
            LAST_TITLE=""
            LAST_PLAYER=""
        elif [ "$LAST_STATUS" = "" ]; then
            LAST_STATUS="inactive"
        fi
    fi

    sleep 2
done
