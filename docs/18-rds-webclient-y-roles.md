# 18. RD Web Client, colección RDS y control por roles

## 18.1 Identidad y red de Jump Server

| Parámetro | Valor |
|---|---|
| Hostname | `JUMP-SRV` |
| Sistema operativo documentado | Windows Server 2019 |
| IPv4 | `10.21.75.138/29` |
| Gateway | `10.21.75.137` |
| Dominio de laboratorio | `jumpserver.lab` |
| Connection Broker | `JUMP-SRV.jumpserver.lab` |
| Colección | `QuickSessionCollection` |

El Jump Server concentra AD DS/DNS y las funciones de Remote Desktop Services necesarias para la colección RemoteApp/Remote Desktop Web Client. El objetivo del diseño es publicar aplicaciones individuales para usuarios de distinto rol, en vez de entregar el mismo catálogo a todos.

## 18.2 Usuarios y grupos

| Grupo de seguridad | Miembros vistos en comprobación | Propósito |
|---|---|---|
| `JUMPSERVER\GG-RemoteApp-Web` | `user.std`, `user.priv` | Publicación de `Caja-Web`. |
| `JUMPSERVER\GG-RemoteApp-Privileged` | `user.priv` | Publicación adicional de PuTTY y RDP. |

La pertenencia al grupo privilegiado es la diferencia que habilita las herramientas de administración. No se deben guardar contraseñas de `user.std`, `user.priv` ni cuentas de dominio en scripts o en las capturas de evidencia.

## 18.3 Aplicaciones RemoteApp

| Display name | Alias | Ejecutable | Argumento/objetivo | Grupos |
|---|---|---|---|---|
| Caja-Web | `Caja-Web` | `C:\Program Files\Internet Explorer\iexplore.exe` | `https://10.21.75.130/` | Web + Privileged |
| PuTTY | `PuTTY` | `C:\Program Files\PuTTY\putty.exe` | Cliente SSH | Privileged |
| Conexión a Escritorio remoto | `mstsc` | `C:\Windows\system32\mstsc.exe` | Cliente RDP | Privileged |

En `Get-RDRemoteApp`, las tres aplicaciones se vieron con `ShowInWebAccess=True` y sus grupos correspondientes. El catálogo observado desde el portal fue:

- `JUMPSERVER\user.std`: solamente `Caja-Web`.
- `JUMPSERVER\user.priv`: `Caja-Web`, `PuTTY` y `Conexión a Escritorio remoto`.

## 18.4 Portal RD Web y URL

Portal de navegador utilizado en la topología:

```text
https://10.21.75.138/RDWeb/webclient/index.html
```

Nombre DNS previsto:

```text
https://JUMP-SRV.jumpserver.lab/RDWeb/webclient/index.html
```

El uso del FQDN requiere resolución interna adecuada. El certificado debe corresponder con el nombre usado y estar en una cadena de confianza reconocida por el navegador. La URL por IP se utilizó para la demostración del portal.

## 18.5 Publicación del Microsoft Remote Desktop Web Client

El módulo `RDWebClientManagement` versión `1.0.4` quedó disponible en el servidor. Los cmdlets que se utilizaron para la instalación/importación/publicación incluyen:

```powershell
Install-RDWebClientPackage
Import-RDWebClientBrokerCert
Publish-RDWebClientPackage -Type Production -Latest
```

Estos comandos son un registro operativo de las tareas realizadas; al reproducir la publicación, consulta primero el estado actual del paquete y el certificado. No vuelvas a importar un PFX ni a publicar el paquete si el cliente ya está publicado y funciona.

## 18.6 Inspección de RDS mediante PowerShell

Las siguientes consultas son de lectura y se ejecutan en una sesión administrativa de Jump Server:

```powershell
Import-Module RemoteDesktop
$broker = 'JUMP-SRV.jumpserver.lab'
$collection = 'QuickSessionCollection'
Get-RDSessionCollection -ConnectionBroker $broker |
  Format-Table CollectionName,CollectionDescription -AutoSize
Get-RDRemoteApp -ConnectionBroker $broker -CollectionName $collection |
  Format-List DisplayName,Alias,FilePath,ShowInWebAccess,UserGroups,RequiredCommandLine
```

Para revisar los grupos en Active Directory:

```powershell
Import-Module ActiveDirectory
Get-ADGroupMember 'GG-RemoteApp-Web' |
  Select-Object Name,SamAccountName
Get-ADGroupMember 'GG-RemoteApp-Privileged' |
  Select-Object Name,SamAccountName
```

El archivo `scripts/maintenance/08-verificar-rds-remoteapps.ps1` agrupa comprobaciones de lectura y permite guardar la salida en un archivo local para revisión.

## 18.7 Evidencia de publicación por rol

1. Captura el catálogo de `user.std`, sin contraseña visible.
2. Cierra esa sesión y entra como `user.priv`.
3. Captura el catálogo de `user.priv`.
4. Para cada aplicación que se ejecute durante una demostración, conserva una captura independiente del catálogo; la visibilidad y la ejecución son evidencias diferentes.
5. Comprueba que no se filtren credenciales o datos de sesión en la grabación.

## 18.8 Licenciamiento y certificados

El modo de licenciamiento RDS, la asociación del certificado y el estado del despliegue deben consultarse desde Server Manager/RDS y el administrador de licencias de Windows. La mera publicación del RD Web Client no sustituye la verificación de licenciamiento del despliegue. Conserva en el repositorio solo la configuración no secreta que sea necesaria para documentar esos componentes; no publiques archivos PFX ni sus contraseñas.
