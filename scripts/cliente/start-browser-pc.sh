#!/bin/bash
# Script de arranque para el nodo gráfico Browser-PC con Firefox ESR.
# Es una plantilla a instalar como /start-network.sh en el contenedor Browser-PC.
# IMPORTANTE: ip addr flush sustituye la dirección IPv4 de eth0; valida que el
# nodo y el plan IP sean los correctos antes de usarlo fuera de ese Browser-PC.
set -e
exec > /var/log/start-network.log 2>&1

IP_ADDR="${IP_ADDR:-10.21.75.110}"
PREFIX="${PREFIX:-25}"
GATEWAY="${GATEWAY:-10.21.75.1}"

printf 'Browser-PC: esperando eth0...\n'
for i in $(seq 1 15); do
  ip link show eth0 >/dev/null 2>&1 && break
  sleep 1
done
ip link show eth0 >/dev/null 2>&1 || { echo 'ERROR: eth0 no existe.'; exit 1; }

printf 'Configurando eth0: %s/%s; gateway %s\n' "$IP_ADDR" "$PREFIX" "$GATEWAY"
ip addr flush dev eth0
ip addr add "${IP_ADDR}/${PREFIX}" dev eth0
ip link set eth0 up
ip route replace default via "$GATEWAY"

if ! command -v firefox-esr >/dev/null 2>&1; then
  echo 'ERROR: firefox-esr no está instalado.'
  exit 127
fi

echo 'Iniciando Firefox ESR. GNS3 debe proporcionar el entorno gráfico VNC.'
exec firefox-esr --no-remote --new-instance
