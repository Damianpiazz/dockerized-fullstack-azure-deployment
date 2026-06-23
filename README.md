# Client Management — Fullstack Azure Deployment

Aplicación fullstack Dockerizada con despliegue automatizado a Azure mediante Terraform, GitHub Actions, y stack de observabilidad OpenTelemetry + Prometheus + Grafana.

## Stack

| Capa | Tecnología |
|---|---|
| Frontend | Next.js 16, React 19, shadcn/ui, Tailwind CSS 4, TypeScript |
| Backend | Node.js 20, Express 5, Prisma ORM, PostgreSQL 16 |
| Infra | Azure VM (Ubuntu 22.04), Terraform, Docker Compose |
| CI/CD | GitHub Actions, GitHub Container Registry |
| Monitoreo | OpenTelemetry, Prometheus, Grafana |
| Testing | Vitest, Supertest, Testing Library, Playwright |

## Arquitectura

```
Internet
   │
   ▼
[Azure NSG] :22 / :80 / :443 / :3001(Grafana)
   │
   ▼
[Azure VM - Ubuntu 22.04]
   │
   ▼
[Nginx - Reverse Proxy] :80
   ├── /api/* ──────► [app-backend :8080] ──► [app-postgres :5432]
   ├── /* ──────────► [app-frontend :3000]
   ├── /grafana/ ───► [grafana :3001] ──► [prometheus :9090]
   └── /health ─────► (nginx directo)
```

## Perfiles de entorno

| Perfil | Archivo .env | Dockerfile | Compose |
|---|---|---|---|
| **dev** | `.env.development` | `Dockerfile.dev` (hot-reload + vol mounts) | `docker-compose.yml` |
| **prod** | `.env.production` | `Dockerfile.prod` (multi-stage, alpine) | `docker-compose.prod.yml` |
| **test** | `.env.test` | `Dockerfile.test` (vitest + coverage) | `docker-compose.test.yml` |

## Arranque rápido

### Desarrollo local

```bash
# Iniciar todo
make dev

# Ver logs
make dev-logs

# Detener
make dev-down
```

### Ejecutar tests

```bash
# Todos los tests
make test

# Solo backend
make test-backend

# Solo frontend
make test-frontend

# E2E (Playwright)
make test-e2e
```

## Estructura del proyecto

```
.
├── backend/                       # API REST con Express + Prisma
│   ├── src/
│   │   ├── app.js                 # Express app (helmet, cors, rate-limit, metrics)
│   │   ├── server.js              # Entry point (env, otel, listen)
│   │   ├── config/
│   │   │   ├── env.js             # Zod schema validation
│   │   │   ├── logger.js          # Pino logger
│   │   │   ├── metrics.js         # Prometheus metrics
│   │   │   ├── cors.js            # CORS configuration
│   │   │   └── telemetry.js       # OpenTelemetry init
│   │   ├── middlewares/
│   │   │   ├── errorHandler.js    # Error handler global
│   │   │   ├── logger.js          # Request logger
│   │   │   └── notFound.js        # 404 handler
│   │   ├── routes/
│   │   │   └── client.routes.js
│   │   └── modules/client/        # Capas: controller → service → repository
│   ├── prisma/
│   │   ├── schema.prisma
│   │   ├── migrations/            # Migraciones versionadas
│   │   └── seed.ts                # Seed data
│   └── Dockerfile.dev/prod/test
├── frontend/                      # UI con Next.js 16 + shadcn
│   ├── app/
│   │   ├── layout.tsx             # Root layout (Toaster, ErrorBoundary)
│   │   ├── page.tsx               # Home page
│   │   └── clients/page.tsx       # Clients CRUD page
│   ├── components/
│   │   ├── ui/                    # shadcn/ui (button, input, table, etc.)
│   │   ├── clients/               # ClientsTable, ClientForm
│   │   └── common/                # ErrorBoundary, LoadingSkeleton
│   ├── services/clientService.ts  # API client
│   └── Dockerfile.dev/prod/test
├── e2e/                           # Playwright E2E tests
│   ├── clients.spec.ts
│   └── playwright.config.ts
├── infra/
│   ├── terraform/                 # IaC con módulos
│   │   ├── main.tf                # Root: RG, VNet, NSG, VM, DNS, Monitoring
│   │   ├── modules/
│   │   │   ├── networking/        # VNet, subnet, NSG, public IP
│   │   │   ├── compute/           # VM, SSH key
│   │   │   ├── monitoring/        # Log Analytics, Application Insights
│   │   │   └── storage/           # Storage Account
│   │   └── scripts/setup.sh       # Cloud-init: Docker, Nginx, UFW
│   └── monitoring/
│       ├── otel-collector.yml     # OTEL Collector config
│       ├── prometheus.yml         # Prometheus scrape targets
│       └── grafana/               # Dashboards + datasources provisioning
├── docker-compose.yml             # Desarrollo
├── docker-compose.prod.yml        # Producción (incluye OTEL + Prometheus + Grafana)
├── docker-compose.test.yml        # Tests
├── Makefile                       # Comandos útiles
└── .github/workflows/
    ├── ci.yml                     # Lint + Test en PR y push a main
    └── deploy.yml                 # Build GHCR + Deploy a Azure VM
```

