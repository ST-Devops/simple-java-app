param(
    [Parameter(Mandatory = $true)][string]$FunctionName,
    [Parameter(Mandatory = $true)][string]$ArtifactPath,
    [string]$AliasName = "live"
)

$ErrorActionPreference = "Stop"

Write-Host "Updating Lambda code for $FunctionName"
$update = aws lambda update-function-code `
    --function-name $FunctionName `
    --zip-file "fileb://$ArtifactPath" `
    --publish | ConvertFrom-Json

$version = $update.Version
Write-Host "Published version $version"

Write-Host "Pointing alias $AliasName to version $version"
aws lambda update-alias `
    --function-name $FunctionName `
    --name $AliasName `
    --function-version $version | Out-Null

Write-Host "Deployment complete"
