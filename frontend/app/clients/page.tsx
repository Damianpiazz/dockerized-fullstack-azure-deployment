import { Metadata } from "next";
import { ErrorBoundary } from "@/components/common/ErrorBoundary";
import ClientsTable from "@/components/clients/ClientsTable";

export const metadata: Metadata = {
  title: "Clientes | Gestión de Clientes",
  description: "Listado y gestión de clientes",
};

export default function ClientsPage() {
  return (
    <main className="container mx-auto py-8 px-4">
      <ErrorBoundary>
        <ClientsTable />
      </ErrorBoundary>
    </main>
  );
}
