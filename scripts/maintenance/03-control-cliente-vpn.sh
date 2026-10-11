#!/usr/bin/env bash
# Ejecutar en GNS3 VM. La contraseña se pide interactivamente; no incluirla en argumentos.
set -euo pipefail
ACTION="${1:-status}"
mapfile -t IDS < <(docker ps -q --filter 'name=CLIENTE-FORTICLIENT')
if [ "${#IDS[@]}" -ne 1 ]; then
  echo "ERROR: se esperaba exactamente un CLIENTE-FORTICLIENT activo; encontrados: ${#IDS[@]}" >&2
  docker ps -a --format 'table {{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Status}}' | grep -Ei 'CLIENTE-FORTICLIENT|CONTAINER ID' || true
  exit 1
fi
CID="${IDS[0]}"
echo "Contenedor: $CID"
case "$ACTION" in
  status)
    docker exec "$CID" lab-vpn status
    ;;
  connect)
    echo 'Se abrirá el prompt interactivo. Mantén esta terminal abierta mientras uses la VPN.'
    docker exec -it "$CID" lab-vpn connect
    ;;
  disconnect)
    docker exec "$CID" lab-vpn disconnect
    ;;
  verify)
    docker exec "$CID" lab-vpn status
    echo '--- Interfaces ---'
    docker exec "$CID" sh -c 'ip addr show ppp0 2>/dev/null || true'
    echo '--- Ruta a Web Server ---'
    docker exec "$CID" ip route get 10.21.75.130
    echo '--- Ruta a Jump Server ---'
    docker exec "$CID" ip route get 10.21.75.138
    ;;
  *)
    echo "Uso: $0 {status|connect|disconnect|verify}" >&2
    exit 2
    ;;
esac
