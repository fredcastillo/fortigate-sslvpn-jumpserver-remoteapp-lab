<#
.SYNOPSIS
  Recopila evidencias de RDS/RemoteApp sin modificar el servidor.
.DESCRIPTION
  Ejecutar en JUMP-SRV en una sesión administrativa. La disponibilidad de los
  cmdlets depende de las herramientas RDS instaladas y del estado del despliegue.
#>
[CmdletBinding()]
param([string]$OutputPath = "$env:USERPROFILE\Desktop\FortiGate SSL-VPN Lab-RDS-evidence.txt")

$ErrorActionPreference = 'Continue'
$lines = [System.Collections.Generic.List[string]]::new()
$lines.Add('FortiGate SSL-VPN Lab - RDS/RemoteApp evidence')
$lines.Add("Captured: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')")
$lines.Add("Computer: $env:COMPUTERNAME")
$lines.Add('')

function Add-CommandOutput {
    param([string]$Title, [scriptblock]$Command)
    $lines.Add("=== $Title ===")
    try {
        $output = & $Command 2>&1 | Out-String -Width 240
        $lines.Add($output.TrimEnd())
    } catch {
        $lines.Add("Not available in this context: $($_.Exception.Message)")
    }
    $lines.Add('')
}

Add-CommandOutput 'IPv4 addresses' { Get-NetIPAddress -AddressFamily IPv4 | Select-Object IPAddress,PrefixLength,InterfaceAlias }
Add-CommandOutput 'Installed RemoteApp cmdlet availability' { Get-Command Get-RDRemoteApp -ErrorAction SilentlyContinue | Select-Object Name,Source }
Add-CommandOutput 'QuickSessionCollection RemoteApps' {
    if (Get-Command Get-RDRemoteApp -ErrorAction SilentlyContinue) {
        Get-RDRemoteApp -CollectionName 'QuickSessionCollection' -ErrorAction Stop |
            Select-Object Alias,DisplayName,FilePath,RequiredCommandLine,UserGroups,Visible
    } else {
        'Get-RDRemoteApp cmdlet is not available. Use Server Manager > Remote Desktop Services > Collections.'
    }
}

$parent = Split-Path -Parent $OutputPath
if ($parent -and -not (Test-Path $parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
$lines | Set-Content -Path $OutputPath -Encoding UTF8
Write-Host "Evidence written to: $OutputPath" -ForegroundColor Green
Write-Host 'Review the file and remove any sensitive names or internal details before committing it to a public repository.'
