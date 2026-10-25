#!/usr/bin/env sh
# Lab GitLab regex (CVE-2026-110264 y CVE-2026-97229) — NIVEL DETECCIÓN.
# Dada una versión de GitLab, dice si está parcheada contra el fallo del 21-oct (110264) y, de paso,
# recuerda el del 12-oct (97229). NO contiene exploit: GitLab no publica la ruta de ataque y no hay
# PoC pública; aquí solo comparamos versiones, como un inventario.
#
# Uso:
#   sh comprobar.sh 19.3.4          # pasas la versión a mano
#   sh comprobar.sh $(gitlab-rake gitlab:env:info 2>/dev/null | awk '/GitLab information/{f=1} f&&/Version:/{print $2; exit}')
set -eu

VER="${1:-}"
[ -n "$VER" ] || { echo "Uso: sh comprobar.sh <version>   (p. ej. 19.3.4)"; echo "En tu servidor: gitlab-rake gitlab:env:info | grep -m1 Version"; exit 2; }

RAMA="$(echo "$VER" | awk -F. '{print $1"."$2}')"

# Primera versión segura de cada rama para CVE-2026-110264 (parche del 21-oct-2026, docs.gitlab.com).
min_segura() {
  case "$1" in
    19.5) echo "19.5.1" ;;
    19.4) echo "19.4.3" ;;
    19.3) echo "19.3.6" ;;
    19.2) echo "19.2.9" ;;
    19.1) echo "19.1.9" ;;
    19.0) echo "19.0.10" ;;
    18.11) echo "18.11.13" ;;
    *) echo "" ;;   # 18.10 y anteriores (hasta 7.0): afectadas, sin parche en su rama
  esac
}

# 0 si $1 >= $2 comparando x.y.z numéricamente.
ge() { [ "$(printf '%s\n%s\n' "$2" "$1" | sort -t. -k1,1n -k2,2n -k3,3n | head -1)" = "$2" ]; }

MIN="$(min_segura "$RAMA")"
echo "GitLab indicado: $VER (rama $RAMA)"
echo "--------------------------------------------------"

if [ -z "$MIN" ]; then
  echo "[VULNERABLE] La rama $RAMA no tiene parche propio para CVE-2026-110264 (afecta desde 7.0)."
  echo "             Salta a una rama con soporte: 18.11.13, 19.0.10, 19.1.9, 19.2.9, 19.3.6, 19.4.3 o 19.5.1."
  R=1
elif ge "$VER" "$MIN"; then
  echo "[OK] $VER es >= $MIN: parcheado contra CVE-2026-110264 (21-oct)."
  R=0
else
  echo "[VULNERABLE] $VER es anterior a $MIN. Actualiza a $MIN o superior en tu rama."
  R=1
fi

# Recordatorio del primer fallo: quien actualizó el 12-oct (19.2.8/19.3.5/19.4.2) quedó dentro de
# rango del segundo hasta el 21. Que estés al día de uno no te cubre del otro.
case "$VER" in
  19.2.8|19.3.5|19.4.2)
    echo "[AVISO] $VER es el parche del 12-oct (CVE-2026-97229): NO cubre el del 21 (110264). Sube a $MIN." ;;
esac

echo "--------------------------------------------------"
if [ "$R" -eq 0 ]; then
  echo "RESULTADO: a salvo según versión. (GitLab.com y Dedicated ya están parcheados.)"
else
  echo "RESULTADO: expuesto. Actualiza; empieza por las instancias accesibles desde Internet (CERT-EU)."
fi
exit "$R"
