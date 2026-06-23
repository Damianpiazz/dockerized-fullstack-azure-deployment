import { describe, it, expect, vi } from "vitest";
import { render, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import ClientForm from "../ClientForm";

vi.mock("@/services/clientService", () => ({
  clientService: {
    create: vi.fn().mockResolvedValue({ id: 1 }),
    update: vi.fn().mockResolvedValue({ id: 1 }),
  },
}));

const defaultProps = {
  open: true,
  onClose: vi.fn(),
  onSuccess: vi.fn(),
  client: null,
};

describe("ClientForm", () => {
  it("renders the form with title 'Nuevo cliente'", () => {
    render(<ClientForm {...defaultProps} />);
    expect(screen.getByText("Nuevo cliente")).toBeDefined();
  });

  it("renders 'Editar cliente' when editing", () => {
    render(
      <ClientForm
        {...defaultProps}
        client={{
          id: 1,
          firstName: "Juan",
          lastName: "Pérez",
          email: "juan@perez.com",
          isActive: true,
          createdAt: "",
          updatedAt: "",
        }}
      />
    );
    expect(screen.getByText("Editar cliente")).toBeDefined();
  });

  it("shows required fields marked with asterisk", () => {
    render(<ClientForm {...defaultProps} />);
    expect(screen.getByText("Nombre *")).toBeDefined();
    expect(screen.getByText("Apellido *")).toBeDefined();
    expect(screen.getByText("Email *")).toBeDefined();
  });

  it("calls onClose when cancel is clicked", async () => {
    const onClose = vi.fn();
    render(<ClientForm {...defaultProps} onClose={onClose} />);

    const cancelButton = screen.getByText("Cancelar");
    await userEvent.click(cancelButton);

    expect(onClose).toHaveBeenCalledOnce();
  });
});
