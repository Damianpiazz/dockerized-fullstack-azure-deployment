const API_URL = process.env.NEXT_PUBLIC_API_URL || "http://localhost:3000/api";

export interface Client {
  id: number;
  firstName: string;
  lastName: string;
  email: string;
  phone?: string | null;
  document?: string | null;
  address?: string | null;
  isActive: boolean;
  createdAt: string;
  updatedAt: string;
}

export interface ClientFormData {
  firstName: string;
  lastName: string;
  email: string;
  phone?: string;
  document?: string;
  address?: string;
  isActive?: boolean;
}

export const clientService = {
  getAll: async (): Promise<Client[]> => {
    const res = await fetch(`${API_URL}/clients`);
    if (!res.ok) throw new Error("Error al obtener clientes");
    return res.json();
  },

  getById: async (id: number): Promise<Client> => {
    const res = await fetch(`${API_URL}/clients/${id}`);
    if (!res.ok) throw new Error("Cliente no encontrado");
    return res.json();
  },

  create: async (data: ClientFormData): Promise<Client> => {
    const res = await fetch(`${API_URL}/clients`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(data),
    });
    if (!res.ok) throw new Error("Error al crear cliente");
    return res.json();
  },

  update: async (id: number, data: ClientFormData): Promise<Client> => {
    const res = await fetch(`${API_URL}/clients/${id}`, {
      method: "PUT",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(data),
    });
    if (!res.ok) throw new Error("Error al actualizar cliente");
    return res.json();
  },

  remove: async (id: number): Promise<void> => {
    const res = await fetch(`${API_URL}/clients/${id}`, {
      method: "DELETE",
    });
    if (!res.ok) throw new Error("Error al eliminar cliente");
  },
};