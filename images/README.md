# Evidencias visuales — carpeta raíz

**Esta carpeta debe permanecer directamente en la raíz del repositorio, al mismo nivel que `README.md` y `docs/`. No la muevas dentro de `docs/`.**

Contiene diez marcadores PNG con nombres estables. Reemplaza cada marcador por una captura real del video y conserva exactamente el nombre. El README raíz enlaza a `images/...`; los documentos dentro de `docs/` enlazan a `../images/...`.

## Inventario

1. `01-topologia-general.png` — GNS3 con la topología completa y los enlaces correctos: CLIENTE-FORTICLIENT + BROWSER-PC → Switch-A/VLAN 10 → R1-CISCO → Router-ISP → FortiGate port1; FortiGate port2 → WEB-SERVER; FortiGate port3 → JUMP-SRV. No ocultes Switch-A, R1 o Router-ISP ni dibujes una conexión directa entre la LAN de usuarios y el ISP/FortiGate.
2. `02-fortigate-interfaces.png` — interfaces de FortiGate.
3. `03-vpn-rutas-cliente.png` — `ppp0` y rutas del cliente.
4. `04-remoteapp-estandar.png` — catálogo de `user.std`.
5. `05-remoteapp-privilegiado.png` — catálogo de `user.priv`.
6. `06-pruebas-jump-web.png` — puertos permitidos del Jump al Web.
7. `07-politicas-firewall.png` — políticas del FortiGate.
8. `08-vlan-usuarios.png` — VLAN 10 en Cisco.
9. `09-dhcp-usuarios.png` — concesiones DHCP.
10. `10-servicios-webserver.png` — direccionamiento y puertos del Web Server.

Los PNG presentes al descargar el ZIP son marcadores visuales, no capturas del laboratorio. Se mantienen diez para respetar el límite acordado. Los SVG de `docs/diagrams/` son diagramas editables y están fuera del conteo de capturas.
