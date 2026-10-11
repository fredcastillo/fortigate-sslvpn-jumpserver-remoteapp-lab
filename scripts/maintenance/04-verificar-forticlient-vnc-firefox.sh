#!/usr/bin/env bash
# Ejecutar en la GNS3 VM. Solo lectura; localiza el contenedor activo por nombre.
set -euo pipefail
mapfile -t IDS < <(docker ps -q --filter 'name=CLIENTE-FORTICLIENT')
if [ "${#IDS[@]}" -ne 1 ]; then
  echo "ERROR: se esperaba un CLIENTE-FORTICLIENT activo; encontrados ${#IDS[@]}" >&2
  docker ps -a --format 'table {{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Status}}' | grep -Ei 'CLIENTE-FORTICLIENT|CONTAINER ID' || true
  exit 1
fi
CID="${IDS[0]}"
echo "ID=$CID"
docker inspect "$CID" --format 'Imagen={{.Config.Image}} Estado={{.State.Status}}'
echo '=== Firefox ==='; docker exec "$CID" firefox --version
echo '=== DISPLAY ==='; docker exec "$CID" sh -c 'printenv DISPLAY || true'
echo '=== Procesos ==='; docker exec "$CID" sh -c 'ps -ef | grep -E "[f]irefox|[f]ctsched|[c]onfighandler|[f]irewall" || true'
echo '=== Estado VPN (desconectado es normal tras reinicio) ==='; docker exec "$CID" lab-vpn status || true
echo '=== Log inicio ==='; docker exec "$CID" sh -c 'tail -n 30 /var/log/start-client.log 2>/dev/null || true'
echo '=== Log Firefox ==='; docker exec "$CID" sh -c 'tail -n 30 /var/log/firefox.log 2>/dev/null || true'
