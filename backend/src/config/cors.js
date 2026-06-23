import { env } from "./env.js";

const corsConfig = {
  origin: env.CORS_ORIGIN.split(",").map((o) => o.trim()),
  methods: ["GET", "POST", "PUT", "DELETE", "PATCH"],
  allowedHeaders: ["Content-Type", "Authorization"],
  credentials: true,
};

export default corsConfig;
