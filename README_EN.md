# FortiGate SSL-VPN, Jump Server & Role-Based RemoteApp

<p align="center"><a href="https://youtu.be/XtP_YsM0tjs"><img src="https://img.youtube.com/vi/XtP_YsM0tjs/maxresdefault.jpg" alt="Watch the lab demo" width="900"></a></p>

**Network Security Lab · GNS3 · FortiOS 7.0.9 · Cisco IOS · RDS/RemoteApp**

This GNS3 lab demonstrates controlled remote access through FortiGate SSL-VPN, a Windows Jump Server, and role-based Remote Desktop Services/RemoteApp. User, web-server and jump-server networks are separated. FortiGate policies constrain VPN access to the Jump Server and limit traffic from Jump to Web to HTTPS, RDP and SSH.

**Physical/logical path:** `CLIENTE-FORTICLIENT` and `BROWSER-PC` → `Switch-A` (VLAN 10) → `R1-CISCO` → `Router-ISP` → FortiGate `port1`. R1 is the user gateway (`10.21.75.1/25`); the ISP router provides the two simulated WAN links. The user LAN is not connected directly to the ISP or FortiGate. On the protected side, FortiGate `port2` connects to `WEB-SERVER` (`10.21.75.130/29`) and `port3` connects to `JUMP-SRV` (`10.21.75.138/29`). The dashed VPN path in the diagram is an SSL-VPN overlay carried over the physical/logical underlay, not a direct cable.

