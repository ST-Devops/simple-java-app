param(
    [ValidateSet("dev", "prod")][string]$Environment = "dev"
)

$ErrorActionPreference = "Stop"

Push-Location "infra/environments/$Environment"
try {
    terraform init
    terraform fmt -check -recursive ../..
    terraform validate
    terraform plan
}
finally {
    Pop-Location
}
