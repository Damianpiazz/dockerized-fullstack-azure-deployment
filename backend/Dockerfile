FROM node:20

WORKDIR /app

# 1. Copiar solo manifests primero (cache óptimo)
COPY package*.json ./

RUN npm install

# 2. Copiar prisma primero (IMPORTANTE)
COPY prisma ./prisma

# 3. Generar Prisma DENTRO del contenedor (Linux)
RUN npx prisma generate

# 4. Copiar el resto del código
COPY . .

EXPOSE 8080

CMD ["npm", "run", "dev"]