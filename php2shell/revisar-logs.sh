#!/usr/bin/env sh
# Lab PHP2Shell — ayuda para revisar logs de acceso desde el 17-oct-2026 (cuando ya había intentos
# de explotación, según Amazon, cuatro días antes del aviso). NO detecta el ataque con certeza:
# marca peticiones con señales compatibles con el vector session.upload_progress para que TÚ las mires.
# Uso: sh revisar-logs.sh /ruta/a/access.log  (formato combinado de Apache/Nginx)
set -eu
LOG="${1:-}"
[ -n "$LOG" ] && [ -f "$LOG" ] || { echo "Uso: sh revisar-logs.sh /ruta/a/access.log"; exit 2; }

echo "Revisando $LOG"
echo "Señales buscadas (compatibles, NO concluyentes): POST con multipart y nombre de campo"
echo "PHP_SESSION_UPLOAD_PROGRESS, o cuerpos anómalamente grandes a un mismo endpoint."
echo "--------------------------------------------------"

# 1) Menciones directas al campo del vector.
echo ">> Peticiones que mencionan PHP_SESSION_UPLOAD_PROGRESS:"
grep -i "PHP_SESSION_UPLOAD_PROGRESS" "$LOG" || echo "   (ninguna)"

echo
# 2) POST repetidos al mismo recurso desde una IP (patrón de fuzzing de heap).
echo ">> Top IPs por número de POST (revisa las que destaquen):"
awk '$6 ~ /POST/ {gsub(/"/,"",$1); print $1}' "$LOG" 2>/dev/null | sort | uniq -c | sort -rn | head -10 || echo "   (sin datos; ¿formato de log distinto?)"

echo
echo "Recuerda: esto es una ayuda, no un veredicto. Si ves algo raro desde el 17-oct, trátalo como"
echo "posible compromiso: aísla, revisa integridad y rota credenciales."
