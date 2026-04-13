import * as clientService from "./client.service.js";

export const getAll = async (req, res) => {
  const clients = await clientService.getAll();
  res.json(clients);
};

export const getById = async (req, res) => {
  const client = await clientService.getById(Number(req.params.id));
  res.json(client);
};

export const create = async (req, res) => {
  const client = await clientService.create(req.body);
  res.status(201).json(client);
};

export const update = async (req, res) => {
  const client = await clientService.update(Number(req.params.id), req.body);
  res.json(client);
};

export const remove = async (req, res) => {
  await clientService.remove(Number(req.params.id));
  res.status(204).send();
};