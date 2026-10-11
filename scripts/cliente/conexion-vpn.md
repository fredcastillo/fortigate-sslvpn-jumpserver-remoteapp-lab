# Conexión del cliente SSL-VPN

El nodo `CLIENTE-FORTICLIENT` incluye el helper `lab-vpn` del laboratorio. Para establecer la sesión en la terminal del nodo:

```bash
lab-vpn connect
```

Introduce la contraseña en el prompt interactivo. Mantén la terminal que ejecuta el túnel abierta durante las pruebas. En otra terminal ejecuta:

```bash
./scripts/cliente/verificar-rutas-vpn.sh
```

Si el script no está en el directorio actual, ejecuta la ruta real donde lo copiaste. La imagen de cliente debe iniciarse desde GNS3; evita crear un contenedor Docker independiente que no tenga las conexiones de red de la topología.
