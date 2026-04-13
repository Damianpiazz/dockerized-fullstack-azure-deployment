import { Router } from "express";
import clientRouter from "./client.routes.js";

const router = Router();

router.use("/clients", clientRouter);

export default router;