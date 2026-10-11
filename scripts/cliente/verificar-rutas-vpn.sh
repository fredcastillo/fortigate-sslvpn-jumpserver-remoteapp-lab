#!/usr/bin/env bash
# Verifica la presencia del túnel ppp0 y las decisiones de ruta relevantes.
# Ejecutar después de establecer la VPN con la utilidad provista en el laboratorio.
set -u
JUMP_IP="${JUMP_IP:-10.21.75.138}"
WEB_IP="${WEB_IP:-10.21.75.130}"

printf '\n=== FortiGate SSL-VPN Lab | Estado del túnel y rutas ===\n'
printf 'Fecha: '; date '+%Y-%m-%d %H:%M:%S %Z' 2>/dev/null || date

if ! command -v ip >/dev/null 2>&1; then
  echo '[FAIL] Falta el comando ip (iproute2).'
  exit 2
fi

if ip link show ppp0 >/dev/null 2>&1; then
  echo '[OK] La interfaz ppp0 existe.'
  ip -br addr show ppp0
else
  echo '[FAIL] ppp0 no existe. Confirma que la sesión VPN está conectada.'
  exit 1
fi

printf '\n--- Ruta hacia Jump Server (%s) ---\n' "$JUMP_IP"
jump_route="$(ip route get "$JUMP_IP" 2>&1)" || { echo "$jump_route"; exit 1; }
echo "$jump_route"
if printf '%s' "$jump_route" | grep -Eq 'dev ppp0([[:space:]]|$)'; then
  echo '[OK] La consulta de ruta hacia Jump Server utiliza ppp0.'
else
  echo '[AVISO] La consulta no muestra ppp0; revisa split tunneling, políticas y rutas.'
fi

printf '\n--- Ruta hacia Web Server (%s) ---\n' "$WEB_IP"
web_route="$(ip route get "$WEB_IP" 2>&1)" || { echo "$web_route"; exit 1; }
echo "$web_route"
if printf '%s' "$web_route" | grep -Eq 'dev ppp0([[:space:]]|$)'; then
  echo '[INFO] La ruta hacia Web Server usa ppp0. Verifica que este comportamiento corresponda al split tunneling deseado.'
else
  echo '[INFO] La consulta no usa ppp0. La ruta, por sí sola, no confirma ni concede acceso; verifica las políticas de FortiGate.'
fi

printf '\n--- Rutas relacionadas ---\n'
ip route | grep -E '10\.21\.75\.(13[0-9]|1[0-4][0-9])|ppp0' || true
