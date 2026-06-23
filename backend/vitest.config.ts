import { defineConfig } from "vitest/config";

export default defineConfig({
  test: {
    globals: true,
    environment: "node",
    include: ["src/**/__tests__/**/*.test.{js,ts}"],
    setupFiles: [],
    testTimeout: 15000,
    hookTimeout: 20000,
    coverage: {
      provider: "v8",
      reporter: ["text", "lcov", "html"],
      include: ["src/modules/**/*.js"],
      exclude: ["src/**/__tests__/**"],
    },
    server: {
      deps: {
        inline: ["zod"],
      },
    },
  },
});
