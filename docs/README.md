# Índice de documentación técnica

Esta carpeta contiene la documentación temática de la práctica. Las diez capturas PNG viven en `../images/`, **fuera de `docs/`**. Los diagramas SVG editables están en `diagrams/`.

## Requisitos, diseño y direccionamiento

- [00 — Requisitos y trazabilidad](00-requisitos-y-trazabilidad.md)
- [01 — Propósito, alcance y criterios del laboratorio](01-proposito-y-alcance.md)
- [02 — Arquitectura y topología](02-arquitectura-y-topologia.md)
- [03 — Plan de direccionamiento](03-plan-direccionamiento.md)

## Dispositivos y servicios

- [04 — FortiGate, objetos y políticas](04-fortigate-y-politicas.md)
- [05 — SSL-VPN, pool y rutas](05-ssl-vpn-y-rutas.md)
- [06 — Jump Server, AD DS, RDS y RemoteApp](06-jump-rds-remoteapp.md)
- [07 — Web Server y servicios de destino](07-web-server.md)
- [08 — Cisco, ISP, VLAN 10 y DHCP](08-cisco-isp-vlan-dhcp.md)

## Pruebas, operación y entrega

- [09 — Pruebas y resultados de referencia](09-pruebas-y-resultados.md)
- [10 — Procedimiento de demostración](10-procedimiento-de-demostracion.md)
- [11 — Recuperación y operación](11-recuperacion-y-operacion.md)
- [12 — Running-configs y exportación segura](12-running-configs.md)
- [13 — Imágenes y evidencia](13-imagenes-y-evidencia.md)
- [14 — Entregables y publicación](14-entregables-y-publicacion.md)
- [15 — Glosario](15-glosario.md)

## Documentación ampliada

- [16 — Implementación por componentes](16-implementacion-y-componentes.md)
- [17 — Modelo de seguridad y flujo de paquetes](17-modelo-de-seguridad-y-flujos.md)
- [18 — RD Web Client y roles RDS](18-rds-webclient-y-roles.md)
- [19 — Catálogo de comandos y consultas](19-catalogo-de-comandos.md)
- [20 — Decisiones de diseño y control de cambios](20-decisiones-de-diseno-y-control-de-cambios.md)
- [21 — Registro de implementación](21-bitacora-de-implementacion.md)
- [22 — Flujo de paquetes, rutas y límites entre zonas](22-flujo-de-paquetes-y-enrutamiento.md)
- [23 — Inspección y configuración de FortiGate mediante GUI](23-procedimiento-fortigate-gui.md)
- [24 — Cisco IOS, ISP, VLAN 10 y DHCP en detalle](24-cisco-isp-vlan-dhcp-detallado.md)
- [25 — Implementación de AD DS, DNS, RDS, RD Web y RemoteApp](25-implementacion-rds-ad-dns-remoteapp.md)
- [26 — Matriz completa de pruebas de aceptación](26-matriz-completa-de-pruebas.md)
- [27 — Hitos de implementación y evolución técnica](27-implementacion-por-hitos.md)
- [28 — Modelo de entrega y publicación](28-modelo-de-entrega-y-publicacion.md)
- [29 — Persistencia y arranque de clientes gráficos](29-persistencia-y-arranque-de-clientes.md)
- [30 — Control de SSH y separación entre roles](30-control-de-ssh-y-separacion-de-roles.md)

## Lectura recomendada

1. Comienza por los requisitos y el direccionamiento (`00`–`03`).
2. Revisa FortiGate, SSL-VPN y la matriz de tráfico (`04`, `05`, `17`, `22`, `23`).
3. Revisa RDS/RemoteApp y la separación de roles (`06`, `18`, `25`, `30`).
4. Usa la matriz de aceptación y el runbook para comprobar cada flujo (`09`, `10`, `26`).
5. Antes de publicar, completa y sanitiza los running-configs reales mediante `12` y revisa la guía de entrega `28`.
