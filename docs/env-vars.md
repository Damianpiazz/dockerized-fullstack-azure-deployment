# Variables de Entorno

## Backend

### Archivos

| Archivo | Perfil | Ubicación |
|---|---|---|
| `.env.development` | Desarrollo | `backend/.env.development` |
| `.env.production` | Producción (template) | `backend/.env.production` |
| `.env.test` | Tests | `backend/.env.test` |

### Validación con Zod

Todas las variables se validan al iniciar la app via `src/config/env.js`:

```javascript
const envSchema = z.object({
  NODE_ENV: z.enum(["development", "production", "test"]),
  PORT: z.coerce.number().int().positive(),
  DATABASE_URL: z.string(),
  CORS_ORIGIN: z.string(),
  LOG_LEVEL: z.enum(["fatal", "error", "warn", "info", "debug", "trace", "silent"]),
  OTEL_ENABLED: z.coerce.boolean(),
  OTEL_SERVICE_NAME: z.string(),
  OTEL_EXPORTER_OTLP_ENDPOINT: z.string(),
});
```

### Referencia

| Variable | dev | prod | test | Requerida |
|---|---|---|---|---|
| `NODE_ENV` | development | production | test | ✓ |
| `PORT` | 8080 | 8080 | 0 (random) | ✓ |
| `DATABASE_URL` | postgresql://... | postgresql://... | postgresql://... | ✓ |
| `CORS_ORIGIN` | http://localhost:3000 | ${CORS_ORIGIN} | http://localhost:3000 | ✓ |
| `LOG_LEVEL` | debug | info | silent | ✗ |
| `OTEL_ENABLED` | false | true | false | ✗ |
| `OTEL_SERVICE_NAME` | app-backend | app-backend | app-backend | ✗ |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | http://localhost:4318 | http://otel-collector:4318 | http://localhost:4318 | ✗ |

## Frontend

### Archivos

| Archivo | Perfil | Ubicación |
|---|---|---|
| `.env.development` | Desarrollo | `frontend/.env.development` |
| `.env.production` | Producción (template) | `frontend/.env.production` |
| `.env.test` | Tests | `frontend/.env.test` |

### Referencia

| Variable | dev | prod | test |
|---|---|---|---|
| `NEXT_PUBLIC_API_URL` | http://localhost:8080/api | ${NEXT_PUBLIC_API_URL} | http://localhost:8080/api |
| `NEXT_PUBLIC_OTEL_ENABLED` | false | true | false |

## Docker Compose

### docker-compose.dev.yml

| Variable | Default | Descripción |
|---|---|---|
| `POSTGRES_DB` | app_db | Nombre de la base de datos |
| `POSTGRES_USER` | app_user | Usuario de PostgreSQL |
| `POSTGRES_PASSWORD` | app_pass | Password de PostgreSQL |
| `POSTGRES_PORT` | 5432 | Puerto expuesto de PostgreSQL |
| `BACKEND_PORT` | 8080 | Puerto del backend |
| `FRONTEND_PORT` | 3000 | Puerto del frontend |
| `CORS_ORIGIN` | http://localhost:3000 | Origen permitido por CORS |
| `NEXT_PUBLIC_API_URL` | http://localhost:8080/api | URL del API para el frontend |

### docker-compose.prod.yml

| Variable | Default | Requerida | Descripción |
|---|---|---|---|
| `POSTGRES_DB` | — | ✓ | Nombre de la base de datos |
| `POSTGRES_USER` | — | ✓ | Usuario de PostgreSQL |
| `POSTGRES_PASSWORD` | — | ✓ | Password de PostgreSQL |
| `CORS_ORIGIN` | — | ✓ | Origen permitido por CORS |
| `NEXT_PUBLIC_API_URL` | — | ✓ | URL pública del API |
| `GRAFANA_ADMIN_USER` | admin | ✗ | Usuario admin de Grafana |
| `GRAFANA_ADMIN_PASSWORD` | — | ✓ | Password de Grafana |
| `DOCKER_REGISTRY` | ghcr.io | ✗ | Registry de Docker |
| `IMAGE_TAG` | latest | ✗ | Tag de la imagen |
| `BACKEND_PORT` | 8080 | ✗ | Puerto del backend |
| `FRONTEND_PORT` | 3000 | ✗ | Puerto del frontend |
| `OTEL_ENABLED` | true | ✗ | Habilita OpenTelemetry |
| `PROMETHEUS_RETENTION` | 15d | ✗ | Retención de métricas |
| `OTEL_COLLECTOR_VERSION` | latest | ✗ | Versión del collector |
| `PROMETHEUS_VERSION` | latest | ✗ | Versión de Prometheus |
| `GRAFANA_VERSION` | latest | ✗ | Versión de Grafana |

### docker-compose.test.yml

| Variable | Default | Descripción |
|---|---|---|
| `TEST_POSTGRES_DB` | app_db_test | Base de datos para tests |
| `TEST_POSTGRES_USER` | app_user | Usuario de PostgreSQL test |
| `TEST_POSTGRES_PASSWORD` | app_pass | Password de PostgreSQL test |
| `TEST_POSTGRES_PORT` | 5433 | Puerto para PostgreSQL test |

## Orden de precedencia

1. Variables del shell / entorno (`export VAR=val`)
2. Archivo `.env` en la raíz del proyecto
3. Archivo `backend/.env.development` / `production` / `test`
4. Defaults hardcodeados en docker-compose

## .env.production (en la VM)

```env
# Base de datos
POSTGRES_DB=app_db
POSTGRES_USER=app_user
POSTGRES_PASSWORD=una_password_segura

# Docker Registry
DOCKER_REGISTRY=ghcr.io/TU_USUARIO_GITHUB

# CORS / URL pública
CORS_ORIGIN=http://TU_IP_O_DOMINIO
NEXT_PUBLIC_API_URL=http://TU_IP_O_DOMINIO/api

# Grafana
GRAFANA_ADMIN_USER=admin
GRAFANA_ADMIN_PASSWORD=otra_password_segura
```
