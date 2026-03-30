$ErrorActionPreference = 'Stop'

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Resolve-Path (Join-Path $scriptDir '..')

Push-Location $projectRoot
try {
    dart run tool\generate_excel.dart
    if ($LASTEXITCODE -ne 0) {
        throw "Fallo al generar el Excel."
    }
    Write-Host "Excel generado correctamente en assets/data/virtual_football_data.xlsx"
}
finally {
    Pop-Location
}
