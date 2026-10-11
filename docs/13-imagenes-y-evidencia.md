# 13. Capturas de evidencia (10 como máximo)

La carpeta `images/` está en la raíz del repositorio, fuera de `docs/`, para que sea fácil localizar y reemplazar las capturas. Los diez PNG incluidos son marcadores visuales con instrucciones; al sustituirlos por capturas reales conserva exactamente el nombre del archivo. El README y esta página ya apuntan a las rutas correctas.

| # | Archivo en `images/` | Qué debe mostrar | Tiempo orientativo |
|---:|---|---|---:|
| 1 | `01-topologia-general.png` | GNS3 con los equipos y enlaces completos. | 00:15 |
| 2 | `02-fortigate-interfaces.png` | FortiGate GUI: port1, port2 y port3. | 00:30 |
| 3 | `03-vpn-rutas-cliente.png` | `ppp0`, ruta al Jump y ruta al Web desde el cliente. | 00:48 |
| 4 | `04-remoteapp-estandar.png` | Catálogo RD Web de `user.std`, solo Caja-Web. | 01:15 |
| 5 | `05-remoteapp-privilegiado.png` | Catálogo RD Web de `user.priv` con Caja-Web, PuTTY y mstsc. | 01:42 |
| 6 | `06-pruebas-jump-web.png` | Pruebas TCP de Jump a Web en 443/3389/22. | 02:10 |
| 7 | `07-politicas-firewall.png` | Políticas SSLVPN-to-Jump, Jump-to-Web y DENY posterior. | 02:50 |
| 8 | `08-vlan-usuarios.png` | VLAN 10 en el switch Cisco. | 03:50 |
| 9 | `09-dhcp-usuarios.png` | DHCP bindings/pool en R1. | 04:10 |
| 10 | `10-servicios-webserver.png` | IP y puertos escuchando en el Web Server. | 04:55 |

## Sustituir un marcador

1. Abre el video <https://youtu.be/XtP_YsM0tjs> y pausa en la sección indicada.
2. Captura el área pertinente con `Win + Shift + S` o una herramienta equivalente.
3. Guarda la imagen en PNG.
4. Copia la imagen encima del marcador en la raíz `images/` usando el mismo nombre exacto.
5. Comprueba la vista previa del README en GitHub.

No añadas más de diez capturas. Los diagramas SVG dentro de `docs/diagrams/` son ilustraciones vectoriales editables, no capturas de pantalla.
