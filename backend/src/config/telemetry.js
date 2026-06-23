import { env } from "./env.js";
import { logger } from "./logger.js";

export async function initOpenTelemetry() {
  if (!env.OTEL_ENABLED) return;

  try {
    const { NodeSDK } = await import("@opentelemetry/sdk-node");
    const { getNodeAutoInstrumentations } = await import("@opentelemetry/instrumentation-http");
    const { HttpInstrumentation } = await import("@opentelemetry/instrumentation-http");
    const { ExpressInstrumentation } = await import("@opentelemetry/instrumentation-express");
    const { PgInstrumentation } = await import("@opentelemetry/instrumentation-pg");
    const { OTLPTraceExporter } = await import("@opentelemetry/exporter-trace-otlp-http");
    const { OTLPMetricExporter } = await import("@opentelemetry/exporter-metrics-otlp-http");
    const { PeriodicExportingMetricReader } = await import("@opentelemetry/sdk-metrics");
    const { Resource } = await import("@opentelemetry/resources");
    const { SEMRESATTRS_SERVICE_NAME } = await import("@opentelemetry/semantic-conventions");

    const sdk = new NodeSDK({
      resource: new Resource({
        [SEMRESATTRS_SERVICE_NAME]: env.OTEL_SERVICE_NAME,
      }),
      traceExporter: new OTLPTraceExporter({
        url: env.OTEL_EXPORTER_OTLP_ENDPOINT + "/v1/traces",
      }),
      metricReader: new PeriodicExportingMetricReader({
        exporter: new OTLPMetricExporter({
          url: env.OTEL_EXPORTER_OTLP_ENDPOINT + "/v1/metrics",
        }),
        exportIntervalMillis: 10000,
      }),
      instrumentations: [
        new HttpInstrumentation(),
        new ExpressInstrumentation(),
        new PgInstrumentation(),
      ],
    });

    await sdk.start();
    logger.info("OpenTelemetry initialized");

    process.on("SIGTERM", async () => {
      await sdk.shutdown();
      logger.info("OpenTelemetry shut down");
    });
  } catch (error) {
    logger.warn({ error }, "Failed to initialize OpenTelemetry (non-blocking)");
  }
}
