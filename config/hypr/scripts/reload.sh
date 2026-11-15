#!/bin/bash
set -euo pipefail

ACTIVE_JSON=$(hyprctl activewindow -j 2>/dev/null || echo '{}')
ACTIVE_ADDR=$(jq -r '.address // empty' <<<"$ACTIVE_JSON")

# Solo juegos de verdad (steam_app / contentType game), y solo si están en fullscreen
GAME_ADDR=$(hyprctl clients -j 2>/dev/null | jq -r '
  [.[]
    | select((.fullscreen // 0) > 0)
    | select(
        (.contentType == "game")
        or (.class | test("^steam_app_"; "i"))
      )
  ]
  | first
  | .address // empty
')

MUSIC_OPEN=$(eww active-windows 2>/dev/null | grep -c "music-widget" || true)

hyprctl reload

# Siempre reiniciar barras (todas las pantallas)
pkill waybar || true
sleep 0.3
waybar &

pkill swaync || true
sleep 0.3
swaync &

pkill -f "music-monitor.sh" 2>/dev/null || true
pkill -f "cava.sh" 2>/dev/null || true
pkill -f "art-spin.sh" 2>/dev/null || true
eww kill || true
sleep 0.3
eww daemon

if [[ "${MUSIC_OPEN}" -gt 0 ]]; then
  sleep 0.2
  eww open music-widget
  systemd-run --user --no-block bash ~/.config/eww/scripts/music-monitor.sh
fi

eww open system-widget
(
  CPU=$(bash ~/.config/eww/scripts/cpu-usage.sh)
  eww update cpu-value="$CPU"
  RAM=$(bash ~/.config/eww/scripts/ram-usage.sh)
  INFO=$(bash ~/.config/eww/scripts/ram-info.sh)
  eww update ram-value="$RAM" ram-info="$INFO"
) &

# Si había un juego en fullscreen: devolverle el foco (la barra queda debajo del fullscreen)
# No forzamos fullscreen a otras apps.
if [[ -n "${GAME_ADDR}" ]]; then
  sleep 0.2
  hyprctl dispatch "hl.dsp.focus({ window = \"address:$GAME_ADDR\" })" >/dev/null 2>&1 || true
  # Solo reafirma fullscreen si el juego lo perdió tras el reload
  fs=$(hyprctl clients -j | jq -r --arg a "$GAME_ADDR" '.[] | select(.address==$a) | .fullscreen // 0')
  if [[ "${fs}" == "0" ]]; then
    hyprctl dispatch "hl.dsp.window.fullscreen_state({ internal = 2, client = 2 })" >/dev/null 2>&1 || true
  fi
  notify-send -u low -i dialog-information "Hyprland" "Config recargada (juego en fullscreen: foco restaurado)"
elif [[ -n "${ACTIVE_ADDR}" ]]; then
  sleep 0.15
  hyprctl dispatch "hl.dsp.focus({ window = \"address:$ACTIVE_ADDR\" })" >/dev/null 2>&1 || true
  notify-send -u low -i dialog-information "Hyprland" "Config recargada"
else
  notify-send -u low -i dialog-information "Hyprland" "Config recargada"
fi
