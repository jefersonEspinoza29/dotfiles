#!/bin/bash

widget="$1"
overlay="$2"
delay="${3:-15}"

[ -z "$widget" ] && exit 1

runtime_dir="${XDG_RUNTIME_DIR:-/tmp}"
token_file="${runtime_dir}/eww-autoclose-${widget}"
token="$(date +%s%N)-$$"

printf '%s\n' "$token" > "$token_file"

(
    sleep "$delay"

    [ -f "$token_file" ] || exit 0
    [ "$(cat "$token_file" 2>/dev/null)" = "$token" ] || exit 0
    eww active-windows 2>/dev/null | grep -q "$widget" || exit 0

    eww close "$widget" 2>/dev/null
    [ -n "$overlay" ] && eww close "$overlay" 2>/dev/null
    rm -f "$token_file"
) &
