# Diagramas de arquitectura

Los diagramas SVG son recursos vectoriales editables:

- `topologia-logica.svg`: topología física/lógica corregida: los dos endpoints de VLAN 10 conectan a Switch-A, luego R1-CISCO, Router-ISP y FortiGate port1; `port2` conecta al Web Server y `port3` al Jump Server. La línea discontinua es el overlay SSL-VPN, no un enlace físico directo.
- `flujo-seguridad.svg`: distingue underlay (Switch-A → R1-CISCO → Router-ISP → FortiGate), overlay SSL-VPN y flujo permitido/denegado Jump-to-Web.
- `matriz-acceso.svg`: resumen de flujos permitidos/no autorizados.

Se pueden visualizar en navegador o GitHub y editar como texto SVG. Las capturas reales se guardan separadas en la carpeta de raíz `images/`.
