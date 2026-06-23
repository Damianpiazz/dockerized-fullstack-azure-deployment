import { describe, it, expect, beforeAll, afterAll } from "vitest";
import request from "supertest";
import { PrismaClient } from "@prisma/client";

process.env.NODE_ENV = "test";
process.env.DATABASE_URL = process.env.DATABASE_URL || "postgresql://app_user:app_pass@localhost:5432/app_db_test";
process.env.LOG_LEVEL = "silent";

const prisma = new PrismaClient();
let app;

beforeAll(async () => {
  const appModule = await import("../../../app.js");
  app = appModule.default;
  await prisma.client.deleteMany();
});

afterAll(async () => {
  await prisma.client.deleteMany();
  await prisma.$disconnect();
});

describe("GET /api/clients", () => {
  it("returns empty list when no clients exist", async () => {
    const res = await request(app).get("/api/clients");
    expect(res.status).toBe(200);
    expect(res.body).toEqual([]);
  });

  it("returns all clients", async () => {
    await prisma.client.create({
      data: { firstName: "Test", lastName: "User", email: "test@test.com" },
    });

    const res = await request(app).get("/api/clients");
    expect(res.status).toBe(200);
    expect(res.body).toHaveLength(1);
    expect(res.body[0].email).toBe("test@test.com");

    await prisma.client.deleteMany();
  });
});

describe("POST /api/clients", () => {
  it("creates a new client", async () => {
    const payload = {
      firstName: "Juan",
      lastName: "Pérez",
      email: "juan@perez.com",
      phone: "+54 11 5555-0101",
    };

    const res = await request(app).post("/api/clients").send(payload);
    expect(res.status).toBe(201);
    expect(res.body.firstName).toBe("Juan");
    expect(res.body.email).toBe("juan@perez.com");
    expect(res.body.isActive).toBe(true);

    await prisma.client.deleteMany();
  });

  it("rejects duplicate email", async () => {
    await prisma.client.create({
      data: { firstName: "A", lastName: "B", email: "dup@test.com" },
    });

    const res = await request(app).post("/api/clients").send({
      firstName: "C",
      lastName: "D",
      email: "dup@test.com",
    });
    expect(res.status).toBe(500);

    await prisma.client.deleteMany();
  });
});

describe("PUT /api/clients/:id", () => {
  it("updates an existing client", async () => {
    const client = await prisma.client.create({
      data: { firstName: "Old", lastName: "Name", email: "old@test.com" },
    });

    const res = await request(app)
      .put(`/api/clients/${client.id}`)
      .send({ firstName: "New", lastName: "Name" });

    expect(res.status).toBe(200);
    expect(res.body.firstName).toBe("New");
    expect(res.body.email).toBe("old@test.com");

    await prisma.client.deleteMany();
  });
});

describe("DELETE /api/clients/:id", () => {
  it("deletes a client", async () => {
    const client = await prisma.client.create({
      data: { firstName: "Del", lastName: "Ete", email: "del@test.com" },
    });

    const res = await request(app).delete(`/api/clients/${client.id}`);
    expect(res.status).toBe(204);

    const deleted = await prisma.client.findUnique({ where: { id: client.id } });
    expect(deleted).toBeNull();
  });
});

describe("GET /health", () => {
  it("returns ok status", async () => {
    const res = await request(app).get("/health");
    expect(res.status).toBe(200);
    expect(res.body.status).toBe("ok");
  });
});
