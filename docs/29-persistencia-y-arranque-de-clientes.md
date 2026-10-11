# 29. Persistencia Docker/GNS3 y arranque de los clientes gráficos

## 29.1 Por qué es importante este tema

El laboratorio utiliza GNS3 VM y nodos basados en contenedores. Hay que distinguir:

- **Imagen Docker:** plantilla de sistema de archivos/capas desde la cual se crea el contenedor.
- **Contenedor:** instancia de ejecución conectada a los enlaces virtuales del proyecto GNS3.
- **Estado de ejecución:** proceso VPN, interfaz `ppp0`, sockets de servicios, display gráfico y sesiones de usuario. Este estado puede desaparecer al detener o recrear el contenedor.
- **Archivos modificados dentro del contenedor:** sobreviven a un `stop/start` del mismo contenedor, pero no necesariamente a que GNS3 recree el nodo desde la imagen original.
- **Etiqueta de imagen local:** nombre que identifica una imagen en el daemon Docker de la GNS3 VM. No significa que la imagen esté publicada en Docker Hub.

Esta distinción fue relevante para mantener Firefox y los ajustes del cliente tras un cierre de GNS3. Por eso se conservaron etiquetas Docker locales para recuperar el estado conocido.

## 29.2 Imágenes identificadas en la GNS3 VM

Las etiquetas observadas en la VM son:

- `forticlient-lite:7.2-fix3`
- `lab-backup/forticlient-original-before-vnc:20261009`
- `lab-backup/forticlient-firefox:checkpoint-20261009`
- `lab-backup/forticlient-vnc-firefox:20261009`

En la imagen de trabajo con Firefox se comprobó `Mozilla Firefox 157.0.1`. Estas imágenes son locales a la GNS3 VM mientras no se haga y verifique una publicación explícita a un registry. El repositorio no declara que estén en Docker Hub.

Antes de un cambio importante, consulta:

```bash
docker ps -a --format 'table {{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Status}}'
docker image ls
```

Para localizar el cliente activo:

```bash
docker ps --format 'table {{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Status}}' \
  | grep -i CLIENTE-FORTICLIENT
```

Usa el ID actual. No reutilices IDs de una sesión anterior: al recrear el contenedor cambian.

## 29.3 Sesión VPN: proceso en primer plano

En `CLIENTE-FORTICLIENT`, la conexión se inicia con la utilidad preinstalada:

```bash
lab-vpn connect
```

El proceso mantiene el túnel mientras se ejecuta, por eso esa terminal debe permanecer abierta durante las pruebas de RD Web. En una segunda terminal, consulta:

```bash
ip -br addr show ppp0
ip route get 10.21.75.138
ip route get 10.21.75.130
ip route show dev ppp0
```

Una vez que el contenedor se detiene o se recrea, el proceso y la interfaz `ppp0` se reconstruyen al volver a conectar. No se almacena la contraseña en scripts del repositorio.

## 29.4 Arranque gráfico de CLIENTE-FORTICLIENT

GNS3 inyecta el entorno de consola VNC/Xvfb y la variable `DISPLAY`. Firefox debe iniciarse solo cuando el display esté disponible y el ejecutable exista. Se añadió `scripts/cliente/start-client-vnc-reference.sh`, plantilla reutilizable basada en el comportamiento observado del script `/usr/local/bin/start.sh` dentro de la imagen.

**Antes de reemplazar el script que existe en la imagen, compara el contenido actual.** La plantilla:

- prepara `/dev/net/tun` y `/dev/ppp` si faltan;
- inicia D-Bus porque el contenedor no usa systemd como PID 1;
- solicita DHCP por `eth0`;
- inicia las unidades FortiClient disponibles;
- crea `/run/user/1000`;
- lanza Firefox si existe `/usr/bin/firefox` y `DISPLAY` está definido;
- mantiene vivo el contenedor mediante una shell interactiva o `tail -f`.

Está diseñada como referencia de arranque dentro del contenedor cliente; no se debe ejecutar desde la GNS3 VM host ni copiar a otro nodo sin comprobar sus rutas/interfaz/display.

## 29.5 Browser-PC como nodo gráfico separado

Browser-PC es distinto del contenedor VPN: utiliza Firefox ESR y se ha usado como un navegador de propósito general. El script `scripts/cliente/start-browser-pc.sh` refleja el arranque del nodo gráfico con IP estática por defecto `10.21.75.110/25` y gateway `10.21.75.1`.

Ese script ejecuta `ip addr flush dev eth0`. Por ello es específico del nodo Browser-PC y **no debe usarse** dentro de CLIENTE-FORTICLIENT, WEB-SERVER ni JUMP-SRV. Las variables `IP_ADDR`, `PREFIX` y `GATEWAY` permiten ajustar el script cuando la topología real lo requiera.

## 29.6 Flujo de recuperación después de un cierre

1. Abre el proyecto GNS3 ya existente; no elimines ni recrees nodos manualmente.
2. Enciende los equipos por etapas para limitar uso de RAM/CPU en el host de 16 GB.
3. Si el nodo VPN aparece `Created`, inícialo desde GNS3 para que se creen correctamente enlaces y consola.
4. Verifica que la dirección del cliente y la ruta al Jump sean correctas.
5. Ejecuta `lab-vpn connect` en la terminal del cliente y mantenla abierta.
6. Si no aparece Firefox, valida `DISPLAY`, el ejecutable y `/var/log/firefox.log` antes de reinstalar.
7. En Web Server, utiliza primero el script de auditoría, no el de restauración. La restauración IP se reserva para un cambio de estado que realmente la requiera.

## 29.7 Evidencia de recuperación

- Salida de `docker image ls` que muestre la etiqueta local del cliente.
- `docker inspect` del contenedor actual para la imagen de origen.
- `ip -br addr show ppp0` tras conectar.
- URL RD Web abierta en Firefox.

No adjuntes contraseñas, contenido del archivo de configuración de OpenFortiVPN ni cookies de sesión a las evidencias públicas.
