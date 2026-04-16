output "vm_public_ip" {
  description = "IP publica de la VM"
  value       = azurerm_public_ip.main.ip_address
}

output "vm_name" {
  description = "Nombre de la VM"
  value       = azurerm_linux_virtual_machine.main.name
}

output "resource_group_name" {
  description = "Nombre del Resource Group"
  value       = azurerm_resource_group.main.name
}

output "ssh_command" {
  description = "Comando SSH para conectarte a la VM"
  value       = "ssh ${var.admin_username}@${azurerm_public_ip.main.ip_address}"
}

output "app_url" {
  description = "URL de la aplicacion"
  value       = var.domain_name != "" ? "https://${var.domain_name}" : "http://${azurerm_public_ip.main.ip_address}"
}

output "dns_nameservers" {
  description = "Nameservers del DNS zone (si usas dominio propio)"
  value       = var.domain_name != "" ? azurerm_dns_zone.main[0].name_servers : []
}
