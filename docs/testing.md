# Testing

## Estrategia

```mermaid
flowchart LR
    subgraph Backend["Backend Tests"]
        direction TB
        B1["Unit Tests<br/>Service layer mocked<br/>Vitest"]
        B2["Integration Tests<br/>API via Supertest<br/>PostgreSQL real"]
    end

    subgraph Frontend["Frontend Tests"]
        direction TB
        F1["Component Tests<br/>Testing Library<br/>Vitest + jsdom"]
        F2["Service Tests<br/>Fetch mocked<br/>Vitest"]
    end

    subgraph E2E["E2E Tests"]
        direction TB
        E1["Playwright<br/>Flujo completo en navegador"]
    end

    B1 --> B2
    B2 --> E1
    F1 --> E1
    F2 --> E1
```

## Backend

### Unit tests (service layer)

ubrcación: `backend/src/modules/client/__tests__/client.service.test.js`

Mockean el repositorio y testean la lógica de negocio:

```mermaid
sequenceDiagram
    participant Test as Test
    participant Service as client.service
    participant Repo as client.repository (mock)

    Test->>Service: getAll()
    Service->>Repo: findAll()
    Repo-->>Service: [{ id: 1, ... }]
    Service-->>Test: [{ id: 1, ... }]
    Test->>Test: assert result[0].id === 1
```

### Integration tests (API)

Ubicación: `backend/src/modules/client/__tests__/client.api.test.js`

Usan Supertest con la app Express y base de datos real:

```mermaid
sequenceDiagram
    participant Test as Test
    participant App as Express App
    participant DB as PostgreSQL

    Test->>App: GET /api/clients
    App->>DB: prisma.client.findMany()
    DB-->>App: []
    App-->>Test: 200 []

    Test->>App: POST /api/clients { name: "Juan" }
    App->>DB: prisma.client.create()
    DB-->>App: { id: 1, ... }
    App-->>Test: 201 { id: 1, ... }
```

### Ejecución

```bash
# Unit tests
cd backend && npx vitest run

# Solo unit
cd backend && npx vitest run src/modules/client/__tests__/client.service.test.js

# Solo API (requiere DB)
cd backend && npx vitest run src/modules/client/__tests__/client.api.test.js

# Con coverage
cd backend && npx vitest run --coverage
```

## Frontend

### Component tests

Ubicación: `frontend/components/clients/__tests__/`

Usan Testing Library con jsdom:

```mermaid
sequenceDiagram
    participant Test as Test
    participant Component as Component
    participant Service as clientService (mock)

    Test->>Component: render(<ClientsTable />)
    Component->>Service: getAll()
    Service-->>Component: [{ id: 1, name: "Juan" }]
    Component-->>Test: "Juan Pérez" visible
    Test->>Test: assert screen.getByText("Juan Pérez")
```

### Service tests

Ubicación: `frontend/services/__tests__/clientService.test.ts`

Mockean `fetch` global:

```mermaid
sequenceDiagram
    participant Test as Test
    participant Service as clientService
    participant Fetch as fetch (mock)

    Test->>Service: getAll()
    Service->>Fetch: GET /api/clients
    Fetch-->>Service: Response { ok: true, json: [...] }
    Service-->>Test: Client[]
    Test->>Test: assert result.length > 0
```

### Ejecución

```bash
# Todos los tests
cd frontend && npx vitest run

# Watch mode
cd frontend && npx vitest

# Coverage
cd frontend && npx vitest run --coverage
```

## E2E (Playwright)

Ubicación: `e2e/clients.spec.ts`

```mermaid
sequenceDiagram
    participant PW as Playwright
    participant FE as Frontend
    participant BE as Backend
    participant DB as PostgreSQL

    PW->>FE: navigate /clients
    PW->>FE: click "Nuevo cliente"
    PW->>FE: fill form
    PW->>FE: click "Crear"
    FE->>BE: POST /api/clients
    BE->>DB: INSERT
    DB-->>BE: OK
    BE-->>FE: 201 { id }
    PW->>FE: assert "Juan Pérez" visible
```

### Ejecución

```bash
# Necesita entorno dev corriendo
make dev

# Ejecutar E2E
make test-e2e

# Con UI
cd e2e && npx playwright test --ui

# Instalar browsers primero
cd e2e && npm run install
```

## CI/CD Pipeline

```yaml
pull request o push a main:
  lint-backend:
  lint-frontend:
  test-backend:
    - PostgreSQL service container
    - prisma migrate deploy
    - vitest run
  test-frontend:
    - vitest run
  build-and-push:
    needs: [test-backend, test-frontend]
    - docker build & push to GHCR
```

Los tests bloquean el deploy — si fallan, no se construyen ni despliegan imágenes.
