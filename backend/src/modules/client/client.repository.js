import "dotenv/config";
import { PrismaClient } from "../../../generated/prisma/index.js";

const prisma = new PrismaClient();

export const findAll = () => prisma.client.findMany();
export const findById = (id) => prisma.client.findUnique({ where: { id } });
export const create = (data) => prisma.client.create({ data });
export const update = (id, data) => prisma.client.update({ where: { id }, data });
export const remove = (id) => prisma.client.delete({ where: { id } });