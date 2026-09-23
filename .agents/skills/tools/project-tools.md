# Herramientas del Proyecto

## Frontend (`frontend_gestion_documental/`)

- `npm run dev`: servidor de desarrollo Next.js (http://localhost:3000).
- `npm run build`: build de producción con verificación de tipos.
- `npm run start`: sirve el build.
- `npm run lint`: ESLint 9 con `eslint-config-next` (core-web-vitals + typescript).

Documentación de Next.js 16 incluida en `node_modules/next/dist/docs/` (leerla antes de
usar APIs; hay cambios respecto a versiones anteriores).

## Backend (`backend_gestion_documental/`)

- Dependencias: `express` 5, `nodemon` (dev).
- Aún no hay scripts `dev`, `start` ni `test` funcionales: se crean en la primera tarea de
  backend.

## Variables de entorno

Todavía no hay ninguna. Cuando se agreguen: `.env` ignorado por git + `.env.example`
versionado. Nada secreto en `NEXT_PUBLIC_*`.

## Vista previa en Claude Code

`.claude/launch.json` define `frontend-dev` (Next.js, puerto 3000).
