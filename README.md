# Dotfiles — Arch Linux + Hyprland
**Acer Predator Helios 300 (PH315-55)**

Setup minimalista con tema dinámico generado automáticamente desde el wallpaper usando **matugen** (Material You). Cada vez que cambias de fondo de pantalla, todo el sistema de colores se actualiza: bordes, barra, terminal, widgets, iconos y GTK.

---

## Programas

| Categoría | Programa |
|---|---|
| Compositor | Hyprland |
| Terminal | Kitty |
| Barra | Waybar |
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
| Login manager | SDDM (tema astronaut) |
| Control de energía CPU | auto-cpufreq |

---

## Instalación

### Requisitos previos

- Arch Linux instalado con usuario configurado y `sudo`
- Conexión a internet
- `git` instalado (`sudo pacman -S git`)

### Pasos

```bash
git clone https://github.com/jefersonEspinoza29/dotfiles.git
cd dotfiles
chmod +x install.sh
./install.sh
```

El script pregunta por cada componente opcional: drivers Intel, drivers NVIDIA, Plymouth, tema SDDM, LibreOffice, Wine, RGB del teclado.

### Después de instalar

1. **Reinicia el sistema**
2. En SDDM selecciona Hyprland e inicia sesión
3. El wallpaper y los colores se cargan automáticamente

---

## Configuración manual (post-instalación)

Estas configuraciones **no se automatizan** porque tocan el sistema de arranque y un error puede dejar el sistema sin arrancar.

### NVIDIA

Edita `/etc/mkinitcpio.conf` — agrega los módulos:
```
MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)
```

Edita `/etc/kernel/cmdline` — agrega al final de la línea:
```
nvidia_drm.modeset=1
```

Regenera los initramfs:
```bash
sudo mkinitcpio -P
```

Para ejecutar una app en la GPU NVIDIA:
```bash
prime-run <aplicación>
```

### Plymouth (splash de arranque)

Edita `/etc/mkinitcpio.conf` — agrega `plymouth` justo después de `udev` en HOOKS:
```
HOOKS=(base udev plymouth autodetect ...)
```

Edita tu entry en `/boot/loader/entries/*.conf` — agrega al final de la línea `options`:
```
quiet splash
```

Regenera los initramfs:
```bash
sudo mkinitcpio -P
```

Ver y aplicar temas:
```bash
sudo plymouth-set-default-theme -l         # listar temas
sudo plymouth-set-default-theme -R TEMA    # aplicar tema
```

---

## Sistema de colores (Matugen)

Los colores se generan desde el wallpaper con Material You y se aplican automáticamente a:

- Hyprland (bordes, sombras)
- Waybar
- Kitty
- Wlogout (incluyendo los iconos PNG)
- GTK 3 y 4
- Eww

Para cambiar wallpaper:
```bash
~/.config/hypr/scripts/wallpaper.sh
```

Para regenerar colores manualmente sobre el wallpaper actual:
```bash
matugen image ~/Wallpapers/tu-wallpaper.jpg --mode dark
```

---

## Wlogout

Los iconos cambian de color según la paleta del wallpaper activo:

| Botón | Color Material You |
|---|---|
| Bloquear | `primary` |
| Cerrar sesión | `secondary` |
| Apagar | `error` |
| Reiniciar | `tertiary` |
| Suspender | `secondary` |
| Hibernar | `tertiary` |

El script `~/.config/wlogout/colorize.py` se ejecuta automáticamente como post-hook de matugen cada vez que cambia el wallpaper.

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
