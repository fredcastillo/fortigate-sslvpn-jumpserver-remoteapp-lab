# Changelog

## 1.8.0 — corrección de topología y flujos

- Redibujada `topologia-logica.svg` para mostrar CLIENTE-FORTICLIENT y BROWSER-PC dentro de VLAN 10, conectados a Switch-A; Switch-A enlaza con R1-CISCO; R1-CISCO enlaza con Router-ISP; Router-ISP enlaza con FortiGate `port1`.
- Representadas por separado las conexiones de FortiGate `port2` a WEB-SERVER y `port3` a JUMP-SRV.
- Rediseñado `flujo-seguridad.svg` para distinguir el trayecto físico (underlay), el túnel SSL-VPN (overlay) y los flujos lógicos entre FortiGate, Jump y Web.
- Actualizados los README español/inglés y los capítulos de arquitectura, Cisco/ISP, implementación por componentes y flujo de paquetes para conservar una única descripción coherente.
- Aclarado en la guía de evidencia que la captura GNS3 debe mostrar todos los nodos intermedios y enlaces reales.

## 1.4.0 — documentación ampliada

- Confirmada la ubicación de `images/` en la raíz del repositorio, fuera de `docs/`, con diez PNG de nombre estable.
- Actualizadas y comprobadas las referencias Markdown a imágenes y diagramas.
- Ampliado el README en español con objetivo, arquitectura, direccionamiento, inventario de políticas, RemoteApp, pruebas, scripts y mapa de documentación.
- Ampliado el README en inglés y enlazado el índice de documentación técnica.
- Añadidos los documentos de implementación por componentes, modelo de seguridad y flujo de paquetes, RDS/RemoteApp, catálogo de comandos, decisiones de diseño y registro de implementación.
- Mantenidos los tres diagramas vectoriales SVG y la estructura de running-configs por dispositivo.
- El ZIP no incluye secretos ni archivos privados de revisión.

## 1.3.0 — base documental

- README técnico, matriz de requisitos, direccionamiento, políticas, SSL-VPN, RDS/RemoteApp, Web Server, Cisco/ISP, pruebas, recuperación y entregables.
- Añadidos scripts de recuperación y verificación de la práctica P4.
- Añadidos los diez marcadores de evidencia en `images/`.

## 1.5.0 — 2026-10-10

- Expandida la documentación con flujo de paquetes y rutas, procedimiento de inspección de FortiGate por GUI, Cisco/ISP/VLAN/DHCP, AD DS/RDS/RemoteApp, matriz de aceptación, hitos de implementación y publicación del repositorio.
- Actualizados README español/inglés e índice de documentación para los nuevos capítulos.
- Confirmada la carpeta `images/` en la raíz del repositorio y ampliada la trazabilidad de las diez capturas.

## 1.6.0 — 2026-10-10

- Añadidos capítulos 29–30 sobre persistencia/arranque de contenedores y separación entre roles RemoteApp y control de SSH.
- Añadidos dos scripts de arranque de referencia para el cliente FortiClient con GUI y Browser-PC, con advertencias sobre su ámbito de ejecución.
- Ampliada la matriz de aceptación y la guía de flujo de paquetes, políticas FortiGate, Cisco/R1/ISP y RDS.

## 1.7.0 — 2026-10-10

- Añadidos los scripts de arranque de referencia para CLIENTE-FORTICLIENT con Firefox/VNC y para Browser-PC/Firefox ESR.
- Añadidos capítulos detallados sobre recorrido de paquetes, inspección FortiGate por GUI, Cisco/ISP/VLAN/DHCP, RDS/RemoteApp, matriz de pruebas y persistencia de contenedores.
- Ampliada la guía de transferencia/ejecución de scripts para evitar asumir que los archivos del repositorio existen dentro de las VMs.
- Reescrito el índice `docs/README.md` por secciones y alineado con los capítulos 00–30.
