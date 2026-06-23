# ─────────────────────────────────────────────────────
# terraform.local.tfvars — valores para simulación local
# Usar con: terraform plan -var-file=terraform.local.tfvars
# ─────────────────────────────────────────────────────

prefix = "app-local"

location = "East US"
vm_size  = "Standard_B2s"

admin_username = "localuser"
ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQ placeholder-local-key-do-not-use"
ssh_source_ip  = "*"

domain_name = ""
