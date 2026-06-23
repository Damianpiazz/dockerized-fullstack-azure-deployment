# Docker

## Perfiles

```mermaid
graph TD
    subgraph dev["docker-compose.dev.yml"]
        direction LR
        dev_pg["PostgreSQL :5432"]
        dev_be["Backend (Dockerfile.dev)<br/>nodemon + vol mounts"]
        dev_fe["Frontend (Dockerfile.dev)<br/>next dev + vol mounts"]
    end

    subgraph test["docker-compose.test.yml"]
        direction LR
        test_pg["PostgreSQL Test :5433"]
        test_be["Backend (Dockerfile.test)<br/>vitest run"]
    end

    subgraph prod["docker-compose.prod.yml"]
        direction LR
        prod_pg["PostgreSQL :5432"]
        prod_be["Backend (Dockerfile.prod)<br/>multi-stage alpine"]
        prod_fe["Frontend (Dockerfile.prod)<br/>multi-stage standalone"]
        prod_otel["OTEL Collector"]
        prod_prom["Prometheus"]
        prod_graf["Grafana"]
    end

    subgraph simulate["docker-compose.simulate.yml"]
        direction LR
        sim_nginx["Nginx Reverse Proxy :80"]
        sim_pg["PostgreSQL :5432"]
        sim_be["Backend (Dockerfile.prod)"]
        sim_fe["Frontend (Dockerfile.prod)"]
        sim_otel["OTEL Collector"]
        sim_prom["Prometheus"]
        sim_graf["Grafana"]
    end
```

## Dockerfiles

### Backend

| Archivo | Base | Uso | Comando |
|---|---|---|---|
| `Dockerfile.dev` | node:20-alpine | Desarrollo | `nodemon src/server.js` |
| `Dockerfile.prod` | node:20-alpine (multi-stage) | Producción | `prisma migrate deploy && node src/server.js` |
| `Dockerfile.test` | node:20-alpine | Tests | `vitest run` |

**Dockerfile.prod — multi-stage:**

```mermaid
flowchart LR
    subgraph Stage1["Stage 1: deps"]
        A1["COPY package*.json prisma/"] --> A2["npm ci --production"]
        A2 --> A3["prisma generate"]
    end

    subgraph Stage2["Stage 2: runner"]
        B1["COPY --from=deps"] --> B2["HEALTHCHECK"]
        B2 --> B3["prisma migrate deploy"]
        B3 --> B4["node src/server.js"]
    end

    A3 -.-> B1
```

### Frontend

| Archivo | Base | Uso | Comando |
|---|---|---|---|
| `Dockerfile.dev` | node:20-alpine | Desarrollo | `npm run dev` |
| `Dockerfile.prod` | node:20-alpine (multi-stage) | Producción | `npm start` |
| `Dockerfile.test` | node:20-alpine | Tests | `vitest run` |

**Dockerfile.prod — multi-stage:**

```mermaid
flowchart LR
    subgraph Deps["Stage 1: deps"]
        D1["npm ci --production"]
    end

    subgraph Builder["Stage 2: builder"]
        B1["npm ci"] --> B2["npm run build"]
    end

    subgraph Runner["Stage 3: runner"]
        R1["COPY .next node_modules"] --> R2["nextjs user"]
        R2 --> R3["HEALTHCHECK :3000"]
        R3 --> R4["npm start"]
    end

    D1 -.-> Builder
    B2 -.-> Runner
```

## Variables de entorno en Compose

Todos los valores sensibles se configuran via variables de entorno:

### docker-compose.dev.yml

```yaml
environment:
  POSTGRES_DB: ${POSTGRES_DB:-app_db}
  POSTGRES_USER: ${POSTGRES_USER:-app_user}
  DATABASE_URL: postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@app-postgres:5432/${POSTGRES_DB}
  CORS_ORIGIN: ${CORS_ORIGIN:-http://localhost:3000}
```

### docker-compose.prod.yml

```yaml
environment:
  POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:?POSTGRES_PASSWORD is required}
  CORS_ORIGIN: ${CORS_ORIGIN:?CORS_ORIGIN is required}
  NEXT_PUBLIC_API_URL: ${NEXT_PUBLIC_API_URL:?NEXT_PUBLIC_API_URL is required}
  GRAFANA_ADMIN_PASSWORD: ${GRAFANA_ADMIN_PASSWORD:?GRAFANA_ADMIN_PASSWORD is required}
```

### docker-compose.test.yml

```yaml
environment:
  POSTGRES_DB: ${TEST_POSTGRES_DB:-app_db_test}
  DATABASE_URL: postgresql://${TEST_POSTGRES_USER}@app-postgres-test:5432/${TEST_POSTGRES_DB}
```

### docker-compose.simulate.yml

```yaml
environment:
  POSTGRES_DB: ${POSTGRES_DB:-app_db}
  CORS_ORIGIN: ${CORS_ORIGIN:-http://localhost}
  NEXT_PUBLIC_API_URL: ${NEXT_PUBLIC_API_URL:-http://localhost/api}
```

## Comandos útiles

```bash
# Dev
docker compose -f docker-compose.dev.yml up --build -d
docker compose -f docker-compose.dev.yml logs -f app-backend
docker compose -f docker-compose.dev.yml exec app-backend sh

# Prod
docker compose -f docker-compose.prod.yml up -d
docker compose -f docker-compose.prod.yml pull
docker compose -f docker-compose.prod.yml down --remove-orphans

# Test
docker compose -f docker-compose.test.yml up --build --abort-on-container-exit

# Simulate Azure
docker compose -f docker-compose.simulate.yml up --build -d
docker compose -f docker-compose.simulate.yml logs -f
docker compose -f docker-compose.simulate.yml down
```
