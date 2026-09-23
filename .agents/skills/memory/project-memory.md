# Memoria del Proyecto

## Estado actual (2026-09-23)

- Repo git en `app gestion documental/` sin commits todavía.
- `frontend_gestion_documental/`: plantilla recién creada de Next.js 16 (solo
  `app/layout.tsx`, `app/page.tsx`, `app/globals.css`).
- `backend_gestion_documental/`: `package.json` con Express 5 y nodemon; sin código ni
  scripts.
- F-02 v1.0 redactado (25-ago-2026); ampliación de alcance con portal público confirmada
  por el cliente el 1-sep-2026. Pendiente firma del numeral 9.

## Decisiones tomadas

- Stack: Next.js + Express (ya instalado).
- Portal público sin inicio de sesión; respuesta solo por correo (decisión explícita del
  cliente).
- Nada se borra: anulación y deshabilitación.

## Riesgos conocidos

- Firma del F-02 pendiente: sin ella no se avanza al siguiente hito.
- Infraestructura de despliegue no autorizada aún (riesgo R-03 del F-00).
- Prellenado por cédula en el portal público expone datos personales (ver
  `ia_contexto/spec/decisiones.md`).
- Volumen real de radicados sin confirmar (RNF-001 es tentativo).
- Series/subseries (TRD) y definición de "expediente" pendientes con Archivo Central.
- Listado completo de dependencias/programas destinatarios pendiente.

## Preguntas abiertas para la segunda entrevista

Ver `ia_contexto/spec/decisiones.md`, sección "Preguntas abiertas".
