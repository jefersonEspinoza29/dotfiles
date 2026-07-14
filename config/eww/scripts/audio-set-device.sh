#!/bin/bash

kind="$1"
device="$2"

[ -z "$kind" ] || [ -z "$device" ] && exit 1

case "$kind" in
    sink)
        pactl set-default-sink "$device" || exit 1
        pactl list short sink-inputs 2>/dev/null | while read -r input _; do
            [ -n "$input" ] && pactl move-sink-input "$input" "$device" 2>/dev/null
        done
        ;;
    source)
        pactl set-default-source "$device" || exit 1
        pactl list short source-outputs 2>/dev/null | while read -r output _; do
            [ -n "$output" ] && pactl move-source-output "$output" "$device" 2>/dev/null
        done
        ;;
    *)
        exit 1
        ;;
esac

eww update audio-outputs="$(~/.config/eww/scripts/audio-devices.sh sinks)" 2>/dev/null
eww update audio-inputs="$(~/.config/eww/scripts/audio-devices.sh sources)" 2>/dev/null
