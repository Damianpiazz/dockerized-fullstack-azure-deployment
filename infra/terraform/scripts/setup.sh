#!/bin/bash
set -euo pipefail

LOG_FILE="/var/log/setup.log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "========================================="
echo "  Setup iniciado: $(date)"
echo "========================================="

# ─────────────────────────────────────────────
# 1. Actualizar sistema
# ─────────────────────────────────────────────
echo "[1/7] Actualizando sistema..."
apt-get update -y
apt-get upgrade -y
apt-get install -y \
  curl \
  wget \
  git \
  unzip \
  jq \
  htop \
  ufw \
  ca-certificates \
  gnupg \
  lsb-release

# ─────────────────────────────────────────────
# 2. Instalar Docker
# ─────────────────────────────────────────────
echo "[2/7] Instalando Docker..."
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" \
  | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update -y
apt-get install -y \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin

# Habilitar Docker al inicio
systemctl enable docker
systemctl start docker

# Agregar usuario al grupo docker
usermod -aG docker ${admin_username}

echo "Docker version: $(docker --version)"
echo "Docker Compose version: $(docker compose version)"

# ─────────────────────────────────────────────
# 3. Instalar Nginx
# ─────────────────────────────────────────────
echo "[3/7] Instalando Nginx..."
apt-get install -y nginx
systemctl enable nginx
systemctl start nginx

# ─────────────────────────────────────────────
# 4. Instalar Certbot (para SSL con Let's Encrypt)
# ─────────────────────────────────────────────
echo "[4/7] Instalando Certbot..."
apt-get install -y certbot python3-certbot-nginx

# ─────────────────────────────────────────────
# 5. Configurar UFW (firewall)
# ─────────────────────────────────────────────
echo "[5/7] Configurando UFW..."
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow 'Nginx Full'
ufw --force enable

# ─────────────────────────────────────────────
# 6. Crear directorios de la app
# ─────────────────────────────────────────────
echo "[6/7] Creando estructura de directorios..."
APP_DIR="/opt/app"
mkdir -p "$APP_DIR"
mkdir -p "$APP_DIR/nginx"
chown -R ${admin_username}:${admin_username} "$APP_DIR"

# ─────────────────────────────────────────────
# 7. Configurar Nginx como reverse proxy
# ─────────────────────────────────────────────
echo "[7/7] Configurando Nginx..."

# Eliminar config por defecto
rm -f /etc/nginx/sites-enabled/default

cat > /etc/nginx/sites-available/app.conf << 'NGINX_CONF'
# Upstream services (Docker containers)
upstream frontend {
    server 127.0.0.1:3000;
}

upstream backend {
    server 127.0.0.1:8080;
}

# HTTP -> Redireccion (una vez que tengas SSL)
# Por ahora sirve directo por HTTP
server {
    listen 80;
    server_name _;

    # Logs
    access_log /var/log/nginx/app_access.log;
    error_log  /var/log/nginx/app_error.log;

    # Tamanio maximo de uploads
    client_max_body_size 50M;

    # API -> Backend
    location /api/ {
        proxy_pass         http://backend;
        proxy_http_version 1.1;
        proxy_set_header   Upgrade $http_upgrade;
        proxy_set_header   Connection 'upgrade';
        proxy_set_header   Host $host;
        proxy_set_header   X-Real-IP $remote_addr;
        proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        proxy_read_timeout 60s;
    }

    # Frontend -> Next.js
    location / {
        proxy_pass         http://frontend;
        proxy_http_version 1.1;
        proxy_set_header   Upgrade $http_upgrade;
        proxy_set_header   Connection 'upgrade';
        proxy_set_header   Host $host;
        proxy_set_header   X-Real-IP $remote_addr;
        proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        proxy_read_timeout 60s;
    }

    # Health check
    location /health {
        access_log off;
        return 200 "OK\n";
        add_header Content-Type text/plain;
    }
}
NGINX_CONF

ln -sf /etc/nginx/sites-available/app.conf /etc/nginx/sites-enabled/app.conf
nginx -t && systemctl reload nginx

# ─────────────────────────────────────────────
# Script de deploy para CI/CD
# ─────────────────────────────────────────────
cat > /opt/app/deploy.sh << 'DEPLOY_SCRIPT'
#!/bin/bash
set -euo pipefail

APP_DIR="/opt/app"
cd "$APP_DIR"

echo "[deploy] Iniciando deploy: $(date)"

# Bajar servicios previos
docker compose down --remove-orphans || true

# Limpiar imagenes antiguas (opcional, libera espacio)
docker image prune -f || true

# Levantar con nueva imagen
docker compose pull
docker compose up -d --build

# Verificar que los containers esten corriendo
sleep 10
docker compose ps

echo "[deploy] Deploy completado: $(date)"
DEPLOY_SCRIPT

chmod +x /opt/app/deploy.sh
chown ${admin_username}:${admin_username} /opt/app/deploy.sh

echo "========================================="
echo "  Setup finalizado: $(date)"
echo "  La VM esta lista para recibir deploys"
echo "========================================="
