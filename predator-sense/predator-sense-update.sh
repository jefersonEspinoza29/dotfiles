#!/usr/bin/env bash
# Revisa si hay commits nuevos en predator-sense y, si los hay, recompila
# y reinstala todo (GUI, módulo de kernel vía DKMS, helper, servicios).
#
# Corre como root desde un pacman hook (PostTransaction) o a mano con sudo.
# Un hook PostTransaction corre TODAVÍA dentro del proceso de pacman, con su
# base de datos bloqueada — por eso, si se invoca mientras ese lock existe,
# se delega el trabajo real a un servicio systemd transient que arranca
# después de que pacman suelta el lock, en vez de compilar/instalar ahí mismo.
set -uo pipefail

CONF="/etc/predator-sense-updater.conf"
[ -f "$CONF" ] || { echo "No existe $CONF, nada que hacer." >&2; exit 0; }
# shellcheck source=/dev/null
source "$CONF"   # define OWNER, HOME_DIR, REPO

if [ "$EUID" -ne 0 ]; then
    echo "Este script debe correr como root (lo hace el pacman hook)." >&2
    exit 1
fi

if [ "${1:-}" != "--worker" ] && [ -e /var/lib/pacman/db.lck ]; then
    # Todavía estamos dentro de la transacción de pacman: delegar y salir ya.
    /usr/bin/systemd-run --quiet --collect --no-block \
        --unit=predator-sense-update \
        "$0" --worker >/dev/null 2>&1 || true
    exit 0
fi

# Si nos delegaron el trabajo, esperar un poco a que el lock se libere
# (yay suele encadenar varias transacciones seguidas).
for _ in $(seq 1 60); do
    [ -e /var/lib/pacman/db.lck ] || break
    sleep 5
done
[ -e /var/lib/pacman/db.lck ] && exit 0

# Evitar dos actualizaciones en paralelo (dos hooks casi simultáneos).
exec 9>/run/predator-sense-update.lock
flock -n 9 || exit 0

STATE_DIR="/var/lib/predator-sense-updater"
MARKER="$STATE_DIR/installed-commit"
LOG="/var/log/predator-sense-update.log"
OWNER_UID=$(id -u "$OWNER")

mkdir -p "$STATE_DIR"
touch "$LOG"

log()    { printf '[%s] %s\n' "$(date -Is)" "$*" >>"$LOG"; }
notify() {
    runuser -u "$OWNER" -- env HOME="$HOME_DIR" \
        DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/${OWNER_UID}/bus" \
        notify-send -a "Predator Sense" "$1" "$2" 2>/dev/null || true
}
as_owner() { runuser -u "$OWNER" -- env HOME="$HOME_DIR" "$@"; }

if [ ! -d "$REPO/.git" ]; then
    log "ERROR: no existe el repo $REPO"
    exit 1
fi

log "=== comprobando actualizaciones ==="
if ! as_owner git -C "$REPO" fetch --quiet origin main; then
    log "git fetch falló (¿sin internet?). Se reintenta en la próxima transacción."
    exit 0
fi

REMOTE=$(as_owner git -C "$REPO" rev-parse origin/main) || exit 1
INSTALLED=$(cat "$MARKER" 2>/dev/null || true)

# Solo se considera "al día" si además el binario sigue instalado: así, un
# fallo a mitad de camino (o un `pm -R` accidental) se reintenta solo.
if [ "$INSTALLED" = "$REMOTE" ] && [ -x /opt/predator-sense/predator-sense ]; then
    log "Ya está al día ($REMOTE)."
    exit 0
fi

if [ -n "$(as_owner git -C "$REPO" status --porcelain)" ]; then
    log "ERROR: $REPO tiene cambios locales sin commitear, no se tocó."
    notify "Predator Sense" "No se actualizó: hay cambios locales sin commitear en $REPO."
    exit 1
fi

log "Actualizando a $REMOTE..."
notify "Actualizando Predator Sense" "Hay una versión nueva, compilando en segundo plano…"

if ! as_owner git -C "$REPO" checkout --quiet main \
    || ! as_owner git -C "$REPO" merge --ff-only "$REMOTE"; then
    log "ERROR: no se pudo avanzar main a $REMOTE (merge no fast-forward)."
    notify "Predator Sense" "No se pudo descargar la actualización."
    exit 1
fi

if ! as_owner bash -c '
    export PATH="$HOME/.cargo/bin:$PATH"
    [ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"
    cd "$1/predator-sense-gui" || exit 1
    cargo build --release || exit 1
    cargo build --release --manifest-path installer/Cargo.toml
' _ "$REPO" >>"$LOG" 2>&1; then
    log "ERROR: la compilación falló. No se marca como instalado (se reintenta)."
    notify "Predator Sense" "Falló la compilación, se mantiene la versión anterior."
    exit 1
fi

pkill -u "$OWNER_UID" -f /opt/predator-sense/predator-sense 2>/dev/null || true
sleep 1

if ! "$REPO/predator-sense-gui/installer/target/release/predator-sense-installer" --install >>"$LOG" 2>&1; then
    log "ERROR: el instalador falló. No se marca como instalado (se reintenta)."
    notify "Predator Sense" "Falló la instalación de la actualización."
    exit 1
fi

echo "$REMOTE" > "$MARKER"
log "Actualización completa a $REMOTE."
notify "Predator Sense actualizado" "Se instaló la última versión correctamente."
