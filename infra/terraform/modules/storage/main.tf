resource "azurerm_storage_account" "main" {
  name                     = "${replace(var.prefix, "-", "")}stg"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
  tags                     = var.tags

  blob_properties {
    versioning_enabled = false
  }
}

resource "azurerm_storage_container" "state" {
  name                  = "terraform-state"
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "private"
}
