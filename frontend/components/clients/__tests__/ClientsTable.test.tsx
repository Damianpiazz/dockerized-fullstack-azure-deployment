import { describe, it, expect, vi } from "vitest";
import { render, screen, waitFor } from "@testing-library/react";
import ClientsTable from "../ClientsTable";

vi.mock("@/services/clientService", () => {
  const mockClients = [
    {
      id: 1,
      firstName: "Juan",
      lastName: "Pérez",
      email: "juan@perez.com",
      phone: "+54 11 5555-0101",
      document: null,
      address: null,
      isActive: true,
      createdAt: "2024-01-01T00:00:00.000Z",
      updatedAt: "2024-01-01T00:00:00.000Z",
    },
  ];

  return {
    clientService: {
      getAll: vi.fn().mockResolvedValue(mockClients),
      remove: vi.fn().mockResolvedValue(undefined),
    },
  };
});

describe("ClientsTable", () => {
  it("renders clients after loading", async () => {
    render(<ClientsTable />);

    await waitFor(() => {
      expect(screen.getByText("Juan Pérez")).toBeDefined();
    });
  });

  it("renders 'Nuevo cliente' button", async () => {
    render(<ClientsTable />);

    await waitFor(() => {
      expect(screen.getByText("Nuevo cliente")).toBeDefined();
    });
  });

  it("renders table headers", async () => {
    render(<ClientsTable />);

    await waitFor(() => {
      expect(screen.getByText("Nombre")).toBeDefined();
      expect(screen.getByText("Email")).toBeDefined();
      expect(screen.getByText("Estado")).toBeDefined();
      expect(screen.getByText("Acciones")).toBeDefined();
    });
  });
});
