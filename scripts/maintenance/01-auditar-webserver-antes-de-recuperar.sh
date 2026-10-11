#!/bin/sh
# SOLO LECTURA. Ejecutar dentro de WEB-SERVER-LAB antes de correr el script de recuperación.
set +e
echo '========== SISTEMA =========='
cat /etc/os-release
echo
echo '========== IDENTIDAD =========='
hostname
id
echo
echo '========== RED =========='
ip addr show dev eth0
ip route
echo
echo '========== DNS =========='
cat /etc/resolv.conf
echo
echo '========== PAQUETES =========='
for pkg in apache2 php php-mysql mariadb-server mysql-server openssh-server xrdp xorgxrdp xfce4 dbus-x11; do
  printf '%-20s ' "$pkg"
  dpkg-query -W -f='${db:Status-Status} ${Version}\n' "$pkg" 2>/dev/null || echo 'no registrado en dpkg'
done
echo
echo '========== CUENTAS =========='
id web-rdp 2>&1
id labssh 2>&1
echo
echo '========== LISTENERS =========='
ss -lntp 2>&1 | grep -E ':(22|80|443|3306|3389)\b'
echo
echo '========== SERVICIOS =========='
for svc in apache2 ssh sshd xrdp mariadb mysql; do
  printf '%-12s ' "$svc"
  service "$svc" status 2>&1 | head -n 3
done
echo
echo '========== CONTENIDO WEB (solo listar) =========='
find /var/www/html -maxdepth 3 -type f -printf '%p (%s bytes)\n' 2>/dev/null | head -n 100
echo
echo '========== CARPETAS DE APLICACION POSIBLES =========='
for d in /var/www/html /var/www/caja /opt/caja /srv/caja; do
  [ ! -e "$d" ] || ls -ld "$d"
done
echo
echo 'Auditoría terminada. No se cambió nada.'
