# Setup

## Requisitos

- [Node.js >= 20](https://nodejs.org)
- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) (para deploy)
- [Terraform >= 1.3](https://developer.hashicorp.com/terraform/install) (para infra)
- Par de claves SSH

## Desarrollo local

```bash
# 1. Clonar el repo
git clone <repo-url>
cd dockerized-fullstack-azure-deployment

# 2. Instalar dependencias del backend
cd backend
npm install
npx prisma generate
cd ..

# 3. Iniciar entorno de desarrollo
make dev
# o
docker compose -f docker-compose.dev.yml up --build -d

# 4. Abrir en el navegador
# Frontend: http://localhost:3000
# Backend:  http://localhost:8080/api/clients
# Health:   http://localhost:8080/health
```

## Detener el entorno

```bash
make dev-down
# o
docker compose -f docker-compose.dev.yml down
```

## Ver logs

```bash
make dev-logs
# o
docker compose -f docker-compose.dev.yml logs -f
```

## Producción (Azure)

### 1. Crear remote state (una vez)

```bash
cd infra/terraform
chmod +x bootstrap.sh
./bootstrap.sh
```

### 2. Configurar Terraform

```bash
cp terraform.tfvars.example terraform.tfvars
# Editar: ssh_public_key, ssh_source_ip
```

### 3. Crear infraestructura

```bash
terraform init -backend-config=backend.hcl
terraform plan
terraform apply
```

Al finalizar muestra:

```text
vm_public_ip = "52.x.x.x"
ssh_command  = "ssh azureuser@52.x.x.x"
app_url      = "http://52.x.x.x"
```

### 4. Configurar la VM (primera vez)

```bash
ssh azureuser@IP_DE_LA_VM
cd /opt/app
nano .env   # Crear con valores reales (ver .env.production.example)
```

### 5. Configurar GitHub Secrets

| Secret | Valor |
|---|---|
| `VM_HOST` | IP pública de la VM |
| `VM_USER` | `azureuser` |
| `VM_SSH_PRIVATE_KEY` | Contenido de `~/.ssh/id_rsa` |
| `NEXT_PUBLIC_API_URL` | `http://IP_DE_LA_VM/api` |

### 6. Pushear a main

El workflow CI/CD se encarga de:
1. Ejecutar tests
2. Buildear y pushear imágenes a GHCR
3. Hacer deploy en la VM via SSH

## SSL con Let's Encrypt (opcional)

```bash
ssh azureuser@IP_DE_LA_VM
sudo certbot --nginx -d miapp.com -d www.miapp.com
```
