# Running-configs y exportaciones reales

Las exportaciones deben salir de los dispositivos de la instancia P4 final. Las carpetas se separan por equipo y el repositorio contiene una captura textual real de políticas FortiGate compartida durante la práctica, junto con una tabla de estado final confirmada después mediante la GUI.

- `fortigate/`: salida de `show firewall policy`, salida de `show firewall vip`, e inventario final confirmado.
- `cisco-switch/`: añadir el `show running-config` final del switch y evidencia de VLAN/trunks.
- `router-isp/`: añadir exportaciones finales de R1 y Router-ISP por separado.
- `jump-server/`: añadir evidencia de red, colección RDS, RemoteApps y grupos.
- `web-server/`: añadir evidencia de red, servicios y configuración web relevante.

No reemplaces exportaciones de la práctica final por un archivo de configuración histórico. Sanitiza credenciales, PSK, llaves privadas, tokens, hashes sensibles y certificados PFX antes de publicar.
