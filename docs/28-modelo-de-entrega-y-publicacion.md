# 28. Modelo de entrega y publicación del repositorio

## 28.1 Entregables solicitados

La asignación requiere un repositorio propio para esta infraestructura y un video de demostración de máximo diez minutos. El archivo TXT debe incluir el enlace real del repositorio y la URL del video. Los nombres requeridos por la rúbrica siguen el patrón:

```text
FredCastillo_20252175_P4.txt
```

El archivo `ENTREGA_FredCastillo_20252175_P4.txt` contiene el enlace del video y el campo que se debe sustituir por la URL definitiva de GitHub una vez creado el repositorio.

## 28.2 Contenido del repositorio

- `README.md` en español, con enlace al video al comienzo.
- `README_EN.md` en inglés.
- `docs/` con trazabilidad, topología, IP, FortiGate, SSL-VPN, RDS, Web Server, Cisco/ISP, pruebas, recuperación, running-configs, evidencia, glosario, decisiones e hitos.
- `images/` en la raíz del repositorio, máximo diez capturas PNG.
- `docs/diagrams/` para los SVG editables.
- `scripts/` con comprobaciones y utilidades de mantenimiento/exportación.
- `running-configs/` organizado por FortiGate, switch, R1/ISP y servidores.
- `LICENSE`, `.gitignore`, `.gitattributes` y `CHANGELOG.md`.

## 28.3 Capturas

El ZIP incluye diez archivos PNG marcadores. Antes de entrega, sustitúyelos por capturas reales sacadas del video o del entorno de laboratorio, conservando exactamente estos nombres:

1. `images/01-topologia-general.png`
2. `images/02-fortigate-interfaces.png`
3. `images/03-vpn-rutas-cliente.png`
4. `images/04-remoteapp-estandar.png`
5. `images/05-remoteapp-privilegiado.png`
6. `images/06-pruebas-jump-web.png`
7. `images/07-politicas-firewall.png`
8. `images/08-vlan-usuarios.png`
9. `images/09-dhcp-usuarios.png`
10. `images/10-servicios-webserver.png`

No es necesario editar Markdown al sustituir imágenes. Los enlaces relativos apuntan a los nombres de la carpeta raíz `images/`.

## 28.4 Running-configs

Las carpetas en `running-configs/` son deliberadamente organizadas por dispositivo. La carpeta FortiGate contiene una captura literal anterior al cambio WAN y una nota de estado posterior confirmado. El resto de las configuraciones finales deben exportarse desde los dispositivos reales de P4. No sustituir un running-config real por un ejemplo inventado.

Antes de publicar, elimina claves privadas, PFX/P12, contraseñas, PSK, tokens, cookies y hashes sensibles. La configuración útil para reproducir la topología debe conservar los nombres de interfaces, los rangos IP, las rutas y los parámetros de política no secretos.

## 28.5 Carga a GitHub

1. Crea un repositorio público con el nombre elegido para esta práctica.
2. Descomprime el ZIP y entra a la carpeta raíz del proyecto.
3. Sube el contenido del directorio (no un segundo nivel de carpeta duplicado).
4. Verifica que `README.md` es la página inicial del repositorio y que la miniatura de YouTube aparece al principio.
5. Comprueba que los SVG de `docs/diagrams/` se renderizan y que las capturas de `images/` se visualizan.
6. Reemplaza la URL de GitHub en el TXT de entrega.
7. Confirma que el video es accesible y que dura menos de diez minutos.

## 28.6 Integridad de la evidencia

Las imágenes deben ser capturas reales de la topología o del video; no deben confundirse con los diagramas ilustrativos SVG. Cada export de configuración debe corresponder a los equipos finales de la práctica. El video enlazado debe mostrar la cara, escuchar la voz y mostrar fecha/hora según la rúbrica.
