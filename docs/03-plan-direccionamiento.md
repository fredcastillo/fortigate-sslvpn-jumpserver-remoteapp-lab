# 03. Plan de direccionamiento IP

El direccionamiento interno incorpora la matrícula `2025-2175` por medio de los segmentos `10.21.75.0` y las subredes asignadas a usuarios y servidores. Esta tabla resume las direcciones conocidas en las comprobaciones y la topología final documentada.

| Segmento | Red/prefijo | Hosts/gateway | Máscara decimal | Observación |
|---|---|---|---|---|
| VLAN 10 — usuarios | `10.21.75.0/25` | R1 `10.21.75.1`; cliente VPN `10.21.75.10`; Browser-PC utilizado `10.21.75.110` estático en una prueba | `255.255.255.128` | La asignación DHCP debe verificarse por usuario/end-device. El rango configurado en la topología base se documentó como `.10–.100`. |
| R1 ↔ ISP | `203.0.113.20/30` | R1 `203.0.113.21`; ISP `203.0.113.22` | `255.255.255.252` | Primer enlace WAN simulado. |
| ISP ↔ FortiGate | `203.0.113.24/30` | ISP `203.0.113.25`; FortiGate `port1` `203.0.113.26` | `255.255.255.252` | Enlace del lado servidor y endpoint VPN. |
| Web LAN | `10.21.75.128/29` | FortiGate `port2` `.129`; WEB-SERVER `.130` | `255.255.255.248` | Gateway `.129`. |
| Jump LAN | `10.21.75.136/29` | FortiGate `port3` `.137`; JUMP-SRV `.138` | `255.255.255.248` | Gateway `.137`. |
| Pool SSL-VPN | `SSLVPN_TUNNEL_ADDR1` | Pool documentado `10.212.134.200–10.212.134.210`; asignación observada `.200` | Según objeto de pool | Confirmar en la GUI del FortiGate. |

## Cálculo de los segmentos `/29`

Un `/29` contiene 8 direcciones: una de red, 6 direcciones host y una de broadcast.

- **Web LAN — `10.21.75.128/29`:** red `.128`; hosts `.129–.134`; broadcast `.135`.
- **Jump LAN — `10.21.75.136/29`:** red `.136`; hosts `.137–.142`; broadcast `.143`.

## Bloques WAN documentales

El rango `203.0.113.0/24` está reservado para documentación (TEST-NET-3), por lo que las dos redes `/30` se describen como enlaces de tránsito simulados dentro de GNS3 y no como direcciones públicas reales enrutables.

## DHCP de usuarios

La configuración de la LAN de usuarios se asocia a VLAN 10 con gateway R1 `.1`. El rango DHCP informado de la topología base era `10.21.75.10–10.21.75.100`. La documentación final de la práctica debe conservar la salida actual de `show ip dhcp binding` para demostrar qué dirección recibió cada endpoint; no deducir la identidad STD/PRIV solo por una IP si no está documentada la asociación.
