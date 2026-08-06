$ErrorActionPreference = "Stop"

Push-Location $PSScriptRoot/..

flutter pub get

dart run flutter_native_splash:create `
  -p config/flutter_native_splash.yaml

Pop-Location

Write-Host "Splash nativo generado. Los launcher icons versionados ya estan listos."
