import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

const clients = [
  { firstName: "Juan", lastName: "Pérez", email: "juan.perez@email.com", phone: "+54 11 5555-0101", document: "DNI 30.123.456", address: "Av. Corrientes 1234, CABA", isActive: true },
  { firstName: "María", lastName: "González", email: "maria.gonzalez@email.com", phone: "+54 11 5555-0102", document: "DNI 31.234.567", address: "Calle Florida 567, CABA", isActive: true },
  { firstName: "Carlos", lastName: "López", email: "carlos.lopez@email.com", phone: "+54 11 5555-0103", document: "DNI 32.345.678", address: "Av. Rivadavia 890, CABA", isActive: true },
  { firstName: "Ana", lastName: "Martínez", email: "ana.martinez@email.com", phone: "+54 11 5555-0104", document: "DNI 33.456.789", address: "Calle San Martín 234, CABA", isActive: false },
  { firstName: "Pedro", lastName: "Ramírez", email: "pedro.ramirez@email.com", phone: "+54 11 5555-0105", isActive: true },
];

async function main() {
  console.log("Seeding database...");

  for (const client of clients) {
    await prisma.client.upsert({
      where: { email: client.email },
      update: {},
      create: client,
    });
  }

  console.log(`Seeded ${clients.length} clients`);
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