## Variables de entorno

### Backend

| Variable | dev | prod | test |
|---|---|---|---|
| `NODE_ENV` | development | production | test |
| `PORT` | 8080 | 8080 | 0 (random) |
| `DATABASE_URL` | postgresql://... | postgresql://... | postgresql://... |
| `CORS_ORIGIN` | http://localhost:3000 | ${CORS_ORIGIN} | http://localhost:3000 |
| `LOG_LEVEL` | debug | info | silent |
| `OTEL_ENABLED` | false | true | false |

### Frontend

| Variable | dev | prod | test |
|---|---|---|---|
| `NEXT_PUBLIC_API_URL` | http://localhost:8080/api | ${NEXT_PUBLIC_API_URL} | http://localhost:8080/api |

## CI/CD

### Pipeline

```yaml
push a main o PR:
  1. lint-backend + lint-frontend (paralelo)
  2. test-backend (postgres service, migrations, vitest)
  3. test-frontend (vitest, jsdom)
  4. Build & Push a GHCR (backend + frontend)
  5. Deploy a Azure VM (SSH, docker compose up)
```

### Secrets de GitHub necesarios

| Secret | Descripción |
|---|---|
| `VM_HOST` | IP pública de la VM |
| `VM_USER` | `azureuser` |
| `VM_SSH_PRIVATE_KEY` | Clave SSH privada |
| `NEXT_PUBLIC_API_URL` | `http://IP/api` |

## Deploy a Azure

### 1. Bootstrap (remote state)

```bash
az login
az account set --subscription "ID_DE_TU_SUSCRIPCION"

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
terraform init
terraform plan
terraform apply
```

### 4. Configurar manual (primera vez)

```bash
ssh azureuser@IP
cd /opt/app
# Crear .env con valores reales
nano .env
```

### 5. Configurar GitHub Secrets y pushear

## Monitoreo

### Stack

- **OpenTelemetry**: Instrumentación automática de Express, HTTP, y PostgreSQL
- **Prometheus**: Scrape de métricas cada 15s, retención 15 días
- **Grafana**: Dashboards precargados, acceso en `http://IP:3001`

### Métricas expuestas

- `app_http_requests_total` — Contador de requests por método/ruta/status
- `app_http_request_duration_seconds` — Histograma de latencia
- `app_db_connections_active` — Conexiones activas a PostgreSQL
- Métricas default de Node.js (memoria, CPU, event loop)

### Acceso a Grafana

```bash
# Las credenciales se configuran via .env en produccion:
GRAFANA_ADMIN_USER=admin
GRAFANA_ADMIN_PASSWORD=password_segura
```

## Destruir infraestructura

```bash
terraform destroy
```

> ⚠️ Elimina TODOS los recursos, incluyendo la base de datos y el estado de Terraform.

## Health check

```bash
curl http://IP/health
# {"status":"ok","timestamp":"2026-06-23T..."}
```

## Troubleshooting

### Los tests fallan con error de DB

```bash
docker compose -f docker-compose.test.yml up --build --abort-on-container-exit
```

### La VM no responde en puerto 80

```bash
ssh azureuser@IP
sudo systemctl status nginx
docker compose -f /opt/app/docker-compose.prod.yml ps
```

### Error al hacer pull de imágenes

```bash
# Re-autenticar en GHCR
echo "GH_TOKEN" | docker login ghcr.io -u TU_USUARIO --password-stdin
```
