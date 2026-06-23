#!/bin/bash
set -euo pipefail

# ─────────────────────────────────────────────
# Bootstrap: crea el Storage Account para remote state
# Ejecutar UNA SOLA VEZ antes de terraform init
# ─────────────────────────────────────────────

PREFIX="${1:-app}"
LOCATION="${2:-eastus}"

RG_NAME="${PREFIX}-tfstate-rg"
SA_NAME="${PREFIX}tfstatestg"
CONTAINER_NAME="terraform-state"

echo "========================================="
echo "  Bootstrap - Remote State Setup"
echo "========================================="

echo "Resource Group: $RG_NAME"
echo "Storage Account: $SA_NAME"
echo "Container: $CONTAINER_NAME"
echo ""

# Crear resource group
az group create \
  --name "$RG_NAME" \
  --location "$LOCATION" \
  --tags "Environment=bootstrap" "Project=terraform-state" "ManagedBy=bootstrap"

# Crear storage account
az storage account create \
  --name "$SA_NAME" \
  --resource-group "$RG_NAME" \
  --location "$LOCATION" \
  --sku Standard_LRS \
  --kind StorageV2 \
  --min-tls-version TLS1_2

# Obtener key
ACCOUNT_KEY=$(az storage account keys list \
  --resource-group "$RG_NAME" \
  --account-name "$SA_NAME" \
  --query "[0].value" \
  --output tsv)

# Crear container
az storage container create \
  --name "$CONTAINER_NAME" \
  --account-name "$SA_NAME" \
  --account-key "$ACCOUNT_KEY"

# Generar backend.hcl para terraform init
cat > backend.hcl << EOF
resource_group_name  = "$RG_NAME"
storage_account_name = "$SA_NAME"
container_name       = "$CONTAINER_NAME"
key                  = "app/terraform.tfstate"
EOF

echo "  ✓ backend.hcl generado"

echo ""
echo "========================================="
echo "  Bootstrap completado!"
echo "========================================="
echo ""
echo "Ejecutá ahora:"
echo "  terraform init -backend-config=backend.hcl"
echo "  terraform plan"
echo "========================================="
