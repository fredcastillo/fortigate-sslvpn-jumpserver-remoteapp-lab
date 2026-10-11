# 20. Decisiones de diseño y control de cambios

Este registro documenta las decisiones técnicas que definen la topología final. Sirve para que un lector entienda por qué existen dos redes de servidor, por qué el acceso VPN termina en Jump y por qué algunas políticas antiguas permanecen deshabilitadas o auxiliares.

## 20.1 VPN Client-to-Site

**Decisión:** SSL-VPN Client-to-Site termina en FortiGate. El cliente del laboratorio utiliza `lab-vpn`/OpenFortiVPN y recibe una dirección del pool `SSLVPN_TUNNEL_ADDR1`.

**Motivo:** el enunciado pide que el cliente acceda al Jump Server mediante una VPN remota. El objetivo no es establecer una VPN entre dos routers.

**Impacto:** la ruta del cliente al Jump debe usar la interfaz `ppp0`; la tabla de rutas se revisa junto con las políticas para confirmar el alcance real.

## 20.2 VLAN 10 en R1/Cisco

**Decisión:** VLAN 10 y su gateway `10.21.75.1/25` residen en el dominio de usuarios atendido por R1/Cisco. FortiGate no declara una interfaz VLAN 10 en esta instancia.

**Motivo:** el tráfico de usuario llega a FortiGate a través de R1, el router ISP simulado y `port1`; las LAN de servidores están conectadas por `port2` y `port3`.

**Impacto:** las políticas FortiGate deben referirse a las interfaces del camino real del paquete. No debe configurarse una regla con una interfaz `VLAN10` inexistente en FortiGate.

## 20.3 Dos LAN de servidor /29

**Decisión:** Web y Jump utilizan subredes distintas: `10.21.75.128/29` y `10.21.75.136/29`.

**Motivo:** permitir que el firewall controle el tráfico entre los dos servidores y dar una LAN propia a cada uno.

**Impacto:** los gateways del servidor son `.129` y `.137`, respectivamente; las políticas Jump → Web atraviesan `port3` → `port2`.

## 20.4 Jump como punto de acceso remoto

**Decisión:** el navegador accede a RD Web en el Jump Server y las aplicaciones se publican por grupos de seguridad.

**Motivo:** el usuario estándar solo necesita Caja-Web, mientras que el privilegiado requiere, además, PuTTY y Remote Desktop Connection.

**Impacto:** el catálogo se valida con dos sesiones distintas; no debe asumirse el rol por la IP del cliente o por el nombre del equipo.

## 20.5 Permiso y denegación Jump → Web

**Decisión:** `JUMP_TO_WEBSERVER_P4` permite HTTPS/RDP/SSH con NAT deshabilitado; `JUMP_TO_WEB_DENY_OTHER` cierra los demás servicios para ese origen/destino.

**Motivo:** expresar el permiso mínimo explícitamente y evitar que la necesidad de tres servicios se convierta en una autorización general.

**Impacto:** el permiso debe evaluarse primero. La verificación completa incluye tres pruebas TCP positivas y al menos una prueba de un puerto no permitido correlacionada con el registro de firewall.

## 20.6 Retirada del acceso HTTPS directo por VIP

**Decisión:** el objeto VIP `VIP_HTTPS_WEBSERVER` se conserva, pero la política `WAN_to_WEBSERVER_HTTPS` se deshabilitó desde la GUI.

**Motivo:** el flujo de acceso previsto para la práctica es cliente VPN → Jump → aplicación, no una publicación WAN directa del servidor web que evite el Jump.

**Impacto:** conservar el objeto no habilita por sí solo el flujo; una política habilitada debe permitir el tráfico. La configuración final debe mostrar la regla WAN deshabilitada.

## 20.7 Salida de servidores a Internet

**Decisión:** `JUMP_SETUP_A_INTERNET` se mantuvo como política auxiliar para DNS/HTTP/HTTPS durante la preparación. `WEBSERVER_A_INTERNET` aparece en el inventario con `ALL` y NAT habilitado.

**Motivo:** permitir descargas y consultas de DNS mientras se terminaban los servicios. Las reglas son de salida y no deben confundirse con las reglas que autorizan tráfico entrante hacia los servidores.

**Impacto:** al cambiar el estado del laboratorio, vuelve a revisar la necesidad de salida y exporta el running-config final. Las políticas de salida no son parte de los tres servicios Jump → Web.

## 20.8 Contenedor de cliente con navegador gráfico

**Decisión:** se conservó una imagen local del cliente con Firefox y soporte de VNC, además de la imagen original anterior a los cambios gráficos.

**Etiquetas documentadas:**

- `forticlient-lite:7.2-fix3`
- `lab-backup/forticlient-original-before-vnc:20261009`
- `lab-backup/forticlient-firefox:checkpoint-20261009`
- `lab-backup/forticlient-vnc-firefox:20261009`

**Motivo:** contar con un navegador gráfico en el endpoint de prueba que establece SSL-VPN, y conservar una imagen recuperable si el contenedor se recrea.

**Impacto:** la sesión VPN es estado de ejecución y debe levantarse de nuevo tras reiniciar. La etiqueta de imagen debe verificarse en la GNS3 VM; un contenedor en estado `Created` no significa que sus servicios hayan arrancado.

## 20.9 Diez capturas con referencias estables

**Decisión:** la carpeta `images/` vive en la raíz del repositorio y contiene diez PNG con nombres estables.

**Motivo:** centralizar capturas y respetar el límite académico de no más de diez imágenes de evidencia.

**Impacto:** reemplazar el archivo conservando el nombre mantiene válidas las referencias del README y de la documentación. Los diagramas SVG en `docs/diagrams/` son recursos vectoriales distintos de las capturas.

## 20.10 Control de cambios

| Elemento | Estado documentado | Evidencia de referencia |
|---|---|---|
| Interfaces y direccionamiento | Datos de la topología final conocida | GUI FortiGate y plan de direccionamiento. |
| Políticas Jump → Web | Permiso y cierre en el orden acordado | GUI y captura `show firewall policy` compartida. |
| SSH directo desde SSL-VPN al Web | Política deshabilitada | Estado `disable` en la salida compartida. |
| HTTPS WAN al Web | Política deshabilitada después desde GUI | Confirmación del estudiante; el VIP sigue guardado. |
| Catálogos RemoteApp | Diferenciados por usuario | Sesiones de `user.std` y `user.priv` en RD Web. |
| Imagen de cliente gráfico | Etiquetas Docker conservadas localmente | `docker image inspect`/`docker image ls` en GNS3 VM. |

Antes de entregar, exporta la configuración final de cada dispositivo y registra cambios posteriores que alteren cualquiera de estos valores.
