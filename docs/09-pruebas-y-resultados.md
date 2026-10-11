# 09. Pruebas y resultados de referencia

Este documento organiza las comprobaciones por origen. Las rutas, conexiones TCP, políticas de firewall y permisos RemoteApp se prueban en capas diferentes y deben relacionarse con el mismo requisito.

## 1. VPN y rutas del cliente

Desde CLIENTE-FORTICLIENT, después de `lab-vpn connect`:

```bash
ip -br addr show ppp0
ip route get 10.21.75.138
ip route get 10.21.75.130
ip route show dev ppp0
```

**Resultado observado:** `ppp0` recibió `10.212.134.200`; la ruta a `10.21.75.138` se instaló mediante `ppp0`. La ruta a `10.21.75.130` se observó por la ruta normal `eth0` vía `10.21.75.1`. La política de firewall determina si un paquete que sigue la ruta normal está permitido o denegado.

## 2. Jump Server → Web Server

Desde PowerShell en JUMP-SRV:

```powershell
Test-NetConnection 10.21.75.130 -Port 443
Test-NetConnection 10.21.75.130 -Port 3389
Test-NetConnection 10.21.75.130 -Port 22
```

**Resultado comunicado:** las tres pruebas TCP fueron comprobadas varias veces desde Jump hacia Web. Para la captura final, muestra simultáneamente destino, puerto y `TcpTestSucceeded`. La comprobación es específica al origen JUMP-SRV y no debe etiquetarse como una prueba desde la VPN o VLAN10.

El script `scripts/windows/verificar-jump-a-web.ps1` permite ejecutar las comprobaciones en un único bloque y muestra el resumen.

## 3. RemoteApp por usuario

| Usuario | Resultado de catálogo observado |
|---|---|
| `JUMPSERVER\\user.std` | Solo `Caja-Web`. |
| `JUMPSERVER\\user.priv` | `Caja-Web`, `PuTTY` y `Conexión a Escritorio remoto`. |

Esta evidencia comprueba la visibilidad y la asignación de publicación por rol. La ejecución de cada aplicación es una prueba separada de la simple visibilidad del catálogo.

## 4. Políticas de Jump-to-Web

En la GUI de FortiGate, comprueba:

- `JUMP_TO_WEBSERVER_P4`: ACCEPT, origen `JUMP_SERVER`, destino `WEBSERVER`, servicios HTTPS/RDP/SSH, NAT deshabilitado y logging `all`.
- `JUMP_TO_WEB_DENY_OTHER`: mismo par de interfaces/origen/destino, servicio ALL, acción DENY predeterminada, logging activado.
- La regla de permiso aparece por encima de la regla de denegación.

Para documentar el cierre de la matriz, prueba desde Jump un puerto no incluido (por ejemplo TCP/80) y correlaciona el resultado con la regla DENY en Forward Traffic logs; conserva en la captura origen, destino, puerto y registro asociado.

## 5. Acceso SSL-VPN al Jump

La validación se realiza combinando:

1. Sesión activa en SSL-VPN Monitor del FortiGate GUI.
2. `ppp0` con dirección de pool del lado cliente.
3. Ruta del cliente hacia `10.21.75.138` mediante `ppp0`.
4. Acceso HTTPS al portal `https://10.21.75.138/RDWeb/webclient/index.html`.
5. Política `SSLVPN_TO_JUMP_HTTPS` activa para el grupo de SSL-VPN.

## 6. Matriz de pruebas

| Prueba | Origen | Destino | Resultado esperado / evidencia |
|---|---|---|---|
| VPN conectada | CLIENTE-FORTICLIENT | FortiGate WAN TCP/10443 | SSL-VPN Monitor + `ppp0`. |
| Portal RD Web | Cliente por túnel | JUMP-SRV TCP/443 | Portal web por HTTPS. |
| SSH directo de SSL-VPN a Web | Cliente VPN | WEB-SERVER TCP/22 | No autorizado; política directa correspondiente deshabilitada y ruta VPN al Web no anunciada. |
| HTTPS Jump → Web | JUMP-SRV | WEB-SERVER TCP/443 | Permitido. |
| RDP Jump → Web | JUMP-SRV | WEB-SERVER TCP/3389 | Permitido. |
| SSH Jump → Web | JUMP-SRV | WEB-SERVER TCP/22 | Permitido. |
| Otro servicio Jump → Web | JUMP-SRV | WEB-SERVER, p. ej. TCP/80 | Denegado por la regla de cierre; registra el resultado final con log. |
| Catálogo estándar | `user.std` | RD Web | Solo Caja-Web. |
| Catálogo privilegiado | `user.priv` | RD Web | Caja-Web, PuTTY y mstsc. |
| DHCP usuario | Endpoint identificado | R1 / DHCP | Concesión asociada a IP/MAC y segmento VLAN10. |

## Interpretación de resultados

- `TcpTestSucceeded=True` confirma que se estableció TCP hacia ese puerto desde la estación desde la que se ejecutó la prueba.
- Una ruta `dev ppp0` muestra que el destino usa el túnel en la tabla de rutas del cliente; no demuestra por sí sola que la política permita la conexión.
- El catálogo RemoteApp confirma la publicación asignada a un usuario; no acredita por sí solo la ejecución completa de todas las aplicaciones.
- La vista GUI y Forward Traffic logs completan la evidencia del control en FortiGate.
