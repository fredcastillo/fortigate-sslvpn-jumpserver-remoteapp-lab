# 10. Procedimiento de demostración — seis minutos

**Video:** [YouTube](https://youtu.be/XtP_YsM0tjs)

La secuencia prioriza la parte sensible (conexión VPN y catálogos RemoteApp) mientras JUMP-SRV está encendido, y luego continúa con políticas y red desde las GUIs.

| Tiempo | Acción | Evidencia |
|---:|---|---|
| 00:00–00:12 | Mostrar rostro, audio, fecha y hora | `Get-Date -Format "dd/MM/yyyy HH:mm:ss"` en PowerShell. |
| 00:12–00:30 | Mostrar topología GNS3 | WAN, R1/Cisco, VLAN10, FortiGate, Web y Jump. |
| 00:30–00:48 | Mostrar interfaces FortiGate | GUI; `port1`, `port2`, `port3`. |
| 00:48–01:15 | Establecer/verificar SSL-VPN | `lab-vpn connect` en primera terminal; mantenerla abierta. En segunda terminal, `ip -br addr show ppp0`, `ip route get 10.21.75.138` y `ip route get 10.21.75.130`. |
| 01:15–01:42 | Catálogo `user.std` | Solo Caja-Web. |
| 01:42–02:10 | Catálogo `user.priv` | Caja-Web, PuTTY, Conexión a Escritorio remoto. |
| 02:10–02:50 | Pruebas Jump → Web | PowerShell con puertos 443, 3389 y 22. |
| 02:50–03:30 | Políticas FortiGate | GUI, permiso y denegación. |
| 03:30–03:50 | Monitor SSL-VPN | GUI de FortiGate. |
| 03:50–04:10 | VLAN 10 | `show vlan brief` en switch Cisco. |
| 04:10–04:35 | Interfaces y DHCP R1 | `show ip interface brief`, `show ip dhcp binding`, `show running-config \\| section dhcp`. |
| 04:35–04:55 | ISP | `show ip interface brief`. |
| 04:55–05:20 | WEB-SERVER | `ip -br addr`, `ip route`, `ss -lntp`. |
| 05:20–05:40 | Resumen de políticas | GUI FortiGate. |
| 05:40–06:00 | Cierre y topología | GNS3 y cámara. |

## Comandos listos para pegar

### Fecha y hora en Windows

```powershell
Get-Date -Format "dd/MM/yyyy HH:mm:ss"
```

### VPN y rutas del cliente

```bash
lab-vpn connect
```

Deja la terminal de conexión abierta durante la demostración. En una segunda terminal:

```bash
ip -br addr show ppp0
ip route get 10.21.75.138
ip route get 10.21.75.130
```

### Pruebas desde Jump

```powershell
$target = '10.21.75.130'
$results = foreach ($port in 443,3389,22) {
  $r = Test-NetConnection -ComputerName $target -Port $port -WarningAction SilentlyContinue
  [pscustomobject]@{Destino=$target;Puerto=$port;TcpTestSucceeded=$r.TcpTestSucceeded}
}
$results | Format-Table -AutoSize
```

### Cisco switch / R1 / ISP

```text
show vlan brief
show ip interface brief
show ip dhcp binding
show running-config | section dhcp
```

### Web Server

```bash
ip -br addr
ip route
ss -lntp | grep -E ':(22|443|3389)\b' || true
```

## Preparación de OBS

- 1280×720, 30 FPS es suficiente para una demostración de configuración legible; usa codificación por hardware si está disponible y estable.
- Graba en MKV para tolerar mejor una interrupción de la aplicación de grabación.
- Revisa que la cámara y el micrófono funcionen en un clip corto antes de la toma final.
- Apaga JUMP-SRV después de terminar las pruebas previstas en ese equipo para reducir consumo durante el resto de la toma.
