# 11. Operación y recuperación del laboratorio

Este documento describe cómo reanudar los nodos sin reconstruirlos desde cero. GNS3 administra los nodos y los contenedores; después de un cierre, abre el proyecto guardado y arranca los equipos gradualmente. No elimines ni recrees un nodo si basta con iniciarlo de nuevo.

## Orden de arranque recomendado

1. GNS3 VM y proyecto guardado.
2. Switch Cisco, R1 e ISP.
3. FortiGate y espera de sus interfaces.
4. Web Server.
5. JUMP-SRV solo cuando se vaya a validar RDS/RemoteApp.
6. CLIENTE-FORTICLIENT para iniciar la sesión y probar el portal.

Con 16 GB de RAM se recomienda mantener apagadas las VMs que no estén participando en la prueba actual, cerrar ventanas pesadas y grabar OBS con resolución moderada. No se necesita mantener JUMP-SRV encendido después de completar las tomas que dependen de él.

## Recuperación de Web Server

Primero ejecuta el script de auditoría de solo lectura:

```bash
sh scripts/maintenance/01-auditar-webserver-antes-de-recuperar.sh
```

Ese script debe copiarse y ejecutarse dentro de WEB-SERVER, no en la GNS3 VM. Si se necesita restaurar IP y servicios, revisa cuidadosamente y ejecuta como root el script:

```bash
sh scripts/maintenance/05-recuperar-webserver-p4-idempotente.sh
```

El script restaura `eth0` a `10.21.75.130/29`, gateway `10.21.75.129`, DNS `8.8.8.8`/`1.1.1.1` e inicia/reinicia servicios relacionados. Incluye `ip addr flush dev eth0`, por lo que **solo debe ejecutarse dentro del Web Server**. No reinstala la aplicación del Sistema de Caja ni reconstruye datos de aplicación.

## Recuperación de Cliente FortiClient

1. Inicia el nodo existente `CLIENTE-FORTICLIENT` desde GNS3.
2. Abre la terminal del contenedor.
3. Ejecuta `lab-vpn connect`.
4. Introduce la contraseña de forma interactiva y deja abierta la terminal que mantiene la sesión.
5. En una segunda terminal, verifica `ip -br addr show ppp0` y `ip route get 10.21.75.138`.
6. Abre Firefox y utiliza `https://10.21.75.138/RDWeb/webclient/index.html`.

Para revisar la imagen almacenada en la GNS3 VM, ejecuta `scripts/maintenance/02-verificar-restaurar-imagen-forticlient.sh`. La imagen se conservó con tags `forticlient-lite:7.2-fix3` y `lab-backup/forticlient-vnc-firefox:20261009`; verifica las etiquetas disponibles antes de restaurar cualquier tag.

## Servicios Web Server

Dentro del contenedor existente, las comprobaciones son:

```bash
service apache2 status
service ssh status || service sshd status
service xrdp-sesman status
service xrdp status
ss -lntp | grep -E ':(22|443|3389)\b' || true
```

`systemctl` no aplica en el contenedor porque no está iniciado con systemd como PID 1. Usa `service`, `ps`, archivos de log y `ss` según corresponda.

## Principios de recuperación

- No guardar contraseñas en scripts.
- No publicar certificados PFX, claves privadas, tokens o backups sin sanitizar.
- No ejecutar scripts de recuperación durante el video; son para reanudar el laboratorio.
- Si un servicio sigue activo y funciona, evita reiniciarlo sin necesidad.
- Verifica el nodo y su IP antes de lanzar un script de red.


## Recuperación de la imagen del cliente VPN con Firefox

La GNS3 VM conservó estas etiquetas de imagen tras las modificaciones del cliente: `forticlient-lite:7.2-fix3`, `lab-backup/forticlient-original-before-vnc:20261009`, `lab-backup/forticlient-firefox:checkpoint-20261009` y `lab-backup/forticlient-vnc-firefox:20261009`. Las etiquetas son locales a la GNS3 VM; no equivalen a una publicación en Docker Hub.

En caso de cierre, inspecciona primero con `docker ps -a` y `docker image ls`. Inicia el nodo desde GNS3 en vez de crear un contenedor independiente, para conservar sus enlaces y configuración del proyecto. `scripts/maintenance/02-verificar-restaurar-imagen-forticlient.sh` comprueba las imágenes de respaldo y puede volver a apuntar la etiqueta de trabajo a la imagen validada; lee el script antes de ejecutarlo.

## Recuperación de una sesión VPN

La sesión `lab-vpn connect` es un proceso en primer plano. Si la GNS3 VM o el contenedor se recrea, la sesión no se conserva y debe iniciarse de nuevo dentro de `CLIENTE-FORTICLIENT`. No guardes la contraseña en la línea de comandos. La dirección de `ppp0` y las rutas se verifican desde una segunda terminal con el script `scripts/cliente/verificar-rutas-vpn.sh`.
