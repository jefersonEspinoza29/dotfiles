#!/bin/bash

# Mapa de clases a iconos (igual que tu window-rewrite)
declare -A ICONS=(
    ["kitty"]="󰞷"
    ["brave-browser"]="󰖟"
    ["code-oss"]="󰨞"
    ["code"]="󰨞"
    ["discord"]="󰙯"
    ["net.lutris.Lutris"]="󰊗"
    ["steam"]="󰊗"
    ["thunar"]="󰉋"
    ["vlc"]="󰕼"
)
DEFAULT_ICON="󰘔"
EMPTY_ICON="󰄰"
OCCUPIED_ICON=""

get_icon() {
    local class="${1,,}"  # lowercase
    echo "${ICONS[$class]:-$DEFAULT_ICON}"
}

# Obtener workspace activo
active_ws=$(hyprctl activeworkspace -j | jq '.id')

# Obtener todos los workspaces con sus ventanas
output=""
while IFS= read -r ws_json; do
    ws_id=$(echo "$ws_json" | jq '.id')
    ws_windows=$(echo "$ws_json" | jq '.windows')

    if [ "$ws_windows" -eq 0 ]; then
        icon="$EMPTY_ICON"
        class="empty"
    else
        # Primera ventana de este workspace
        first_class=$(hyprctl clients -j | jq -r \
            --argjson wsid "$ws_id" \
            '[.[] | select(.workspace.id == $wsid)] | first | .class // ""')
        first_icon=$(get_icon "$first_class")

        # Contador si hay más de 1
        if [ "$ws_windows" -gt 1 ]; then
            extra=$((ws_windows - 1))
            icon="${first_icon} <span size='small'>+${extra}</span>"
        else
            icon="$first_icon"
        fi
        class="occupied"
    fi

    [ "$ws_id" -eq "$active_ws" ] && class="active"

    output+="$ws_id|$icon|$class\n"
done < <(hyprctl workspaces -j | jq -c '.[] | {id,windows}' | sort -t'"' -k4 -n)

echo -e "$output"
