output "vm_public_ip" {
  description = "Public IP address of the VM"
  value       = module.networking.public_ip
}

output "vm_name" {
  description = "Name of the VM"
  value       = module.compute.vm_name
}

output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "ssh_command" {
  description = "SSH command to connect to the VM"
  value       = "ssh ${var.admin_username}@${module.networking.public_ip}"
}

output "app_url" {
  description = "Application URL"
  value       = var.domain_name != "" ? "https://${var.domain_name}" : "http://${module.networking.public_ip}"
}

output "grafana_url" {
  description = "Grafana URL"
  value       = "http://${module.networking.public_ip}:3001"
}

output "dns_nameservers" {
  description = "DNS nameservers (if using custom domain)"
  value       = var.domain_name != "" ? azurerm_dns_zone.main[0].name_servers : []
}

output "application_insights_connection_string" {
  description = "Application Insights connection string (sensitive — vacío si está deshabilitado)"
  value       = var.enable_application_insights ? module.monitoring.application_insights_connection_string : ""
  sensitive   = true
}
