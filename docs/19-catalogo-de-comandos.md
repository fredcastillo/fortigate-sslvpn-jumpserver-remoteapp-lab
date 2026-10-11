# 19. Catálogo de comandos y consultas de verificación

Este documento reúne los comandos operativos utilizados o recuperados durante la implementación. Las configuraciones de FortiGate se realizan en la GUI, según el requisito académico; sus comandos `show` se incluyen únicamente para consulta/exportación. Las pruebas deben ejecutarse desde el dispositivo cuyo tráfico se quiere demostrar.

## 19.1 Windows PowerShell en el equipo de grabación

Fecha y hora para el comienzo del video:

```powershell
Get-Date -Format "dd/MM/yyyy HH:mm:ss"
```

## 19.2 Cliente CLIENTE-FORTICLIENT

Conexión de la herramienta preinstalada del laboratorio, en una terminal que se mantiene abierta:

```bash
lab-vpn connect
```

En otra terminal del mismo cliente:

```bash
ip -br addr show ppp0
ip route get 10.21.75.138
ip route get 10.21.75.130
ip route show dev ppp0
```

Uso del script incluido:

```bash
bash scripts/cliente/verificar-rutas-vpn.sh
```

Variables opcionales para la comprobación de rutas:

```bash
JUMP_IP=10.21.75.138 WEB_IP=10.21.75.130 \
  bash scripts/cliente/verificar-rutas-vpn.sh
```

`lab-vpn connect` requiere la contraseña interactiva y debe mantenerse ejecutándose mientras haya pruebas dependientes de la VPN. La contraseña no forma parte del repositorio.

## 19.3 GNS3 VM: identificar contenedor y estado

Ejecutar desde la terminal SSH de la GNS3 VM (no dentro de WEB-SERVER):

```bash
docker ps -a --format 'table {{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Status}}'
docker image ls
```

Para localizar el nodo cliente activo:

```bash
docker ps --format 'table {{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Status}}' \
  | grep -Ei 'CLIENTE-FORTICLIENT|web-server-lab'
```

Los nombres e IDs pueden variar después de un nuevo arranque; vuelve a identificarlos y no copies un ID antiguo sin comprobarlo.

## 19.4 WEB-SERVER: red y servicios

Comprobaciones de solo lectura dentro del contenedor WEB-SERVER:

```bash
cat /etc/os-release
ip -br addr
ip route
cat /etc/resolv.conf
service apache2 status
service ssh status || service sshd status
service xrdp-sesman status
service xrdp status
ss -lntp | grep -E ':(22|443|3389)\b' || true
```

Los scripts están versionados en el repositorio del equipo de administración. No están automáticamente dentro del contenedor; transfiérelos mediante `docker cp` desde la GNS3 VM. Ejemplo, suponiendo que primero se copió el archivo al `/tmp` de la GNS3 VM:

```bash
WEB_CID="$(docker ps -q --filter 'name=web-server-lab' | head -n1)"
test -n "$WEB_CID" || { echo 'Web Server no está iniciado'; exit 1; }
docker cp /tmp/verificar-webserver.sh "$WEB_CID:/tmp/verificar-webserver.sh"
docker exec -it "$WEB_CID" bash /tmp/verificar-webserver.sh
```

Para una auditoría más amplia, copia `scripts/maintenance/01-auditar-webserver-antes-de-recuperar.sh` del mismo modo y ejecútalo como lectura. Revisa `scripts/maintenance/README.md` para distinguir los scripts de lectura de los que cambian direccionamiento o servicios.

## 19.5 JUMP-SRV: probar los servicios de Web Server

PowerShell ejecutado **en JUMP-SRV**:

```powershell
Test-NetConnection 10.21.75.130 -Port 443
Test-NetConnection 10.21.75.130 -Port 3389
Test-NetConnection 10.21.75.130 -Port 22
```

Script consolidado: `scripts/windows/verificar-jump-a-web.ps1`. Transfiérelo a JUMP-SRV o colócalo en un directorio compartido antes de ejecutarlo; la ruta del repositorio local no existe automáticamente en el servidor. En PowerShell, desde la carpeta donde copiaste el archivo:

```powershell
.\verificar-jump-a-web.ps1
```

El script comprueba que la IP esperada del Jump sea local e imprime el resultado TCP para cada puerto. `TcpTestSucceeded=True` significa que TCP se pudo establecer desde ese origen; no sustituye una prueba funcional de la aplicación.

