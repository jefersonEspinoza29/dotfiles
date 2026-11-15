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

En pantalla se ve el progreso paso a paso (`[N/18] ...`), con `✔` en verde, `⚠` en amarillo para avisos, y `✘` en rojo si algo falla. Es seguro volver a correrlo si se corta a mitad de camino.

Los 18 pasos, en orden:

 1. Repositorio multilib + actualizar sistema
 2. yay
 3. Paquetes base (incluye el locale `es_PE` que usa el reloj de waybar)
 4. Drivers Intel *(opcional)*
 5. Drivers NVIDIA *(opcional, deja instrucciones de configuración manual)*
 6. Brillo, compilado desde fuente
 7. Paquetes AUR
 8. Plymouth *(opcional, deja instrucciones de configuración manual)*
 9. LibreOffice *(opcional)*
10. Wine / Gaming *(opcional)*
11. Predator Sense / RGB *(opcional, clona y compila el repo, deja el hook de auto-actualización)*
12. Copiar configuraciones a `~/.config`
13. Shell config (`.bashrc`, con backup si ya tenías uno distinto)
14. Directorios de usuario
15. Wallpapers
16. Generar colores iniciales con matugen
17. Habilitar SDDM *(opcional)*
18. Tema SDDM astronaut *(opcional)*

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

## Configuración de Hyprland

Hyprland 0.57+ usa **`config/hypr/hyprland.lua`** como archivo de configuración real (Lua). `hyprland.conf` y `modules/*.conf` quedaron del esquema viejo, se copian por compatibilidad pero **ya no los lee nada** — para tocar binds, monitores, autostart, etc., edita `hyprland.lua`.

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

El instalador compila [Predator Sense for Linux](https://github.com/cleyton1986/predator-sense) desde el código fuente (no es un proyecto oficial de Acer) y lo deja con auto-actualización:

- **Código fuente:** `~/herramientas/predator-sense` (clon de git, se actualiza solo).
- **App instalada:** `/opt/predator-sense/predator-sense` (también aparece en el menú de aplicaciones y se abre con la tecla Predator).
- **Auto-actualización:** un hook de pacman (`/etc/pacman.d/hooks/predator-sense-update.hook` → `/usr/local/bin/predator-sense-update.sh`) revisa en cada `pacman`/`yay` si hay commits nuevos en el repo. Si los hay, recompila e instala en segundo plano (no bloquea la terminal ni compite por el lock de pacman).
- **Log:** `/var/log/predator-sense-update.log`.
- Si hacés cambios locales a mano en `~/herramientas/predator-sense` (commits sin pushear), el hook los detecta y **no** sobrescribe nada — solo actualiza cuando el checkout está limpio.
