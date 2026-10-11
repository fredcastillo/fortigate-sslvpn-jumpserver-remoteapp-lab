# 22. Flujo de paquetes, rutas y límites entre zonas

## 22.1 Propósito de este capítulo

Este capítulo sigue el tráfico por la topología real para evitar un error común: asumir que un equipo está conectado directamente a una interfaz porque pertenece a una determinada subred. La cadena física/lógica es **CLIENTE-FORTICLIENT y BROWSER-PC → Switch-A (VLAN 10) → R1-CISCO → Router-ISP → FortiGate port1**. R1 es el gateway de usuario; Router-ISP se encuentra entre R1 y la WAN del firewall. FortiGate tiene sus LAN de servidores separadas: `port2` → WEB-SERVER y `port3` → JUMP-SRV. El cliente SSL-VPN utiliza el underlay completo para alcanzar el listener de `port1`; después de descifrar el túnel, los paquetes interiores dirigidos al Jump se procesan por `ssl.root` y se enrutan a través de `port3`.

La lectura correcta siempre combina cuatro elementos:

1. Ruta elegida por el sistema operativo de origen.
2. Interfaz de entrada de FortiGate después de descifrar, o interfaz WAN si es tráfico exterior.
3. Política de firewall que coincide con origen, destino y servicio.
4. Ruta de retorno y servicio realmente escuchando en destino.

Una ruta por `ppp0` no es una autorización de firewall. Del mismo modo, un `Test-NetConnection` satisfactorio confirma una apertura TCP desde ese origen, no la disponibilidad funcional de la aplicación de extremo a extremo.

## 22.2 Underlay: cómo llega el cliente al endpoint SSL-VPN

| Orden | Dispositivo/interfaz | Dirección conocida | Función |
|---:|---|---|---|
| 1 | CLIENTE-FORTICLIENT `eth0` | `10.21.75.10/25` observada | Endpoint de la VLAN 10 que origina el túnel. |
| 1b | BROWSER-PC | `10.21.75.110/25` estática en la instancia de referencia | Segundo endpoint de la misma LAN; no sustituye al cliente FortiClient. |
| 2 | Switch-A | VLAN 10 | Conecta ambos endpoints y enlaza con R1-CISCO. |
| 3 | R1-CISCO `Gi2/0` | `10.21.75.1/25` | Gateway de la LAN de usuarios y DHCP/routing. |
| 4 | R1-CISCO `Gi1/0` | `203.0.113.21/30` | Extremo R1 del primer enlace WAN simulado. |
| 5 | Router-ISP `Gi1/0` | `203.0.113.22/30` | Par de R1 en `203.0.113.20/30`. |
| 6 | Router-ISP `Gi2/0` | `203.0.113.25/30` | Extremo ISP del segundo enlace WAN simulado. |
| 7 | FortiGate `port1` | `203.0.113.26/30` | Listener SSL-VPN por TCP/10443. |

El recorrido de red hasta el listener es **endpoint → Switch-A → R1-CISCO → Router-ISP → FortiGate `port1`**. La conexión cliente/Firewall que muestra el túnel es una representación lógica del overlay, no un enlace físico que salte el switch, R1 o ISP.

Los bloques `203.0.113.20/30` y `203.0.113.24/30` pertenecen al bloque TEST-NET-3 reservado para documentación. Se emplean para simular enlaces WAN dentro de GNS3; no deben describirse como direcciones reales asignadas por un ISP comercial.

## 22.3 Overlay: acceso SSL-VPN al Jump Server

Durante una sesión se observó la dirección `10.212.134.200` en la interfaz `ppp0`. La utilidad de conexión del contenedor del laboratorio se ejecuta de manera interactiva con:

```bash
lab-vpn connect
```

La terminal que mantiene ese proceso debe permanecer abierta. Una vez establecido el túnel, el kernel muestra la ruta hacia `10.21.75.138` por `ppp0`. FortiGate recibe el tráfico exterior por `port1`, descifra la sesión y procesa el paquete interior por la interfaz lógica `ssl.root`; la política `SSLVPN_TO_JUMP_HTTPS` lo dirige hacia `port3`, destino `JUMP_SERVER` y servicio HTTPS.

```text
CLIENTE-FORTICLIENT 10.21.75.10/25
  └─ underlay: Switch-A (VLAN 10) → R1-CISCO (10.21.75.1)
                → Router-ISP (.22/.25) → FortiGate port1 (.26:10443)

Después de establecer el túnel:
  overlay: 10.212.134.200 → ppp0 → SSL-VPN / ssl.root
                                         │ política HTTPS
                                         ▼
                                  FortiGate port3
                                         │
                                         ▼
                                  JUMP-SRV .138/29
```

