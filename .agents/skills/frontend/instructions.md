# Instrucciones de Frontend

## Stack

- Next.js 16.3 con App Router, React 19.2, TypeScript estricto.
- Tailwind CSS 4: tokens en `app/globals.css` con `@theme` (no hay `tailwind.config.js`).
- Alias de imports `@/*` → raíz de `frontend_gestion_documental/`.
- **Antes de usar cualquier API de Next, leer la guía en `node_modules/next/dist/docs/`.**
  En Next 16, `middleware.ts` pasó a llamarse `proxy.ts`; `params` y `searchParams` son
  promesas (`await params`) y existen los tipos globales `PageProps<"/ruta">` y `LayoutProps`.

## Librerías de interfaz (usar estas, no agregar equivalentes)

| Para | Librería | Dónde se envuelve |
|---|---|---|
| Iconos | `lucide-react` (los mismos de la maquetación) | directo |
| Botones y variantes | `class-variance-authority` + `clsx` + `tailwind-merge` | `components/ui/boton.tsx`, `lib/utils.ts` (`cn`) |
| Alertas emergentes (toasts) | `sileo` — arriba al centro, relleno dorado `#f4b400`, texto `sobre-acento` | `components/ui/notificaciones.tsx` → usar siempre `notificar.*` |
| Animaciones | `gsap` | `components/ui/aparecer.tsx` (entrada con `data-aparecer`), `contador.tsx`, `sello-exito.tsx` |
| Diálogos y popovers accesibles | `@radix-ui/react-dialog`, `@radix-ui/react-popover` | `components/ui/dialogo.tsx`, panel de alertas |
| Comprobante PDF | `jspdf` (import dinámico) | `components/publico/comprobante-pdf.tsx` |

Toda animación respeta `prefers-reduced-motion`. Con GSAP: limpiar en el efecto
(`ctx.revert()` / `tween.kill()`) y no usarlo para ocultar contenido que deba verse sin JS.

`react-router-dom`, `@tailwindcss/vite`, `konva`/`react-konva` y `html2canvas` están en
`package.json` pero no se usan: Next ya enruta y Tailwind 4 va por PostCSS. Decidir si se
quitan.

## Estructura de rutas (implementada)

```
app/
  (publico)/                         portal público, sin sesión
    page.tsx                         inicio
    radicar/page.tsx                 nueva solicitud (RF-017)
    radicar/confirmacion/page.tsx    comprobante + PDF
    mis-tramites/page.tsx            consulta con número + cédula (RF-018)
  login/page.tsx                     RF-013
  panel/                             panel interno, menú según rol (lib/navegacion.ts)
    radicados/ · radicados/nuevo · radicados/[id] · [id]/responder · [id]/comite
    sin-consecutivo · verificacion · alertas · personas · asignados
    archivo/(por-clasificar|clasificar|expedientes|digitalizar)
    admin/(usuarios|tramites|auditoria)
components/ui/                       piezas reutilizables (botón, campos, tabla, diálogo…)
components/panel/ · components/publico/
lib/                                 tipos, datos de demostración, navegación, utilidades
```

El portal no importa nada de `components/panel/`.

**Estado actual: maquetación funcional con datos de demostración** (`lib/datos-demo.ts`) y
una sesión simulada en `sessionStorage` (`components/panel/sesion-demo.ts`) con cuatro
cuentas de prueba (`recepcion@`, `dependencia@`, `archivo@`, `admin@uniautonoma.edu.co`,
contraseña `Demo2026*`). El login lleva a `/panel`, que muestra las secciones del rol; el
panel sin sesión redirige a `/login` y una sección ajena al rol muestra un aviso. Nada de
esto es seguridad real: se reemplaza por `POST /api/v1/auth/login` y cookie `HttpOnly` (RF-013).
No se implementó lo propio del prototipo (pestañas para cambiar de rol y panel de "Notas
del documento").

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
