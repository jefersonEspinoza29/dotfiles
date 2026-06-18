#!/bin/bash
ssid=$(eww get wifi-connect-ssid)
pass=$(eww get wifi-connect-pass)

eww update wifi-connect-error="Conectando..."

(
    result=$(nmcli dev wifi connect "$ssid" password "$pass" 2>&1)
    if [ $? -eq 0 ]; then
        eww update wifi-connect-error=""
        eww update wifi-connect-pass=""
        eww update wifi-pass-show=false
        eww close wifi-password-widget
        eww close wifi-pass-overlay
    else
        eww update wifi-connect-error="Contraseña incorrecta"
    fi
) &
