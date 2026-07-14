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
| Control laptop Predator | Predator Sense |

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

El script pregunta por cada componente opcional: drivers Intel, drivers NVIDIA, Plymouth con el tema `supramk4-jheff`, LibreOffice, Wine, Predator Sense para RGB/tecla Predator/ventiladores y, al final, el tema SDDM astronaut.

### Después de instalar

1. **Reinicia el sistema**
2. En SDDM selecciona Hyprland e inicia sesión
3. El wallpaper y los colores se cargan automáticamente

---

## Configuración manual (post-instalación)

Algunas configuraciones quedan **manuales** porque tocan el sistema de arranque y un error puede dejar el sistema sin arrancar.

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

El instalador intenta aplicar el tema `supramk4-jheff` si ya existe dentro del repo en:

```bash
plymouth/supramk4-jheff
```

Si tienes el tema guardado en otro disco, cópialo manualmente antes de ejecutar el instalador:

```bash
cd ~/dotfiles
mkdir -p plymouth
cp -a /ruta/donde/tengas/supramk4-jheff plymouth/
```

Lo que todavía queda manual es activar Plymouth en el arranque.

Edita `/etc/mkinitcpio.conf` — agrega `plymouth` justo después de `udev` en HOOKS:
```
HOOKS=(base udev plymouth autodetect ...)
```

Si usas `systemd-boot` con UKI, puede que `/boot/loader/entries/` esté vacío. En ese caso edita `/etc/kernel/cmdline` y agrega al final:

```
quiet splash
```

Regenera el initramfs/UKI:
```bash
sudo mkinitcpio -P
```

Verifica la línea de arranque:
```bash
bootctl status
```

Ver y aplicar temas:
```bash
sudo plymouth-set-default-theme -l         # listar temas
sudo plymouth-set-default-theme -R supramk4-jheff
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

## Predator Sense — RGB / tecla Predator / ventiladores

El instalador puede instalar [Predator Sense for Linux](https://github.com/cleyton1986/predator-sense), que agrega la app gráfica, el módulo DKMS, reglas udev y el servicio para abrirla con la tecla Predator.

Después de instalarlo puedes abrirlo desde:

```bash
/opt/predator-sense/predator-sense
```

También aparece en el menú de aplicaciones como **Predator Sense**.
