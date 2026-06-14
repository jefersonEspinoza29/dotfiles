#!/usr/bin/env bash
# ============================================================
#  Dotfiles installer — Arch Linux + Hyprland (Predator Helios 300)
#  github.com/jefersonEspinoza29/dotfiles
# ============================================================
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── Colores ──────────────────────────────────────────────────
R='\033[0;31m'; G='\033[0;32m'; Y='\033[1;33m'; B='\033[0;34m'; N='\033[0m'
info()    { echo -e "${B}==> ${N}$*"; }
ok()      { echo -e "${G} ✔  ${N}$*"; }
warn()    { echo -e "${Y} ⚠  ${N}$*"; }
err()     { echo -e "${R} ✘  ${N}$*"; exit 1; }
ask()     { local r; read -rp "$(echo -e "${Y}[?]${N} $1 [s/N]: ")" r; [[ "$r" =~ ^[sS]$ ]]; }

command -v pacman >/dev/null 2>&1 || err "Este script requiere Arch Linux"

echo -e "${G}"
echo "  ██████╗  ██████╗ ████████╗███████╗██╗██╗     ███████╗███████╗"
echo "  ██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝██║██║     ██╔════╝██╔════╝"
echo "  ██║  ██║██║   ██║   ██║   █████╗  ██║██║     █████╗  ███████╗"
echo "  ██║  ██║██║   ██║   ██║   ██╔══╝  ██║██║     ██╔══╝  ╚════██║"
echo "  ██████╔╝╚██████╔╝   ██║   ██║     ██║███████╗███████╗███████║"
echo "  ╚═════╝  ╚═════╝    ╚═╝   ╚═╝     ╚═╝╚══════╝╚══════╝╚══════╝"
echo -e "${N}"
echo "  Arch Linux + Hyprland — Acer Predator Helios 300"
echo

# ── 1. yay ───────────────────────────────────────────────────
if ! command -v yay >/dev/null 2>&1; then
    info "Instalando yay..."
    sudo pacman -S --needed --noconfirm git base-devel
    tmp=$(mktemp -d)
    git clone https://aur.archlinux.org/yay.git "$tmp/yay"
    (cd "$tmp/yay" && makepkg -si --noconfirm)
    rm -rf "$tmp"
    ok "yay instalado"
else
    ok "yay ya está instalado"
fi

# ── 2. Actualizar sistema ─────────────────────────────────────
info "Actualizando sistema..."
sudo pacman -Syu --noconfirm
ok "Sistema actualizado"

# ── 3. Paquetes base ─────────────────────────────────────────
PKGS=(
    # Entorno Hyprland
    hyprland hypridle hyprlock
    sddm kitty thunar
    waybar
    swaync
    hyprshot

    # Audio
    pipewire pipewire-pulse wireplumber
    pavucontrol pamixer playerctl

    # Red / Bluetooth / Sistema
    blueman network-manager-applet nm-connection-editor
    polkit-gnome jq

    # Wayland utils
    grim slurp wl-clipboard
    xdg-desktop-portal-hyprland xdg-desktop-portal-gtk

    # Fuentes
    ttf-jetbrains-mono-nerd noto-fonts noto-fonts-emoji

    # Plymouth (splash de arranque)
    plymouth

    # Brillo (dependencia de compilación)
    go-md2man

    # Cursor
    hyprcursor

    # GTK theme
    adw-gtk-theme

    # Gaming / Herramientas
    mangohud lib32-mangohud
    wofi

    # Python (para wlogout colorize)
    python-pillow
)

info "Instalando paquetes pacman..."
sudo pacman -S --needed --noconfirm "${PKGS[@]}"
ok "Paquetes base instalados"

# ── 4. Drivers Intel ─────────────────────────────────────────
if ask "¿Instalar drivers Intel (GPU integrada)?"; then
    sudo pacman -S --needed --noconfirm \
        mesa lib32-mesa \
        vulkan-intel lib32-vulkan-intel \
        intel-media-driver libva-utils
    ok "Drivers Intel instalados"
fi

