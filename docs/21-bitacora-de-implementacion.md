# 21. Registro de implementación y estado técnico de la topología

Este capítulo agrupa la implementación por hitos funcionales. Describe componentes y decisiones que forman el estado documentado de la práctica, sin sustituir los running-configs que se exportan de los nodos reales.

## Hito 1 — Topología y direccionamiento

La cadena de conexión debe leerse como `CLIENTE-FORTICLIENT + BROWSER-PC → Switch-A/VLAN 10 → R1-CISCO → Router-ISP → FortiGate port1`. Switch-A conecta ambos endpoints a la LAN de usuarios; R1 actúa como gateway; Router-ISP está entre R1 y FortiGate. Del lado servidor, FortiGate `port2` conecta a WEB-SERVER y `port3` a JUMP-SRV. El overlay SSL-VPN termina en `port1`, usando el trayecto anterior; no es un enlace físico directo entre el cliente y el firewall.

Se organizaron en GNS3 los siguientes segmentos:

- Usuarios: `10.21.75.0/25`, gateway en R1 `10.21.75.1`, VLAN 10.
- Enlace R1–ISP: `203.0.113.20/30`, direcciones `.21` y `.22`.
- Enlace ISP–FortiGate: `203.0.113.24/30`, direcciones `.25` y `.26`.
- Web LAN: `10.21.75.128/29`, FortiGate `port2` `.129`, WEB-SERVER `.130`.
- Jump LAN: `10.21.75.136/29`, FortiGate `port3` `.137`, JUMP-SRV `.138`.

Los segmentos `/29` separan los servicios de Web y Jump, y permiten que el FortiGate aplique reglas entre las interfaces de ambos servidores. Los enlaces `203.0.113.0/24` son rangos de documentación utilizados para simular la WAN dentro de GNS3.

## Hito 2 — Web Server/Sistema de Caja

WEB-SERVER utiliza Ubuntu 22.04.5 LTS y `eth0` con `10.21.75.130/29`, gateway `10.21.75.129`. El directorio principal de Apache es `/var/www/html`. Los servicios observados para la práctica son:

- Apache HTTPS: TCP/443.
- OpenSSH Server: TCP/22.
- XRDP: TCP/3389.

La comprobación de puertos desde Jump se hace por separado para cada servicio. Los datos de red y estado de servicios pueden recogerse mediante `scripts/linux/verificar-webserver.sh` o `scripts/maintenance/06-verificar-webserver.sh`.

## Hito 3 — Jump Server, dominio y RemoteApp

JUMP-SRV utiliza Windows Server 2019, `10.21.75.138/29`, gateway `10.21.75.137` y el dominio `jumpserver.lab`. Se creó la colección `QuickSessionCollection`, se organizaron los grupos de seguridad y se publicaron las tres aplicaciones requeridas.

### Grupos

- `GG-RemoteApp-Web`: contiene `user.std` y `user.priv`.
- `GG-RemoteApp-Privileged`: contiene solo `user.priv`.

### Publicaciones

- `Caja-Web`: Internet Explorer, URL objetivo `https://10.21.75.130/`, asignada a ambos grupos.
- `PuTTY`: `C:\Program Files\PuTTY\putty.exe`, asignada al grupo privilegiado.
- `mstsc`: `C:\Windows\system32\mstsc.exe`, asignada al grupo privilegiado.

La consulta `Get-RDRemoteApp` mostró las entradas con `ShowInWebAccess=True`. Las sesiones realizadas desde RD Web mostraron `Caja-Web` para `user.std` y las tres aplicaciones para `user.priv`.

## Hito 4 — Remote Desktop Web Client

Se instaló el módulo `RDWebClientManagement` versión `1.0.4`, se importó el certificado público del broker y se publicó el Remote Desktop Web Client. Las operaciones del módulo usadas durante la implementación incluyen `Install-RDWebClientPackage`, `Import-RDWebClientBrokerCert` y `Publish-RDWebClientPackage -Type Production -Latest`.

Portal de navegador documentado:

```text
https://JUMP-SRV.jumpserver.lab/RDWeb/webclient/index.html
```

URL por IP utilizada en la demostración:

