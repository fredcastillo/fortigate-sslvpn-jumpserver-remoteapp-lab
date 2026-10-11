# 30. Control de SSH y separación entre permisos de red y permisos RemoteApp

## 30.1 Dos capas de control distintas

La práctica exige limitar el acceso SSH para el usuario estándar y publicar un catálogo RemoteApp distinto por rol. Son controles complementarios, pero no intercambiables:

- **Control de publicación de aplicaciones:** se aplica en Windows/RDS mediante grupos de seguridad. Decide qué aplicaciones aparecen en el catálogo RemoteApp del usuario.
- **Control de conectividad de red:** se aplica donde el tráfico del endpoint entra en un router/firewall. Decide si paquetes TCP hacia el puerto 22 pueden alcanzar el Jump/Web.
- **Control de autenticación del servicio:** SSH y otros servicios validan la identidad según su configuración local/del directorio.

Que `PuTTY` no aparezca en el catálogo del usuario estándar no es, por sí solo, prueba de que el tráfico SSH esté bloqueado por el firewall. Una política de red que deniegue SSH tampoco sustituye la asignación correcta de las RemoteApps.

## 30.2 Identidades del laboratorio

| Contexto | Identidad observada | Dónde se aplica el control |
|---|---|---|
| Sesión SSL-VPN | Grupo `SSLVPN_USERS` y el pool `SSLVPN_TUNNEL_ADDR1` | FortiGate SSL-VPN/Firewall Policy. |
| Usuario estándar de RDS | `JUMPSERVER\user.std` | Membresía `GG-RemoteApp-Web`; catálogo Caja-Web. |
| Usuario privilegiado de RDS | `JUMPSERVER\user.priv` | Membresía `GG-RemoteApp-Web` y `GG-RemoteApp-Privileged`; catálogo de tres aplicaciones. |
| Flujo de red Jump→Web | Origen `JUMP_SERVER` | FortiGate `port3`→`port2`; servicios específicos. |
| Endpoint de usuario en VLAN 10 | IP/MAC de DHCP del endpoint real | Switch/R1 y política/ACL en el punto por el que transite ese flujo. |

El usuario de la VPN y el usuario de Windows/RDS son capas de identidad distintas. En la sesión de laboratorio, la utilidad `lab-vpn` mantiene una conexión SSL-VPN; la autenticación del catálogo RemoteApp la realiza RDS con el usuario Windows correspondiente.

## 30.3 Restricción explícita de SSH para STD

El requisito académico especifica una denegación de SSH para el usuario estándar hacia los servidores. La regla debe observar el tráfico real del endpoint STD y registrar la denegación cuando sea posible. Antes de crear o mover una política, identifica el camino del paquete:

`Endpoint VLAN 10 → Switch VLAN 10 → R1-CISCO → Router-ISP → FortiGate port1 → red de destino`.

Como los usuarios no están conectados directamente a una interfaz VLAN del FortiGate en esta topología, la denegación no se debe inventar con una interfaz `VLAN10` que no existe. Selecciona el punto de control que realmente ve la IP origen. Revisa NAT en R1: si la IP de usuario se traduce antes de FortiGate, el firewall podría no distinguir STD de PRIV por IP.

La evidencia de aceptación debe mostrar:

1. La política/ACL explícita de denegación SSH para el endpoint/identidad STD en el dispositivo que ve su tráfico.
2. El orden de la regla frente a cualquier permiso general que pudiera coincidir.
3. Un intento TCP/22 desde el origen estándar hacia Jump y/o Web con resultado denegado.
4. El hit o registro de la regla que demuestra la denegación.
5. Que las conexiones autorizadas desde Jump al Web Server por TCP/22 siguen funcionando bajo `JUMP_TO_WEBSERVER_P4`.

## 30.4 SSH desde Jump hacia Web

El requisito también permite SSH desde Jump hacia Web para el usuario privilegiado. El control de red usa `JUMP_TO_WEBSERVER_P4`, que permite HTTPS, RDP y SSH desde `JUMP_SERVER` a `WEBSERVER`, con NAT deshabilitado y logging. La regla `JUMP_TO_WEB_DENY_OTHER` cierra el resto de servicios entre el mismo origen/destino.

Para la verificación de TCP/22 desde Jump, usa PowerShell en JUMP-SRV:

```powershell
Test-NetConnection 10.21.75.130 -Port 22
```
## 30.5 Diferencia entre catálogo y acceso directo

- `user.std` debe ver solo `Caja-Web` en RD Web.
- `user.priv` debe ver `Caja-Web`, `PuTTY` y `Conexión a Escritorio remoto`.
- El acceso SSH desde el endpoint estándar debe rechazarse por una regla explícita de red.
- El SSH desde Jump a Web permanece autorizado, porque es uno de los tres servicios requeridos.
