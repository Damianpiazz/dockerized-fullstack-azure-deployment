# Documentación

## Índice

| Documento | Descripción |
|---|---|
| [Arquitectura](./architecture.md) | Diagramas de red, stack tecnológico, puertos |
| [Setup](./setup.md) | Instalación local, deploy a Azure, configuración |
| [Docker](./docker.md) | Perfiles, Dockerfiles, compose, comandos |
| [Testing](./testing.md) | Estrategia, tests unitarios, integración, E2E |
| [Monitoreo](./monitoring.md) | OpenTelemetry, Prometheus, Grafana, métricas |
| [CI/CD](./ci-cd.md) | Pipelines de GitHub Actions, secrets, health check |
| [Terraform](./terraform.md) | Módulos, remote state, NSG, outputs |
| [API](./api.md) | Endpoints, modelos, códigos de error |
| [Variables de Entorno](./env-vars.md) | Referencia completa de todas las env vars |

## Stack

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
