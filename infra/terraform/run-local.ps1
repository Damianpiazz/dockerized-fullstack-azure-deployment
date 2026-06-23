#Requires -Version 5.1

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "  Terraform — Simulacion Local" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

$ErrorActionPreference = "Stop"
$DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location -LiteralPath $DIR

# ── 1. Validacion sin backend ────────────────
Write-Host "[1/3] Validando sintaxis (fmt + validate)..." -ForegroundColor Yellow
terraform fmt -check -recursive 2>$null
if ($LASTEXITCODE -eq 0) { Write-Host "  ✓ fmt OK" -ForegroundColor Green }
else { Write-Host "  ⚠  fmt necesita correcciones" -ForegroundColor Yellow }

terraform init -backend=false -reconfigure 2>$null
terraform validate 2>$null
if ($LASTEXITCODE -eq 0) { Write-Host "  ✓ validate OK" -ForegroundColor Green }
else { Write-Host "  ✗ validate fallo" -ForegroundColor Red; exit 1 }

# ── 2. Plan con backend local ────────────────
Write-Host ""
Write-Host "[2/3] Ejecutando plan con backend local..." -ForegroundColor Yellow

# Backup
Copy-Item -LiteralPath "main.tf" -Destination "main.tf.bak" -Force

# Reemplazar backend azurerm por local
$content = Get-Content -LiteralPath "main.tf" -Raw
$content = $content -replace 'backend "azurerm"\s*\{[^}]*\}', 'backend "local" {}'
Set-Content -LiteralPath "main.tf" -Value $content -NoNewline

terraform init -reconfigure -input=false 2>$null
if ($LASTEXITCODE -eq 0) {
    terraform plan `
        -var-file=terraform.local.tfvars `
        -input=false `
        -out=local.tfplan 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✓ plan generado (local.tfplan)" -ForegroundColor Green
    } else {
        Write-Host "  ⚠  plan requiere autenticacion Azure — solo se valido sintaxis" -ForegroundColor Yellow
    }
} else {
    Write-Host "  ⚠  terraform init fallo — solo se valido sintaxis" -ForegroundColor Yellow
}

# ── 3. Restaurar ─────────────────────────────
Write-Host ""
Write-Host "[3/3] Restaurando main.tf original..." -ForegroundColor Yellow
Move-Item -LiteralPath "main.tf.bak" -Destination "main.tf" -Force
if (Test-Path -LiteralPath "local.tfplan") { Remove-Item -LiteralPath "local.tfplan" -Force }

Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "  Simulacion completada" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
