#!/bin/sh

echo "Generating Prisma client..."
npx prisma generate

echo "=== Prisma db push ==="
npx prisma db push

echo "Starting server..."
npm run dev