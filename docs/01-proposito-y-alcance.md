# 01. Propósito, alcance y diseño de seguridad

## Propósito

Implementar y demostrar un acceso remoto de mínimo privilegio en una topología GNS3. El cliente se autentica por SSL-VPN en FortiGate y utiliza el Jump Server como punto de acceso a las aplicaciones publicadas. El tráfico entre el Jump Server y el servidor web se limita a tres servicios definidos por la práctica.

## Objetivos técnicos

1. Separar las zonas de usuarios, Web y Jump mediante direccionamiento independiente.
2. Terminar SSL-VPN en FortiGate y utilizar el pool de direcciones configurado.
3. Dirigir el acceso remoto HTTPS al portal RD Web del Jump Server.
4. Publicar catálogos RemoteApp distintos para usuario estándar y usuario privilegiado.
5. Autorizar desde Jump hacia Web los servicios HTTPS, RDP y SSH, con registro de sesiones.
6. Denegar el resto de los servicios entre Jump y Web mediante una política posterior de cierre.
7. Mantener evidencia técnica reproducible del direccionamiento, rutas, políticas, servicios, VLAN, DHCP y RDS.

## Principios aplicados

### Mínimo privilegio

Las reglas de firewall especifican origen, destino e interfaces y reducen los servicios permitidos a los necesarios para la práctica. Las aplicaciones RemoteApp se asignan a grupos de seguridad, de modo que el catálogo visible depende del rol del usuario.

### Segmentación

La ruta de usuario es `CLIENTE-FORTICLIENT` y `BROWSER-PC` → `Switch-A` (VLAN 10) → `R1-CISCO` → `Router-ISP` → FortiGate `port1`. El switch conecta los endpoints con R1; el Router-ISP está en serie entre R1 y FortiGate. No hay conexión directa de la LAN de usuarios al Router-ISP ni a FortiGate. En el lado protegido, FortiGate `port2` conecta al WEB-SERVER y `port3` al JUMP-SRV. No se crea una interfaz de usuario VLAN 10 en FortiGate.

### Acceso a través del Jump Server

El diseño evita conceder una ruta SSL-VPN directa al Web Server. El portal RD Web del Jump Server actúa como punto intermedio de acceso. La ruta de cliente hacia `10.21.75.138` se observó por `ppp0`; `10.21.75.130` se observó por la interfaz normal del cliente, por lo que las políticas de firewall también son necesarias para evitar el acceso no autorizado.

### Configuración GUI-first de FortiGate

Las políticas, objetos, interfaces y ajustes SSL-VPN que se muestran como configuración de la práctica se gestionan desde la GUI de FortiGate. La CLI es útil para consultas de lectura (`show firewall policy`, `show firewall vip`) y para exportar evidencia, no como sustituto de la demostración requerida por el profesor.

## Alcance

- GNS3 y GNS3 VM para la topología.
- FortiGate-VM64-KVM con FortiOS 7.0.9 build 0444.
- Router/ switch Cisco y router ISP simulado.
- Cliente Ubuntu con utilidad de conexión `lab-vpn`/OpenFortiVPN y navegador Firefox.
- Windows Server 2019 con Active Directory, DNS, RDS/RemoteApp y Remote Desktop Web Client.
- Web Server Ubuntu 22.04.5 LTS con Apache HTTPS, SSH y XRDP para las comprobaciones previstas.

El entorno es académico y no debe interpretarse como una arquitectura endurecida y certificada para producción.
