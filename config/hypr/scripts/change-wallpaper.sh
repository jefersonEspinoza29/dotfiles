#!/usr/bin/env bash

WALLDIR="$HOME/Wallpapers"
CACHE="$HOME/.cache/last_wallpaper"

mkdir -p ~/.cache

apply_theme() {
    local wall="$1"

    matugen image "$wall" \
        --mode dark \
        --prefer saturation \
        --source-color-index 0 \
        --quiet

    # Recargar waybar solo si no hay ventana en fullscreen
    fullscreen_count=$(hyprctl clients -j 2>/dev/null | jq '[.[] | select(.fullscreen > 0)] | length')
    if [ "${fullscreen_count:-0}" -eq 0 ]; then
        killall -SIGUSR2 waybar 2>/dev/null
    fi

    # Recargar colores de borde en Hyprland
    hyprctl reload >/dev/null 2>&1

    # Matar todo lo relacionado con eww antes de reiniciar
    pkill -f "playerctl.*--follow" 2>/dev/null
    pkill -f "music-monitor.sh" 2>/dev/null
    pkill -f "art-spin.sh" 2>/dev/null
    pkill -f "cava.sh" 2>/dev/null

    # Reiniciar eww para aplicar el nuevo SCSS
    eww kill 2>/dev/null
    sleep 0.8
    eww daemon &
    sleep 0.8
    # El monitor decide si abrir el widget o no (systemd-run para que sobreviva)
    systemd-run --user --no-block bash ~/.config/eww/scripts/music-monitor.sh
}

while true; do

    LAST=""
    [ -f "$CACHE" ] && LAST=$(cat "$CACHE")

    while :; do
        WALL=$(find "$WALLDIR" -type f \( \
            -iname "*.jpg" -o \
            -iname "*.jpeg" -o \
            -iname "*.png" \
        \) | shuf -n 1)

        [ "$WALL" != "$LAST" ] && break
    done

    TRANSITION=$(shuf -e fade wipe wave grow outer left right top bottom any -n 1)

    DURATION=$(shuf -i 2-6 -n 1)

    ANGLE=$(shuf -i 0-359 -n 1)

    POSITION=$(shuf -e \
        center \
        top \
        bottom \
        left \
        right \
        top-left \
        top-right \
        bottom-left \
        bottom-right \
        -n 1)

    awww img "$WALL" \
        --transition-type "$TRANSITION" \
        --transition-duration "$DURATION" \
        --transition-angle "$ANGLE" \
        --transition-pos "$POSITION"

    echo "$WALL" > "$CACHE"

    apply_theme "$WALL" &

    sleep 180

done
