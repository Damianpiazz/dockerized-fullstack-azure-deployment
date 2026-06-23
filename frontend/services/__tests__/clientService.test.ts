import { describe, it, expect, vi, beforeEach } from "vitest";
import { clientService } from "../clientService";

const mockClient = {
  id: 1,
  firstName: "Juan",
  lastName: "Pérez",
  email: "juan@perez.com",
  phone: "+54 11 5555-0101",
  isActive: true,
  createdAt: "2024-01-01T00:00:00.000Z",
  updatedAt: "2024-01-01T00:00:00.000Z",
};

beforeEach(() => {
  vi.restoreAllMocks();
});

describe("clientService", () => {
  describe("getAll", () => {
    it("returns clients on success", async () => {
      vi.spyOn(globalThis, "fetch").mockResolvedValue({
        ok: true,
        json: () => Promise.resolve([mockClient]),
      } as Response);

      const result = await clientService.getAll();
      expect(result).toEqual([mockClient]);
      expect(fetch).toHaveBeenCalledWith(expect.stringContaining("/clients"));
    });

    it("throws on error response", async () => {
      vi.spyOn(globalThis, "fetch").mockResolvedValue({
        ok: false,
      } as Response);

      await expect(clientService.getAll()).rejects.toThrow("Error al obtener clientes");
    });
  });

  describe("create", () => {
    it("sends POST with correct payload", async () => {
      vi.spyOn(globalThis, "fetch").mockResolvedValue({
        ok: true,
        json: () => Promise.resolve(mockClient),
      } as Response);

      const payload = { firstName: "Juan", lastName: "Pérez", email: "juan@perez.com" };
      const result = await clientService.create(payload);

      expect(result).toEqual(mockClient);
      expect(fetch).toHaveBeenCalledWith(
        expect.stringContaining("/clients"),
        expect.objectContaining({
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify(payload),
        })
      );
    });
  });

  describe("update", () => {
    it("sends PUT with correct payload", async () => {
      vi.spyOn(globalThis, "fetch").mockResolvedValue({
        ok: true,
        json: () => Promise.resolve(mockClient),
      } as Response);

      const payload = { firstName: "Updated" };
      const result = await clientService.update(1, payload);

      expect(result).toEqual(mockClient);
      expect(fetch).toHaveBeenCalledWith(
        expect.stringContaining("/clients/1"),
        expect.objectContaining({ method: "PUT" })
      );
    });
  });

  describe("remove", () => {
    it("sends DELETE", async () => {
      vi.spyOn(globalThis, "fetch").mockResolvedValue({
        ok: true,
      } as Response);

      await clientService.remove(1);
      expect(fetch).toHaveBeenCalledWith(
        expect.stringContaining("/clients/1"),
        expect.objectContaining({ method: "DELETE" })
      );
    });
  });
});
