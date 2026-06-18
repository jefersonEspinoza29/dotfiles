#!/bin/bash
ssid=$(eww get wifi-connect-ssid)
pass=$(eww get wifi-connect-pass)
eww update wifi-connect-pass=""
eww close wifi-password-widget
eww close wifi-pass-overlay
nmcli dev wifi connect "$ssid" password "$pass" &
