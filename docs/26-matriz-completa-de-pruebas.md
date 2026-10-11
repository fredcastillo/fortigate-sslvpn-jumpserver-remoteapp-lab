# 26. Matriz completa de pruebas de aceptación

## 26.1 Cómo registrar una prueba

Cada registro de prueba debe indicar: ID, fecha/hora, origen real, destino, servicio/puerto, comando o pantalla utilizada, resultado observado, política/ACL asociada cuando aplique y archivo de evidencia. No mezcles resultados históricos con una prueba ejecutada después de cambios posteriores.

La tabla siguiente distingue resultados positivos comunicados durante la implementación de las pruebas que deben quedar registradas en la instancia final. Se evita afirmar que un requisito está probado solo porque existe un objeto o porque la ruta se ve correcta.

## 26.2 Pruebas de red y VPN

| ID | Prueba | Origen | Destino | Método | Resultado/captura esperada |
|---|---|---|---|---|---|
| N01 | Interfaz WAN | GUI FortiGate | `port1` | Network → Interfaces | `203.0.113.26/30` visible. |
| N02 | LAN Web | GUI FortiGate | `port2` | Network → Interfaces | `10.21.75.129/29` visible. |
| N03 | LAN Jump | GUI FortiGate | `port3` | Network → Interfaces | `10.21.75.137/29` visible. |
| N04 | VLAN 10 existe | Consola switch | VLAN 10 | `show vlan brief` | VLAN y puertos de usuarios visibles. |
| N05 | Gateway de usuarios | Consola R1 | `10.21.75.1/25` | `show ip interface brief` | Interfaz LAN up/up y gateway esperado. |
| N06 | DHCP de estándar | Endpoint identificado como STD | R1/DHCP | `ipconfig /all` y `show ip dhcp binding` | Dirección, máscara, gateway y lease identificables. |
| N07 | DHCP de privilegiado | Endpoint identificado como PRIV | R1/DHCP | `ipconfig /all` y binding DHCP | Lease independiente y correlación con endpoint. |
| N08 | Listener SSL-VPN | FortiGate GUI | WAN TCP/10443 | SSL-VPN Settings | Listener y grupo/portal correctos. |
| N09 | Sesión SSL-VPN | CLIENTE-FORTICLIENT | FortiGate | `lab-vpn connect`, SSL-VPN Monitor | Túnel activo y cliente en el pool. |
| N10 | Ruta VPN al Jump | Cliente VPN | `10.21.75.138` | `ip route get 10.21.75.138` | `dev ppp0`; se observó así en el estado comunicado. |
| N11 | Ruta normal al Web | Cliente VPN | `10.21.75.130` | `ip route get 10.21.75.130` | La ruta observada usó `eth0` vía `10.21.75.1`; el firewall decide si el intento se admite. |
| N12 | RD Web sobre HTTPS | Cliente VPN | Jump TCP/443 | Firefox | Portal RD Web accesible. |
| N13 | VPN a Web directo | Cliente VPN | Web | Intento directo + logs de FortiGate | No debe recibir permiso directo; registrar política/log que decide el resultado. |
| N14 | VPN a VLAN 10 | Cliente VPN | Dirección de usuario | Prueba dirigida + logs | Debe quedar fuera del acceso concedido por SSL-VPN; registrar regla/log real. |

## 26.3 Pruebas Jump → Web

