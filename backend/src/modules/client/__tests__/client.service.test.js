import { describe, it, expect, vi, beforeEach } from "vitest";
import * as repo from "../client.repository.js";
import * as service from "../client.service.js";

vi.mock("../client.repository.js", () => ({
  findAll: vi.fn(),
  findById: vi.fn(),
  create: vi.fn(),
  update: vi.fn(),
  remove: vi.fn(),
}));

const mockClient = {
  id: 1,
  firstName: "Juan",
  lastName: "Pérez",
  email: "juan@perez.com",
  isActive: true,
  createdAt: new Date().toISOString(),
  updatedAt: new Date().toISOString(),
};

beforeEach(() => {
  vi.clearAllMocks();
});

describe("getAll", () => {
  it("calls repo.findAll and returns clients", async () => {
    vi.mocked(repo.findAll).mockResolvedValue([mockClient]);
    const result = await service.getAll();
    expect(repo.findAll).toHaveBeenCalledOnce();
    expect(result).toEqual([mockClient]);
  });
});

describe("getById", () => {
  it("calls repo.findById with the id", async () => {
    vi.mocked(repo.findById).mockResolvedValue(mockClient);
    const result = await service.getById(1);
    expect(repo.findById).toHaveBeenCalledWith(1);
    expect(result).toEqual(mockClient);
  });
});

describe("create", () => {
  it("calls repo.create with the data", async () => {
    const data = { firstName: "Juan", lastName: "Pérez", email: "juan@perez.com" };
    vi.mocked(repo.create).mockResolvedValue(mockClient);
    const result = await service.create(data);
    expect(repo.create).toHaveBeenCalledWith(data);
    expect(result).toEqual(mockClient);
  });
});

describe("update", () => {
  it("calls repo.update with id and data", async () => {
    const data = { firstName: "Updated" };
    vi.mocked(repo.update).mockResolvedValue({ ...mockClient, ...data });
    const result = await service.update(1, data);
    expect(repo.update).toHaveBeenCalledWith(1, data);
    expect(result.firstName).toBe("Updated");
  });
});

describe("remove", () => {
  it("calls repo.remove with the id", async () => {
    vi.mocked(repo.remove).mockResolvedValue(undefined);
    await service.remove(1);
    expect(repo.remove).toHaveBeenCalledWith(1);
  });
});
