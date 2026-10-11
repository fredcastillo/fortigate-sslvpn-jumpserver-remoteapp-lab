# 02. Arquitectura y topología

## Topologia 
![Topología](../images/01-topologia-general.png)

![Topología lógica](diagrams/topologia-logica.svg)

La topología debe leerse de izquierda a derecha en el tramo de usuarios/WAN y después desde las interfaces LAN del FortiGate hacia cada servidor. **La LAN de usuarios no está conectada directamente al Router-ISP ni al FortiGate.**

```text
CLIENTE-FORTICLIENT ─┐
                     ├─ Switch-A (VLAN 10) ─ R1-CISCO ───────── Router-ISP ───────── FortiGate port1
BROWSER-PC ──────────┘                        LAN: 10.21.75.1/25  Gi1/0: .21/30      Gi1/0: .22/30
                                                                    Gi2/0: .25/30 ─ port1: .26/30

FortiGate port2: 10.21.75.129/29 ── WEB-SERVER: 10.21.75.130/29
FortiGate port3: 10.21.75.137/29 ── JUMP-SRV:   10.21.75.138/29
```

La línea discontinua del diagrama representa el **overlay SSL-VPN** que se origina en CLIENTE-FORTICLIENT y termina en la WAN de FortiGate por TCP/10443. No representa un cable directo entre el cliente y el firewall: el transporte del túnel atraviesa Switch-A, R1-CISCO y Router-ISP.

## Componentes y enlaces

| Nodo/zona | Conexión y función | Dirección o dato documentado |
|---|---|---|
| CLIENTE-FORTICLIENT | Endpoint en la LAN; inicia la sesión SSL-VPN | `10.21.75.10/25` observada; `10.212.134.200` observada en `ppp0` durante una sesión. |
| BROWSER-PC | Endpoint de la misma LAN de usuarios; navegación y acceso GUI | `10.21.75.110/25` estática en la instancia de referencia; confirmar el estado actual. |
| Switch-A | Conecta ambos endpoints de usuario y enlaza con la interfaz LAN de R1-CISCO | Capa 2, VLAN 10 (`LAN_Usuarios`). |
| R1-CISCO | Gateway de usuarios; enlaza Switch-A con Router-ISP | LAN `10.21.75.1/25`; WAN `203.0.113.21/30`. |
| Router-ISP | Tránsito entre R1-CISCO y FortiGate | Lado R1 `203.0.113.22/30`; lado FortiGate `203.0.113.25/30`. |
| FortiGate `port1` | Interfaz WAN conectada a Router-ISP; termina SSL-VPN | `203.0.113.26/30`; listener SSL-VPN documentado en TCP/10443. |
| FortiGate `port2` | Gateway de la LAN exclusiva de Web Server | `10.21.75.129/29`. |
| WEB-SERVER | Servidor web/Sistema de Caja, conectado a `port2` | `10.21.75.130/29`; Ubuntu 22.04.5 LTS. |
| FortiGate `port3` | Gateway de la LAN exclusiva de Jump Server | `10.21.75.137/29`. |
| JUMP-SRV | Servidor de salto conectado a `port3`; AD DS/DNS, RDS, RD Web y RemoteApp | `10.21.75.138/29`; dominio `jumpserver.lab`. |

## Diagrama de flujo de seguridad

![Flujo de seguridad](diagrams/flujo-seguridad.svg)

1. CLIENTE-FORTICLIENT envía el túnel por su LAN de usuario; el underlay pasa por **Switch-A → R1-CISCO → Router-ISP → FortiGate `port1`**.
2. FortiGate autentica y descifra la sesión. El tráfico interior entra por `ssl.root`.
3. `SSLVPN_TO_JUMP_HTTPS` permite el HTTPS autorizado hacia `JUMP_SERVER` por `port3`; la regla DNS asociada solo es útil si el destino DNS configurado presta ese servicio.
4. Jump Server alcanza Web Server cruzando FortiGate de `port3` a `port2` mediante `JUMP_TO_WEBSERVER_P4` para HTTPS, RDP y SSH.
5. `JUMP_TO_WEB_DENY_OTHER`, ubicada después del permiso específico, deniega los demás servicios entre Jump y Web.

## Zonas de seguridad

### Usuarios

Red `10.21.75.0/25`, VLAN 10 en Switch-A y gateway `10.21.75.1` en R1-CISCO. CLIENTE-FORTICLIENT y BROWSER-PC son endpoints distintos que comparten la LAN de usuarios. La pertenencia a VLAN se comprueba en el switch y el gateway/DHCP en R1; FortiGate no tiene una interfaz VLAN 10 en este diseño.

### Tránsito WAN simulado

- R1-CISCO ↔ Router-ISP: `203.0.113.20/30`, R1 `.21` e ISP `.22`.
- Router-ISP ↔ FortiGate `port1`: `203.0.113.24/30`, ISP `.25` y FortiGate `.26`.

Las direcciones pertenecen al bloque TEST-NET-3 reservado para documentación; dentro de GNS3 representan enlaces WAN simulados, no una asignación pública de un ISP comercial.

### Servidor web

Red `10.21.75.128/29`. La interfaz FortiGate `port2` utiliza `.129`, y WEB-SERVER utiliza `.130`.

### Jump Server

Red `10.21.75.136/29`. La interfaz FortiGate `port3` utiliza `.137`, y JUMP-SRV utiliza `.138`.
