# 00. Requisitos y trazabilidad

Este documento relaciona la rúbrica de la práctica con los elementos de la topología y las evidencias del repositorio. Las pruebas de red deben identificar siempre **origen, destino, servicio, resultado y punto desde el que se ejecutan**. Una aplicación publicada, un objeto o una política por sí solos no equivalen a una prueba de conectividad.

## Matriz de requisitos

| ID | Requisito de la práctica | Implementación | Evidencia asociada |
|---|---|---|---|
| R01 | FortiGate; su configuración y demostración por GUI | FortiGate-VM64-KVM, FortiOS 7.0.9 | Interfaces, SSL-VPN Monitor y Firewall Policy desde GUI; `../images/02-*`, `../images/07-*`. |
| R02 | VPN Client-to-Site que solo da acceso al Jump Server | SSL-VPN en `port1`; políticas `SSLVPN_TO_JUMP_HTTPS` / `SSLVPN_TO_JUMP_DNS`; split tunneling basado en destinos de política | `../images/03-vpn-rutas-cliente.png`; tabla de rutas en el cliente; políticas en GUI. |
| R03 | Equipo de red, preferiblemente Cisco | R1-CISCO / switch Cisco en la red de usuarios | `show vlan brief`, interfaces y configuración exportada. |
| R04 | ISP y direccionamiento WAN simulado | Dos enlaces `/30` en TEST-NET-3 | Interfaces de R1, ISP y FortiGate; `../images/02-*`. |
| R05 | Dos servidores separados en redes `/29` | Web `10.21.75.128/29`; Jump `10.21.75.136/29` | Plan de direccionamiento y diagramas. |
| R06 | Web Server para Sistema de Caja | WEB-SERVER Ubuntu 22.04.5 LTS, Apache HTTPS | Página/portal web y sockets de servicio; `../images/10-*`. |
| R07 | RDS RemoteApp y Microsoft Remote Desktop Web Client | Windows Server 2019, AD DS/DNS, `QuickSessionCollection`, RD Web Client publicado | `../images/04-*`, `../images/05-*`; comandos de auditoría RDS. |
| R08 | Dos usuarios, VLAN 10, `/25` y DHCP | VLAN 10 en el equipo Cisco; gateway R1 `10.21.75.1`; DHCP en la LAN de usuarios | `../images/08-*`, `../images/09-*`, binding DHCP actual. |
| R09 | STD solo ve Caja-Web | `GG-RemoteApp-Web` y catálogo de `user.std` | `../images/04-remoteapp-estandar.png`. |
| R10 | Restricción explícita de SSH para STD hacia servidores | Control explícito de SSH para STD en el punto donde realmente atraviesa el flujo de usuario (ACL/política correspondiente a la topología), con logging de la denegación; no debe atribuirse a una política de FortiGate si está configurado en R1/Cisco | Captura de la política/ACL de denegación y prueba desde el origen STD correspondiente. |
| R11 | PRIV ve Web, PuTTY y RDP | `GG-RemoteApp-Privileged`; catálogo de `user.priv` | `../images/05-remoteapp-privilegiado.png`. |
| R12 | Jump → Web solo HTTPS, RDP y SSH | `JUMP_TO_WEBSERVER_P4` permite TCP 443/3389/22; `JUMP_TO_WEB_DENY_OTHER` deniega el resto | `../images/06-*`, `../images/07-*`, logs y al menos una prueba de puerto no permitido. |
| R13 | Demostrar VPN, salto y controles | Cliente VPN, RD Web, políticas y pruebas positivas/negativas | Video, imágenes y registros relevantes. |
| R14 | Repositorio con README, documentación, imágenes, diagramas, scripts y running-configs | Esta estructura | Raíz del repositorio; `images/`; `docs/diagrams/`; `scripts/`; `running-configs/`. |
| R15 | Video ≤10 minutos, cara/voz/fecha/hora | Demostración de aproximadamente seis minutos | [Video demostrativo](https://youtu.be/XtP_YsM0tjs). |
| R16 | TXT con enlace del repositorio y video | `ENTREGA_FredCastillo_20252175_P4.txt` | Completar la URL definitiva de GitHub antes de entregar. |

## Evidencia esperada por tipo de requisito

- **Configuración:** captura de la GUI o exportación de la configuración real.
- **Conectividad permitida:** prueba ejecutada desde el origen correcto y con destino/puerto visible.
- **Conectividad denegada:** resultado fallido acompañado por la regla de denegación correspondiente y su log/hit cuando aplique.
- **Control por rol:** catálogo RemoteApp visible al iniciar sesión con cada usuario.
- **Entregables:** URL pública del repo, video publicado y TXT con ambos enlaces.

## Pautas de demostración

La administración y las modificaciones del FortiGate se realizan por GUI según la rúbrica. Los comandos CLI incluidos en el repositorio son principalmente para inspección, validación o exportación de datos; no sustituyen la demostración por GUI.


## Ubicación de capturas

Todas las capturas PNG se guardan en la carpeta **`images/` ubicada en la raíz del repositorio**, fuera de `docs/`. Las referencias desde los archivos de documentación usan `../images/archivo.png`; las referencias desde el README usan `images/archivo.png`. No debe crearse una segunda carpeta `docs/images/`.
