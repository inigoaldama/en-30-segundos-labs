#!/usr/bin/env sh
# Lab PHP2Shell (CVE-2026-109618 / CVE-2026-109619 / CVE-2026-115560) — NIVEL DETECCIÓN.
# Comprueba si la versión de PHP en ejecución está parcheada y si el vector del tercer aviso
# (session.upload_progress) está activo. NO contiene exploit ni dispara ningún fallo: solo mira
# versión y configuración, como haría un inventario de seguridad. Pensado para correr DENTRO del
# contenedor o en un servidor propio: `sh comprobar.sh`.
set -eu

# Primera versión parcheada de cada rama con soporte (php.net, 21-oct-2026).
# Rama → versión mínima segura.
min_segura() {
  case "$1" in
    8.5) echo "8.5.12" ;;
    8.4) echo "8.4.27" ;;
    8.3) echo "8.3.36" ;;
    8.2) echo "8.2.35" ;;
    *)   echo "" ;;      # 8.1, 8.0, 7.4 y anteriores: sin release oficial / fin de soporte
  esac
}

# Compara dos versiones x.y.z: devuelve 0 si $1 >= $2.
ge() { [ "$(printf '%s\n%s\n' "$2" "$1" | sort -t. -k1,1n -k2,2n -k3,3n | head -1)" = "$2" ]; }

VER="$(php -r 'echo PHP_VERSION;')"
RAMA="$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;')"
# Config efectiva de session.upload_progress.enabled, leída del propio PHP.
UP="$(php -r 'echo ini_get("session.upload_progress.enabled") ? "on" : "off";')"
MIN="$(min_segura "$RAMA")"

echo "PHP en ejecución: $VER (rama $RAMA)"
echo "session.upload_progress.enabled: $UP"
echo "--------------------------------------------------"

EXPUESTO=0

if [ -z "$MIN" ]; then
  echo "[VULNERABLE] La rama $RAMA no tiene release oficial con el arreglo (7.4/8.0/8.1 y anteriores)."
  echo "             Solo hay parche en código fuente; depende de que tu distro lo empaquete. Migra de rama."
  EXPUESTO=1
elif ge "$VER" "$MIN"; then
  echo "[OK] $VER es >= $MIN: esta rama ya incluye el arreglo de PHP2Shell."
else
  echo "[VULNERABLE] $VER es anterior a $MIN. Actualiza a $MIN o superior en esta rama."
  EXPUESTO=1
fi

if [ "$UP" = "on" ]; then
  echo "[AVISO] session.upload_progress.enabled está activo: es el vector de CVE-2026-115560."
  echo "        Mitigación hasta tener versión: session.upload_progress.enabled = 0 en php.ini."
  EXPUESTO=1
fi

echo "--------------------------------------------------"
if [ "$EXPUESTO" -eq 0 ]; then
  echo "RESULTADO: a salvo según versión y configuración. Igualmente, revisa logs desde el 17-oct-2026."
  exit 0
else
  echo "RESULTADO: expuesto. Actualiza y revisa accesos desde el 17-oct-2026 (ver revisar-logs.sh)."
  exit 1
fi
