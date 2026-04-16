# Infraestructura - Deploy en Azure con Terraform

## Arquitectura

```
Internet
   │
   ▼
[Azure NSG]
  80 / 443 / 22
   │
   ▼
[Azure VM - Ubuntu 22.04]
   │
   ▼
[Nginx - Reverse Proxy]
  :80 / :443
   ├── /api/* ──────► [Docker: app-backend :8080]
   │                         │
   │                         ▼
   │                  [Docker: app-postgres :5432]
   │
   └── /* ──────────► [Docker: app-frontend :3000]
```
 
**Puertos expuestos al exterior:** 22 (SSH), 80 (HTTP), 443 (HTTPS)
**Puertos internos (solo localhost):** 3000, 8080, 5432
 
---
 
## Prerequisitos
 
- [Terraform >= 1.3](https://developer.hashicorp.com/terraform/install)
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
- Cuenta de Azure con una suscripción activa
- Par de claves SSH

## Tabla de puertos

| Servicio           | Puerto Local | Puerto en Docker | Descripción                    |
| ------------------ | ------------ | ---------------- | ------------------------------ |
| Frontend (Next.js) | 3000         | 3000             | Interfaz web (React/Next)      |
| Backend (Express)  | 8080         | 8080             | API REST                       |
| PostgreSQL         | 5432         | 5432             | Base de datos                  |

---
 
## Paso 1: Autenticar Azure CLI
 
```bash
az login
az account show  # Verificar que estás en la suscripcion correcta
 
# Si tenés varias suscripciones:
az account list --output table
az account set --subscription "ID_DE_TU_SUSCRIPCION"
```
 
---
 
## Paso 2: Configurar Terraform
 
```bash
cd infra/terraform
 
# Copiar el archivo de variables
cp terraform.tfvars.example terraform.tfvars
 
# Editar con tus valores reales
nano terraform.tfvars
```
 
Valores que necesitás completar en `terraform.tfvars`:
 
```hcl
# Tu clave SSH publica
ssh_public_key = "ssh-rsa AAAA..."  # cat ~/.ssh/id_rsa.pub
 
# Tu IP para restringir SSH (recomendado)
ssh_source_ip = "190.x.x.x/32"     # curl ifconfig.me
 
# Dominio (opcional)
domain_name = ""                    # "miapp.com" si tenes
```
 
---
 
## Paso 3: Crear la VM con Terraform
 
```bash
cd infra/terraform
 
# Inicializar Terraform
terraform init
 
# Ver qué va a crear
terraform plan
 
# Crear la infraestructura (tarda ~3-5 minutos)
terraform apply
 
# Al finalizar, Terraform muestra:
# - vm_public_ip: "X.X.X.X"
# - ssh_command:  "ssh azureuser@X.X.X.X"
# - app_url:      "http://X.X.X.X"
```
 
> ⚠️ **El script setup.sh se ejecuta automáticamente** al crear la VM.
> Instalará Docker, Nginx y Certbot. Puede tardar 3-5 minutos adicionales.
 
---
 
## Paso 4: Configurar la VM manualmente (primera vez)
 
```bash
# Conectarse a la VM
ssh azureuser@IP_DE_LA_VM
 
# Verificar que Docker está instalado
docker --version
docker compose version
 
# Verificar que Nginx está corriendo
systemctl status nginx
 
# Ir al directorio de la app
cd /opt/app
 
# Crear el archivo .env con tus valores reales
nano .env
```
 
Contenido del `.env` en la VM:
 
```env
POSTGRES_DB=app_db
POSTGRES_USER=app_user
POSTGRES_PASSWORD=una_password_muy_segura_aqui_cambiar
 
DOCKER_REGISTRY=ghcr.io/TU_USUARIO_GITHUB
IMAGE_TAG=latest
 
CORS_ORIGIN=http://IP_DE_LA_VM
NEXT_PUBLIC_API_URL=http://IP_DE_LA_VM/api
```
 
---
 
## Paso 5: Configurar GitHub Actions
 
### 5.1 Habilitar GitHub Container Registry
 
En tu repo de GitHub:
1. Settings → Actions → General
2. Asegurarse de que "Read and write permissions" esté activado
### 5.2 Crear los Secrets en GitHub
 
Ve a: **Settings → Secrets and variables → Actions → New repository secret**
 
| Secret | Valor |
|--------|-------|
| `VM_HOST` | IP pública de la VM (ej: `52.x.x.x`) |
| `VM_USER` | `azureuser` |
| `VM_SSH_PRIVATE_KEY` | Contenido de `~/.ssh/id_rsa` (clave PRIVADA) |
| `NEXT_PUBLIC_API_URL` | `http://IP_DE_LA_VM/api` |
 
> 💡 El `GITHUB_TOKEN` se genera automáticamente, no necesitás crearlo.
 
### 5.3 Copiar el docker-compose y workflow
 
```bash
# En tu repositorio local
cp docker-compose.prod.yml ./docker-compose.prod.yml
mkdir -p .github/workflows
cp .github/workflows/deploy.yml ./.github/workflows/deploy.yml
 
git add .
git commit -m "feat: add CI/CD pipeline"
git push origin main
```
 
### 5.4 Primer deploy manual
 
Después del push, el workflow se activa automáticamente.
Podés verlo en: **GitHub → Actions → CI/CD Deploy**
 
---
 
## Paso 6: SSL con Let's Encrypt (opcional, si tenés dominio)
 
```bash
# En la VM
ssh azureuser@IP_DE_LA_VM
 
# Configurar SSL (reemplaza miapp.com con tu dominio)
sudo certbot --nginx -d miapp.com -d www.miapp.com
 
# Certbot modifica Nginx automáticamente
# Verifica que funcione:
sudo nginx -t
sudo systemctl reload nginx
```
 
Certbot renueva el certificado automáticamente. Para verificar:
```bash
sudo certbot renew --dry-run
```
 
---
 
## Comandos útiles en la VM
 
```bash
# Ver estado de los containers
cd /opt/app
docker compose -f docker-compose.prod.yml ps
 
# Ver logs de un servicio
docker compose -f docker-compose.prod.yml logs -f app-backend
docker compose -f docker-compose.prod.yml logs -f app-frontend
 
# Reiniciar un servicio
docker compose -f docker-compose.prod.yml restart app-backend
 
# Deploy manual (sin GitHub Actions)
./deploy.sh
 
# Ver logs de Nginx
sudo tail -f /var/log/nginx/app_access.log
sudo tail -f /var/log/nginx/app_error.log
 
# Ver logs del setup inicial
cat /var/log/setup.log
```
 
---
 
## Destruir la infraestructura
 
```bash
cd infra/terraform
terraform destroy
```
 
> ⚠️ Esto elimina TODOS los recursos, incluyendo la base de datos.
 
---
 
## Estructura de archivos
 
```
├── infra/
│   └── terraform/
│       ├── main.tf                    # Recursos Azure (VM, Red, NSG)
│       ├── variables.tf               # Variables configurables
│       ├── outputs.tf                 # Outputs (IP, URLs, etc)
│       ├── terraform.tfvars.example   # Plantilla de configuración
│       └── scripts/
│           └── setup.sh               # Script de instalación de la VM
├── docker-compose.prod.yml            # Docker Compose para producción
├── .env.production.example            # Plantilla del .env en la VM
└── .github/
    └── workflows/
        └── deploy.yml                 # Pipeline de CI/CD
```
 
---
 
## Troubleshooting
 
### La VM no responde en el puerto 80
 
```bash
# Verificar Nginx
ssh azureuser@IP
sudo systemctl status nginx
sudo nginx -t
 
# Verificar containers
docker compose -f /opt/app/docker-compose.prod.yml ps
```
 
### El setup.sh no terminó de ejecutarse
 
```bash
# Ver el log del setup
ssh azureuser@IP
cat /var/log/setup.log
 
# Si hay errores, ejecutar manualmente:
sudo bash /var/lib/cloud/instance/scripts/part-001
```
 
### Error al hacer pull de imágenes en la VM
 
```bash
# Re-autenticar en ghcr.io
echo "TU_GITHUB_TOKEN" | docker login ghcr.io -u TU_USUARIO --password-stdin
```
 
Para obtener un token: GitHub → Settings → Developer settings → Personal access tokens
Permisos necesarios: `read:packages`