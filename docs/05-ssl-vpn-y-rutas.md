# 05. SSL-VPN: conexión, pool y rutas

## Diseño

La práctica utiliza una SSL-VPN **Client-to-Site** que termina en el FortiGate, por `port1`. El listener documentado utiliza TCP/10443. El usuario de laboratorio pertenece al grupo `SSLVPN_USERS`; el portal de acceso remoto se identificó como `REMOTE_ACCESS` en la configuración de referencia.

El pool de direcciones se documentó como `SSLVPN_TUNNEL_ADDR1`, con rango `10.212.134.200–10.212.134.210`. Durante las comprobaciones se asignó al cliente `10.212.134.200` sobre la interfaz `ppp0`.

## Split tunneling

El portal se configuró con **Enabled based on policy destination**, con el pool `SSLVPN_TUNNEL_ADDR1`. En este modo, el cliente recibe rutas correspondientes a los destinos alcanzables por las políticas que aplican al tráfico SSL-VPN. Para esta práctica, la ruta de interés por el túnel es el Jump Server (`10.21.75.138`), no el Web Server (`10.21.75.130`).

La tabla siguiente captura la diferencia observada durante la validación del cliente:

| Destino | Salida observada en el cliente | Lectura |
|---|---|---|
| `10.21.75.138` — Jump Server | `dev ppp0`, origen `10.212.134.200` | El destino Jump fue instalado en la ruta VPN. |
| `10.21.75.130` — Web Server | `via 10.21.75.1 dev eth0`, origen `10.21.75.10` | La ruta a Web usa la red normal, no el túnel. Las políticas de firewall son necesarias para controlar si el tráfico se permite. |

## Conexión desde el cliente

En la terminal del contenedor `CLIENTE-FORTICLIENT` se utiliza la utilidad preinstalada del laboratorio:

```bash
lab-vpn connect
```

Se introducen las credenciales en el prompt interactivo. Debe mantenerse esa terminal abierta mientras se utilizan los recursos que dependen del túnel.

En una segunda terminal del cliente:

```bash
ip -br addr show ppp0
ip route get 10.21.75.138
ip route get 10.21.75.130
ip route show dev ppp0
```

El repositorio incluye `scripts/cliente/verificar-rutas-vpn.sh` para recopilar estas comprobaciones. La utilidad `lab-vpn` se proporciona por la imagen del contenedor del laboratorio; este repositorio no incorpora su binario interno ni credenciales.

## Portal RD Web

URL por nombre DNS:

```text
https://JUMP-SRV.jumpserver.lab/RDWeb/webclient/index.html
```

URL por IP utilizada en la demostración:

```text
https://10.21.75.138/RDWeb/webclient/index.html
```

Al utilizar el nombre DNS, el cliente requiere la resolución correcta de `JUMP-SRV.jumpserver.lab`. Al utilizar la IP, el navegador puede mostrar una advertencia si el certificado no coincide o no se confía en su CA; el certificado del despliegue se asoció al nombre del Jump Server.

## Evidencia de FortiGate

Muestra por GUI:

1. Listener SSL-VPN en la WAN.
2. Pool y grupo de usuarios autorizados.
3. Portal con split tunneling basado en destino de política.
4. SSL-VPN Monitor con sesión activa.
5. Políticas `SSLVPN_TO_JUMP_HTTPS` y `SSLVPN_TO_JUMP_DNS`.
6. Estado deshabilitado de `SLVPN_to_WEBSERVER_SSH`.

No uses una sola ruta como prueba de autorización completa: combina la ruta del cliente con la política de firewall y el resultado de la conexión al portal.