# ── 5. Drivers NVIDIA ────────────────────────────────────────
NVIDIA=false
if ask "¿Instalar drivers NVIDIA?"; then
    NVIDIA=true
    # nvidia-open-dkms = driver open-source oficial NVIDIA (Turing/RTX en adelante)
    sudo pacman -S --needed --noconfirm \
        nvidia-open-dkms nvidia-utils lib32-nvidia-utils nvidia-settings nvidia-prime
    ok "Drivers NVIDIA instalados"
    echo
    warn "NVIDIA requiere configuración MANUAL para no romper el sistema:"
    echo "  1. Edita /etc/mkinitcpio.conf y busca la línea MODULES=(...)"
    echo "     Agrégale dentro del paréntesis:"
    echo "       nvidia nvidia_modeset nvidia_uvm nvidia_drm"
    echo "     Ejemplo:"
    echo "       MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)"
    echo
    echo "  2. Edita /etc/kernel/cmdline y agrega al FINAL de la línea:"
    echo "       nvidia_drm.modeset=1"
    echo
    echo "  3. Ejecuta: sudo mkinitcpio -P"
    echo
    echo "  Con envycontrol (instalado en paso 7) puedes elegir GPU:"
    echo "    sudo envycontrol -s integrated  → solo Intel (ahorro batería)"
    echo "    sudo envycontrol -s hybrid      → Intel + NVIDIA bajo demanda"
    echo "    sudo envycontrol -s nvidia      → solo NVIDIA (máximo rendimiento)"
    echo "    prime-run <app>                 → corre una app específica en NVIDIA"
    echo
fi

# ── 6. Brillo (desde fuente) ─────────────────────────────────
if ! command -v brillo >/dev/null 2>&1; then
    info "Compilando brillo..."
    tmp=$(mktemp -d)
    git clone https://gitlab.com/cameronnemo/brillo.git "$tmp/brillo"
    (cd "$tmp/brillo" && make && sudo make install.setgid)
    rm -rf "$tmp"
    sudo usermod -aG video "$USER"
    ok "brillo instalado (necesitas re-loguear para el grupo video)"
else
    ok "brillo ya está instalado"
fi

# ── 7. Paquetes AUR ──────────────────────────────────────────
AUR=(
    brave-bin
    wlogout
    matugen-bin        # compilado, más rápido de instalar que matugen
    awww               # wallpaper setter (fork de swww)
    eww
    nwg-look
    bibata-cursor-theme
    gapless
    ntfs-3g
    envycontrol        # selector de GPU: integrated / hybrid / nvidia
)

info "Instalando paquetes AUR..."
yay -S --needed --noconfirm "${AUR[@]}"
ok "AUR instalados"

# ── 8. Plymouth ──────────────────────────────────────────────
if ask "¿Instalar Plymouth (splash de arranque)?"; then
    ok "Plymouth ya fue instalado con los paquetes base"
    echo
    warn "Plymouth requiere configuración MANUAL:"
    echo "  1. Edita /etc/mkinitcpio.conf y en la línea HOOKS=(...)"
    echo "     agrega 'plymouth' justo después de 'udev':"
    echo "       HOOKS=(base udev plymouth autodetect ...)"
    echo
    echo "  2. Ejecuta: sudo mkinitcpio -P"
    echo
    echo "  3. Edita tu entry en /boot/loader/entries/*.conf"
    echo "     y agrega al FINAL de la línea 'options':"
    echo "       quiet splash"
    echo "     Ejemplo:"
    echo "       options root=UUID=xxxx rw quiet splash"
    echo
    echo "  4. Para ver temas disponibles: sudo plymouth-set-default-theme -l"
    echo "     Para aplicar uno:           sudo plymouth-set-default-theme -R TEMA"
    echo
fi

# ── 9. Tema SDDM astronaut ───────────────────────────────────
if ask "¿Instalar tema SDDM astronaut?"; then
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/keyitdev/sddm-astronaut-theme/master/setup.sh)"
    ok "Tema SDDM instalado"
fi

# ── 10. LibreOffice ──────────────────────────────────────────
if ask "¿Instalar LibreOffice en español?"; then
    sudo pacman -S --needed --noconfirm \
        libreoffice-fresh libreoffice-fresh-es hunspell-es_es
    ok "LibreOffice instalado"
