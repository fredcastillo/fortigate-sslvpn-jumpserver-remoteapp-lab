# 07. WEB-SERVER y servicios de destino

## Identidad y red

| Parámetro | Valor |
|---|---|
| Sistema | Ubuntu 22.04.5 LTS |
| Nombre lógico de nodo | `web-server-lab` / WEB-SERVER |
| IPv4 | `10.21.75.130/29` |
| Gateway | `10.21.75.129` |
| Interfaz de red en el contenedor | `eth0` |
| DocumentRoot Apache | `/var/www/html` |

## Servicios

En las comprobaciones de la práctica quedaron activos:

| Servicio | Puerto TCP | Uso en la topología |
|---|---:|---|
| Apache HTTPS | 443 | Sistema de Caja y servicio web objetivo de las políticas. |
| OpenSSH Server | 22 | Administración/prueba autorizada desde Jump. |
| XRDP | 3389 | Servicio RDP necesario para la prueba desde Jump. |

Para comprobar listeners dentro del Web Server:

```bash
ip -br addr
ip route
ss -lntp | grep -E ':(22|443|3389)\b' || true
```

El repositorio incluye scripts de solo lectura y de recuperación. La recuperación de red restaura `10.21.75.130/29` y la ruta por `10.21.75.129`; los scripts de recuperación deben ejecutarse dentro del contenedor Web Server y no en la GNS3 VM.

## Relación con la política de seguridad

El servidor web es el destino de la política `JUMP_TO_WEBSERVER_P4`. En la práctica se verificaron los puertos TCP 443, 3389 y 22 desde JUMP-SRV. El diseño de firewall permite esos puertos desde `JUMP_SERVER` y deniega el resto del tráfico entre esas dos redes.

## Comprobación local de servicios

```bash
service apache2 status
service ssh status || service sshd status
service xrdp status
ss -lntp | grep -E ':(22|443|3389)\b' || true
```

En los contenedores GNS3 puede no existir `systemd`; por esa razón se usa `service`/`ss` en lugar de depender de `systemctl`. La verificación del puerto no sustituye la validación del contenido de la aplicación.
