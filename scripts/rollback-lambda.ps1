param(
    [Parameter(Mandatory = $true)][string]$FunctionName,
    [Parameter(Mandatory = $true)][string]$Version,
    [string]$AliasName = "live"
)

$ErrorActionPreference = "Stop"

aws lambda update-alias `
    --function-name $FunctionName `
    --name $AliasName `
    --function-version $Version | Out-Null

Write-Host "Rolled $FunctionName alias $AliasName back to version $Version"
