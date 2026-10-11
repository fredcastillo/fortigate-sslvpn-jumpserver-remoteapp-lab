# 06. Jump Server, AD DS, RDS y RemoteApp

## Identidad del servidor

| Parámetro | Valor documentado |
|---|---|
| Hostname | `JUMP-SRV` |
| Sistema | Windows Server 2019 |
| IPv4 | `10.21.75.138/29` |
| Gateway | `10.21.75.137` |
| Dominio | `jumpserver.lab` |
| Colección RDS | `QuickSessionCollection` |
| URL RD Web Client | `https://JUMP-SRV.jumpserver.lab/RDWeb/webclient/index.html` |
| URL por IP usada desde el cliente | `https://10.21.75.138/RDWeb/webclient/index.html` |

JUMP-SRV reúne el directorio de laboratorio, DNS, Remote Desktop Services, portal RD Web, RemoteApp y las aplicaciones entregadas al usuario. Es el punto intermedio desde el que se administran o utilizan recursos controlados del Web Server.

## Certificados y Web Client

Durante la configuración se usó el paquete `RDWebClientManagement`. El certificado PFX del broker se ubicó en:

```text
C:\RDS-Certificados\JUMP-SRV.jumpserver.lab.pfx
```

Se exportó un certificado público `.cer`, se importó el certificado del broker y el paquete de Microsoft Remote Desktop Web Client se publicó en el servidor. El certificado debe asociarse al FQDN que se utiliza en la URL para evitar advertencias de identidad no coincidente; la confianza de la CA depende del navegador/cliente de prueba.

## Usuarios y grupos

| Grupo | Miembros registrados durante la validación | Rol |
|---|---|---|
| `GG-RemoteApp-Web` | `user.std`, `user.priv` | Acceso a Caja-Web. |
| `GG-RemoteApp-Privileged` | `user.priv` | Acceso adicional a herramientas privilegiadas. |

El inicio de sesión remoto como `user.std` mostró únicamente Caja-Web. El inicio de sesión como `user.priv` mostró tres aplicaciones. Esta evidencia confirma la diferenciación de los catálogos publicada en RD Web.

## RemoteApps publicadas

| Display name | Alias | Ejecutable | Parámetro / objetivo | Grupo(s) |
|---|---|---|---|---|
| `Caja-Web` | `Caja-Web` | `C:\Program Files\Internet Explorer\iexplore.exe` | URL configurada: `https://10.21.75.130/` | `GG-RemoteApp-Web`, `GG-RemoteApp-Privileged` |
| `PuTTY` | `PuTTY` | `C:\Program Files\PuTTY\putty.exe` | Cliente SSH | `GG-RemoteApp-Privileged` |
| `Conexión a Escritorio remoto` | `mstsc` | `C:\Windows\system32\mstsc.exe` | Cliente RDP | `GG-RemoteApp-Privileged` |

Las tres aplicaciones tienen `ShowInWebAccess=True` en la salida de `Get-RDRemoteApp`. La publicación se administra desde el despliegue RDS y los permisos se corresponden con los grupos de seguridad de Active Directory.

## Flujo de usuario

1. Cliente autenticado en SSL-VPN.
2. El navegador llega al portal RD Web del Jump Server mediante HTTPS.
3. El usuario inicia sesión en `jumpserver.lab`.
4. RD Web presenta solo las aplicaciones asignadas a los grupos de ese usuario.
5. Las conexiones posteriores que parten del Jump Server hacia Web se rigen por las políticas `JUMP_TO_WEBSERVER_P4` y `JUMP_TO_WEB_DENY_OTHER`.

## Verificación solo lectura

Ejecuta en PowerShell administrativo en JUMP-SRV, donde los módulos estén disponibles:

```powershell
Import-Module RemoteDesktop
$broker = 'JUMP-SRV.jumpserver.lab'
$collection = 'QuickSessionCollection'
Get-RDSessionCollection -ConnectionBroker $broker
Get-RDRemoteApp -ConnectionBroker $broker -CollectionName $collection |
  Format-List DisplayName,Alias,FilePath,ShowInWebAccess,UserGroups,RequiredCommandLine
```

Para revisar los grupos en el dominio:

```powershell
Import-Module ActiveDirectory
Get-ADGroupMember 'GG-RemoteApp-Web' | Select-Object Name,SamAccountName
Get-ADGroupMember 'GG-RemoteApp-Privileged' | Select-Object Name,SamAccountName
```

El script `scripts/maintenance/08-verificar-rds-remoteapps.ps1` contiene estas consultas para reutilizarlas durante las comprobaciones.