**Video:** [YouTube demonstration](https://youtu.be/XtP_YsM0tjs)

## Security goals

- Configure and inspect FortiGate interfaces, routes and firewall policies through its GUI.
- Establish client-to-site SSL-VPN access.
- Route the authorized VPN destination through the Jump Server rather than granting direct VPN access to the web server.
- Permit only TCP/443, TCP/3389 and TCP/22 from Jump Server to Web Server, denying other services between those segments.
- Publish `Caja-Web` to the standard user and `Caja-Web`, PuTTY and Remote Desktop Connection to the privileged user.
- Document addressing, access flows, verification commands, screenshots and configuration-collection procedures.

## Architecture

![Logical topology](docs/diagrams/topologia-logica.svg)

## Main components

| Component | Function | Known settings |
|---|---|---|
| GNS3 / GNS3 VM | Virtual topology and Docker/VM nodes | Start nodes gradually to control resource use. |
| FortiGate-VM64-KVM | Firewall, SSL-VPN, policies | FortiOS 7.0.9 build 0444; GUI is the required configuration/demo method. |
| Cisco R1 / access switch | User network and VLAN 10 | User gateway `10.21.75.1/25`. |
| ISP router | Simulated WAN transit | Uses documentation-only TEST-NET ranges inside GNS3. |
| CLIENTE-FORTICLIENT | Linux VPN client | Observed VPN address `10.212.134.200` on `ppp0`. |
| JUMP-SRV | Bastion, AD DS/DNS, RDS/RemoteApp | `10.21.75.138/29`; domain `jumpserver.lab`; collection `QuickSessionCollection`. |
| WEB-SERVER | Web/Caja server and service-test target | Ubuntu 22.04.5 LTS; `10.21.75.130/29`; HTTPS, SSH and XRDP listeners observed. |

## Addressing reference

| Zone | Network/prefix | Known addresses | Purpose |
|---|---|---|---|
| User VLAN 10 | `10.21.75.0/25` | R1 `10.21.75.1`; FortiClient client IP observed `10.21.75.10`; Browser-PC previously `10.21.75.110/25` static | User LAN. DHCP range `.10–.100` was documented in the base lab; verify current leases for each endpoint. |
| R1 ↔ ISP | `203.0.113.20/30` | R1 `.21`; ISP `.22` | Simulated WAN hop. |
| ISP ↔ FortiGate | `203.0.113.24/30` | ISP `.25`; FortiGate port1 `.26` | Simulated WAN hop and SSL-VPN endpoint. |
| Web LAN | `10.21.75.128/29` | FortiGate port2 `.129`; Web `.130` | Web app and controlled target services. |
| Jump LAN | `10.21.75.136/29` | FortiGate port3 `.137`; Jump `.138` | RD Web/RemoteApp and managed access point. |
| SSL-VPN pool | FortiGate configured pool | Client IP `.200` observed | Remote session addressing. |

`203.0.113.0/24` is TEST-NET-3, reserved for documentation. It represents a simulated ISP link here, not a real publicly routed allocation.

## Key policies

| Policy | Flow | Service/function | Confirmed status |
|---|---|---|---|
| `SSLVPN_TO_JUMP_HTTPS` | `ssl.root` → `port3` | HTTPS to `JUMP_SERVER`, group `SSLVPN_USERS` | Enabled. |
| `SSLVPN_TO_JUMP_DNS` | `ssl.root` → `port3` | DNS to `JUMP_SERVER` | Enabled. |
| `SLVPN_to_WEBSERVER_SSH` | `ssl.root` → `port2` | Direct SSL-VPN SSH to Web | Disabled. |
| `JUMP_TO_WEBSERVER_P4` | `port3` → `port2` | HTTPS, RDP, SSH; NAT off; session logging | Enabled. |
| `JUMP_TO_WEB_DENY_OTHER` | `port3` → `port2` | Deny remaining services | Enabled below the allow rule; default action is deny. |
| `JUMP_SETUP_A_INTERNET` | `port3` → `port1` | DNS, HTTP, HTTPS for preparation | Enabled in the supplied final state; NAT on. |
| `WEBSERVER_A_INTERNET` | `port2` → `port1` | Web-server egress | Existing supporting policy. |
| `WAN_to_WEBSERVER_HTTPS` | `port1` → `port2` via VIP | Public HTTPS publication | Disabled in the GUI; the VIP object is retained. |

## RemoteApp by role

| Account | Published catalog | Group association |
|---|---|---|
| `user.std` | `Caja-Web` only | `GG-RemoteApp-Web` |
| `user.priv` | `Caja-Web`, PuTTY, Remote Desktop Connection | `GG-RemoteApp-Web` and `GG-RemoteApp-Privileged` |

The RDS collection is `QuickSessionCollection`. RD Web Client URL: `https://JUMP-SRV.jumpserver.lab/RDWeb/webclient/index.html`. The IP-based URL used during the demonstration was `https://10.21.75.138/RDWeb/webclient/index.html`.

## Repository layout

- [`docs/`](docs/): technical documentation by topic and requirements traceability.
- [`images/`](images/): root-level folder containing ten PNG screenshot slots. Replace the placeholders with real screenshots without changing names.
- [`docs/diagrams/`](docs/diagrams/): editable architecture, flow and access-matrix SVGs.
- [`scripts/`](scripts/): checks, recovery utilities and configuration-collection guides.
- [`running-configs/`](running-configs/): organized export folders; includes the shared FortiGate policy capture and final-state notes.
- [`README.md`](README.md): primary Spanish documentation.

## Evidence images — maximum 10

| # | Evidence | File | Suggested video time |
|---:|---|---|---:|
| 1 | Full GNS3 topology | [`images/01-topologia-general.png`](images/01-topologia-general.png) | 00:15 |
| 2 | FortiGate interfaces | [`images/02-fortigate-interfaces.png`](images/02-fortigate-interfaces.png) | 00:30 |
| 3 | VPN and client routes | [`images/03-vpn-rutas-cliente.png`](images/03-vpn-rutas-cliente.png) | 00:48 |
| 4 | Standard RemoteApp catalog | [`images/04-remoteapp-estandar.png`](images/04-remoteapp-estandar.png) | 01:15 |
| 5 | Privileged RemoteApp catalog | [`images/05-remoteapp-privilegiado.png`](images/05-remoteapp-privilegiado.png) | 01:42 |
| 6 | Jump-to-Web TCP checks | [`images/06-pruebas-jump-web.png`](images/06-pruebas-jump-web.png) | 02:10 |
| 7 | FortiGate policies | [`images/07-politicas-firewall.png`](images/07-politicas-firewall.png) | 02:50 |
| 8 | Cisco VLAN 10 | [`images/08-vlan-usuarios.png`](images/08-vlan-usuarios.png) | 03:50 |
| 9 | User DHCP leases | [`images/09-dhcp-usuarios.png`](images/09-dhcp-usuarios.png) | 04:10 |
| 10 | Web server listeners | [`images/10-servicios-webserver.png`](images/10-servicios-webserver.png) | 04:55 |

---

## Verification examples

From JUMP-SRV (PowerShell):

```powershell
Test-NetConnection 10.21.75.130 -Port 443
Test-NetConnection 10.21.75.130 -Port 3389
Test-NetConnection 10.21.75.130 -Port 22
```

From the Linux VPN client after connecting:

```bash
lab-vpn connect
ip -br addr show ppp0
ip route get 10.21.75.138
ip route get 10.21.75.130
```

TCP success proves connectivity to a port from that source; it does not by itself prove the entire application works or that the firewall policy is correct. Combine tests with FortiGate GUI policy review and logs.

## Configuration exports and safe publication

The repository includes the FortiGate policy output shared during the lab and a separate final-state inventory incorporating the later GUI confirmation that `WAN_to_WEBSERVER_HTTPS` was disabled. The final complete exports for the routers, switch and both servers should be obtained from the actual running devices and placed in `running-configs/` before final submission.

Sanitize passwords, PSKs, private keys, tokens, sensitive hashes and other authentication material. Never commit unreviewed binary backups.

---

## Technical documentation index

- [Requirements traceability](docs/00-requisitos-y-trazabilidad.md)
- [Purpose and scope](docs/01-proposito-y-alcance.md)
- [Architecture and topology](docs/02-arquitectura-y-topologia.md)
- [IP addressing plan](docs/03-plan-direccionamiento.md)
- [FortiGate policies](docs/04-fortigate-y-politicas.md)
- [SSL-VPN and routes](docs/05-ssl-vpn-y-rutas.md)
- [Jump Server, AD DS, RDS and RemoteApp](docs/06-jump-rds-remoteapp.md)
- [Web Server](docs/07-web-server.md)
- [Cisco, ISP, VLAN and DHCP](docs/08-cisco-isp-vlan-dhcp.md)
- [Verification tests](docs/09-pruebas-y-resultados.md)
- [Demonstration runbook](docs/10-procedimiento-de-demostracion.md)
- [Operation and recovery](docs/11-recuperacion-y-operacion.md)
- [Running-config exports](docs/12-running-configs.md)
- [Images and evidence](docs/13-imagenes-y-evidencia.md)
- [Submission and publication](docs/14-entregables-y-publicacion.md)
- [Glossary](docs/15-glosario.md)
- [Implementation details](docs/16-implementacion-y-componentes.md)
- [Security model and traffic flows](docs/17-modelo-de-seguridad-y-flujos.md)
- [RD Web Client and RDS roles](docs/18-rds-webclient-y-roles.md)
- [Command catalog](docs/19-catalogo-de-comandos.md)
- [Design decisions](docs/20-decisiones-de-diseno-y-control-de-cambios.md)
- [Implementation record](docs/21-bitacora-de-implementacion.md)
- [Packet flow and routing](docs/22-flujo-de-paquetes-y-enrutamiento.md)
- [FortiGate GUI inspection procedure](docs/23-procedimiento-fortigate-gui.md)
- [Cisco, ISP, VLAN 10 and DHCP details](docs/24-cisco-isp-vlan-dhcp-detallado.md)
- [AD DS, DNS, RDS and RemoteApp deployment](docs/25-implementacion-rds-ad-dns-remoteapp.md)
- [Full acceptance-test matrix](docs/26-matriz-completa-de-pruebas.md)
- [Implementation milestones](docs/27-implementacion-por-hitos.md)
- [Submission and publishing model](docs/28-modelo-de-entrega-y-publicacion.md)
- [GNS3 client persistence and startup](docs/29-persistencia-y-arranque-de-clientes.md)
- [SSH control and role separation](docs/30-control-de-ssh-y-separacion-de-roles.md)

---
## Academic information

- **Student:** Fred Sneyder Castillo Apolinar
- **Student ID:** 2025-2175
- **Program:** Information Security Technologist
- **Institution:** ITLA

---

## License

Educational lab. See [`LICENSE`](LICENSE). Use scripts only on systems and networks you own or are authorized to administer.
