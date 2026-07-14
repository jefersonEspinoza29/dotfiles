#!/bin/bash

mode="${1:-sinks}"

escape_yuck() {
    tr '"' "'" | tr '\\' '/' | sed 's/[{}()]//g'
}

device_icon() {
    kind="$1"
    name="$2"
    label="$3"
    icon_name="$4"

    text="${name} ${label} ${icon_name}"

    if [ "$kind" = "source" ]; then
        case "$text" in
            *bluez*|*Bluetooth*|*Headset*) echo "󰋎" ;;
            *Headphone*|*Headset*|*Mic2*|*Jack*) echo "󰋎" ;;
            *) echo "󰍬" ;;
        esac
        return
    fi

    case "$text" in
        *bluez*|*Bluetooth*) echo "󰋋" ;;
        *HDMI*|*DisplayPort*|*video-display*) echo "󰽟" ;;
        *Headphone*|*Headset*|*Jack*) echo "󰋋" ;;
        *Speaker*|*audio-speakers*) echo "󰓃" ;;
        *) echo "󰕾" ;;
    esac
}

friendly_label() {
    kind="$1"
    name="$2"
    description="$3"
    nick="$4"
    port_description="$5"

    label="$description"
    [ -z "$label" ] || [ "$label" = "(null)" ] && label="$nick"
    [ -z "$label" ] || [ "$label" = "(null)" ] && label="$port_description"
    [ -z "$label" ] || [ "$label" = "(null)" ] && label="$name"

    case "$name $label $port_description" in
        *bluez*|*Bluetooth*) label="Bluetooth" ;;
        *Speaker*) label="Speakers laptop" ;;
        *Digital\ Microphone*|*Mic1*) label="Mic laptop" ;;
        *HDMI*|*DisplayPort*) label="${port_description:-HDMI / DisplayPort}" ;;
        *Headphone*|*Headset*|*Mic2*|*Jack*) [ "$kind" = "source" ] && label="Mic audifonos" || label="Audifonos / Jack" ;;
    esac

    printf '%s' "$label" | escape_yuck
}

default_sink=$(pactl info 2>/dev/null | awk -F': ' '/Default Sink/ {print $2; exit}')
default_source=$(pactl info 2>/dev/null | awk -F': ' '/Default Source/ {print $2; exit}')

case "$mode" in
    sinks)
        list_cmd='pactl --format=json list sinks'
        default_device="$default_sink"
        kind="sink"
        empty_text="Sin salidas de audio"
        ;;
    sources)
        list_cmd='pactl --format=json list sources'
        default_device="$default_source"
        kind="source"
        empty_text="Sin entradas de audio"
        ;;
    *)
        exit 1
        ;;
esac

rows=""

while IFS=$'\t' read -r name description nick icon_name active_port port_description; do
    [ -z "$name" ] && continue

    label=$(friendly_label "$kind" "$name" "$description" "$nick" "$port_description")
    icon=$(device_icon "$kind" "$name" "$label" "$icon_name")

    if [ "$name" = "$default_device" ]; then
        row_class="audio-device-row audio-device-active"
        state_icon="󰄬"
    else
        row_class="audio-device-row"
        state_icon=""
    fi

    rows+=" (button :class \"${row_class}\" :onclick \"~/.config/eww/scripts/audio-set-device.sh ${kind} '${name}'\"
      (box :orientation \"h\" :space-evenly false :spacing 8
        (label :class \"audio-device-icon\" :text \"${icon}\")
        (label :class \"audio-device-name\" :text \"${label}\" :hexpand true :halign \"start\" :limit-width 24)
        (label :class \"audio-device-check\" :text \"${state_icon}\")))"
done < <(
    $list_cmd 2>/dev/null | jq -r --arg mode "$mode" '
        def active_availability:
            . as $d
            | ([ $d.ports[]? | select(.name == $d.active_port) | .availability ][0] // "available");

        def active_port_description:
            . as $d
            | ([ $d.ports[]? | select(.name == $d.active_port) | .description ][0] // "");

        .[]
        | select(
            if $mode == "sources"
            then .properties["media.class"] == "Audio/Source"
            else true
            end
        )
        | select(active_availability != "not available")
        | [
            .name,
            (.description // ""),
            (.properties["node.nick"] // ""),
            (.properties["device.icon_name"] // ""),
            (.active_port // ""),
            active_port_description
        ]
        | @tsv
    ' 2>/dev/null
)

if [ -z "$rows" ]; then
    printf '(label :class "audio-empty" :text "%s")\n' "$empty_text"
else
    printf '(box :orientation "v" :space-evenly false :spacing 4 %s)\n' "$rows"
fi
