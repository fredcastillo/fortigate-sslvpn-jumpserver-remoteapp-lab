# Scripts y comandos de la práctica

Los scripts incluidos se separan en cuatro grupos:

- **Verificación:** comandos de solo lectura para medir estado de servicios, rutas, puertos y RDS.
- **Mantenimiento:** scripts preservados para la recuperación de nodos usados en GNS3.
- **Comandos de recopilación:** instrucciones para capturar running-configs e información de los dispositivos.
- **Conexión VPN:** instrucciones para utilizar el helper preinstalado `lab-vpn` en el cliente.

## Inventario

| Archivo | Plataforma | Uso | Cambios |
|---|---|---|---|
| `linux/verificar-webserver.sh` | Web Server Linux | Comprueba IP, servicios y listeners. | Solo lectura. |
| `windows/verificar-jump-a-web.ps1` | JUMP-SRV | Prueba TCP 443, 3389 y 22 hacia Web. | Solo lectura. |
| `windows/extraer-evidencia-rds.ps1` | JUMP-SRV | Recopila IP y RemoteApps si los cmdlets están disponibles. | Solo lectura; escribe un archivo de evidencia local. |
| `cliente/verificar-rutas-vpn.sh` | Cliente Linux | Verifica `ppp0` y ruta a Jump/Web. | Solo lectura. |
| `cliente/start-client-vnc-reference.sh` | Cliente FortiClient dentro de GNS3 | Referencia de arranque: tun/ppp, D-Bus, DHCP, servicios y Firefox si hay DISPLAY. | Arranque y creación de procesos; comparar con el archivo actual de la imagen antes de sustituirlo. |
| `cliente/start-browser-pc.sh` | Browser-PC | Configura IP estática opcional y lanza Firefox ESR. | Modifica la IPv4 de `eth0`; solo en el nodo Browser-PC. |
| `maintenance/01-auditar-webserver-antes-de-recuperar.sh` | Web Server | Audita paquete, red, cuentas, listeners y archivos. | Solo lectura. |
| `maintenance/02-verificar-restaurar-imagen-forticlient.sh` | GNS3 VM | Verifica imagen/tags del cliente y Firefox. | Puede reetiquetar la imagen según su contenido; inspeccionar antes. |
| `maintenance/03-control-cliente-vpn.sh` | GNS3 VM | Controla status/connect/disconnect del helper VPN mediante Docker. | Conectar/desconectar sesión VPN. |
| `maintenance/04-verificar-forticlient-vnc-firefox.sh` | GNS3 VM | Inspecciona nodo, procesos, DISPLAY y logs. | Solo lectura. |
| `maintenance/05-recuperar-webserver-p4-idempotente.sh` | Web Server | Restaura IP/ruta/DNS e inicia servicios. | Cambia red y servicios; solo en Web Server como root. |
| `maintenance/06-verificar-webserver.sh` | Web Server | Consulta OS, red, DNS, listeners y servicios. | Solo lectura. |
| `maintenance/07-verificar-webserver-desde-jump.ps1` | JUMP-SRV | Prueba puertos TCP a Web. | Solo lectura. |
| `maintenance/08-verificar-rds-remoteapps.ps1` | JUMP-SRV | Muestra la colección, RemoteApps y grupos. | Solo lectura. |
| `fortigate/recopilar-configuracion.txt` | FortiGate GUI/CLI | Lista comandos de consulta y exportación. | Comandos de lectura; configuración de FortiGate por GUI. |
| `cisco/recopilar-configuracion.txt` | Cisco IOS | Lista comandos de interfaz, VLAN, DHCP y running-config. | Solo lectura. |

## Antes de ejecutar

1. Lee el encabezado del script y confirma el nodo en el que se ejecutará.
2. No ejecutes scripts de mantenimiento durante la grabación.
3. El script `maintenance/05-recuperar-webserver-p4-idempotente.sh` vacía las direcciones actuales de `eth0` antes de asignar `10.21.75.130/29`; ejecútalo solo dentro de WEB-SERVER como root.
4. Los comandos `lab-vpn` se ejecutan dentro de `CLIENTE-FORTICLIENT`. La utilidad se instala en la imagen del contenedor; su binario/código interno no se incluye aquí y sus credenciales no se guardan en scripts.
5. Sanitiza cualquier salida antes de subirla a un repositorio público.


El script `cliente/start-client-vnc-reference.sh` es una versión de referencia documentada a partir del comportamiento observado del cliente; antes de reemplazar el `/usr/local/bin/start.sh` de la imagen, compara el archivo actual. El script `cliente/start-browser-pc.sh` vacía las direcciones IPv4 de `eth0` y aplica la IP estática predeterminada, por lo que no se debe ejecutar en otros contenedores.

## Ejecutar los scripts desde la ubicación correcta

Los archivos de este repositorio no aparecen automáticamente dentro de los contenedores GNS3 ni dentro de JUMP-SRV. Para usarlos, transfiere el script a la VM/servidor adecuado o copia el bloque de verificación. Ejemplo para WEB-SERVER, desde la GNS3 VM, si el archivo ya se encuentra en `/tmp`:

```bash
WEB_CID="$(docker ps -q --filter 'name=web-server-lab' | head -n1)"
test -n "$WEB_CID" || { echo 'Web Server no está iniciado'; exit 1; }
docker cp /tmp/verificar-webserver.sh "$WEB_CID:/tmp/verificar-webserver.sh"
docker exec -it "$WEB_CID" bash /tmp/verificar-webserver.sh
```

Para un script destinado al cliente VPN, usa el ID actual del contenedor y `docker cp` al nodo `CLIENTE-FORTICLIENT`; no pegues un ID antiguo copiado de otra sesión. Para scripts PowerShell, copia el archivo a JUMP-SRV mediante un recurso compartido/clipboard/transferencia autorizada y ejecútalo allí. Las referencias `scripts/windows/...` del repositorio son rutas locales, no rutas que existan automáticamente en Windows Server.
