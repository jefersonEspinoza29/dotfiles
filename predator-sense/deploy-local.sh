#!/usr/bin/env bash
# Despliega en este sistema el hook corregido de Predator Sense (clon local
# en ~/herramientas/predator-sense + auto-update sin deadlock con pacman).
# Correr con: sudo bash deploy-local.sh
set -euo pipefail

if [ "$EUID" -ne 0 ]; then
    echo "Corré esto con sudo: sudo bash $0" >&2
    exit 1
fi

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="/home/jheff/herramientas/predator-sense"

printf 'OWNER=%q\nHOME_DIR=%q\nREPO=%q\n' "jheff" "/home/jheff" "$REPO" > /etc/predator-sense-updater.conf
chmod 600 /etc/predator-sense-updater.conf
echo "✔ /etc/predator-sense-updater.conf"

install -Dm755 "$HERE/predator-sense-update.sh" /usr/local/bin/predator-sense-update.sh
echo "✔ /usr/local/bin/predator-sense-update.sh"

install -Dm644 "$HERE/predator-sense-update.hook" /etc/pacman.d/hooks/predator-sense-update.hook
echo "✔ /etc/pacman.d/hooks/predator-sense-update.hook"

mkdir -p /var/lib/predator-sense-updater
git -C "$REPO" rev-parse HEAD > /var/lib/predator-sense-updater/installed-commit
echo "✔ /var/lib/predator-sense-updater/installed-commit = $(cat /var/lib/predator-sense-updater/installed-commit)"

touch /var/log/predator-sense-update.log
echo
echo "Listo. Verificación:"
cat /etc/predator-sense-updater.conf
