import express from "express";
import cors from "cors";
import routes from "./routes/index.js";
import logger from "./middlewares/logger.js";
import notFound from "./middlewares/notFound.js";
import corsConfig from "./config/cors.js";

const app = express();

app.use(express.json());
app.use(cors(corsConfig));

// middlewares
app.use(logger);

// rutas
app.use("/api", routes);

// 404
app.use(notFound);

export default app;