# Inventario del estado final confirmado de políticas

Este inventario combina la captura `show firewall policy` compartida en la sesión con la confirmación posterior del estudiante de que `WAN_to_WEBSERVER_HTTPS` fue deshabilitada desde la GUI. No es una exportación CLI en bruto; para la entrega definitiva se recomienda guardar una nueva salida `show firewall policy` después de los últimos cambios.

| ID observado | Policy | Interfaces | Servicio | NAT | Estado comunicado |
|---:|---|---|---|---|---|
| 3 | `WEBSERVER_A_INTERNET` | `port2` → `port1` | `ALL` | Enabled | Figura activa en la última captura de CLI compartida. |
| 2 | `WAN_to_WEBSERVER_HTTPS` | `port1` → `port2` | HTTPS hacia VIP | — | Deshabilitada posteriormente desde GUI. |
| 4 | `SLVPN_to_WEBSERVER_SSH` | `ssl.root` → `port2` | SSH | — | Disabled. |
| 5 | `JUMP_TO_WEBSERVER_P4` | `port3` → `port2` | HTTPS, RDP, SSH | Disabled | Enabled; logging all. |
| 6 | `JUMP_SETUP_A_INTERNET` | `port3` → `port1` | DNS, HTTP, HTTPS | Enabled | Enabled; salida auxiliar documentada. |
| 7 | `SSLVPN_TO_JUMP_HTTPS` | `ssl.root` → `port3` | HTTPS | Disabled | Enabled; grupo `SSLVPN_USERS`. |
| 8 | `SSLVPN_TO_JUMP_DNS` | `ssl.root` → `port3` | DNS | Disabled | Enabled; grupo `SSLVPN_USERS`. |
| 9 | `JUMP_TO_WEB_DENY_OTHER` | `port3` → `port2` | ALL | Disabled | Enabled; acción DENY predeterminada. |

## Observaciones funcionales

- `JUMP_TO_WEBSERVER_P4` precede a `JUMP_TO_WEB_DENY_OTHER` en la política validada por el estudiante.
- La regla de Jump→Web permite los tres servicios requeridos y deshabilita NAT.
- La regla directa SSLVPN→Web SSH está deshabilitada.
- La publicación directa WAN→Web se deshabilitó; el objeto VIP se conserva.
- FortiGate se configura y demuestra mediante GUI como exige la práctica.
