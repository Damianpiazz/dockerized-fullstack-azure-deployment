import { logger } from "../config/logger.js";
import { env } from "../config/env.js";

export default function errorHandler(err, _req, res, _next) {
  logger.error({ err }, "Unhandled error");

  const statusCode = err.statusCode || err.status || 500;

  const body = {
    error: statusCode === 500 ? "Error interno del servidor" : err.message,
  };

  if (env.NODE_ENV === "development" && statusCode === 500) {
    body.stack = err.stack;
  }

  res.status(statusCode).json(body);
}
