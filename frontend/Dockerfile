FROM node:20-bullseye

WORKDIR /app

# Copiar manifests primero para aprovechar cache
COPY package*.json ./

# Instalar dependencias
RUN npm ci

# Copiar el resto del código
COPY . .

# Puerto de Next.js
EXPOSE 3000

# Ejecutar modo desarrollo
CMD ["npm", "run", "dev"]