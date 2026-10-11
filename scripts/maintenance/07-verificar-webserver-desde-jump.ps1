# Ejecutar en PowerShell de JUMP-SRV. Solo verifica conectividad; no cambia configuración.
$ErrorActionPreference = 'Continue'
$Destination = '10.21.75.130'
foreach ($Port in 22,443,3389) {
    $Result = Test-NetConnection -ComputerName $Destination -Port $Port -WarningAction SilentlyContinue
    [pscustomobject]@{ Destino=$Destination; Puerto=$Port; TcpTestSucceeded=$Result.TcpTestSucceeded }
}
