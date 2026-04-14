FROM node:20-alpine

WORKDIR /app

RUN apk add --no-cache openssl

COPY package*.json ./
COPY prisma ./prisma/

RUN npm install

RUN npx prisma generate

COPY . .

EXPOSE 8080

CMD ["sh", "-c", "sleep 5 && npx prisma db push && node src/server.js"]