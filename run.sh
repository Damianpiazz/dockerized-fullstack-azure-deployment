#!/usr/bin/env bash
set -euo pipefail

CMD="${1:-help}"

case "$CMD" in
  dev)
    echo "==> Starting dev environment..."
    docker compose -f docker-compose.dev.yml up --build -d
    echo "==> Frontend: http://localhost:3000"
    echo "==> Backend:  http://localhost:8080"
    echo "==> Grafana:  http://localhost:3001"
    echo "==> Run 'make dev-logs' to see logs"
    ;;
  test)
    echo "==> Running all tests..."
    echo "--- Backend unit tests ---"
    cd backend && npx vitest run src/modules/client/__tests__/client.service.test.js && cd ..
    echo ""
    echo "--- Frontend tests ---"
    cd frontend && npx vitest run && cd ..
    echo ""
    echo "=== All tests passed! ==="
    ;;
  test:e2e)
    echo "==> Running E2E tests (requires dev environment)..."
    cd e2e && npx playwright test && cd ..
    ;;
  simulate)
    echo "==> Starting Azure simulation stack..."
    docker compose -f docker-compose.simulate.yml up --build -d
    echo "==> App:          http://localhost"
    echo "==> API:          http://localhost/api"
    echo "==> Grafana:      http://localhost/grafana (admin:admin)"
    echo "==> Grafana (direct): http://localhost:3001"
    echo "==> Prometheus:   http://localhost:9090"
    ;;

  simulate-down)
    docker compose -f docker-compose.simulate.yml down
    ;;

  prod)
    echo "==> Starting production stack..."
    docker compose -f docker-compose.prod.yml up -d
    echo "==> App: http://localhost"
    echo "==> Grafana: http://localhost:3001"
    ;;
  clean)
    echo "==> Cleaning up..."
    docker compose -f docker-compose.dev.yml down -v --remove-orphans 2>/dev/null || true
    docker compose -f docker-compose.prod.yml down -v --remove-orphans 2>/dev/null || true
    docker system prune -f
    echo "==> Done"
    ;;
  *)
    echo "Usage: ./run.sh <command>"
    echo ""
    echo "Commands:"
    echo "  dev       Start development environment"
    echo "  test      Run unit/integration tests"
    echo "  test:e2e  Run Playwright E2E tests"
    echo "  simulate  Start Azure simulation stack (full prod + Nginx)"
    echo "  simulate-down  Stop simulation stack"
    echo "  prod      Start production stack"
    echo "  clean     Remove all containers and volumes"
    ;;
esac
