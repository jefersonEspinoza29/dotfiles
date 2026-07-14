#!/bin/bash
# Genera yuck markup para la lista de dispositivos BT emparejados

if ! bluetoothctl show 2>/dev/null | grep -q "Powered: yes"; then
    echo '(label :class "bt-no-devices" :text "Bluetooth apagado")'
    exit 0
fi

devices=$(bluetoothctl devices Paired 2>/dev/null)

if [ -z "$devices" ]; then
    echo '(label :class "bt-no-devices" :text "Sin dispositivos vinculados")'
    exit 0
fi

rows=""
while IFS= read -r line; do
    [ -z "$line" ] && continue
    mac=$(echo "$line" | awk '{print $2}')
    [ -z "$mac" ] && continue
    # Sanitizar nombre: quitar chars que rompan el parseo de yuck
    name=$(echo "$line" | cut -d' ' -f3- | tr '"' "'" | tr '\\' '/' | sed 's/[{}()]//g')

    connected=$(bluetoothctl info "$mac" 2>/dev/null | grep "Connected:" | awk '{print $2}')

    if [ "$connected" = "yes" ]; then
        icon="󰂱"
        action="(button :class \"bt-btn bt-btn-disconnect\" :tooltip \"Desconectar\" :onclick \"bluetoothctl disconnect ${mac}\" \"󰂲\")"
    else
        icon="󰂯"
        action="(button :class \"bt-btn bt-btn-connect\" :tooltip \"Conectar\" :onclick \"bluetoothctl connect ${mac}\" \"󰂱\")"
    fi

    rows+=" (box :class \"bt-device-row\" :orientation \"h\" :space-evenly false :spacing 8
      (label :class \"bt-device-icon\" :text \"${icon}\")
      (label :class \"bt-device-name\" :text \"${name}\" :hexpand true :halign \"start\" :limit-width 15)
      ${action}
      (button :class \"bt-btn bt-btn-remove\" :tooltip \"Desvincular\" :onclick \"bluetoothctl remove ${mac}\" \"󰗑\"))"
done <<< "$devices"

if [ -z "$rows" ]; then
    echo '(label :class "bt-no-devices" :text "Sin dispositivos")'
else
    printf '(box :orientation "v" :space-evenly false :spacing 4 %s)\n' "$rows"
fi
