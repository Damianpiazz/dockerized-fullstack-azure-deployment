# CI/CD

## Pipeline

```mermaid
flowchart LR
    A["Push a main / PR"] --> B["lint-backend"]
    A --> C["lint-frontend"]
    B --> D["test-backend"]
    C --> E["test-frontend"]
    D --> F["build-and-push"]
    E --> F
    F --> G["deploy"]
```

## Workflows

### CI (`ci.yml`)

Se ejecuta en **push a main** y **pull requests**.

```mermaid
flowchart TD
    Trigger["on: push main<br/>pull_request main"] --> LintBE["lint-backend"]
    Trigger --> LintFE["lint-frontend"]

    LintBE --> TestBE["test-backend"]
    LintFE --> TestFE["test-frontend"]

    subgraph TestBEJob["test-backend"]
        direction TB
        PGSQL["PostgreSQL service<br/>:5432"] --> Migrate["prisma migrate deploy"]
        Migrate --> Vitest["vitest run"]
        Vitest --> CoverageBE["coverage artifact"]
    end

    subgraph TestFEJob["test-frontend"]
        direction TB
        VitestFE["vitest run"] --> CoverageFE["coverage artifact"]
    end
```

### CD — Deploy (`deploy.yml`)

Solo en **push a main** o **workflow_dispatch**.

```mermaid
flowchart TD
    A["on: push main"] --> B["test-backend<br/>(reusable workflow)"]
    A --> C["test-frontend<br/>(reusable workflow)"]

    B --> D["build-and-push"]
    C --> D

    subgraph BuildStage["build-and-push"]
        direction TB
        Login["Login GHCR"] --> BuildBE["Build & Push Backend<br/>Dockerfile.prod"]
        Login --> BuildFE["Build & Push Frontend<br/>Dockerfile.prod"]
    end

    D --> E["deploy"]

    subgraph DeployStage["deploy"]
        direction TB
        SCP["SCP docker-compose.prod.yml"] --> SSH["SSH to VM"]
        SSH --> Down["docker compose down"]
        Down --> Pull["docker compose pull"]
        Pull --> Up["docker compose up -d"]
        Up --> Health["Health check"]
    end
```

### Concurrency

El workflow de deploy tiene `concurrency` para evitar deploys simultáneos:

```yaml
concurrency:
  group: deploy-${{ github.ref }}
  cancel-in-progress: true
```

## Secrets de GitHub

| Secret | Descripción | Ejemplo |
|---|---|---|
| `VM_HOST` | IP pública de la VM | `52.184.100.50` |
| `VM_USER` | Usuario SSH | `azureuser` |
| `VM_SSH_PRIVATE_KEY` | Clave SSH privada | `-----BEGIN RSA PRIVATE KEY-----\n...` |
| `NEXT_PUBLIC_API_URL` | URL pública del API | `http://52.184.100.50/api` |

> El `GITHUB_TOKEN` se genera automáticamente y tiene permisos de escritura en packages.

## Health check post-deploy

```yaml
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost/health)
if [ "$HTTP_CODE" = "200" ]; then
  echo "✅ Health check OK"
else
  echo "❌ Health check failed"
  exit 1
fi
```

## Flujo de deploy manual

```bash
# 1. Ir a GitHub → Actions → CD - Deploy
# 2. Click "Run workflow"
# 3. Opcional: especificar IMAGE_TAG
# 4. Monitorear el progreso
```

## Cache

El pipeline cachea:

- `node_modules` via `actions/setup-node` con `cache: npm`
- Capas de Docker via GitHub Actions Cache (`type=gha`)
