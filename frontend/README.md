# Frontend - Gestión de Clientes

## 📌 Descripción

Este proyecto es el frontend de la aplicación de gestión de clientes, desarrollado con Next.js 16 y TypeScript. Consume la API REST del backend Express y ofrece una interfaz moderna construida con shadcn/ui y Tailwind CSS.

---

## 🧱 Tecnologías utilizadas

* Next.js 16 (App Router)
* TypeScript
* Tailwind CSS v4
* shadcn/ui (radix-ui)
* react-hook-form
* lucide-react

---

## 📁 Estructura del proyecto
```
frontend/
├── app/
│    ├── layout.tsx
│    ├── page.tsx
│    └── clients/
│         └── page.tsx
├── components/
│    ├── ui/
│    │    ├── button.tsx
│    │    ├── input.tsx
│    │    ├── label.tsx
│    │    ├── switch.tsx
│    │    ├── dialog.tsx
│    │    ├── alert-dialog.tsx
│    │    ├── table.tsx
│    │    └── badge.tsx
│    └── clients/
│         ├── ClientsTable.tsx
│         └── ClientForm.tsx
├── services/
│    └── clientService.ts
├── .env.local
└── package.json
```

---

## 📄 Páginas

### `app/page.tsx`

Página de inicio. Muestra el título del sistema y un botón que navega a `/clients`.

### `app/clients/page.tsx`

Página de listado de clientes. Renderiza el componente `ClientsTable`.

---

## 🧩 Componentes

### `ClientsTable`

Archivo: `components/clients/ClientsTable.tsx`

Componente principal de la gestión de clientes. Se encarga de:

* Listar todos los clientes en una tabla
* Abrir el formulario para crear un nuevo cliente
* Abrir el formulario con datos precargados para editar
* Confirmar y ejecutar la eliminación de un cliente

### `ClientForm`

Archivo: `components/clients/ClientForm.tsx`

Formulario en modal (Dialog) para crear o editar un cliente. Utiliza `react-hook-form` para el manejo del estado y validaciones. Campos:

* `firstName` — Nombre (requerido)
* `lastName` — Apellido (requerido)
* `email` — Email (requerido, formato válido)
* `phone` — Teléfono (opcional)
* `document` — Documento (opcional)
* `address` — Dirección (opcional)
* `isActive` — Estado activo/inactivo (Switch)

---

## 🌐 Servicio

### `clientService`

Archivo: `services/clientService.ts`

Encapsula todas las llamadas HTTP a la API REST del backend. Métodos disponibles:

| Método     | Descripción                        |
| ---------- | ---------------------------------- |
| `getAll`   | Obtiene todos los clientes         |
| `getById`  | Obtiene un cliente por ID          |
| `create`   | Crea un nuevo cliente              |
| `update`   | Actualiza un cliente existente     |
| `remove`   | Elimina un cliente                 |

---

## 📡 Conexión con el backend

El frontend se comunica con el backend mediante fetch directo al API REST de Express.

La URL base se configura mediante variable de entorno:
NEXT_PUBLIC_API_URL=http://localhost:8080/api

---

## ⚙️ Variables de entorno

Archivo: `.env.local`
NEXT_PUBLIC_API_URL=http://localhost:8080/api

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

El frontend corre en `http://localhost:3000`.