#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR"

echo "========================================="
echo "  Terraform — Simulación Local"
echo "========================================="
echo ""

# ── 1. Validación sin backend ────────────────
echo "[1/3] Validando sintaxis (fmt + validate)..."
terraform fmt -check -recursive 2>/dev/null && echo "  ✓ fmt OK" || echo "  ⚠  fmt necesita correcciones"
terraform init -backend=false -reconfigure 2>/dev/null
terraform validate 2>/dev/null && echo "  ✓ validate OK" || { echo "  ✗ validate falló"; exit 1; }

# ── 2. Plan con backend local ────────────────
echo ""
echo "[2/3] Ejecutando plan con backend local..."

# Backup del backend original
cp main.tf main.tf.bak

# Reemplazar backend azurerm → local
python3 -c "
import re
with open('main.tf') as f:
    content = f.read()
# Reemplaza el bloque terraform completo
new_block = '''terraform {
  required_providers {
    azurerm = {
      source  = \"hashicorp/azurerm\"
      version = \"~> 3.0\"
    }
  }
  required_version = \">= 1.3.0\"
  backend \"local\" {}
}'''
# Reemplazar backend 'azurerm' + su contenido por 'local'
content = re.sub(
    r'backend \"azurerm\"\s*\{[^}]*\}',
    'backend \"local\" {}',
    content,
    flags=re.DOTALL
)
with open('main.tf', 'w') as f:
    f.write(content)
"

terraform init -reconfigure -input=false 2>/dev/null
terraform plan \
  -var-file=terraform.local.tfvars \
  -input=false \
  -out=local.tfplan 2>/dev/null && echo "  ✓ plan generado (local.tfplan)" \
  || echo "  ⚠  plan requiere autenticación Azure — solo se validó sintaxis"

# ── 3. Restaurar ─────────────────────────────
echo ""
echo "[3/3] Restaurando main.tf original..."
mv main.tf.bak main.tf
rm -f local.tfplan

echo ""
echo "========================================="
echo "  Simulación completada"
echo "========================================="
