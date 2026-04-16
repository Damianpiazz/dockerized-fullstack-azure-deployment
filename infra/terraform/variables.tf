variable "prefix" {
  description = "Prefijo para nombrar todos los recursos"
  type        = string
  default     = "app"
}

variable "location" {
  description = "Region de Azure donde se despliegan los recursos"
  type        = string
  default     = "East US"
  # Otras opciones: "Brazil South", "West Europe", "East US 2"
}

variable "vm_size" {
  description = "Tamaño de la VM de Azure"
  type        = string
  default     = "Standard_B2s"
  # Standard_B1s  -> 1 vCPU, 1 GB  RAM  (muy basico, gratis a veces)
  # Standard_B2s  -> 2 vCPU, 4 GB  RAM  (recomendado para esta app)
  # Standard_B4ms -> 4 vCPU, 16 GB RAM  (si necesitas mas)
}

variable "admin_username" {
  description = "Usuario administrador de la VM"
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key" {
  description = "Clave publica SSH para acceder a la VM"
  type        = string
  # Pasa el valor via TF_VAR_ssh_public_key o terraform.tfvars
}

variable "ssh_source_ip" {
  description = "IP desde donde se permite SSH (tu IP publica). Usa * para cualquiera (no recomendado)"
  type        = string
  default     = "*"
  # Ejemplo: "190.210.x.x/32"
}

variable "domain_name" {
  description = "Dominio para la app (deja vacio si no tenes)"
  type        = string
  default     = ""
  # Ejemplo: "miapp.com"
}

variable "tags" {
  description = "Tags para los recursos de Azure"
  type        = map(string)
  default = {
    Environment = "production"
    Project     = "client-management"
    ManagedBy   = "terraform"
  }
}
