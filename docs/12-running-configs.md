# 12. Running-configs y exportación segura

La entrega académica requiere configuraciones reales de los dispositivos de la topología. El directorio `running-configs/` separa la información por equipo. Solo deben llamarse **running-configs finales** a las salidas que se exporten desde la instancia P4 final; una captura anterior o una matriz de resumen no las sustituye.

## Estructura

| Carpeta | Export esperado |
|---|---|
| `running-configs/fortigate/` | `show system status`, interfaces, rutas, objetos relevantes, políticas, VIP y SSL-VPN (sin secretos). |
| `running-configs/cisco-switch/` | `show running-config`, VLAN y estado de puertos/trunks. |
| `running-configs/router-isp/` | `show running-config` de R1 y Router-ISP en archivos separados, además de interfaces/rutas/DHCP. |
| `running-configs/jump-server/` | IP, colección RDS, RemoteApps y grupos relevantes. |
| `running-configs/web-server/` | Red, listeners y parámetros pertinentes de Apache/SSH/XRDP; sin llaves privadas. |

## FortiGate

La práctica se configura mediante GUI. Las consultas de lectura que se pueden guardar después de revisar la GUI incluyen:

```text
get system status
show system interface
show router static
show firewall address
show firewall addrgrp
show firewall service custom
show firewall vip
show firewall policy
show vpn ssl settings
show vpn ssl web portal
show user group
```

Los archivos del directorio FortiGate incluyen el extracto de políticas que el estudiante compartió en la conversación y una tabla del estado final confirmado posteriormente. La captura literal se etiqueta para que se sepa que se tomó antes de deshabilitar `WAN_to_WEBSERVER_HTTPS`; no la uses como única evidencia del estado final sin una nueva exportación.

## Cisco IOS

En modo EXEC privilegiado, utiliza:

```text
show version
show ip interface brief
show running-config
show vlan brief
show interfaces trunk
show ip dhcp binding
show ip dhcp pool
show ip route
```

Guarda las salidas finales de Switch, R1 e ISP por separado. Es importante que la configuración provenga del nodo P4 activo, no de un archivo de otro proyecto o de un diseño previo.

## Windows Server

El script `scripts/maintenance/08-verificar-rds-remoteapps.ps1` recopila la colección y la configuración de las RemoteApps. Exporta y revisa la salida antes de publicarla. No incluyas contraseñas, hashes de contraseñas, certificados PFX ni información privada que no sea necesaria.

## Sanitización

- Elimina claves privadas (`.key`, `.pfx`, `.p12`, `.pem` con clave privada), contraseñas y PSK.
- Oculta tokens, cookies, datos de sesión y hashes sensibles.
- No subas backups binarios completos sin inspeccionar su contenido.
- Mantén los nombres de interfaces, subredes, servicios y políticas necesarios para reproducir el diseño.
- Conserva una copia privada íntegra para recuperación; el repositorio público debe contener solo datos saneados.