```text
https://10.21.75.138/RDWeb/webclient/index.html
```

La URL por IP se incluye para hacer explícito el destino del portal. El uso del nombre DNS depende de que el cliente resuelva `JUMP-SRV.jumpserver.lab` correctamente.

## Hito 5 — Cliente VPN y entorno gráfico

El cliente `CLIENTE-FORTICLIENT` utiliza una imagen Linux con la utilidad `lab-vpn`, OpenFortiVPN y Firefox. La dirección `10.212.134.200` se observó en `ppp0` durante una sesión activa. La conexión se mantiene en una terminal con:

```bash
lab-vpn connect
```

Se conservó una imagen original y una imagen de trabajo con Firefox y arranque gráfico de VNC. Las etiquetas conocidas se enumeran en [11 — Operación y recuperación](11-recuperacion-y-operacion.md). Estas etiquetas son locales de la GNS3 VM; el repositorio no afirma que la imagen se haya publicado en un registry externo.

## Hito 6 — Políticas del FortiGate

Las políticas relevantes del estado documentado son:

- `SSLVPN_TO_JUMP_HTTPS`: HTTPS desde `ssl.root` hacia `JUMP_SERVER`.
- `SSLVPN_TO_JUMP_DNS`: DNS desde `ssl.root` hacia el destino especificado en Jump LAN.
- `SLVPN_to_WEBSERVER_SSH`: deshabilitada.
- `JUMP_TO_WEBSERVER_P4`: acepta HTTPS/RDP/SSH desde Jump hacia Web, NAT deshabilitado y logging.
- `JUMP_TO_WEB_DENY_OTHER`: deniega el resto de servicios entre Jump y Web.
- `WAN_to_WEBSERVER_HTTPS`: deshabilitada posteriormente mediante GUI; `VIP_HTTPS_WEBSERVER` se conserva.

La captura literal de `show firewall policy` incluida en `running-configs/fortigate/` es anterior a la desactivación de la política WAN. `estado-final-politicas-confirmado.md` registra el cambio posterior comunicado; la exportación final debe obtenerse de la instancia final.

## Hito 7 — Pruebas de aceptación

Las verificaciones comunicadas y documentadas incluyen:

- Sesión SSL-VPN autenticada, asignación IP y presencia de `ppp0`.
- Ruta del cliente hacia `10.21.75.138` mediante `ppp0`.
- Acceso al portal RD Web por HTTPS con IP del Jump.
- Catálogo RemoteApp diferenciado para `user.std` y `user.priv`.
- Pruebas TCP desde Jump hacia Web en puertos 443, 3389 y 22.
- Inspección de las políticas `JUMP_TO_WEBSERVER_P4` y `JUMP_TO_WEB_DENY_OTHER` en la GUI.

La verificación de una restricción explícita SSH para STD requiere que la regla/ACL se muestre en el punto donde realmente transita ese tráfico y que se relacione con una prueba de denegación y su registro. La visibilidad del catálogo RemoteApp demuestra el control de publicación de aplicaciones; por sí sola no sustituye una prueba de política de red.

## Hito 8 — Persistencia y operación de contenedores

La topología se ejecuta sobre una GNS3 VM con un host de 16 GB de RAM. El orden de arranque recomendado es ISP/R1/switch, FortiGate, Web Server, Jump Server y finalmente Cliente FortiClient. El Jump Server se puede apagar después de las tomas que requieren RemoteApp.

Tras un cierre de GNS3, las sesiones VPN y algunos servicios de contenedor son estado temporal, mientras que las etiquetas de imágenes guardadas permanecen en la GNS3 VM si no fueron eliminadas. Primero se abre el proyecto existente y se arrancan los nodos a través de GNS3; solo después se ejecutan los scripts de auditoría/recuperación que correspondan.

## Relación con la entrega

- Video: https://youtu.be/XtP_YsM0tjs
- Evidencias: carpeta raíz `images/`, máximo diez PNG.
- Diagramas editables: `docs/diagrams/`.
- Scripts: `scripts/`.
- Configuraciones: `running-configs/`, exportadas desde los dispositivos de la instancia final y sanitizadas antes de publicarse.
