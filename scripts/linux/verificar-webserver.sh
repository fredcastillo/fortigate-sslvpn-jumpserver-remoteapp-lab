#!/usr/bin/env bash
# Verificación no destructiva para WEB-SERVER (10.21.75.130/29).
# No cambia red, firewall ni servicios. Ejecutar localmente en el servidor.
set -u

PASS=0
FAIL=0
INFO=0

ok()   { printf '[OK]   %s\n' "$*"; PASS=$((PASS+1)); }
fail() { printf '[FAIL] %s\n' "$*"; FAIL=$((FAIL+1)); }
info() { printf '[INFO] %s\n' "$*"; INFO=$((INFO+1)); }

printf '\n=== FortiGate SSL-VPN Lab | Verificación no destructiva de WEB-SERVER ===\n'
printf 'Fecha: '; date '+%Y-%m-%d %H:%M:%S %Z' 2>/dev/null || date
printf '\n--- Identidad y red ---\n'
hostname 2>/dev/null || true
ip -br addr 2>/dev/null || info 'No se encontró iproute2 (comando ip).'
ip route 2>/dev/null || true

if command -v ip >/dev/null 2>&1; then
  if ip -o -4 addr show | grep -qE 'inet 10\.21\.75\.130/29([[:space:]]|$)'; then
    ok 'Se encontró 10.21.75.130/29.'
  else
    fail 'No se encontró 10.21.75.130/29 en las interfaces IPv4.'
  fi
else
  info 'No se pudo validar la IP porque el comando ip no está disponible.'
fi

printf '\n--- Servicios del sistema ---\n'
for svc in apache2 ssh xrdp; do
  if command -v systemctl >/dev/null 2>&1; then
    if systemctl is-active --quiet "$svc" 2>/dev/null; then
      ok "Servicio activo: $svc"
    else
      info "Servicio no activo/no encontrado: $svc"
    fi
  else
    info 'systemctl no está disponible; se omite la comprobación de unidades.'
    break
  fi
done

printf '\n--- Puertos TCP escuchando ---\n'
if command -v ss >/dev/null 2>&1; then
  ss -lntp 2>/dev/null | grep -E ':(22|443|3389)([[:space:]]|$)' || info 'No se detectaron sockets en 22/443/3389 en la salida de ss.'
  for port in 22 443 3389; do
    if ss -lntH 2>/dev/null | awk '{print $4}' | grep -Eq "(^|:|\\])${port}$"; then
      ok "Hay un socket TCP escuchando en puerto $port."
    else
      fail "No se detectó un socket TCP escuchando en puerto $port."
    fi
  done
else
  info 'El comando ss no está disponible; instala iproute2 para verificar puertos.'
fi

printf '\n--- Resumen ---\n'
printf 'OK: %d | FAIL: %d | INFO: %d\n' "$PASS" "$FAIL" "$INFO"
if [ "$FAIL" -gt 0 ]; then exit 1; fi
exit 0
