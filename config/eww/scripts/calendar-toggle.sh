#!/bin/bash

rm -f "${XDG_RUNTIME_DIR:-/tmp}/eww-calendar-year-overlay"

if eww active-windows | grep -q "calendar-widget"; then
    eww close calendar-widget
    eww close calendar-month-overlay 2>/dev/null
else
    eww close calendar-year-widget 2>/dev/null
    eww close calendar-year-overlay 2>/dev/null
    eww close calendar-month-overlay 2>/dev/null
    eww update calendar-month="$(~/.config/eww/scripts/calendar-month.sh)" 2>/dev/null
    eww open calendar-month-overlay
    eww open calendar-widget
    ~/.config/eww/scripts/autoclose-widget.sh calendar-widget calendar-month-overlay 15
fi
