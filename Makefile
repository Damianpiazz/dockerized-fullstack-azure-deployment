.PHONY: dev dev-build test test-backend test-frontend test-e2e prod-build simulate simulate-down clean

# ─── Development ──────────────────────────────
dev:
	docker compose -f docker-compose.dev.yml up --build -d

dev-build:
	docker compose -f docker-compose.dev.yml build --no-cache

dev-logs:
	docker compose -f docker-compose.dev.yml logs -f

dev-down:
	docker compose -f docker-compose.dev.yml down

# ─── Testing ──────────────────────────────────
test:
	docker compose -f docker-compose.test.yml up --build --abort-on-container-exit

test-backend:
	cd backend && npm test

test-frontend:
	cd frontend && npm test

test-e2e:
	cd e2e && npm test

test-e2e-headed:
	cd e2e && npm run test:headed

# ─── Production Build ────────────────────────
prod-build:
	docker compose -f docker-compose.prod.yml build

prod-up:
	docker compose -f docker-compose.prod.yml up -d

prod-down:
	docker compose -f docker-compose.prod.yml down

prod-logs:
	docker compose -f docker-compose.prod.yml logs -f

# ─── Database ─────────────────────────────────
db-migrate:
	cd backend && npx prisma migrate dev

db-reset:
	cd backend && npx prisma migrate reset --force

db-studio:
	cd backend && npx prisma studio

# ─── Simulación Azure Local ────────────────────
simulate:
	docker compose -f docker-compose.simulate.yml up --build -d

simulate-build:
	docker compose -f docker-compose.simulate.yml build --no-cache

simulate-down:
	docker compose -f docker-compose.simulate.yml down

simulate-logs:
	docker compose -f docker-compose.simulate.yml logs -f

# ─── Terraform Local ───────────────────────────
terraform-validate:
	cd infra/terraform && terraform init -backend=false -reconfigure && terraform fmt -check -recursive && terraform validate

terraform-local:
	cd infra/terraform && sh run-local.sh

# ─── Cleanup ──────────────────────────────────
clean:
	docker compose -f docker-compose.dev.yml down -v --remove-orphans
	docker compose -f docker-compose.simulate.yml down -v --remove-orphans 2>/dev/null || true
	docker system prune -f
