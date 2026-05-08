param(
    [string]$AppDir = "app"
)

$ErrorActionPreference = "Stop"

Push-Location $AppDir
try {
    mvn clean test package
    Write-Host "Built artifact: $AppDir/target/serverless-java-api.jar"
}
finally {
    Pop-Location
}
