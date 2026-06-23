output "vm_id" {
  description = "ID of the VM"
  value       = azurerm_linux_virtual_machine.main.id
}

output "vm_name" {
  description = "Name of the VM"
  value       = azurerm_linux_virtual_machine.main.name
}

output "admin_username" {
  description = "Admin username"
  value       = azurerm_linux_virtual_machine.main.admin_username
}
