import { test, expect } from "@playwright/test";

test.describe("Client management flow", () => {
  test("creates, displays, and deletes a client", async ({ page }) => {
    await page.goto("/clients");

    await expect(page.getByRole("heading", { name: "Clientes" })).toBeVisible();

    await page.getByRole("button", { name: "Nuevo cliente" }).click();

    await page.getByLabel("Nombre *").fill("E2E");
    await page.getByLabel("Apellido *").fill("Test");
    await page.getByLabel("Email *").fill("e2e@test.com");
    await page.getByLabel("Teléfono").fill("+54 11 5555-0000");

    await page.getByRole("button", { name: "Crear" }).click();

    await expect(page.getByText("E2E Test")).toBeVisible();
    await expect(page.getByText("e2e@test.com")).toBeVisible();

    await page.getByRole("button", { name: "Nuevo cliente" }).click();
    await page.getByLabel("Nombre *").fill("Second");
    await page.getByLabel("Apellido *").fill("User");
    await page.getByLabel("Email *").fill("second@test.com");
    await page.getByRole("button", { name: "Crear" }).click();

    await expect(page.getByText("Second User")).toBeVisible();

    const deleteButtons = page.getByRole("button", { name: "" }).filter({ has: page.locator("svg.lucide-trash2") });
    await deleteButtons.first().click();

    await page.getByRole("button", { name: "Eliminar" }).click();

    await expect(page.getByText("E2E Test")).not.toBeVisible();
  });

  test("shows validation errors on empty form", async ({ page }) => {
    await page.goto("/clients");

    await page.getByRole("button", { name: "Nuevo cliente" }).click();
    await page.getByRole("button", { name: "Crear" }).click();

    await expect(page.getByText("Requerido")).toHaveCount(3);
  });
});
