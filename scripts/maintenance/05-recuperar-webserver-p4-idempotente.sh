#!/bin/sh
# Recuperación de WEB-SERVER-LAB P4. Ejecutar como root DENTRO de ese contenedor.
# Restaura red/DNS y servicios usados. Instala XRDP/XFCE solo si faltan paquetes.
# --reset-password fuerza restablecimiento interactivo de web-rdp.
set -eu

if [ "$(id -u)" -ne 0 ]; then
  echo "ERROR: ejecutar como root dentro de WEB-SERVER-LAB." >&2
  exit 1
fi
if [ "${1:-}" != "" ] && [ "${1:-}" != "--reset-password" ]; then
  echo "Uso: sh $0 [--reset-password]" >&2
  exit 2
fi
RESET_PASSWORD=0
[ "${1:-}" = "--reset-password" ] && RESET_PASSWORD=1

IFACE='eth0'
WEB_CIDR='10.21.75.130/29'
WEB_GW='10.21.75.129'
DNS1='8.8.8.8'
DNS2='1.1.1.1'
RDP_USER='web-rdp'

printf '\n== 1/7: Restaurar IP del Web Server ==\n'
command -v ip >/dev/null 2>&1 || { echo 'ERROR: no existe el comando ip.' >&2; exit 1; }
ip link set "$IFACE" up
# AVISO: elimina direcciones previas de eth0; ejecutar solo en el Web Server.
ip addr flush dev "$IFACE"
ip addr add "$WEB_CIDR" dev "$IFACE"
ip route replace default via "$WEB_GW" dev "$IFACE"

printf '\n== 2/7: Restaurar DNS ==\n'
printf 'nameserver %s\nnameserver %s\n' "$DNS1" "$DNS2" > /etc/resolv.conf
cat /etc/resolv.conf

printf '\n== 3/7: Revisar paquetes requeridos ==\n'
MISSING=0
for pkg in xrdp xorgxrdp xfce4 dbus-x11; do
  status="$(dpkg-query -W -f='${db:Status-Status}' "$pkg" 2>/dev/null || true)"
  if [ "$status" != 'installed' ]; then
    echo "Falta paquete: $pkg"
    MISSING=1
  fi
done
if [ "$MISSING" -eq 1 ]; then
  echo 'Actualizando APT e instalando solo porque faltan paquetes...'
  apt-get update
  DEBIAN_FRONTEND=noninteractive apt-get install -y xrdp xorgxrdp xfce4 dbus-x11
else
  echo 'XRDP/XFCE ya están instalados; se omite apt-get update.'
fi

printf '\n== 4/7: Preparar cuenta y sesión XFCE ==\n'
mkdir -p /etc/skel
printf '#!/bin/sh\nexec startxfce4\n' > /etc/skel/.xsession
chmod 0644 /etc/skel/.xsession
NEW_USER=0
if id "$RDP_USER" >/dev/null 2>&1; then
  echo "La cuenta $RDP_USER existe."
else
  echo "Creando cuenta local $RDP_USER."
  adduser --disabled-password --gecos 'RDP lab account' "$RDP_USER"
  NEW_USER=1
fi
[ -d "/home/$RDP_USER" ] || { echo "ERROR: falta /home/$RDP_USER" >&2; exit 1; }
printf '#!/bin/sh\nexec startxfce4\n' > "/home/$RDP_USER/.xsession"
chown "$RDP_USER:$RDP_USER" "/home/$RDP_USER/.xsession"
chmod 0644 "/home/$RDP_USER/.xsession"
if [ "$NEW_USER" -eq 1 ] || [ "$RESET_PASSWORD" -eq 1 ]; then
  echo "Define la contraseña local de $RDP_USER (no queda guardada en este archivo)."
  passwd "$RDP_USER"
else
  echo 'Se conserva la contraseña existente. Usa --reset-password si hay que restablecerla.'
fi

printf '\n== 5/7: Reparar permisos de la clave XRDP ==\n'
if getent group ssl-cert >/dev/null 2>&1 && id xrdp >/dev/null 2>&1; then
  adduser xrdp ssl-cert >/dev/null 2>&1 || true
  id xrdp
  ls -l /etc/xrdp/key.pem /etc/xrdp/cert.pem 2>/dev/null || true
else
  echo 'AVISO: revisar usuario xrdp/grupo ssl-cert; no se han encontrado ambos.'
fi

printf '\n== 6/7: Iniciar servicios existentes ==\n'
service xrdp restart >/dev/null 2>&1 || service xrdp start
service apache2 start >/dev/null 2>&1 || true
service ssh start >/dev/null 2>&1 || service sshd start >/dev/null 2>&1 || true

printf '\n== 7/7: Comprobación final ==\n'
ip -4 addr show dev "$IFACE"
ip route
if command -v ss >/dev/null 2>&1; then
  ss -lntp | grep -E ':(22|443|3389)\b' || true
fi
service xrdp status || true
cat <<'MSG'
Recuperación de red/servicios completada.
Desde JUMP-SRV, comprueba TCP 22, 443 y 3389 hacia 10.21.75.130.
Este script NO recrea una aplicación web de Caja ni datos de base de datos que se hayan perdido.
MSG
