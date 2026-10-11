# Mantenimiento del laboratorio

Estos scripts son utilidades de diagnóstico, recuperación y control de componentes del laboratorio GNS3. No todos son scripts de configuración FortiGate; la configuración/demostración de FortiGate se realiza mediante GUI, según el requisito de la práctica.

| Archivo | Acción | Dónde ejecutarlo |
|---|---|---|
| `01-auditar-webserver-antes-de-recuperar.sh` | Solo lectura: red, paquetes, cuentas, listeners y servicios. | Dentro de WEB-SERVER-LAB. |
| `02-verificar-restaurar-imagen-forticlient.sh` | Inspecciona/ajusta una etiqueta Docker de la imagen de trabajo guardada y revisa Firefox/start.sh. | GNS3 VM con Docker disponible. |
| `03-control-cliente-vpn.sh` | `status`, `connect`, `disconnect`, `verify` del contenedor CLIENTE-FORTICLIENT. | GNS3 VM con el nodo activo. |
| `04-verificar-forticlient-vnc-firefox.sh` | Inspección de solo lectura de contenedor, versión Firefox, DISPLAY y logs. | GNS3 VM con el nodo activo. |
| `05-recuperar-webserver-p4-idempotente.sh` | Restaura direccionamiento/DNS y prepara/inicia servicios del Web Server. | Exclusivamente dentro de WEB-SERVER-LAB como root. |
| `06-verificar-webserver.sh` | Consulta OS, IP, ruta, DNS, listeners y estado de servicios. | Dentro de WEB-SERVER-LAB. |
| `07-verificar-webserver-desde-jump.ps1` | Prueba puertos TCP 443, 3389 y 22 hacia Web Server. | PowerShell en JUMP-SRV. |
| `08-verificar-rds-remoteapps.ps1` | Consulta colección, RemoteApps y asignaciones de grupos. | PowerShell en JUMP-SRV. |

## Importante: script de recuperación del Web Server

`05-recuperar-webserver-p4-idempotente.sh` ejecuta `ip addr flush dev eth0`, asigna `10.21.75.130/29`, configura gateway `10.21.75.129` y puede escribir DNS y arrancar servicios. No ejecutarlo desde la GNS3 VM, Jump Server ni cliente. Si se necesita recuperar la contraseña local de `web-rdp`, el argumento `--reset-password` abre un cambio interactivo de contraseña; no se guarda en el archivo.

## Scripts de arranque de cliente

`start-client-vnc-reference.sh` está en `scripts/cliente/` porque se usa en el contexto de CLIENTE-FORTICLIENT. Es una **plantilla de referencia funcional** reconstruida a partir del comportamiento observado del `start.sh` del contenedor; antes de reemplazar `/usr/local/bin/start.sh` en la imagen, compara el contenido real. `start-browser-pc.sh` aplica una dirección estática a `eth0`; solo está pensado para el nodo Browser-PC y vacía su configuración IPv4 al arrancar.

## Dónde reside cada archivo

Los scripts del repositorio no están montados automáticamente dentro de los nodos. Transfiere el archivo con un método adecuado (por ejemplo SCP al host GNS3 VM, luego `docker cp` al contenedor) o copia los comandos de lectura. Identifica el contenedor en ejecución por nombre actual antes de usar `docker cp`/`docker exec`.

La utilidad `lab-vpn` se encuentra preinstalada en la imagen del contenedor usada por la práctica; su código interno no está incluido aquí. El script de control solo la invoca mediante Docker y no codifica contraseñas.
