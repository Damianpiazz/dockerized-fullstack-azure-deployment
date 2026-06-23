output "storage_account_name" {
  description = "Name of the storage account"
  value       = azurerm_storage_account.main.name
}

output "storage_container_name" {
  description = "Name of the state container"
  value       = azurerm_storage_container.state.name
}

output "storage_account_resource_group" {
  description = "Resource group of the storage account"
  value       = azurerm_storage_account.main.resource_group_name
}
