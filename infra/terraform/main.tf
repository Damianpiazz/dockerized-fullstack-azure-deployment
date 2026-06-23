terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  required_version = ">= 1.3.0"

  backend "azurerm" {}
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = false
      recover_soft_deleted_key_vaults = true
    }
  }
}

# ─────────────────────────────────────────────
# Resource Group
# ─────────────────────────────────────────────
resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-rg"
  location = var.location
  tags     = var.tags
}

# ─────────────────────────────────────────────
# Storage Account (Remote State)
# ─────────────────────────────────────────────
# Nota: el storage account para remote state debe crearse manualmente
# ANTES de hacer terraform init. Usar bootstrap.sh que ademas genera backend.hcl
#
#   ./bootstrap.sh [prefix] [location]
#   terraform init -backend-config=backend.hcl
#
# O bien crear manualmente:
#   az group create -n app-tfstate-rg -l eastus
#   az storage account create -n apptfstatestg -g app-tfstate-rg -l eastus --sku Standard_LRS
#   az storage container create -n terraform-state --account-name apptfstatestg
#   terraform init -backend-config="resource_group_name=app-tfstate-rg" \
#                  -backend-config="storage_account_name=apptfstatestg" \
#                  -backend-config="container_name=terraform-state" \
#                  -backend-config="key=app/terraform.tfstate"

# ─────────────────────────────────────────────
# Networking
# ─────────────────────────────────────────────
module "networking" {
  source = "./modules/networking"

  prefix             = var.prefix
  resource_group_name = azurerm_resource_group.main.name
  location           = azurerm_resource_group.main.location
  tags               = var.tags

  security_rules = [
    {
      name                       = "Allow-SSH"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      destination_port_range     = "22"
      source_address_prefix      = var.ssh_source_ip
    },
    {
      name                       = "Allow-HTTP"
      priority                   = 110
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      destination_port_range     = "80"
    },
    {
      name                       = "Allow-HTTPS"
      priority                   = 120
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      destination_port_range     = "443"
    },
    {
      name                       = "Allow-Grafana"
      priority                   = 130
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      destination_port_range     = "3001"
      source_address_prefix      = var.ssh_source_ip
    },
    {
      name                       = "Deny-All-Inbound"
      priority                   = 4096
      direction                  = "Inbound"
      access                     = "Deny"
      protocol                   = "*"
      destination_port_range     = "*"
    },
  ]
}

# ─────────────────────────────────────────────
# Compute
# ─────────────────────────────────────────────
module "compute" {
  source = "./modules/compute"

  prefix              = var.prefix
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  network_interface_id = module.networking.network_interface_id
  vm_size             = var.vm_size
  admin_username      = var.admin_username
  ssh_public_key      = var.ssh_public_key
  tags                = var.tags
}

# ─────────────────────────────────────────────
# Monitoring (Azure)
# ─────────────────────────────────────────────
module "monitoring" {
  source = "./modules/monitoring"

  prefix             = var.prefix
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  log_retention_days = 30
  enable_application_insights = var.enable_application_insights
  tags                = var.tags
}

# ─────────────────────────────────────────────
# DNS (opcional)
# ─────────────────────────────────────────────
resource "azurerm_dns_zone" "main" {
  count               = var.domain_name != "" ? 1 : 0
  name                = var.domain_name
  resource_group_name = azurerm_resource_group.main.name
  tags                = var.tags
}

resource "azurerm_dns_a_record" "root" {
  count               = var.domain_name != "" ? 1 : 0
  name                = "@"
  zone_name           = azurerm_dns_zone.main[0].name
  resource_group_name = azurerm_resource_group.main.name
  ttl                 = 300
  records             = [module.networking.public_ip]
}

resource "azurerm_dns_a_record" "www" {
  count               = var.domain_name != "" ? 1 : 0
  name                = "www"
  zone_name           = azurerm_dns_zone.main[0].name
  resource_group_name = azurerm_resource_group.main.name
  ttl                 = 300
  records             = [module.networking.public_ip]
}