## 19.6 JUMP-SRV: RDS/RemoteApp y grupos

Consultas de solo lectura en PowerShell administrativo:

```powershell
Import-Module RemoteDesktop
$broker = 'JUMP-SRV.jumpserver.lab'
$collection = 'QuickSessionCollection'
Get-RDSessionCollection -ConnectionBroker $broker |
  Format-Table CollectionName,CollectionDescription -AutoSize
Get-RDRemoteApp -ConnectionBroker $broker -CollectionName $collection |
  Format-List DisplayName,Alias,FilePath,ShowInWebAccess,UserGroups,RequiredCommandLine
```

Grupos:

```powershell
Import-Module ActiveDirectory
Get-ADGroupMember 'GG-RemoteApp-Web' | Select-Object Name,SamAccountName
Get-ADGroupMember 'GG-RemoteApp-Privileged' | Select-Object Name,SamAccountName
```

Script que genera un archivo de evidencia local: copia `scripts/windows/extraer-evidencia-rds.ps1` al Jump Server y ejecútalo desde la carpeta donde se encuentre:

```powershell
.\extraer-evidencia-rds.ps1
```

También está disponible `scripts/maintenance/08-verificar-rds-remoteapps.ps1`, que muestra el estado actual de la colección y sus aplicaciones. No subas al repositorio nombres de cuentas, información de sesión o detalles no necesarios para demostrar el requisito.

## 19.7 Cisco IOS: switch, R1 e ISP

En modo EXEC privilegiado del switch:

```text
show version
show ip interface brief
show vlan brief
show interfaces trunk
show running-config
```

En R1:

```text
show ip interface brief
show ip route
show ip dhcp binding
show ip dhcp pool
show running-config | section dhcp
show running-config
```

En Router-ISP:

```text
show ip interface brief
show ip route
show running-config
```

Guarda salidas de cada nodo en archivos separados. No compartas una salida de R1 bajo el nombre de Router-ISP ni llames “running-config” a un esquema reconstruido manualmente.

## 19.8 FortiGate: consultas de lectura

La modificación de configuración debe realizarse por GUI. Para crear una exportación de lectura desde la CLI integrada o consola, los comandos pertinentes incluyen:

```text
get system status
show system interface
show router static
show firewall address
show firewall addrgrp
show firewall service custom
show firewall vip
show firewall policy
show vpn ssl settings
show vpn ssl web portal
show user group
```

Las salidas pueden contener identificadores, información de red y parámetros sensibles. Sanitiza antes de publicar. `show firewall policy` y `show firewall vip` ya se registraron durante el trabajo; la salida de políticas se obtuvo antes de que `WAN_to_WEBSERVER_HTTPS` se deshabilitara desde la GUI, por lo que no debe usarse por sí sola como exportación final.


## 19.9 DNS y diagnóstico de RD Web en JUMP-SRV

Consultas no destructivas para confirmar que Jump resuelve su nombre y su destino web:

```powershell
Get-DnsServerForwarder
Resolve-DnsName JUMP-SRV.jumpserver.lab -Server 127.0.0.1
Resolve-DnsName 10.21.75.130 -ErrorAction SilentlyContinue
Test-NetConnection 10.21.75.130 -Port 443
```

`Resolve-DnsName 10.21.75.130` no es sustituto de PTR configurado; se incluye solo para observar si hay búsqueda inversa. La prueba principal de portal se realiza en Firefox con la URL que corresponde al certificado y la resolución DNS disponibles. La URL por IP utilizada en la demostración es `https://10.21.75.138/RDWeb/webclient/index.html`.

## 19.10 Servicios del Web Server en un contenedor sin systemd

La consola del contenedor puede devolver el mensaje de que PID 1 no es systemd. En ese entorno usa `service`, `ps`, `ss` y los logs de aplicación, en lugar de asumir que `systemctl` opera dentro del contenedor:

```bash
service apache2 status
service ssh status || service sshd status
service xrdp-sesman status
service xrdp status
ss -lntp
tail -n 50 /var/log/xrdp.log /var/log/xrdp-sesman.log 2>/dev/null
```

Los comandos que inician/reinician servicios deben ejecutarse solo cuando corresponda a una tarea operativa. Para la demostración final, prioriza consultas de lectura y evita reinstalaciones.