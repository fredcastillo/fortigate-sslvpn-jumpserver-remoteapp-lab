# 24. Cisco IOS, router ISP, VLAN 10 y DHCP — guía de implementación y verificación

## 24.1 Responsabilidad de cada dispositivo

El requisito pide al menos un equipo de red, preferiblemente Cisco, y un ISP con direcciones públicas/simuladas. El diseño documentado usa Switch-A (IOSvL2), R1-CISCO y Router-ISP (IOSv), en ese orden entre endpoints y FortiGate. La cadena es `CLIENTE-FORTICLIENT + BROWSER-PC → Switch-A/VLAN 10 → R1-CISCO → Router-ISP → FortiGate port1`. No hay conexión directa entre la LAN de usuarios y Router-ISP ni entre esa LAN y FortiGate. En el otro lado del firewall, `port2` conecta a WEB-SERVER y `port3` a JUMP-SRV. La GUI de FortiGate se mantiene como método para configurar/demostrar el firewall; Cisco se inspecciona desde consola IOS.

| Dispositivo | Función | Dirección/interfaz conocida |
|---|---|---|
| Switch-A / Cisco IOSvL2 | VLAN 10 y puertos de acceso de usuarios | VLAN 10, denominada `LAN_Usuarios` en el inventario de referencia. |
| R1-CISCO | Gateway de usuarios y tránsito hacia ISP | `Gi2/0` `10.21.75.1/25`; `Gi1/0` `203.0.113.21/30`. |
| Router-ISP | Enrutamiento simulado entre R1, FortiGate y Cloud | `Gi1/0` `203.0.113.22/30`; `Gi2/0` `203.0.113.25/30`. |
| FortiGate port1 | WAN firewall y terminación SSL-VPN | `203.0.113.26/30`. |
| Router-ISP Fa0/0 | Salida de gestión/simulación por Cloud/VMnet8 | La instancia registró una concesión `192.168.133.169/24`, gateway `192.168.133.2`; es una red del hipervisor, no parte del direccionamiento académico `/30`. |

## 24.2 VLAN 10 y red de usuarios

- VLAN: `10`.
- Nombre documentado en el switch base: `LAN_Usuarios`.
- Red: `10.21.75.0/25`.
- Máscara: `255.255.255.128`.
- Gateway en R1: `10.21.75.1`.
- Rango DHCP documentado en la configuración de referencia: `10.21.75.10–10.21.75.100`.
- CLIENTE-FORTICLIENT se observó con `10.21.75.10/25` entregada por DHCP en el entorno de referencia. Browser-PC usó `10.21.75.110/25` estática en una instancia.

La rúbrica requiere dos usuarios finales en VLAN 10 con DHCP. En la evidencia final, identifica cada endpoint y correlaciona su IP/MAC con el lease DHCP real. No concluyas que ambos usuarios cumplen DHCP a partir de una sola concesión.

## 24.3 Switch: VLAN y puertos de acceso

Comandos de inspección en modo EXEC privilegiado:

```text
show vlan brief
show interfaces status
show interfaces trunk
show ip interface brief
show running-config
```

Verifica que VLAN 10 exista, que los puertos usados por los endpoints sean access VLAN 10 y que los cables virtuales de GNS3 coincidan con la topología que aparece en el diagrama. La configuración de referencia mostró `Gi0/0`, `Gi0/1` y `Gi0/2` en access VLAN 10; el running-config final del nodo P4 debe confirmar el estado actual.

## 24.4 R1-CISCO: gateway y DHCP

Comandos de solo lectura:

```text
show ip interface brief
show ip route
show ip dhcp pool
show ip dhcp binding
show running-config | section dhcp
show running-config | section interface
show running-config | include ip nat|access-list|ip route
```

La comprobación de DHCP debe demostrar:

1. Pool/scope asociado a la LAN `10.21.75.0/25`.
2. Gateway entregado `10.21.75.1`.
3. Una concesión por endpoint relevante, con dirección e identidad/MAC.
4. Ausencia de leases duplicados o direcciones estáticas no documentadas dentro del pool.
5. Si existe NAT, el efecto sobre la IP origen de los usuarios al atravesar el ISP hacia FortiGate.

La regla SSH por usuario estándar debe ubicarse en el punto real que observa el tráfico de ese usuario. No asumas que FortiGate ve `10.21.75.10` si R1 traduce el origen; comprueba el camino y las exclusiones de NAT en la configuración real. Esta es una decisión de ubicación de política.

## 24.5 Router-ISP y direccionamiento WAN

Comandos de inspección:

```text
show ip interface brief
show ip route
show running-config
```

Los enlaces lógicos registrados son:

- R1 ↔ ISP: `203.0.113.20/30`, R1 `.21`, ISP `.22`.
- ISP ↔ FortiGate: `203.0.113.24/30`, ISP `.25`, FortiGate `.26`.

`203.0.113.0/24` es TEST-NET-3, reservado para documentación. En GNS3 cumple el papel de direccionamiento WAN simulado y no se debe presentar como una asignación pública real de Internet.

El enlace del Router-ISP a Cloud/VMnet8 usa una red de la infraestructura VMware. Esa red resuelve la conectividad del hipervisor; no debe confundirse con los dos enlaces `/30` del diagrama académico.

