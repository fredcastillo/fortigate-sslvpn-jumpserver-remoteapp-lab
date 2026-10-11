# 04. FortiGate: interfaces, objetos y políticas

## Plataforma y principio operativo

- Appliance: `FortiGate-VM64-KVM`.
- Versión: FortiOS 7.0.9 build 0444.
- Administración de la práctica: GUI de FortiGate.
- Interfaces relevantes: `port1` (WAN/SSL-VPN), `port2` (Web LAN) y `port3` (Jump LAN).

El requisito de la práctica establece que la configuración y demostración del FortiGate se realicen mediante la GUI. Las salidas CLI `show firewall policy` y `show firewall vip` se conservan como consulta/exportación de evidencia; no representan el método de configuración utilizado en la demostración.

## Interfaces relevantes

| Interfaz | Dirección conocida | Conectividad |
|---|---|---|
| `port1` | `203.0.113.26/30` | Hacia router ISP `.25`; listener SSL-VPN en puerto TCP 10443 según el diseño del laboratorio. |
| `port2` | `10.21.75.129/29` | Gateway de Web LAN. |
| `port3` | `10.21.75.137/29` | Gateway de Jump LAN. |
| `ssl.root` | Interfaz lógica | Entrada de tráfico descifrado de SSL-VPN. |

VLAN 10 no se define como subinterfaz del FortiGate en esta topología: la LAN de usuarios está conectada al switch/Cisco R1 y su gateway es `10.21.75.1` en R1.

## Objetos de dirección

| Objeto | Dirección | Uso |
|---|---|---|
| `WEBSERVER` | `10.21.75.130/32` | Host destino en Web LAN. |
| `JUMP_SERVER` | `10.21.75.138/32` | Host destino de SSL-VPN y origen autorizado para acceder a Web. |
| `SSLVPN_TUNNEL_ADDR1` | Pool SSL-VPN configurado | Origen de los clientes remotos en las reglas del túnel. |
| `VIP_HTTPS_WEBSERVER` | `203.0.113.26:443` → `10.21.75.130:443` | Objeto VIP conservado; la política de publicación WAN fue deshabilitada. |

## Inventario de políticas de la práctica

| ID observado | Nombre | Entrada → salida | Origen → destino | Servicios | NAT | Estado y función |
|---:|---|---|---|---|---|---|
| 3 | `WEBSERVER_A_INTERNET` | `port2` → `port1` | `LAN_SERVIDOR` → `all` | `ALL` | ON | Salida de Web Server hacia Internet simulado; política auxiliar existente. |
| 2 | `WAN_to_WEBSERVER_HTTPS` | `port1` → `port2` | `all` → `VIP_HTTPS_WEBSERVER` | `HTTPS` | VIP/port forward | Deshabilitada después desde la GUI para retirar la publicación directa. |
| 4 | `SLVPN_to_WEBSERVER_SSH` | `ssl.root` → `port2` | `all` → `WEBSERVER` | `SSH` | No habilitado explícitamente | Deshabilitada para evitar SSH directo desde SSL-VPN al Web Server. Grupo `SSLVPN_USERS`. |
| 5 | `JUMP_TO_WEBSERVER_P4` | `port3` → `port2` | `JUMP_SERVER` → `WEBSERVER` | `HTTPS`, `RDP`, `SSH` | OFF | Permitir los tres servicios requeridos, con registro de sesiones. |
| 6 | `JUMP_SETUP_A_INTERNET` | `port3` → `port1` | `JUMP_SERVER` → `all` | `DNS`, `HTTP`, `HTTPS` | ON | Salida usada durante la preparación/instalación. |
| 7 | `SSLVPN_TO_JUMP_HTTPS` | `ssl.root` → `port3` | `SSLVPN_TUNNEL_ADDR1` → `JUMP_SERVER` | `HTTPS` | OFF salvo valor predeterminado | Permite el acceso HTTPS al Jump Server al grupo `SSLVPN_USERS`, con logging. |
| 8 | `SSLVPN_TO_JUMP_DNS` | `ssl.root` → `port3` | `SSLVPN_TUNNEL_ADDR1` → `JUMP_SERVER` | `DNS` | OFF salvo valor predeterminado | Regla DNS asociada a `SSLVPN_USERS`, con logging. |
| 9 | `JUMP_TO_WEB_DENY_OTHER` | `port3` → `port2` | `JUMP_SERVER` → `WEBSERVER` | `ALL` | OFF | Regla de cierre. La acción `deny` es la predeterminada de FortiOS cuando no se especifica `set action`. Debe quedar debajo de la regla permitida. |

## Orden y lógica

1. El permiso `JUMP_TO_WEBSERVER_P4` coincide con TCP/443, TCP/3389 y TCP/22.
2. La regla siguiente `JUMP_TO_WEB_DENY_OTHER` cierra el resto del tráfico entre el origen y el destino descritos.
3. NAT está deshabilitado para el tráfico Jump → Web, de modo que no se traduce el origen dentro de ese flujo.
4. El acceso SSH directo desde `ssl.root` a Web se mantiene deshabilitado.
5. El acceso HTTPS público a través del VIP se conserva como objeto, pero la política `WAN_to_WEBSERVER_HTTPS` fue deshabilitada en la GUI.

## Salida a Internet de servidores

`JUMP_SETUP_A_INTERNET` está limitada a DNS/HTTP/HTTPS y se utilizó durante la preparación. `WEBSERVER_A_INTERNET` aparece con servicio `ALL` y NAT en la captura compartida. La función de cada una debe entenderse en el contexto de la salida a Internet de los servidores y no como permisos entrantes hacia ellos.

## Dónde verificar en GUI

- **Network → Interfaces:** IP/máscara de `port1`, `port2`, `port3`.
- **VPN → SSL-VPN Settings / SSL-VPN Portals:** listener, grupo, portal, pool y split tunneling.
- **Policy & Objects → Addresses:** objetos `WEBSERVER`, `JUMP_SERVER`, pool y VIP relacionado.
- **Policy & Objects → Firewall Policy:** interfaces, origen, destino, servicio, estado, NAT, logging y orden.
- **Log & Report → Forward Traffic:** sesiones permitidas/denegadas que se correlacionen con las pruebas.

## Diagrama de matriz

![Matriz de acceso](diagrams/matriz-acceso.svg)