El DNS por SSL-VPN se representa en la política `SSLVPN_TO_JUMP_DNS`, con destino `JUMP_SERVER`. Como el DNS interno pertenece al entorno de Active Directory, debe distinguirse la resolución del nombre del permiso HTTPS: una regla DNS solo ayuda si el servidor destino realmente presta DNS y el cliente está configurado para consultarlo.

## 22.4 Flujo Jump Server → Web Server

```text
JUMP-SRV 10.21.75.138/29
  gateway 10.21.75.137
       │
       ▼
FortiGate port3 → policy evaluation → port2
       │     ALLOW TCP/443, TCP/3389, TCP/22
       │     NAT disabled
       │
       ├── HTTPS TCP/443 ─┐
       ├── RDP   TCP/3389 ├──► WEB-SERVER 10.21.75.130/29
       └── SSH   TCP/22 ──┘     gateway 10.21.75.129

Cualquier otro servicio entre ese origen/destino
queda sujeto a JUMP_TO_WEB_DENY_OTHER.
```

La política `JUMP_TO_WEBSERVER_P4` utiliza `port3` como interfaz de entrada, `port2` como salida, `JUMP_SERVER` como origen y `WEBSERVER` como destino. Los servicios permitidos son HTTPS, RDP y SSH. NAT está deshabilitado para mantener el origen identificable en el Web Server y en los logs. La ruta de retorno de Web vuelve a su gateway `10.21.75.129`.

`JUMP_TO_WEB_DENY_OTHER` usa el mismo par de interfaces y objetos, con servicio `ALL` y acción de denegación. Debe estar debajo de la regla de permiso. Si la consulta `show firewall policy` no imprime `set action deny`, FortiOS puede estar usando la acción predeterminada; confirma la acción y el orden en la GUI, tal como exige la práctica.

## 22.5 Ruta normal del cliente hacia Web

Durante la verificación, el cliente mostraba esta ruta:

```text
10.21.75.130 via 10.21.75.1 dev eth0 src 10.21.75.10
```

Eso significa que la tabla de rutas no está enviando `.130` dentro de `ppp0`; el tráfico de destino toma el camino normal de usuario: `CLIENTE-FORTICLIENT → Switch-A → R1-CISCO → Router-ISP → FortiGate port1`. La ruta por sí sola no demuestra que el flujo se permita: el paquete deberá cruzar R1/ISP y llegar a `port1` de FortiGate, donde necesita una política válida. La política pública `WAN_to_WEBSERVER_HTTPS` se deshabilitó desde GUI y el objeto VIP quedó conservado. La política SSH directo de `ssl.root` al Web Server también se encuentra deshabilitada.

## 22.6 NAT y visibilidad de la identidad del origen

Hay dos contextos distintos:

- **Jump → Web:** NAT deshabilitado en `JUMP_TO_WEBSERVER_P4`; Web puede observar el origen Jump, si las rutas de retorno siguen el gateway correcto.
- **Jump → Internet:** `JUMP_SETUP_A_INTERNET` tuvo NAT habilitado para permitir salida auxiliar durante preparación.
- **Web → Internet:** `WEBSERVER_A_INTERNET` aparecía con destino `all`, servicio `ALL` y NAT habilitado en la salida compartida. Esta es una regla de salida; no es equivalente a una autorización entrante. La instancia final debe conservar el inventario actualizado de esa regla.
- **Usuarios → FortiGate:** el tráfico de usuarios cruza Switch-A, R1-CISCO e ISP antes de llegar a `port1`; cualquier política explícita por usuario/IP depende de si R1 preserva o traduce el origen para ese flujo. No se debe suponer que FortiGate tiene una interfaz conectada directamente a VLAN 10.

## 22.7 Comandos de lectura para trazar rutas

En CLIENTE-FORTICLIENT, después de conectar la VPN:

```bash
ip -br addr show ppp0
ip route get 10.21.75.138
ip route get 10.21.75.130
ip route show dev ppp0
```

En WEB-SERVER:

```bash
ip -br addr
ip route
```

En JUMP-SRV:

```powershell
Get-NetIPAddress -AddressFamily IPv4 | Format-Table IPAddress,PrefixLength,InterfaceAlias -AutoSize
Get-NetRoute -AddressFamily IPv4 | Sort-Object DestinationPrefix | Format-Table DestinationPrefix,NextHop,InterfaceAlias,RouteMetric -AutoSize
```

Para la GUI de FortiGate, correlaciona las consultas con **Network → Interfaces**, **VPN → SSL-VPN Settings/Monitor**, **Policy & Objects → Firewall Policy** y **Log & Report → Forward Traffic**.
