#!/bin/bash

radio=$(nmcli radio wifi 2>/dev/null)

if [ "$radio" != "enabled" ]; then
    tooltip=$'Wi-Fi apagado\nClic para abrir el widget'

    jq -cn \
        --arg text "󰤭" \
        --arg tooltip "$tooltip" \
        '{text: $text, tooltip: $tooltip, class: "off"}'
    exit 0
fi

iface=$(nmcli -t -f DEVICE,TYPE dev 2>/dev/null | awk -F: '$2=="wifi" {print $1; exit}')

if [ -z "$iface" ]; then
    tooltip=$'Sin interfaz Wi-Fi\nClic para abrir el widget'

    jq -cn \
        --arg text "󰤭" \
        --arg tooltip "$tooltip" \
        '{text: $text, tooltip: $tooltip, class: "off"}'
    exit 0
fi

state=$(nmcli -t -f GENERAL.STATE dev show "$iface" 2>/dev/null | cut -d: -f2-)

if [[ "$state" != *"(connected)"* ]]; then
    tooltip=$'Wi-Fi encendido\nSin conexión\nClic para abrir el widget'

    jq -cn \
        --arg text "󰤭" \
        --arg tooltip "$tooltip" \
        '{text: $text, tooltip: $tooltip, class: "disconnected"}'
    exit 0
fi

ssid=$(nmcli -t -f GENERAL.CONNECTION dev show "$iface" 2>/dev/null | cut -d: -f2-)
signal=$(nmcli --escape no -t -f IN-USE,SIGNAL dev wifi 2>/dev/null | awk -F: '$1=="*" {print $2; exit}')

if [[ "$signal" =~ ^[0-9]+$ ]]; then
    if [ "$signal" -ge 75 ]; then
        icon="󰤨"
    elif [ "$signal" -ge 50 ]; then
        icon="󰤥"
    elif [ "$signal" -ge 25 ]; then
        icon="󰤢"
    else
        icon="󰤟"
    fi

    text="$icon ${signal}%"
    printf -v tooltip '%s\n%s%%\nClic para abrir el widget' "$ssid" "$signal"
else
    text="󰤨"
    printf -v tooltip '%s\nClic para abrir el widget' "$ssid"
fi

jq -cn \
    --arg text "$text" \
    --arg tooltip "$tooltip" \
    '{text: $text, tooltip: $tooltip, class: "connected"}'
