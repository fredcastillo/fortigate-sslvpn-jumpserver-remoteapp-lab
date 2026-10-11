# Solo lectura. Ejecutar en JUMP-SRV con módulo RemoteDesktop y ActiveDirectory disponibles.
$Broker = 'JUMP-SRV.jumpserver.lab'
$Collection = 'QuickSessionCollection'
Import-Module RemoteDesktop -ErrorAction Stop
Import-Module ActiveDirectory -ErrorAction Continue
Write-Host '=== Colección ===' -ForegroundColor Cyan
Get-RDSessionCollection -ConnectionBroker $Broker |
  Format-Table CollectionName,CollectionDescription -AutoSize
Write-Host "=== RemoteApps en $Collection ===" -ForegroundColor Cyan
Get-RDRemoteApp -ConnectionBroker $Broker -CollectionName $Collection |
  Format-List DisplayName,Alias,FilePath,ShowInWebAccess,UserGroups,RequiredCommandLine
Write-Host '=== Miembros de grupos (si AD module está disponible) ===' -ForegroundColor Cyan
Get-ADGroupMember 'GG-RemoteApp-Web' -ErrorAction Continue |
  Select-Object Name,SamAccountName,ObjectClass | Format-Table -AutoSize
Get-ADGroupMember 'GG-RemoteApp-Privileged' -ErrorAction Continue |
  Select-Object Name,SamAccountName,ObjectClass | Format-Table -AutoSize
