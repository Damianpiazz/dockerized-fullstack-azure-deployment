# Deploy a Azure

## Prerrequisitos

- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) instalado y logueado (`az login`)
- [Terraform >= 1.3](https://developer.hashicorp.com/terraform/install) instalado
- Par de claves SSH generada (`ssh-keygen -t rsa -b 4096`)
- Repositorio en GitHub con GitHub Actions habilitado

---

## Paso 1: Crear infraestructura en Azure

```bash
cd infra/terraform

# 1. Crear storage account para remote state + backend.hcl
./bootstrap.sh

# 2. Configurar variables de Terraform
cp terraform.tfvars.example terraform.tfvars
# EDITAR terraform.tfvars:
#   - ssh_public_key = "ssh-rsa AAAAB3... tu_clave_publica"
#   - ssh_source_ip  = "TU_IP/32" (o "*" para cualquier IP)

# 3. Inicializar Terraform con backend remoto
terraform init -backend-config=backend.hcl

# 4. Ver el plan y crear recursos (~5-10 min)
terraform plan
terraform apply
```

Al finalizar Terraform te muestra:

```
vm_public_ip = "52.x.x.x"
ssh_command  = "ssh azureuser@52.x.x.x"
app_url      = "http://52.x.x.x"
```

Anotá la IP pública.

---

## Paso 2: Esperar que la VM termine de configurarse

El cloud-init tarda ~3-5 min en instalar Docker, Nginx, y crear la estructura.

```bash
# Esperar que termine
ssh azureuser@IP_DE_LA_VM "tail -f /var/log/setup.log"
# Cuando veas "Setup finalizado", ya está lista
```

---

## Paso 3: Crear archivo `.env` en la VM

```bash
ssh azureuser@IP_DE_LA_VM

# Crear /opt/app/.env con valores reales
cat > /opt/app/.env << 'EOF'
POSTGRES_DB=app_db
POSTGRES_USER=app_user
POSTGRES_PASSWORD=una_password_segura_aqui
DOCKER_REGISTRY=ghcr.io/TU_USUARIO_GITHUB
IMAGE_TAG=latest
CORS_ORIGIN=http://IP_DE_LA_VM
NEXT_PUBLIC_API_URL=http://IP_DE_LA_VM/api
GRAFANA_ADMIN_USER=admin
GRAFANA_ADMIN_PASSWORD=una_password_segura_aqui
EOF

exit
```

---

## Paso 4: Configurar GitHub Secrets

Ir a GitHub → Settings → Secrets and variables → Actions → New repository secret:

| Secret | Valor |
|---|---|
| `VM_HOST` | IP pública de la VM (ej: `52.x.x.x`) |
| `VM_USER` | `azureuser` |
| `VM_SSH_PRIVATE_KEY` | Contenido de tu clave privada (`cat ~/.ssh/id_rsa`) |
| `NEXT_PUBLIC_API_URL` | `http://IP_DE_LA_VM/api` (o dominio) |

---

## Paso 5: Pushear a `main` y hacer deploy

```bash
git add .
git commit -m "Deploy a Azure"
git push origin main
```

GitHub Actions ejecuta automáticamente:

1. **CI**: lint → tests (backend + frontend)
2. **CD**: build & push imágenes a GHCR → SSH deploy a la VM
3. **Health check**: verifica que `http://localhost/health` responda 200

Podés monitorear en GitHub → Actions.

---

## Paso 6: Verificar

| URL | Qué es |
|---|---|
| `http://IP_DE_LA_VM` | Frontend |
| `http://IP_DE_LA_VM/api/clients` | API |
| `http://IP_DE_LA_VM/health` | Health check |
| `http://IP_DE_LA_VM/grafana` | Grafana (admin / la_password) |
| `http://IP_DE_LA_VM:3001` | Grafana directo |

---

## Opcional: SSL con Let's Encrypt (si tenés dominio)

```bash
ssh azureuser@IP_DE_LA_VM
sudo certbot --nginx -d tudominio.com -d www.tudominio.com
```

---

## Resumen de comandos

```bash
# Infraestructura
cd infra/terraform
./bootstrap.sh
cp terraform.tfvars.example terraform.tfvars
# editar terraform.tfvars
terraform init -backend-config=backend.hcl
terraform apply

# Configurar VM
ssh azureuser@$(terraform output -raw vm_public_ip)
# crear /opt/app/.env (ver paso 3)
exit

# En GitHub: agregar secrets y pushear a main
git push origin main
```
