# Backend - API REST con Express

## 📌 Descripción

Este proyecto corresponde al desarrollo de un backend utilizando Express, enfocado en la implementación de una API REST para la gestión de clientes. Se aplican buenas prácticas de arquitectura en capas, separación de responsabilidades y configuración modular, permitiendo un código escalable, mantenible y profesional.

---

## 🧱 Tecnologías utilizadas

* Node.js
* Express
* dotenv
* cors

---

## 📁 Estructura del proyecto

```
backend/
 ├── src/
 │    ├── app.js
 │    ├── server.js
 │    ├── config/
 │    │    └── cors.js
 │    ├── middlewares/
 │    │    ├── logger.js
 │    │    └── notFound.js
 │    ├── routes/
 │    │    ├── index.js
 │    │    └── client.routes.js
 │    └── modules/
 │         └── client/
 │              ├── client.controller.js
 │              ├── client.service.js
 │              └── client.repository.js
 ├── .env
 └── package.json
```

---

## ⚙️ Configuración del servidor

### `server.js`

Este archivo es el punto de entrada de la aplicación. Su responsabilidad es:

* Cargar variables de entorno
* Inicializar el servidor
* Definir el puerto de ejecución

```js
import dotenv from "dotenv";
import app from "./app.js";

dotenv.config();

const PORT = process.env.PORT || 3000;

app.listen(PORT, "0.0.0.0", () => {
  console.log(`Servidor corriendo en http://localhost:${PORT}`);
});
```

---

## ⚙️ Configuración de la aplicación

### `app.js`

Se encarga de:

* Inicializar Express
* Configurar middlewares
* Registrar rutas
* Manejar errores globales

```js
import express from "express";
import cors from "cors";
import routes from "./routes/index.js";
import logger from "./middlewares/logger.js";
import notFound from "./middlewares/notFound.js";
import corsConfig from "./config/cors.js";

const app = express();

app.use(express.json());
app.use(cors(corsConfig));

app.use(logger);

app.use("/api", routes);

app.use(notFound);

export default app;
```

---

## 🌐 Configuración de CORS

Archivo: `config/cors.js`

Permite controlar qué orígenes pueden consumir la API.

```js
const corsConfig = {
  origin: ["http://localhost:3001"],
  methods: ["GET", "POST", "PUT", "DELETE"],
  allowedHeaders: ["Content-Type"],
};

export default corsConfig;
```

---

## 🧩 Middlewares

### Logger

Archivo: `middlewares/logger.js`

Registra cada request que llega al servidor.

```js
export default function logger(req, res, next) {
  console.log(`${req.method} ${req.url}`);
  next();
}
```

---

### NotFound

Archivo: `middlewares/notFound.js`

Maneja rutas inexistentes.

```js
export default function notFound(req, res) {
  res.status(404).json({ error: "Ruta no encontrada" });
}
```

---

## 🔌 Rutas

### `routes/index.js`

Centraliza todas las rutas de la aplicación.

```js
import { Router } from "express";
import clientRouter from "./client.routes.js";

const router = Router();

router.use("/clients", clientRouter);

export default router;
```

---

### `routes/client.routes.js`

Define los endpoints del módulo cliente.

```js
import { Router } from "express";
import * as clientController from "../modules/client/client.controller.js";

const router = Router();

router.get("/", clientController.getAll);
router.get("/:id", clientController.getById);
router.post("/", clientController.create);
router.put("/:id", clientController.update);
router.delete("/:id", clientController.remove);

export default router;
```

---

## 🧠 Arquitectura en capas

Se implementa una arquitectura en capas para mejorar la organización del código:

```
Controller → Service → Repository
```

---

### Controller

Archivo: `client.controller.js`

Responsable de:

* Recibir requests
* Validar parámetros básicos
* Enviar respuestas

---

### Service

Archivo: `client.service.js`

Responsable de:

* Contener la lógica de negocio
* Coordinar operaciones

---

### Repository

Archivo: `client.repository.js`

Responsable de:

* Acceso a datos
* Interacción con la base de datos

---

## 📡 Endpoints disponibles

Base URL:

```
/api/clients
```

| Método | Endpoint     | Descripción        |
| ------ | ------------ | ------------------ |
| GET    | /clients     | Obtener todos      |
| GET    | /clients/:id | Obtener por ID     |
| POST   | /clients     | Crear cliente      |
| PUT    | /clients/:id | Actualizar cliente |
| DELETE | /clients/:id | Eliminar cliente   |

---

## ⚙️ Variables de entorno

Archivo: `.env`

```
PORT=3000
NODE_ENV=development
CORS_ORIGIN=http://localhost:3001
```

---

## 🚀 Ejecución del proyecto

### Instalar dependencias

```bash
npm install
```

### Ejecutar en desarrollo

```bash
npm run dev
```

---

## 🧪 Ejemplo de request

### Crear cliente

```json
{
  "firstName": "Juan",
  "lastName": "Perez",
  "email": "juan@mail.com"
}
```

---

## ⚠️ Consideraciones

* El servidor escucha en `0.0.0.0` para compatibilidad con Docker
* Las rutas están prefijadas con `/api`
* Se utiliza JSON como formato de intercambio

---

## 🎯 Objetivo

Este backend demuestra la construcción de una API REST utilizando Express con una arquitectura organizada y escalable, aplicando principios de separación de responsabilidades y buenas prácticas de desarrollo.

---