# 27. Hitos de implementación y evolución técnica

## 27.1 Objetivo

Este registro resume los hitos que dieron forma a la práctica final. No es un diario de errores ni sustituye los running-configs; documenta el orden funcional y las decisiones que explican la arquitectura que se presenta.

## 27.2 Hito A — Conectividad WAN y LAN de usuarios

- Se definieron los enlaces simulados R1–ISP (`203.0.113.20/30`) e ISP–FortiGate (`203.0.113.24/30`).
- La LAN de usuarios quedó en `10.21.75.0/25`, con gateway `10.21.75.1` en R1-CISCO.
- La VLAN 10 reside en el segmento de acceso Cisco. Los usuarios no están conectados directamente a una interfaz VLAN del FortiGate.
- El Router-ISP utiliza una interfaz adicional hacia Cloud/VMnet8 para la salida de la GNS3 VM; ese segmento del hipervisor se distingue del direccionamiento WAN de la práctica.

## 27.3 Hito B — Separación de las LAN de servidores

La asignación definitiva de la implementación es:

- Web: red `10.21.75.128/29`; FortiGate `port2` `.129`; WEB-SERVER `.130`.
- Jump: red `10.21.75.136/29`; FortiGate `port3` `.137`; JUMP-SRV `.138`.

El plan inicial contenía la asociación invertida. La documentación final utiliza la dirección y función del despliegue real. Los diagramas y tablas del repositorio deben mantener esta versión para evitar confundir roles.

## 27.4 Hito C — Servicios de WEB-SERVER

WEB-SERVER se ejecuta como contenedor Linux Ubuntu 22.04.5 LTS. El Web Server contiene Apache/HTTPS, OpenSSH y XRDP/RDP; se trabajó con `service` para iniciar los servicios porque los contenedores GNS3 no tienen systemd como PID 1. La dirección estática queda en `eth0` (`10.21.75.130/29`), con gateway `10.21.75.129`.

El directorio DocumentRoot es `/var/www/html`. La configuración de los servicios y sus puertos se puede inspeccionar con `scripts/linux/verificar-webserver.sh`. El script de recuperación específico es operativo y debe usarse únicamente dentro del Web Server, después de leer sus efectos.

## 27.5 Hito D — Jump Server, Active Directory y RemoteApp

Se instaló Windows Server 2019, hostname `JUMP-SRV`, dominio `jumpserver.lab` y colección `QuickSessionCollection`. AD DS/DNS proporciona identidad de los usuarios y resolución interna. RemoteApp diferencia los catálogos según grupos:

- `GG-RemoteApp-Web`: `user.std`, `user.priv`.
- `GG-RemoteApp-Privileged`: `user.priv`.

Se publicaron `Caja-Web`, `PuTTY` y `mstsc`. El usuario estándar vio `Caja-Web`; el privilegiado vio las tres aplicaciones. `Caja-Web` se configura con Internet Explorer como ejecutable y una URL objetivo HTTPS hacia el Web Server. PuTTY se seleccionó como cliente SSH; `mstsc` es el cliente de Escritorio remoto de Windows.

## 27.6 Hito E — Microsoft Remote Desktop Web Client

Se instaló el módulo `RDWebClientManagement` y se ejecutaron sus cmdlets de instalación, importación del certificado del broker y publicación del Web Client. Se identificaron un PFX para el nombre `JUMP-SRV.jumpserver.lab` y un certificado público exportado. El material de clave privada no forma parte del repositorio.

El portal se utilizó mediante IP (`https://10.21.75.138/RDWeb/webclient/index.html`) desde el navegador del cliente. El uso por FQDN depende de DNS y certificado alineados con `JUMP-SRV.jumpserver.lab`.

## 27.7 Hito F — Cliente SSL-VPN y navegador gráfico

El cliente Linux `CLIENTE-FORTICLIENT` usa una utilidad del laboratorio llamada `lab-vpn`, que inicia una sesión OpenFortiVPN en primer plano. Durante la conexión se observó `ppp0` con `10.212.134.200`; la terminal de conexión se mantiene abierta mientras se utilizan los recursos del túnel.

En la GNS3 VM se conservan etiquetas locales de imagen del cliente:

- `forticlient-lite:7.2-fix3`
- `lab-backup/forticlient-original-before-vnc:20261009`
- `lab-backup/forticlient-firefox:checkpoint-20261009`
- `lab-backup/forticlient-vnc-firefox:20261009`

Las etiquetas documentan puntos de recuperación locales; no equivalen a publicación de la imagen en Docker Hub. La imagen final conocida contiene Firefox `157.0.1`. La sesión de VPN no persiste al recrearse el contenedor, de modo que se inicia de nuevo con `lab-vpn connect`.

## 27.8 Hito G — Políticas FortiGate

Se prepararon objetos y reglas usando la GUI, respetando el requisito académico de configurar y demostrar FortiGate desde su interfaz gráfica. El flujo Jump→Web permite HTTPS/RDP/SSH, sin NAT y con logging; la regla de cierre deniega los demás servicios. Las reglas SSLVPN→Jump permiten HTTPS y la resolución DNS prevista, mientras se mantiene deshabilitada la regla heredada SSLVPN→Web SSH.

La política `WAN_to_WEBSERVER_HTTPS` que apuntaba al VIP directo `203.0.113.26:443` → `10.21.75.130:443` fue deshabilitada desde la GUI, conservando el objeto VIP para que la tabla muestre claramente la diferencia entre un objeto y una política habilitada.

## 27.9 Hito H — Validación y evidencia

Las validaciones reportadas incluyeron:

- VPN autenticada, interfaz `ppp0` y ruta hacia Jump mediante el túnel.
- Portal RD Web accesible por IP desde el cliente.
- Catálogo estándar con `Caja-Web` solamente.
- Catálogo privilegiado con `Caja-Web`, `PuTTY` y `Conexión a Escritorio remoto`.
- Pruebas TCP desde Jump hacia Web en 443, 3389 y 22.
- Inspección en GUI de las políticas Jump→Web, regla de denegación posterior y estado deshabilitado de las políticas directas.

El conjunto final de evidencias se organiza en diez capturas máximo, diagramas SVG, scripts reutilizables y exportaciones reales de configuración.
