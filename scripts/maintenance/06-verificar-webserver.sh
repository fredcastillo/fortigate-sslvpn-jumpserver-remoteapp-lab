#!/bin/sh
# Solo lectura, ejecutar dentro del Web Server. No cambia red ni servicios.
set +e
echo '=== OS ==='; cat /etc/os-release
echo; echo '=== INTERFAZ ==='; ip -4 addr show dev eth0
echo; echo '=== RUTAS ==='; ip route
echo; echo '=== DNS ==='; cat /etc/resolv.conf
echo; echo '=== LISTENERS ==='; ss -lntp 2>/dev/null | grep -E ':(22|443|3389)\b'
echo; echo '=== SERVICIOS ==='; service apache2 status; service ssh status 2>/dev/null || service sshd status 2>/dev/null; service xrdp status
