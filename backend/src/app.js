import express from "express";
import cors from "cors";
import helmet from "helmet";
import rateLimit from "express-rate-limit";
import pinoHttp from "pino-http";
import { env } from "./config/env.js";
import { logger } from "./config/logger.js";
import routes from "./routes/index.js";
import errorHandler from "./middlewares/errorHandler.js";
import notFound from "./middlewares/notFound.js";
import { register, httpRequestDuration, httpRequestsTotal, dbConnectionsGauge } from "./config/metrics.js";

const app = express();

app.use(helmet());
app.use(express.json({ limit: "1mb" }));

app.use(
  cors({
    origin: env.CORS_ORIGIN.split(",").map((o) => o.trim()),
    methods: ["GET", "POST", "PUT", "DELETE", "PATCH"],
    allowedHeaders: ["Content-Type", "Authorization"],
    credentials: true,
  })
);

app.use(
  pinoHttp({
    logger,
    quietReqLogger: true,
    autoLogging: env.NODE_ENV !== "test",
    redact: ["req.headers.authorization", "req.headers.cookie"],
  })
);

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100,
  standardHeaders: true,
  legacyHeaders: false,
  message: { error: "Demasiadas solicitudes, intentá de nuevo más tarde" },
});
app.use(limiter);

app.use((req, res, next) => {
  const start = Date.now();
  res.on("finish", () => {
    const duration = (Date.now() - start) / 1000;
    httpRequestsTotal.inc({ method: req.method, route: req.route?.path || req.path, status: res.statusCode });
    httpRequestDuration.observe({ method: req.method, route: req.route?.path || req.path, status: res.statusCode }, duration);
  });
  next();
});

app.get("/health", (_req, res) => {
  res.json({ status: "ok", timestamp: new Date().toISOString() });
});

app.get("/metrics", async (_req, res) => {
  res.set("Content-Type", register.contentType);
  res.end(await register.metrics());
});

app.use("/api", routes);

app.use(notFound);
app.use(errorHandler);

export default app;
