#!/bin/bash
# Plantilla reproducible basada en el comportamiento de arranque observado en
# CLIENTE-FORTICLIENT. Comparar con /usr/local/bin/start.sh en la imagen activa
# antes de reemplazar el archivo dentro del contenedor.
# Requiere ejecutarse como root dentro del contenedor GNS3 del cliente.

set +e
mkdir -p /var/log /dev/net
exec >> /var/log/start-client.log 2>&1

echo "========== FortiGate SSL-VPN / cliente FortiClient =========="
echo "Fecha: $(date 2>/dev/null || true)"
echo "DISPLAY=${DISPLAY:-<vacío>}"

# Dispositivos utilizados por el cliente VPN. Si GNS3 ya los inyectó,
# se conservan; mknod solo se intenta cuando no existen.
[ -c /dev/net/tun ] || mknod /dev/net/tun c 10 200 2>/dev/null || true
[ -c /dev/ppp ] || mknod /dev/ppp c 108 0 2>/dev/null || true

# D-Bus: contenedor sin systemd como PID 1.
mkdir -p /run/dbus
rm -f /run/dbus/pid
dbus-daemon --system --fork 2>/dev/null || true

# Obtención de la red de usuarios por DHCP en eth0.
ip link set eth0 up 2>/dev/null
dhclient -nw eth0 || echo "AVISO: eth0 no obtuvo DHCP durante el arranque."
grep -q '^[[:space:]]*nameserver' /etc/resolv.conf 2>/dev/null || \
  echo 'nameserver 8.8.8.8' >> /etc/resolv.conf

# Arrancar los servicios FortiClient declarados por el paquete instalado.
for unit in /lib/systemd/system/forti*.service /usr/lib/systemd/system/forti*.service; do
  [ -f "$unit" ] || continue
  grep -E '^ExecStart=' "$unit" | sed 's/^ExecStart=//; s/^[-@+!]*//' | while IFS= read -r command_line; do
    [ -n "$command_line" ] || continue
    nohup $command_line >"/var/log/$(basename "$unit").log" 2>&1 &
  done
done

mkdir -p /run/user/1000
chown 1000:1000 /run/user/1000 2>/dev/null || true
chmod 700 /run/user/1000 2>/dev/null || true

# GNS3 puede inyectar Xvfb/VNC y DISPLAY. Solo intentar abrir Firefox si
# el ejecutable y el display están disponibles.
if [ -x /usr/bin/firefox ] && [ -n "${DISPLAY:-}" ]; then
  nohup /usr/bin/firefox --no-remote --new-instance \
    >/var/log/firefox.log 2>&1 &
  echo "Firefox iniciado con PID $!"
else
  echo "INFO: Firefox no se inició; requiere /usr/bin/firefox y DISPLAY válido."
fi

echo "Arranque completado. Manteniendo el contenedor disponible."
if [ -t 0 ]; then
  exec /bin/bash
else
  exec tail -f /dev/null
fi
