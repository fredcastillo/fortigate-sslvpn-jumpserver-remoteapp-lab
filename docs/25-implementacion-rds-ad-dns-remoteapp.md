# 25. Implementación de AD DS, DNS, RDS, RD Web Client y RemoteApp

## 25.1 Identidad y red de JUMP-SRV

| Parámetro | Valor final documentado |
|---|---|
| Hostname | `JUMP-SRV` |
| Sistema operativo | Windows Server 2019 |
| IPv4 | `10.21.75.138/29` |
| Máscara | `255.255.255.248` |
| Gateway | `10.21.75.137` |
| Dominio | `jumpserver.lab` |
| FQDN | `JUMP-SRV.jumpserver.lab` |
| Colección | `QuickSessionCollection` |

La versión de Windows y el dominio difieren de un diseño preliminar. La documentación final utiliza el sistema y dominio instalados en el laboratorio real: Windows Server 2019 y `jumpserver.lab`.

## 25.2 Active Directory y grupos

Se utiliza el directorio del dominio para distribuir las publicaciones RemoteApp por grupos. La pertenencia observada fue:

| Grupo de seguridad | Miembros observados | Alcance de publicación |
|---|---|---|
| `GG-RemoteApp-Web` | `user.std`, `user.priv` | Aplicación `Caja-Web`. |
| `GG-RemoteApp-Privileged` | `user.priv` | Aplicaciones administrativas adicionales `PuTTY` y `mstsc`. |

El usuario privilegiado pertenece a ambos grupos, por eso recibe la aplicación web y las herramientas adicionales. El estándar pertenece al grupo web y no al grupo privilegiado.

Consulta de lectura:

```powershell
Import-Module ActiveDirectory
Get-ADGroupMember 'GG-RemoteApp-Web' |
  Select-Object Name,SamAccountName
Get-ADGroupMember 'GG-RemoteApp-Privileged' |
  Select-Object Name,SamAccountName
```

## 25.3 Colección RDS

La colección `QuickSessionCollection` existe. Las aplicaciones fueron consultadas mediante:

```powershell
Import-Module RemoteDesktop
$broker = 'JUMP-SRV.jumpserver.lab'
$collection = 'QuickSessionCollection'
Get-RDSessionCollection -ConnectionBroker $broker |
  Format-Table CollectionName,CollectionDescription -AutoSize
Get-RDRemoteApp -ConnectionBroker $broker -CollectionName $collection |
  Format-List DisplayName,Alias,FilePath,ShowInWebAccess,UserGroups,RequiredCommandLine
```

Los resultados observados incluyen `ShowInWebAccess=True` para las tres RemoteApps. Las entradas y asignaciones son:

| Display name | Alias | Ruta del ejecutable | Parámetro | Grupos |
|---|---|---|---|---|
| Caja-Web | `Caja-Web` | `C:\Program Files\Internet Explorer\iexplore.exe` | `https://10.21.75.130/` | `GG-RemoteApp-Web`, `GG-RemoteApp-Privileged` |
| PuTTY | `PuTTY` | `C:\Program Files\PuTTY\putty.exe` | Cliente SSH | `GG-RemoteApp-Privileged` |
| Conexión a Escritorio remoto | `mstsc` | `C:\Windows\system32\mstsc.exe` | Cliente RDP de Windows | `GG-RemoteApp-Privileged` |

Las aplicaciones estándar prepublicadas WordPad, Paint y Calculadora fueron retiradas del catálogo RemoteApp; los binarios de Windows no se desinstalaron por esa operación.

## 25.4 Microsoft Remote Desktop Web Client

El cliente web de Microsoft se instaló y publicó desde el Jump Server usando el módulo PowerShell `RDWebClientManagement` versión `1.0.4`. Los cmdlets utilizados durante la implementación fueron:

```powershell
Install-RDWebClientPackage
Import-RDWebClientBrokerCert
Publish-RDWebClientPackage -Type Production -Latest
```

El certificado exportado/importado se asocia al broker y a las funciones RDS correspondientes. Los archivos identificados durante el proceso fueron:

```text
C:\RDS-Certificados\JUMP-SRV.jumpserver.lab.pfx
C:\RDS-Certificados\JUMP-SRV.jumpserver.lab.cer
```

El `.pfx` contiene material de clave privada y no debe subirse al repositorio. El `.cer` contiene el certificado público, pero también debe evaluarse si es necesario compartirlo; el repositorio no necesita distribuir archivos de certificado para describir la arquitectura.

Portal por FQDN:

```text
https://JUMP-SRV.jumpserver.lab/RDWeb/webclient/index.html
```

Portal por IP usado desde el cliente:

```text
https://10.21.75.138/RDWeb/webclient/index.html
```

Al utilizar la URL por IP, el nombre del certificado puede no coincidir con el host de la URL. Para un despliegue normal, es preferible el FQDN que coincide con el certificado y una cadena de confianza válida en el cliente.

## 25.5 Recorrido de usuario

1. El cliente SSL-VPN establece el túnel hacia FortiGate.
2. La ruta al Jump Server usa el túnel según la tabla observada del cliente.
3. Firefox abre el portal RD Web del Jump Server por HTTPS.
4. La cuenta del dominio inicia sesión.
5. RD Web presenta la lista de aplicaciones asignadas a los grupos del usuario.
6. La conexión posterior se ejecuta a través de la infraestructura RDS; los accesos del Jump al Web Server deben respetar las políticas de FortiGate.

## 25.6 Evidencia por perfil

**Estándar (`user.std`):** la sesión de RD Web mostró únicamente `Caja-Web`.

**Privilegiado (`user.priv`):** la sesión de RD Web mostró `Caja-Web`, `PuTTY` y `Conexión a Escritorio remoto`.

Las capturas de catálogo deben hacerse con cada cuenta y no mostrar contraseñas. La publicación visible se verifica con el catálogo; para una validación funcional de apertura se puede abrir la aplicación en la demostración prevista.

## 25.7 Comprobación de licenciamiento y roles

El inventario técnico de RDS debe conservar la salida actual de despliegue/roles, modo de licenciamiento configurado y estado de RD Licensing, si aplica al entorno. Las aplicaciones y el cliente web deben documentarse con datos obtenidos del servidor en la configuración final. Para la rúbrica, la evidencia clave del Web Client es el acceso al portal desde el navegador del cliente y la asignación diferenciada de RemoteApps.
