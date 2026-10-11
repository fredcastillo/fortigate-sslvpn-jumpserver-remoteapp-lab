# 15. Glosario

| Término | Significado en esta práctica |
|---|---|
| SSL-VPN Client-to-Site | Túnel remoto entre el cliente y FortiGate. |
| `ssl.root` | Interfaz lógica de FortiGate donde ingresa el tráfico SSL-VPN descifrado. |
| Split tunneling | Enrutamiento selectivo: solo destinos elegidos usan el túnel; el resto continúa por la interfaz normal del cliente. |
| Jump Server / bastion | Servidor controlado usado como punto intermedio para acceder a aplicaciones o recursos internos. |
| RDS | Remote Desktop Services de Windows Server. |
| RemoteApp | Publicación individual de una aplicación remota sin exponer todo el escritorio como catálogo general. |
| RD Web Client | Portal accesible desde navegador para iniciar aplicaciones/escritorios publicados por RDS. |
| VLAN 10 | Segmento de capa 2 de los usuarios. Su gateway está en R1-CISCO, no en FortiGate en esta topología. |
| `/25` | Prefijo IPv4 de 128 direcciones, 126 utilizables. |
| `/29` | Prefijo IPv4 de 8 direcciones, 6 utilizables. |
| VIP | Virtual IP de FortiGate, utilizada para mapear una dirección/puerto externo a un destino interno. |
| NAT | Traducción de direcciones. Está deshabilitado en la política interna Jump→Web. |
| TEST-NET | Rango reservado por IANA para documentación, utilizado aquí como ISP simulado. |
