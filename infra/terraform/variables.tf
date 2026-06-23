variable "prefix" {
  description = "Prefix for naming all Azure resources"
  type        = string
  default     = "app"
}

variable "location" {
  description = "Azure region for deployment"
  type        = string
  default     = "East US"
}

variable "vm_size" {
  description = "Azure VM size"
  type        = string
  default     = "Standard_B2s"
}

variable "admin_username" {
  description = "Admin username for the VM"
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key" {
  description = "SSH public key for VM access (required)"
  type        = string
}

variable "ssh_source_ip" {
  description = "Source IP for SSH access (format: X.X.X.X/32)"
  type        = string
  default     = "*"
}

variable "domain_name" {
  description = "Custom domain name (leave empty if not using)"
  type        = string
  default     = ""
}

variable "enable_application_insights" {
  description = "Enable Azure Application Insights (disabled by default — usar Prometheus/Grafana)"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags for Azure resources"
  type        = map(string)
  default = {
    Environment = "production"
    Project     = "client-management"
    ManagedBy   = "terraform"
  }
}
