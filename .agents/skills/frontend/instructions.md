# Instrucciones de Frontend

## Stack

- Next.js 16.3 con App Router, React 19.2, TypeScript estricto.
- Tailwind CSS 4: tokens en `app/globals.css` con `@theme` (no hay `tailwind.config.js`).
- Alias de imports `@/*` → raíz de `frontend_gestion_documental/`.
- **Antes de usar cualquier API de Next, leer la guía en `node_modules/next/dist/docs/`.**
  En Next 16, `middleware.ts` pasó a llamarse `proxy.ts`.

## Estructura de rutas propuesta

```
app/
  (publico)/                 portal público, sin sesión (RF-017)
    radicar/page.tsx
    radicar/comprobante/page.tsx
  (panel)/                   panel interno, con sesión y menú por rol
    login/page.tsx           RF-013
    radicados/…              bandeja, detalle, línea de tiempo (RF-001, 002, 004–006, 009, 011)
    personas/…               búsqueda por cédula e historial (RF-007, RF-008)
    correspondencia/…        registro sin consecutivo (RF-014)
    expedientes/…            Archivo Central (RF-010)
    usuarios/…               solo Administrador (RF-012)
    configuracion/…          tipos de trámite, plazos, comité (RN-007)
components/                  UI compartida
lib/                         cliente de la API, tipos de contrato, utilidades
```

Los grupos `(publico)` y `(panel)` tienen layouts distintos: el portal no importa nada del
panel.

## Reglas

- La API es la fuente de verdad: el frontend no calcula consecutivos, estados ni permisos.
- Tipos de contrato y vocabularios cerrados (estado, rol, tipo de documento, canal) en
  `lib/`, como uniones de literales. Nada de `any`.
- Server Components por defecto; `"use client"` solo donde hay interacción.
- No pasar a componentes cliente objetos con datos sensibles que no se muestran.
- Menú y acciones según rol **para ergonomía**; la autorización real es del backend.
- Listados siempre paginados; filtros combinados reflejados en la URL (sin datos
  personales en la URL: la cédula va en el cuerpo de la petición).
- Adjuntos: mostrar progreso de carga (paquetes de hasta ~100 MB, RNF-007) y el motivo del
  rechazo si el archivo no es válido.

## Formularios (RNF-003: radicar en < 5 min sin capacitación)

- Etiquetas visibles, orden lógico, valores por defecto sensatos (fecha y hora actuales).
- Buscar remitente por cédula y prellenar sus datos en el panel (RF-001).
- Validación en el cliente para guiar; el backend vuelve a validar.
- Errores junto al campo, en lenguaje claro, sin borrar lo escrito.
- Tras radicar, mostrar el consecutivo de forma destacada y copiable.
- Acciones irreversibles (anular, deshabilitar usuario) piden confirmación y motivo.

## Contenido visible

- Español claro e institucional. Términos del dominio tal como los usa la dependencia:
  radicado, consecutivo, dependencia, remitente, trámite, expediente.
- Fechas y horas en formato colombiano, zona `America/Bogota`.

## Validación

```bash
cd frontend_gestion_documental
npm run lint
npm run build
```

Para cambios visuales, revisar escritorio y celular en Chrome y Edge (RNF-005).
