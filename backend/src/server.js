import "./config/env.js";
import { logger } from "./config/logger.js";
import { env } from "./config/env.js";
import app from "./app.js";
import { initOpenTelemetry } from "./config/telemetry.js";

async function main() {
  if (env.OTEL_ENABLED) {
    await initOpenTelemetry();
  }

  app.listen(env.PORT, "0.0.0.0", () => {
    logger.info({ port: env.PORT, env: env.NODE_ENV }, `Servidor corriendo en http://0.0.0.0:${env.PORT}`);
  });
}

main().catch((err) => {
  logger.fatal(err, "Error al iniciar el servidor");
  process.exit(1);
});
