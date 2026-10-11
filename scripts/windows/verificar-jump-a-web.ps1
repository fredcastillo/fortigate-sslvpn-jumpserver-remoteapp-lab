<#
.SYNOPSIS
  Verificación de red no destructiva desde JUMP-SRV hacia WEB-SERVER.
.DESCRIPTION
  Comprueba la IP esperada del Jump Server y TCP 443, 3389 y 22 contra WEB-SERVER.
  No cambia configuración. Ejecutar en PowerShell desde el Jump Server.
#>
[CmdletBinding()]
param(
    [string]$WebServerIP = '10.21.75.130',
    [string]$ExpectedJumpIP = '10.21.75.138',
    [int[]]$Ports = @(443, 3389, 22)
)

$ErrorActionPreference = 'Continue'
Write-Host '=== FortiGate SSL-VPN Lab | Verificación Jump -> Web ===' -ForegroundColor Cyan
Write-Host (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
Write-Host "Equipo: $env:COMPUTERNAME"

$jumpAddresses = @(
    Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue |
    Where-Object { $_.IPAddress -eq $ExpectedJumpIP }
)
if ($jumpAddresses.Count -gt 0) {
    Write-Host "[OK] IP esperada presente: $ExpectedJumpIP" -ForegroundColor Green
    $jumpAddresses | Format-Table IPAddress, PrefixLength, InterfaceAlias -AutoSize
} else {
    Write-Host "[AVISO] No se encontró $ExpectedJumpIP en este equipo." -ForegroundColor Yellow
    Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue |
      Format-Table IPAddress, PrefixLength, InterfaceAlias -AutoSize
}

$results = foreach ($port in $Ports) {
    Write-Host "`nProbando TCP $WebServerIP`:$port ..."
    $result = Test-NetConnection -ComputerName $WebServerIP -Port $port -WarningAction SilentlyContinue
    [pscustomobject]@{
        Destino = $WebServerIP
        Puerto = $port
        TcpTestSucceeded = [bool]$result.TcpTestSucceeded
    }
}
$results | Format-Table -AutoSize

$failed = @($results | Where-Object { -not $_.TcpTestSucceeded })
if ($failed.Count -gt 0) {
    Write-Host "[RESULTADO] $($failed.Count) prueba(s) TCP fallaron. Revisa ruta, servicio y política desde el punto de origen." -ForegroundColor Yellow
    exit 1
}
Write-Host '[RESULTADO] Todos los puertos solicitados aceptaron TCP desde este equipo.' -ForegroundColor Green
Write-Host 'Nota: conectividad TCP no equivale a una validación funcional completa de cada aplicación.'
exit 0
