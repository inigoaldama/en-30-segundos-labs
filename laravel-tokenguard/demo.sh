#!/usr/bin/env sh
# Lanza los cuatro casos del lab contra la web ya levantada (docker compose up -d).
set -eu
BASE="${1:-http://127.0.0.1:8080}"

linea() { echo; echo "================================================================"; echo "$1"; echo "================================================================"; }

linea "1) VULNERABLE · token = 0  (el ataque: un número, sin conocer ningún token)"
curl -s "$BASE/?modo=vulnerable&token=0"

linea "2) VULNERABLE · token real de Luis  (uso legítimo, para comparar)"
curl -s "$BASE/?modo=vulnerable&token=7c21e9f0a1b2c3d4e5f6a7b8c9d0e1f2"

linea "3) PARCHEADO · token = 0  (el mismo ataque, ya no entra)"
curl -s "$BASE/?modo=parcheado&token=0"

linea "4) PARCHEADO · token real de Ana  (lo legítimo sigue funcionando)"
curl -s "$BASE/?modo=parcheado&token=a8f3c1d4e5f6a7b8c9d0e1f2a3b4c5d6"
echo
