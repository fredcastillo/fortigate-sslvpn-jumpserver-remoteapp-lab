# 23. Procedimiento de inspección y configuración de FortiGate mediante GUI

## 23.1 Regla del laboratorio

La rúbrica exige que **la configuración y la demostración del FortiGate se realicen mediante GUI**. Los comandos de `running-configs/` son para recolectar evidencia y para comparar el estado, no para reemplazar el procedimiento visual. Las instrucciones de este documento describen las pantallas y los campos que deben revisarse; no solicitan pegar bloques de configuración CLI en el firewall.

## 23.2 Preparación y respaldo

Antes de alterar políticas:

1. Accede a la GUI por el método de administración definido en el proyecto.
2. Confirma el nombre del equipo y la versión en Dashboard/System Information.
3. Guarda un respaldo desde la sección de configuración/backup disponible en esa versión.
4. Guarda el proyecto GNS3 (`Ctrl+S`).
5. No edites varias reglas a la vez: inspecciona, modifica el requisito puntual, aplica y vuelve a comprobar.

## 23.3 Network → Interfaces

Verifica las interfaces que conectan a cada zona:

| Interfaz | Dirección | Zona |
|---|---|---|
| `port1` | `203.0.113.26/30` | WAN/ISP simulado; endpoint SSL-VPN por TCP/10443. |
| `port2` | `10.21.75.129/29` | Web LAN. |
| `port3` | `10.21.75.137/29` | Jump LAN. |

VLAN 10 no es una interfaz de FortiGate en esta topología: la LAN de usuarios termina en R1/Cisco, con gateway `10.21.75.1/25`. No crees una subinterfaz VLAN 10 en FortiGate por analogía con otra infraestructura; utiliza la topología real.

## 23.4 Policy & Objects → Addresses

Los siguientes objetos se utilizan por nombre en las reglas:

| Objeto | Tipo esperado | Dirección |
|---|---|---|
| `WEBSERVER` | Subnet/Host | `10.21.75.130/32` |
| `JUMP_SERVER` | Subnet/Host | `10.21.75.138/32` |
| `SSLVPN_TUNNEL_ADDR1` | Address Pool/objeto del pool SSL-VPN según el modelo | `10.212.134.200–10.212.134.210` documentado. |
| `VIP_HTTPS_WEBSERVER` | Virtual IP | `203.0.113.26:443` → `10.21.75.130:443`. |

Comprueba nombres, interfaces y subredes antes de reutilizar los objetos. No dupliques objetos equivalentes con nombres distintos solo para resolver una prueba puntual.

## 23.5 Policy & Objects → Services

El flujo Jump → Web necesita tres servicios de destino:

- HTTPS: TCP/443.
- RDP: TCP/3389.
- SSH: TCP/22.

Si se utiliza un grupo de servicios, sus miembros deben ser exclusivamente esos tres servicios. La política de denegación usa `ALL` para los mismos objetos de origen/destino del flujo Jump→Web.

## 23.6 VPN → SSL-VPN Settings y SSL-VPN Portals

Revisa visualmente:

1. Listener sobre `port1`, TCP/10443, según el diseño registrado.
2. Grupo autorizado `SSLVPN_USERS`.
3. Pool `SSLVPN_TUNNEL_ADDR1`.
4. Portal `REMOTE_ACCESS` mencionado en la configuración de referencia.
5. Split tunneling **Enabled based on policy destination**.
6. Asignación de grupo al portal correcto.

En ese modo, la ruta que recibe el cliente depende de los destinos que aplican a las políticas SSL-VPN. Para la topología actual, la ruta de interés es Jump (`10.21.75.138`); el acceso VPN directo al Web Server no debe autorizarse.

## 23.7 Firewall Policy: inventario del estado comunicado

Las reglas principales identificadas son:

| ID | Política | Interfaces | Parámetros clave |
|---:|---|---|---|
| 3 | `WEBSERVER_A_INTERNET` | `port2` → `port1` | `LAN_SERVIDOR` → `all`; servicio `ALL`; NAT enabled; salida auxiliar. |
| 2 | `WAN_to_WEBSERVER_HTTPS` | `port1` → `port2` vía VIP | HTTPS al `VIP_HTTPS_WEBSERVER`; posteriormente deshabilitada por GUI. |
| 4 | `SLVPN_to_WEBSERVER_SSH` | `ssl.root` → `port2` | SSH directo al Web Server; deshabilitada. |
| 5 | `JUMP_TO_WEBSERVER_P4` | `port3` → `port2` | `JUMP_SERVER` → `WEBSERVER`; HTTPS/RDP/SSH; NAT disabled; logging all. |
| 6 | `JUMP_SETUP_A_INTERNET` | `port3` → `port1` | `JUMP_SERVER` → `all`; DNS/HTTP/HTTPS; NAT enabled; logging all. |
| 7 | `SSLVPN_TO_JUMP_HTTPS` | `ssl.root` → `port3` | Pool VPN → `JUMP_SERVER`; HTTPS; grupo `SSLVPN_USERS`; logging all. |
| 8 | `SSLVPN_TO_JUMP_DNS` | `ssl.root` → `port3` | Pool VPN → `JUMP_SERVER`; DNS; grupo `SSLVPN_USERS`; logging all. |
| 9 | `JUMP_TO_WEB_DENY_OTHER` | `port3` → `port2` | `JUMP_SERVER` → `WEBSERVER`; servicio `ALL`; deny predeterminado; logging all. |

El estado de `WAN_to_WEBSERVER_HTTPS` fue actualizado en GUI después de la salida literal guardada. La captura en `running-configs/fortigate/captura-show-firewall-policy-previa-a-desactivar-wan.txt` es histórica y está titulada como anterior al cambio. `estado-final-politicas-confirmado.md` registra la confirmación posterior. Para una presentación de configuración final, exporta una nueva captura/salida sanitizada del estado actual.

## 23.8 Orden de evaluación

En **Policy & Objects → Firewall Policy**:

1. Comprueba `JUMP_TO_WEBSERVER_P4` con ACCEPT y los tres servicios.
2. Confirma que `JUMP_TO_WEB_DENY_OTHER` está debajo, con acción DENY y logging habilitado.
3. Confirma que NAT esté desactivado en el flujo Jump→Web.
4. Confirma que `SLVPN_to_WEBSERVER_SSH` está deshabilitada.
5. Confirma que `WAN_to_WEBSERVER_HTTPS` está deshabilitada y que el objeto VIP solo se conserva como objeto.
6. Comprueba el estado habilitado de las reglas SSLVPN→Jump y su grupo de usuarios.

No crees reglas nuevas si las reglas existentes ya expresan los requisitos y las pruebas lo demuestran. Primero inspecciona la lista completa y el orden.

## 23.9 Logs y correlación de pruebas

En **Log & Report → Forward Traffic**, correlaciona cada prueba usando:

- hora aproximada;
- IP de origen;
- IP de destino;
- protocolo/servicio;
- interfaz de entrada y salida;
- acción/policy ID;
- bytes/sesión si aparecen.

Un fallo TCP no basta para afirmar que una política específica bloqueó el tráfico. El log debe mostrar la regla coincidente o la denegación implícita. Del mismo modo, una prueba positiva desde Jump demuestra el flujo desde ese origen, no desde VLAN 10.
