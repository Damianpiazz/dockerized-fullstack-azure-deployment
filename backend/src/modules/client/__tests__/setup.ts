import { beforeAll, afterAll } from "vitest";

beforeAll(async () => {
  process.env.NODE_ENV = "test";
  process.env.LOG_LEVEL = "silent";
});

afterAll(async () => {
  const { PrismaClient } = await import("@prisma/client");
  const prisma = new PrismaClient();
  await prisma.$disconnect();
});
