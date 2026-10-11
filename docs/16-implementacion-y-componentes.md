# 16. Implementación por componentes y decisiones de diseño

Este documento describe qué componente cumple cada función, cómo encaja en la topología final y cómo se evidencia su configuración. Complementa la matriz de requisitos y permite comprender el laboratorio sin depender únicamente del video.

## 16.1 Reglas de diseño

1. **El enunciado académico es la autoridad:** solo se incluyen elementos necesarios para cumplir los requisitos.
2. **Dos servidores, dos LAN de servidor:** Web y Jump no comparten subred.
3. **Client-to-Site:** la sesión VPN termina en FortiGate; no es una VPN site-to-site.
4. **Acceso a través del Jump:** el portal RD Web está alojado en JUMP-SRV y las aplicaciones se asignan por grupos.
5. **Mínimo privilegio entre servidores:** Jump → Web permite los tres servicios definidos y una política posterior deniega el resto.
6. **FortiGate GUI-first:** las operaciones de configuración y la demostración de FortiGate se realizan desde la GUI; CLI se utiliza para lectura/recopilación.
7. **Estabilidad de laboratorio:** con un host de 16 GB de RAM, se arrancan los nodos gradualmente y se apagan los que no se usan en una toma.
8. **Evidencia rastreable:** cada afirmación de conectividad debe identificar el origen y destino de la prueba.

## 16.2 FortiGate

- Appliance: `FortiGate-VM64-KVM`.
- Versión reportada: `FortiOS 7.0.9 build 0444`.
- `port1`: WAN `203.0.113.26/30`, conexión al ISP `.25/30`; listener SSL-VPN documentado en TCP/10443.
- `port2`: Web LAN, gateway `10.21.75.129/29`.
- `port3`: Jump LAN, gateway `10.21.75.137/29`.
- `ssl.root`: interfaz lógica de entrada del tráfico descifrado de SSL-VPN.

La GUI es la interfaz principal para mostrar `Network → Interfaces`, `VPN → SSL-VPN Settings/Portals`, `Policy & Objects` y `Log & Report`.

## 16.3 Red de usuarios, Cisco e ISP

La topología correcta es `CLIENTE-FORTICLIENT + BROWSER-PC → Switch-A (VLAN 10) → R1-CISCO → Router-ISP → FortiGate port1`. Ambos endpoints están dentro de la LAN de usuarios; no se conectan directamente al ISP ni al FortiGate. Switch-A aporta la conectividad de capa 2 y enlaza con la interfaz LAN de R1. La puerta de enlace de usuarios está en R1 (`10.21.75.1/25`); no se crea una interfaz VLAN 10 en FortiGate.

El trayecto WAN simulado desde R1 hasta FortiGate consta de dos enlaces en serie:

- R1 `Gi1/0` `.21/30` ↔ Router-ISP `Gi1/0` `.22/30` sobre `203.0.113.20/30`.
- Router-ISP `Gi2/0` `.25/30` ↔ FortiGate `port1` `.26/30` sobre `203.0.113.24/30`.

Los endpoints de usuario utilizan `10.21.75.0/25`. Durante el trabajo se observó CLIENTE-FORTICLIENT con `10.21.75.10/25`; Browser-PC tenía `10.21.75.110/25` estático en la instancia de referencia. Para la entrega, identifica en las capturas ambos equipos y muestra las concesiones/reservas DHCP vigentes.

## 16.4 WEB-SERVER

- Sistema: Ubuntu 22.04.5 LTS.
- IP: `10.21.75.130/29` en `eth0`.
- Gateway: `10.21.75.129`.
- Document root de Apache: `/var/www/html`.
- Servicios usados por la práctica: HTTPS `443`, SSH `22`, XRDP/RDP `3389`.

El nodo sirve como Sistema de Caja y como destino de pruebas controladas. El hecho de que un puerto escuche debe combinarse con una verificación desde el origen autorizado para demostrar el flujo a través de FortiGate.

## 16.5 JUMP-SRV y roles de usuario

- Sistema documentado: Windows Server 2019.
- IP: `10.21.75.138/29`.
- Gateway: `10.21.75.137`.
- Dominio: `jumpserver.lab`.
- Colección: `QuickSessionCollection`.
- Componentes: AD DS, DNS, RDS, RD Web y RemoteApp.

Grupos de seguridad:

- `JUMPSERVER\GG-RemoteApp-Web`: contiene `user.std` y `user.priv`.
- `JUMPSERVER\GG-RemoteApp-Privileged`: contiene únicamente `user.priv`.

El usuario estándar tiene publicada `Caja-Web`. El usuario privilegiado tiene `Caja-Web`, `PuTTY` y `Conexión a Escritorio remoto` (`mstsc`). El catálogo observado en RD Web corresponde a esas asignaciones.

## 16.6 Componentes del cliente VPN

El contenedor `CLIENTE-FORTICLIENT` utiliza una imagen Linux personalizada con la utilidad de laboratorio `lab-vpn`, OpenFortiVPN y Firefox. Se observó `openfortivpn 1.17.1` en una comprobación de cliente y Firefox `157.0.1` en la imagen guardada del cliente gráfico.

Etiquetas de imagen conservadas en GNS3 VM:

- `forticlient-lite:7.2-fix3`
- `lab-backup/forticlient-original-before-vnc:20261009`
- `lab-backup/forticlient-firefox:checkpoint-20261009`
- `lab-backup/forticlient-vnc-firefox:20261009`

El helper `lab-vpn` es proporcionado dentro de la imagen del contenedor; no se documenta como un binario desarrollado desde este repositorio. La conexión se invoca con `lab-vpn connect` y permanece en primer plano mientras el túnel esté activo.

## 16.7 Servicios y flujos que se deben mostrar

1. Cliente: sesión SSL-VPN activa y `ppp0` con IP de pool.
2. Cliente: la ruta a `10.21.75.138` utiliza `ppp0`.
3. RD Web: portal HTTPS del Jump Server.
4. `user.std`: catálogo con `Caja-Web`.
5. `user.priv`: catálogo con `Caja-Web`, `PuTTY` y `mstsc`.
6. Jump → Web: TCP/443, TCP/3389, TCP/22.
7. FortiGate: permiso Jump → Web seguido por deny del resto.
8. Cisco/R1: VLAN10, interfaz gateway, DHCP binding y configuración.

## 16.8 Convención de evidencia

Una imagen de configuración prueba que el control está definido; una prueba desde el origen correcto demuestra el comportamiento observado. Para las políticas de firewall, lo ideal es conservar ambas clases de evidencia: la regla en GUI y la conexión/log asociado.
