# 17. Modelo de seguridad, políticas y flujo de paquetes

## 17.1 Zonas y puntos de control

**Topología física de referencia:** `CLIENTE-FORTICLIENT` y `BROWSER-PC` → `Switch-A (VLAN 10)` → `R1-CISCO` → `Router-ISP` → `FortiGate port1`. Switch-A y R1 forman el segmento de usuarios; Router-ISP es el router de tránsito entre R1 y la WAN de FortiGate. Desde el firewall, `port2` conduce a la LAN de WEB-SERVER y `port3` conduce a la LAN de JUMP-SRV. El túnel SSL-VPN es un overlay que usa el underlay anterior para llegar al listener de `port1`; no sustituye ni elimina esos saltos físicos/lógicos.

| Zona | Punto de entrada al FortiGate | Función del control |
|---|---|---|
| WAN / ISP simulado | `port1` | Listener SSL-VPN, rutas de tránsito y tráfico que llegue desde los enlaces WAN. |
| SSL-VPN | `ssl.root` | Políticas del tráfico autenticado y descifrado del cliente remoto. |
| Web LAN | `port2` | Servicios del servidor `10.21.75.130`. |
| Jump LAN | `port3` | RD Web/RDS en `10.21.75.138` y conexiones iniciadas por Jump. |
| VLAN 10 / usuarios | Del lado R1/Cisco | Segmento de usuario detrás de R1; no es una interfaz FortiGate en la topología final. |

## 17.2 Recorrido de SSL-VPN

1. El cliente se conecta al listener de FortiGate por el enlace WAN simulado.
2. El cliente autenticado recibe una dirección del pool `SSLVPN_TUNNEL_ADDR1`; en las verificaciones se observó `10.212.134.200` en `ppp0`.
3. La política `SSLVPN_TO_JUMP_HTTPS` recibe tráfico por `ssl.root`, lo dirige por `port3` y limita el destino a `JUMP_SERVER` con servicio HTTPS para `SSLVPN_USERS`.
4. La política `SSLVPN_TO_JUMP_DNS` define el flujo DNS documentado hacia el destino configurado.
5. El acceso web del cliente se efectúa al portal RD Web del Jump Server.

El portal se alcanzó por la URL con IP:

```text
https://10.21.75.138/RDWeb/webclient/index.html
```

La URL FQDN documentada es `https://JUMP-SRV.jumpserver.lab/RDWeb/webclient/index.html`; su funcionamiento por nombre requiere que el cliente resuelva ese FQDN mediante DNS adecuado.

## 17.3 Split tunneling basado en política

El portal SSL-VPN utiliza el modo **Enabled based on policy destination** y el pool `SSLVPN_TUNNEL_ADDR1`. Con este modo, los destinos de las políticas SSL-VPN influyen en las rutas instaladas en el cliente. La validación observó:

```text
10.21.75.138 dev ppp0 src 10.212.134.200
10.21.75.130 via 10.21.75.1 dev eth0 src 10.21.75.10
```

La ruta decide por qué interfaz intenta salir el paquete; no autoriza por sí sola la conexión. La política de firewall y la disponibilidad del servicio siguen determinando el resultado.

## 17.4 Flujo Jump Server → Web Server

Origen: `JUMP_SERVER` (`10.21.75.138/32`).
Destino: `WEBSERVER` (`10.21.75.130/32`).

### Permiso específico — `JUMP_TO_WEBSERVER_P4`

- Incoming: `port3`.
- Outgoing: `port2`.
- Services: HTTPS, RDP y SSH.
- NAT: deshabilitado.
- Logging: `all`.

### Denegación de otros servicios — `JUMP_TO_WEB_DENY_OTHER`

- Incoming: `port3`.
- Outgoing: `port2`.
- Source: `JUMP_SERVER`.
- Destination: `WEBSERVER`.
- Service: `ALL`.
- La salida `show firewall policy` no incluye `set action deny` para esta regla; en FortiOS esa ausencia corresponde al valor predeterminado DENY.
- Debe estar situada debajo de `JUMP_TO_WEBSERVER_P4`.

Este patrón crea un permiso específico para los tres servicios requeridos y una regla de cierre para el resto. La evidencia de denegación se completa con una prueba de un puerto no permitido y el log/hit correspondiente.

## 17.5 Política SSL-VPN → Web Server SSH

`SLVPN_to_WEBSERVER_SSH` existía con origen `ssl.root`, destino `WEBSERVER`, servicio SSH y grupo `SSLVPN_USERS`. Se deshabilitó para retirar esa autorización directa desde el túnel hacia el servidor web. Esta regla deshabilitada no sustituye otros controles para tráfico que llegue a FortiGate por rutas físicas normales.

## 17.6 Publicación WAN HTTPS

El objeto `VIP_HTTPS_WEBSERVER` mapea:

- External IP: `203.0.113.26` en `port1`.
- External port: TCP/443.
- Mapped IP: `10.21.75.130`.
- Mapped port: TCP/443.

La política `WAN_to_WEBSERVER_HTTPS`, que utilizaba esa VIP, fue deshabilitada desde la GUI; el objeto VIP se conserva en la configuración. La distinción es importante: el objeto de traducción y la política que permite el tráfico son componentes distintos.

## 17.7 NAT y salida de servidores

- `JUMP_TO_WEBSERVER_P4`: NAT deshabilitado; preserva el origen del Jump para la comunicación interna.
- `JUMP_SETUP_A_INTERNET`: `port3` → `port1`, servicios DNS/HTTP/HTTPS, NAT habilitado; utilizada como salida auxiliar durante la preparación.
- `WEBSERVER_A_INTERNET`: `port2` → `port1`, servicio `ALL`, NAT habilitado en el inventario comunicado.

Estas políticas de salida no deben confundirse con permisos entrantes. La regla `WEBSERVER_A_INTERNET` es amplia en servicio y se debe analizar como flujo de salida, no presentarla como parte de la autorización Jump → Web.

## 17.8 Matriz de seguridad para la revisión

| Origen | Destino | Servicio | Evidencia adecuada |
|---|---|---|---|
| SSL-VPN autorizado | Jump | HTTPS | SSL-VPN Monitor + ruta `ppp0` + portal RD Web. |
| SSL-VPN | Web | SSH directo | Política directa de SSH deshabilitada; verificar también ruta/política real del flujo. |
| Jump | Web | 443, 3389, 22 | Pruebas TCP iniciadas desde Jump. |
| Jump | Web | Puerto no permitido (p. ej., TCP/80) | Prueba negativa + `JUMP_TO_WEB_DENY_OTHER`/log. |
| Usuario estándar | Jump/Web | SSH | Mostrar el control explícito implementado en el punto por donde circula ese tráfico y su denegación/log. No inferirlo únicamente de RemoteApp. |

## 17.9 GUI y registro

Para mostrar estas políticas, utiliza `Policy & Objects → Firewall Policy` y revisa interfaces, origen, destino, servicios, estado, NAT, logging y orden. Correlaciona la prueba con `Log & Report → Forward Traffic`. La CLI incluida en el repositorio está destinada a consulta y exportación, no a sustituir la configuración GUI requerida.