fi

# ── 11. Wine / Gaming ────────────────────────────────────────
if ask "¿Instalar Wine + gamemode?"; then
    yay -S --needed --noconfirm \
        wine winetricks wine-gecko wine-mono \
        gamemode lib32-gamemode \
        lib32-gnutls lib32-libpulse lib32-alsa-lib
    ok "Wine + gamemode instalados"
fi

# ── 12. RGB Predator Helios 300 ──────────────────────────────
if ask "¿Instalar control RGB del teclado (Predator Helios 300)?"; then
    sudo pacman -S --needed --noconfirm linux-headers gcc make dkms
    tmp=$(mktemp -d)
    git clone https://github.com/JafarAkhondali/acer-predator-turbo-and-rgb-keyboard-linux-module "$tmp/rgb"
    (cd "$tmp/rgb" && chmod +x ./*.sh && sudo ./install_service.sh)
    rm -rf "$tmp"
    ok "RGB instalado en /opt/turbo-fan/"
    echo
    echo "  Modos RGB disponibles:"
    echo "    Wave:    python /opt/turbo-fan/facer_rgb.py -m 3 -s 5 -b 100"
    echo "    Breath:  python /opt/turbo-fan/facer_rgb.py -m 1 -s 4 -b 100 -cR 255 -cG 0 -cB 255"
    echo "    Neon:    python /opt/turbo-fan/facer_rgb.py -m 2 -s 3 -b 100"
    echo "    Apagar:  python /opt/turbo-fan/facer_rgb.py -m 0 -b 0"
fi

# ── 13. Copiar configuraciones ───────────────────────────────
info "Copiando configuraciones a ~/.config..."
CONFIG_DIRS=(hypr waybar wlogout matugen kitty eww swaync)
for dir in "${CONFIG_DIRS[@]}"; do
    if [ -d "$DOTFILES/config/$dir" ]; then
        mkdir -p "$HOME/.config/$dir"
        cp -r "$DOTFILES/config/$dir/." "$HOME/.config/$dir/"
        ok "~/.config/$dir"
    fi
done

# Hacer ejecutables los scripts
chmod +x ~/.config/hypr/scripts/*.sh 2>/dev/null || true
chmod +x ~/.config/eww/scripts/*.sh  2>/dev/null || true
chmod +x ~/.config/wlogout/colorize.py            || true

# ── 14. Wallpapers ───────────────────────────────────────────
if [ -d "$DOTFILES/wallpapers" ]; then
    mkdir -p "$HOME/Wallpapers"
    cp -r "$DOTFILES/wallpapers/." "$HOME/Wallpapers/"
    ok "Wallpapers copiados a ~/Wallpapers"
fi

# ── 15. Generar colores con matugen ──────────────────────────
FIRST_WALL=$(find "$HOME/Wallpapers" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) 2>/dev/null | head -1)
if [[ -n "${FIRST_WALL:-}" ]]; then
    info "Generando colores iniciales con matugen..."
    matugen image "$FIRST_WALL" --mode dark --quiet 2>/dev/null || warn "matugen falló, ejecuta manualmente más tarde"
    ok "Colores generados"
fi

# ── 16. Habilitar SDDM ───────────────────────────────────────
if ask "¿Habilitar SDDM al inicio del sistema?"; then
    sudo systemctl enable sddm
    sudo systemctl set-default graphical.target
    ok "SDDM habilitado"
fi

# ── Fin ──────────────────────────────────────────────────────
echo
echo -e "${G}╔═══════════════════════════════════════════╗${N}"
echo -e "${G}║      ✔  Instalación completada            ║${N}"
echo -e "${G}╚═══════════════════════════════════════════╝${N}"
echo
echo "  Próximos pasos:"
echo "  1. Reinicia el sistema"
echo "  2. Inicia sesión en Hyprland desde SDDM"
echo "  3. Cambia wallpaper: usa el keybind o corre ~/.config/hypr/scripts/wallpaper.sh"
echo
$NVIDIA && warn "NVIDIA: verifica /etc/mkinitcpio.conf y /etc/kernel/cmdline antes de reiniciar"
echo