| ID | Puerto | Servicio | Origen | Destino | Método | Resultado de aceptación |
|---|---:|---|---|---|---|---|
| J01 | 443 | HTTPS | JUMP-SRV `.138` | WEB-SERVER `.130` | `Test-NetConnection 10.21.75.130 -Port 443` | TCP satisfactorio; prueba repetida y comunicada. |
| J02 | 3389 | RDP | JUMP-SRV `.138` | WEB-SERVER `.130` | `Test-NetConnection 10.21.75.130 -Port 3389` | TCP satisfactorio; después se confirmó XRDP escuchando. |
| J03 | 22 | SSH | JUMP-SRV `.138` | WEB-SERVER `.130` | `Test-NetConnection 10.21.75.130 -Port 22` | TCP satisfactorio; prueba repetida y comunicada. |
| J04 | 80 | HTTP | JUMP-SRV `.138` | WEB-SERVER `.130` | `Test-NetConnection 10.21.75.130 -Port 80` | Debe ser denegado por política de cierre si no hay permiso más amplio. |
| J05 | 445 | SMB | JUMP-SRV `.138` | WEB-SERVER `.130` | `Test-NetConnection 10.21.75.130 -Port 445` | Debe ser denegado. |
| J06 | 3306 | MariaDB/MySQL | JUMP-SRV `.138` | WEB-SERVER `.130` | `Test-NetConnection 10.21.75.130 -Port 3306` | Debe ser denegado/no listener, según el servicio instalado; correlaciona el log. |
| J07 | Política de permiso | GUI FortiGate | `JUMP_SERVER` → `WEBSERVER` | 443/3389/22 | Policy & Objects | `JUMP_TO_WEBSERVER_P4` arriba de la denegación, NAT off, log all. |
| J08 | Regla de cierre | GUI FortiGate | `JUMP_SERVER` → `WEBSERVER` | ALL | Policy & Objects / logs | `JUMP_TO_WEB_DENY_OTHER` deniega el resto de servicios. |

Las pruebas J01–J03 fueron realizadas repetidamente desde Jump en el contexto de la práctica. J04–J06 deben incluirse en evidencia solo después de ejecutar la prueba negativa final y correlacionarla con el firewall o con el servicio de destino. Un error de conexión aislado no prueba por sí solo qué regla lo bloqueó.

## 26.4 Pruebas RemoteApp

| ID | Cuenta | Comprobación | Resultado observado/esperado |
|---|---|---|---|
| R01 | `user.std` | Inicio de sesión en RD Web | Se completó el acceso al catálogo. |
| R02 | `user.std` | Catálogo publicado | Se observó únicamente `Caja-Web`. |
| R03 | `user.priv` | Inicio de sesión en RD Web | Se completó el acceso al catálogo. |
| R04 | `user.priv` | Catálogo publicado | Se observaron `Caja-Web`, `PuTTY` y `Conexión a Escritorio remoto`. |
| R05 | Ambos | Configuración RDS | `ShowInWebAccess=True` en las tres publicaciones. |
| R06 | Estándar | SSH directo al Jump/Web | El requisito requiere restricción explícita/log en el punto de tráfico real; guarda evidencia de política/ACL de denegación y hit. |
| R07 | Privilegiado | PuTTY/RDP disponibles | La publicación está asignada al grupo privilegiado; la evidencia final debe corresponder al catálogo y a la configuración real. |

## 26.5 Reglas para concluir resultados

- **Permitido TCP:** la prueba fue satisfactoria desde el origen indicado; no demuestra funcionamiento completo de la aplicación.
- **Denegado por FortiGate:** debe estar respaldado por la política/log que realmente coincidió, o por una denegación implícita identificada en el trayecto.
- **Publicado en RD Web:** se confirma con `Get-RDRemoteApp` y el catálogo del usuario; es distinto a la apertura de la aplicación.
- **Ruta VPN:** confirma el camino seleccionado por el cliente; no reemplaza la prueba de política.
- **Configuración:** una captura de GUI muestra los parámetros, pero la prueba de aceptación debe incluir el resultado de tráfico cuando el requisito trata de permitir/bloquear comunicaciones.

## 26.6 Evidencia asociada

Utiliza los diez nombres estables de `images/` y conserva las salidas de prueba sanitizadas en `running-configs/` o en registros específicos por dispositivo. No añadas un undécimo PNG: mantén los diez slots de captura y usa logs de texto adicionales cuando una misma captura no pueda mostrar claramente varias pruebas.
