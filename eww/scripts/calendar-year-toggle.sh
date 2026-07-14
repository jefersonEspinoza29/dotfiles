#!/bin/bash

runtime_dir="${XDG_RUNTIME_DIR:-/tmp}"
overlay_token_file="${runtime_dir}/eww-calendar-year-overlay"

if eww active-windows | grep -q "calendar-year-widget"; then
    rm -f "$overlay_token_file"
    eww close calendar-year-widget
    eww close calendar-year-overlay 2>/dev/null
else
    eww close calendar-widget 2>/dev/null
    eww close calendar-month-overlay 2>/dev/null
    eww close calendar-year-overlay 2>/dev/null
    eww update calendar-year="$(~/.config/eww/scripts/calendar-year.sh)" 2>/dev/null

    token="$(date +%s%N)-$$"
    printf '%s\n' "$token" > "$overlay_token_file"

    eww open calendar-year-widget
    (
        sleep 0.2
        [ -f "$overlay_token_file" ] || exit 0
        [ "$(cat "$overlay_token_file" 2>/dev/null)" = "$token" ] || exit 0
        eww active-windows 2>/dev/null | grep -q "calendar-year-widget" || exit 0
        eww open calendar-year-overlay 2>/dev/null
    ) &
    ~/.config/eww/scripts/autoclose-widget.sh calendar-year-widget calendar-year-overlay 15
fi
