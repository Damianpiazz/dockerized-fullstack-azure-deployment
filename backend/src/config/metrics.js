import promClient from "prom-client";

const register = new promClient.Registry();

promClient.collectDefaultMetrics({ register, prefix: "app_" });

const httpRequestsTotal = new promClient.Counter({
  name: "app_http_requests_total",
  help: "Total number of HTTP requests",
  labelNames: ["method", "route", "status"],
  registers: [register],
});

const httpRequestDuration = new promClient.Histogram({
  name: "app_http_request_duration_seconds",
  help: "Duration of HTTP requests in seconds",
  labelNames: ["method", "route", "status"],
  buckets: [0.01, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5, 10],
  registers: [register],
});

const dbConnectionsGauge = new promClient.Gauge({
  name: "app_db_connections_active",
  help: "Number of active database connections",
  registers: [register],
});

export { register, httpRequestsTotal, httpRequestDuration, dbConnectionsGauge };
