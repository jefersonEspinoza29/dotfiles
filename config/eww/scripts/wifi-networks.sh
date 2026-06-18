#!/bin/bash
# Genera yuck markup para la lista de redes WiFi visibles

if ! nmcli radio wifi 2>/dev/null | grep -q "enabled"; then
    echo '(label :class "wifi-no-networks" :text "Wi-Fi desactivado")'
    exit 0
fi

# Detectar interfaz wifi activa
iface=$(nmcli -t -f DEVICE,TYPE dev 2>/dev/null | awk -F: '$2=="wifi" {print $1}' | head -1)

# Rescan no bloqueante
nmcli dev wifi rescan ifname "$iface" 2>/dev/null &

# Leer hasta 10 redes: IN-USE:SSID:SIGNAL:SECURITY
# --escape no evita que los : del SSID se escapen con \
mapfile -t lines < <(nmcli --escape no -t -f IN-USE,SSID,SIGNAL,SECURITY dev wifi 2>/dev/null | head -10)

if [ ${#lines[@]} -eq 0 ]; then
    echo '(label :class "wifi-no-networks" :text "Sin redes disponibles")'
    exit 0
fi

rows=""
for line in "${lines[@]}"; do
    [ -z "$line" ] && continue

    # Parsear: IN-USE:SSID:SIGNAL:SECURITY
    # Signal y security son los últimos 2 campos (sin dos puntos internos)
    security=$(echo "$line" | awk -F: '{print $NF}')
    signal=$(echo "$line" | awk -F: '{print $(NF-1)}')
    inuse=$(echo "$line" | awk -F: '{print $1}')
    ssid=$(echo "$line" | awk -F: '{
        s=""
        for(i=2; i<=NF-2; i++) {
            if(i>2) s=s":"
            s=s$i
        }
        print s
    }')

    # Saltar si signal no es número o SSID vacío
    [[ "$signal" =~ ^[0-9]+$ ]] || continue
    [ -z "$ssid" ] && continue

    # Sanitizar SSID para yuck (quitar chars que rompen el parser)
    ssid_clean=$(echo "$ssid" | tr '"' "'" | sed "s/[{}()\\\\]//g")

    # Icono de señal
    if   [ "$signal" -ge 75 ]; then sig_icon="󰤨"
    elif [ "$signal" -ge 50 ]; then sig_icon="󰤥"
    elif [ "$signal" -ge 25 ]; then sig_icon="󰤢"
    else                             sig_icon="󰤟"
    fi

    # Icono de candado
    if [ -n "$security" ] && [ "$security" != "--" ]; then
        lock_icon="󰌾"
    else
        lock_icon=""
    fi

    if [ "$inuse" = "*" ]; then
        action="(button :class \"wifi-btn wifi-btn-disconnect\" :tooltip \"Desconectar\" :onclick \"nmcli dev disconnect ${iface}\" \"󰤭\")"
        row_class="wifi-network-row wifi-network-connected"
    elif [ -n "$security" ] && [ "$security" != "--" ]; then
        action="(button :class \"wifi-btn wifi-btn-connect\" :tooltip \"Conectar\" :onclick \"eww update wifi-connect-ssid=\\\"${ssid_clean}\\\" && eww close wifi-widget && eww close wifi-overlay && eww open wifi-pass-overlay && eww open wifi-password-widget\" \"󰤨\")"
        row_class="wifi-network-row"
    else
        action="(button :class \"wifi-btn wifi-btn-connect\" :tooltip \"Conectar\" :onclick \"nmcli dev wifi connect '${ssid_clean}'\" \"󰤨\")"
        row_class="wifi-network-row"
    fi

    rows+=" (box :class \"${row_class}\" :orientation \"h\" :space-evenly false :spacing 8
      (label :class \"wifi-signal-icon\" :text \"${sig_icon}\")
      (label :class \"wifi-network-name\" :text \"${ssid_clean}\" :hexpand true :halign \"start\" :limit-width 16)
      (label :class \"wifi-lock-icon\" :text \"${lock_icon}\")
      ${action})"
done

if [ -z "$rows" ]; then
    echo '(label :class "wifi-no-networks" :text "Sin redes")'
else
    printf '(box :orientation "v" :space-evenly false :spacing 4 %s)\n' "$rows"
fi
