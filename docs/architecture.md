# Arquitectura

## Visión general

```mermaid
graph TB
    Internet["🌐 Internet"] --> NSG["Azure NSG<br/>:22 :80 :443 :3001"]
    NSG --> VM["Azure VM<br/>Ubuntu 22.04"]
    VM --> Nginx["Nginx Reverse Proxy<br/>:80"]

    subgraph Docker["Docker Compose — Producción"]
        direction TB
        Nginx --> Frontend["app-frontend<br/>Next.js 16 :3000"]
        Nginx --> Backend["app-backend<br/>Express 5 :8080"]
        Nginx --> Grafana["grafana<br/>:3001"]

        Frontend -.->|fetch /api/*| Backend
        Backend --> Postgres["app-postgres<br/>PostgreSQL 16 :5432"]

        Backend --> OTel["otel-collector<br/>:4318"]
        OTel --> Prometheus["prometheus<br/>:9090"]
        Grafana --> Prometheus
    end

    style Internet fill:#e1f5fe
    style NSG fill:#fff3e0
    style VM fill:#f3e5f5
    style Nginx fill:#e8f5e9
```

## Flujo de red

```mermaid
sequenceDiagram
    participant U as Usuario
    participant N as Nginx (:80)
    participant F as Frontend (:3000)
    participant B as Backend (:8080)
    participant P as PostgreSQL (:5432)

    U->>N: GET /
    N->>F: proxy_pass http://frontend
    F-->>U: HTML (Next.js SSR)

    U->>N: GET /api/clients
    N->>B: proxy_pass http://backend
    B->>P: Prisma query
    P-->>B: rows
    B-->>U: JSON response
```

## Puertos

| Servicio | Container | Host (prod) | Descripción |
|---|---|---|---|
| Frontend | 3000 | 127.0.0.1:3000 | Next.js |
| Backend | 8080 | 127.0.0.1:8080 | Express API |
| PostgreSQL | 5432 | 127.0.0.1:5432 | Base de datos |
| OTEL Collector | 4318 | 127.0.0.1:4318 | Trazas OTLP |
| Prometheus | 9090 | 127.0.0.1:9090 | Métricas |
| Grafana | 3000 | 127.0.0.1:3001 | Dashboards |
| Nginx | — | 0.0.0.0:80 | Reverse proxy |

## Stack tecnológico

```mermaid
mindmap
  root((Client Management))
    Frontend
      Next.js 16
      React 19
      shadcn/ui
      Tailwind CSS 4
      TypeScript
    Backend
      Node.js 20
      Express 5
      Prisma ORM
      PostgreSQL 16
    Infraestructura
      Azure VM
      Terraform
      Docker Compose
      Nginx
    CI/CD
      GitHub Actions
      GHCR
    Monitoreo
      OpenTelemetry
      Prometheus
      Grafana
    Testing
      Vitest
      Testing Library
      Playwright
```

## Perfiles de Docker Compose

```mermaid
flowchart LR
    subgraph Dev["docker-compose.dev.yml"]
        D1["PostgreSQL :5432"]
        D2["Backend (hot-reload) :8080"]
        D3["Frontend (hot-reload) :3000"]
    end

    subgraph Test["docker-compose.test.yml"]
        T1["PostgreSQL Test :5433"]
        T2["Backend Tests"]
    end

    subgraph Prod["docker-compose.prod.yml"]
        P1["PostgreSQL :5432"]
        P2["Backend (GHCR) :8080"]
        P3["Frontend (GHCR) :3000"]
        P4["OTEL Collector"]
        P5["Prometheus"]
        P6["Grafana :3001"]
    end
```
