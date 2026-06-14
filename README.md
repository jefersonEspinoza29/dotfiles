# Dotfiles — Arch Linux + Hyprland
**Acer Predator Helios 300 (PH315-55)**

Setup minimalista con tema dinámico generado desde el wallpaper usando **matugen** (Material You).

---

## Programas principales

| Categoría | Programa |
|---|---|
| Compositor | Hyprland |
| Terminal | Kitty |
| Bar | Waybar |
| Launcher | Wofi |
| Gestor de archivos | Thunar |
| Notificaciones | Swaync |
| Pantalla de bloqueo | Hyprlock + Hypridle |
| Menú de apagado | Wlogout |
| Wallpaper | awww |
| Colores dinámicos | Matugen |
| Widgets | Eww |
| Navegador | Brave |
| Música | Gapless |
| Login manager | SDDM |

---

## Instalación rápida

```bash
git clone https://github.com/jefersonEspinoza29/dotfiles.git
cd dotfiles
chmod +x install.sh
./install.sh
```

El script te pregunta por cada componente opcional (drivers, Wine, LibreOffice, RGB, etc.).

---

## Sistema de colores (Matugen)

Los colores se generan automáticamente desde el wallpaper usando **Material You**. Cada vez que cambias de fondo de pantalla, todos los colores del sistema se actualizan:

- Waybar
- Hyprland (bordes)
- Kitty
- Wlogout (incluyendo los iconos)
- GTK 3 y 4
- Eww

Para cambiar wallpaper manualmente:
```bash
~/.config/hypr/scripts/wallpaper.sh
```

---

## Wlogout

Los iconos de wlogout cambian de color según el wallpaper activo:

| Botón | Color (Material You) |
|---|---|
| Bloquear | `primary` |
| Cerrar sesión | `secondary` |
| Apagar | `error` |
| Reiniciar | `tertiary` |
| Suspender | `secondary` |
| Hibernar | `tertiary` |

El script `~/.config/wlogout/colorize.py` se ejecuta automáticamente como post-hook de matugen.

---

## Control RGB — Predator Helios 300

```bash
# Wave
python /opt/turbo-fan/facer_rgb.py -m 3 -s 5 -b 100

# Breath (color personalizado)
python /opt/turbo-fan/facer_rgb.py -m 1 -s 4 -b 100 -cR 255 -cG 0 -cB 255

# Neon
python /opt/turbo-fan/facer_rgb.py -m 2 -s 3 -b 100

# Shifting
python /opt/turbo-fan/facer_rgb.py -m 4 -s 5 -b 100 -cR 0 -cB 255 -cG 0

# Estático por zona (1=izq, 2, 3, 4=der)
python /opt/turbo-fan/facer_rgb.py -m 0 -z 1 -cR 255 -cG 0 -cB 0

# Apagar
python /opt/turbo-fan/facer_rgb.py -m 0 -b 0

# Guardar/cargar perfil
python /opt/turbo-fan/facer_rgb.py -m 3 -s 2 -b 100 -save perfil
python /opt/turbo-fan/facer_rgb.py -load perfil
```

---

## NVIDIA (configuración post-instalación)

Edita `/etc/mkinitcpio.conf`:
```
MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)
```

Edita `/etc/kernel/cmdline` — agrega al final:
```
nvidia_drm.modeset=1
```

Regenera:
```bash
sudo mkinitcpio -P
```

---

## Plymouth

Agrega `quiet splash` al final de `options` en `/boot/loader/entries/*.conf`:
```
options root=UUID=xxxx rw quiet splash
```
