import pino from "pino";
import { env } from "./env.js";

const targets = [];

if (env.NODE_ENV === "development") {
  targets.push({
    target: "pino/file",
    options: { destination: 1 },
    level: "debug",
  });
} else if (env.NODE_ENV === "production") {
  targets.push({
    target: "pino/file",
    options: { destination: 1 },
    level: "info",
  });
}

export const logger = pino({
  level: env.LOG_LEVEL,
  transport: targets.length > 0
    ? {
        targets,
      }
    : undefined,
  serializers: {
    req: (req) => ({
      method: req.method,
      url: req.url,
      headers: undefined,
    }),
    res: (res) => ({
      statusCode: res.statusCode,
    }),
    err: pino.stdSerializers.err,
  },
  redact: ["req.headers.authorization", "req.headers.cookie"],
});
