# FortiGate

- `captura-show-firewall-policy-previa-a-desactivar-wan.txt`: salida real compartida antes de deshabilitar por GUI `WAN_to_WEBSERVER_HTTPS`.
- `captura-show-firewall-vip.txt`: salida real de `show firewall vip` (el objeto VIP se conserva tras deshabilitar su policy de publicación).
- `estado-final-politicas-confirmado.md`: inventario del estado posterior a los cambios confirmados mediante GUI.

La captura de policy se conserva como evidencia de sesión; al preparar la entrega final, vuelve a exportar `show firewall policy` después de la configuración final y sustituye/añade la salida actual.
