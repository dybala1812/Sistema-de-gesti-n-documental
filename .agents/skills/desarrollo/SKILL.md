---
name: desarrollo
description: Stack, convenciones de código, estructura de carpetas y criterio de commits del Sistema de Gestión Documental (Universidad Autónoma). Úsala antes de escribir o revisar código en este repo.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
---

# Desarrollo — Sistema de Gestión Documental

Aplicación web para la dependencia de Gestión Documental de la Universidad Autónoma.
Reemplaza el registro en Excel, carpetas físicas y búsqueda manual de la correspondencia
institucional: radicación, envío a dependencias, seguimiento, respuesta, consulta por
cédula y apoyo a Archivo Central (Ley 594 de 2000, Decreto 1080 de 2015).

Proyecto de práctica profesional: **dos desarrolladores, 16 semanas, 3 sprints**. Cualquier
decisión que agregue infraestructura o dependencias debe justificarse contra ese límite.

Antes de escribir código, lee la spec en `ia_contexto/spec/`. La fuente original es el
documento **F-02 Especificación de requisitos v1.0** (25-ago-2026); `ia_contexto/spec/` es
su versión operativa. Las decisiones de `ia_contexto/spec/decisiones.md` son vinculantes;
no las reabras sin hablar con el usuario.

## Stack

| Capa | Tecnología | Estado |
|---|---|---|
| Frontend | Next.js 16.3 (App Router) + React 19.2 | instalado |
| Lenguaje frontend | TypeScript 5 (`strict: true`) | instalado |
| Estilos | Tailwind CSS 4 (`@tailwindcss/postcss`) | instalado |
| Linter frontend | ESLint 9 + `eslint-config-next` | instalado |
| UI frontend | lucide-react, sileo, gsap, Radix (dialog/popover), cva, jspdf | instalado (ver `frontend/instructions.md`) |
| Backend | Node + Express 5 (CommonJS) | instalado, sin código |
| Recarga backend | nodemon | instalado, sin script |
| Base de datos | relacional (PostgreSQL recomendado) | **por decidir** (ver `decisiones.md`) |
| Almacenamiento de adjuntos | disco del servidor u objeto en la nube | **por decidir** |
| Correo | SMTP o API de correo | **por decidir** |
| Pruebas | — | **por definir** (ver skill `testing`) |

```
app gestion documental/            ← raíz del repo git
├── frontend_gestion_documental/   ← Next.js (portal público + panel interno)
├── backend_gestion_documental/    ← Express (API REST, reglas de negocio, BD, archivos)
├── ia_contexto/                   ← spec, tablero de tareas e historial
└── .agents/skills/                ← estas guías
```

```bash
# frontend
cd frontend_gestion_documental
npm install
npm run dev      # http://localhost:3000
npm run lint
npm run build    # incluye verificación de tipos: un error de tipos rompe el build
```

El backend aún no tiene `main`, script `dev` ni `start`. Crearlos es parte de la primera
tarea de backend; no inventes comandos que no existan en `package.json`.

### Next.js 16 no es el que conoces

Lee `frontend_gestion_documental/AGENTS.md` y la guía correspondiente en
`frontend_gestion_documental/node_modules/next/dist/docs/` antes de usar cualquier API de
Next. Diferencias que ya afectan a este proyecto:

- `middleware.ts` ahora se llama **`proxy.ts`** (`01-app/01-getting-started/16-proxy.md`).
  Sirve para redirecciones optimistas por sesión, **no** como autorización.
- Autenticación: `01-app/02-guides/authentication.md`.
- Seguridad de datos en Server Components / Actions: `01-app/02-guides/data-security.md`.
- Formularios y Server Actions: `01-app/02-guides/forms.md`.

## Forma del sistema

Cliente web (Next) + API (Express) + base de datos relacional + almacén de archivos +
servicio de correo + tarea periódica de alertas.

Dos experiencias en el frontend, ambas responsivas (escritorio y navegador del celular):

| Experiencia | Usuarios | Sesión |
|---|---|---|
| **Portal público** (`app/(publico)/…`) | Estudiante / solicitante externo | **Sin sesión, sin cuenta** (RN-008) |
| **Panel interno** (`app/(panel)/…`) | Administrador, Recepción/Ventanilla, Dependencia destinataria, Archivo Central | Con sesión; menú según rol |

### Módulos del backend (RNF-004: un módulo por dominio)

```
backend_gestion_documental/src/
  modulos/
    autenticacion/     RF-013
    usuarios/          RF-012
    radicacion/        RF-001, RF-002, RF-004, RF-005, RF-011, RF-014
    consecutivos/      RF-003   ← servicio crítico, cobertura ≥ 60 %
    trazabilidad/      RF-006
    personas/          RF-007, RF-008
    consultas/         RF-009
    tramites/          tipos de trámite, plazos, comité (RF-015, RF-016, RN-007)
    alertas/           RF-015
    archivo-central/   RF-010
    portal-publico/    RF-017
  compartido/          errores, validación, permisos, auditoría, correo, archivos
```

Cada módulo expone rutas → servicio (reglas de negocio) → repositorio (SQL). Un módulo
no lee las tablas de otro directamente: llama a su servicio.

### Reglas de la frontera

1. **Las reglas de negocio viven en el backend**, en la capa de servicio. El frontend
   valida para ergonomía; el backend vuelve a validar todo.
2. **La autorización se comprueba en el backend en cada endpoint.** Ocultar un botón o
   redirigir en `proxy.ts` es ergonomía, no un permiso (RNF-002).
3. **El portal público usa endpoints propios** (`/api/publico/...`) que solo pueden crear
   una solicitud y consultar catálogos. Nunca reutiliza endpoints del panel.
4. **Los contratos de la API** se documentan en `ia_contexto/spec/api.md` y se tipan en el
   frontend; nunca objetos sueltos.
5. El navegador no habla con la base de datos ni con el almacén de archivos: todo pasa por
   la API.

## Dominio: vocabulario cerrado

Estos valores son uniones de literales / enums en la BD, nunca cadenas libres:

- **Tipo de documento con consecutivo** (RF-003): `recibida`, `enviada`, `circular`,
  `resolucion`, `convenio`.
- **Estado del radicado** (RF-001, 002, 005, 006, 011, 016): `recibido`, `enviado`,
  `recibido_dependencia`, `en_revision_requisitos`, `en_comite`,
  `rechazado_requisitos`, `respondido`, `anulado`.
- **Rol**: `administrador`, `recepcion`, `dependencia`, `archivo_central`.
- **Canal de entrada**: `ventanilla`, `correo`, `plataforma_web`, `comunicacion_interna`,
  `portal_publico`. El canal **no** cambia el tratamiento del radicado (RN-009).
- **Tipo de trámite** (reingreso, reintegro, homologación, trabajo de grado, tutela, …):
  **tabla configurable**, no enum, porque plazo y comité se parametrizan (RN-007).

Las transiciones de estado se validan en el servicio con una tabla de transiciones
permitidas; una transición no permitida es un error 409, no un `UPDATE` silencioso.

## Reglas de negocio que el código debe hacer imposibles de romper

| Regla | Cómo se garantiza |
|---|---|
| RN-001 consecutivo único aun con concurrencia | Contador por `(tipo, anio)` incrementado **dentro de una transacción** con bloqueo de fila (`UPDATE … RETURNING` o `SELECT … FOR UPDATE`) + `UNIQUE (tipo, anio, numero)`. Nunca `MAX(numero)+1` |
| RF-003 reinicio anual | El año forma parte de la clave del contador; no hay tarea que "reinicie" nada |
| RN-002 nada se borra | Sin `DELETE` sobre radicados, personas, usuarios ni adjuntos. Se anula o deshabilita |
| RN-003 auditoría de personas | Cada cambio escribe en la tabla de auditoría en la **misma transacción** (quién, cuándo, campo, valor anterior, valor nuevo) |
| RN-004 solo Admin gestiona usuarios | Chequeo de rol en el endpoint, no en la UI |
| RN-006 correspondencia sin consecutivo | Registro distinto que no toca el contador |
| RN-008 respuesta del portal solo por correo | El portal no tiene vista de seguimiento ni login |
| RN-009 mismo tratamiento por canal | El portal llama al **mismo servicio** de radicación que Recepción |
| RF-006 trazabilidad | Cada cambio de estado, envío o reasignación inserta un evento (fecha, hora, usuario, acción) en la misma transacción |
| RF-015 plazos | La fecha límite se calcula desde la fecha de radicación y el plazo del tipo de trámite, en una función pura y probada |

## Convenciones

- Español para el dominio (`radicado`, `consecutivo`, `dependencia`, `expediente`,
  `persona`), inglés solo donde lo impone la librería. Sin tildes ni eñes en
  identificadores (`anio`, `numero`, `resolucion`).
- BD en `snake_case`; TypeScript/JS en `camelCase`; componentes React en `PascalCase`.
  La conversión ocurre en la capa de repositorio, en un solo sitio.
- Nada de `any`. Lo desconocido se modela con `unknown` y se estrecha.
- Cédula/NIT se guardan como **texto** (ceros a la izquierda, guiones).
- La BD guarda marcas de tiempo con zona; la UI muestra hora de Colombia (`America/Bogota`).
- Sin comentarios que repitan el código. Un comentario explica **por qué**.
- Listados paginados y filtrados en SQL con índices (RNF-001: < 3 s con 500 radicados).
  Nunca traer la tabla y filtrar en memoria.
- Adjuntos grandes (RNF-007: ≥ 100 MB en < 30 s) se reciben en *streaming* al almacén; no
  se cargan enteros en memoria ni viajan como base64 en JSON.

## Errores que no se pueden repetir

| No hagas | Por qué |
|---|---|
| Calcular el consecutivo en el frontend o con `MAX()+1` | Duplica bajo concurrencia (RN-001, RNF-006) |
| Guardar un estado que se puede calcular | "Vencido" / "próximo a vencer" se **calculan** desde la fecha límite |
| Escribir en dos tablas sin transacción | Radicado sin evento de trazabilidad, persona sin auditoría |
| Borrar filas | Todo se anula o deshabilita (RN-002, RF-012) |
| Confiar en que la UI ya validó | El portal público es accesible por cualquiera |
| Usar el nombre original del archivo para construir la ruta | Path traversal (ver skill `seguridad`) |

## Commits

- Un commit por cambio con sentido propio. Si el mensaje necesita un "y", son dos.
- Mensaje en español, imperativo, con el porqué si no es obvio:
  `Generar el consecutivo dentro de una transacción con bloqueo de fila`.
- Si cierra una tarea del tablero, cítala: `(GD-012)`. Si implementa un requisito, cita el
  RF: `RF-003`.
- No commitear sin haber corrido lint y build del paquete tocado.
- Cambio de spec y cambio de código van juntos. Si solo puedes hacer uno, deja el otro como
  tarea explícita en `ia_contexto/tareas-faltantes.md`.

## Qué no tocar

- El PDF F-02 y cualquier acta firmada por el cliente son **evidencia**: se leen, no se
  corrigen. Un cambio de requisito pasa por el control de cambios (numeral 10 del F-02) y
  requiere nueva aprobación del cliente.
- Fuera de alcance (no construir aunque parezca útil): gestión de PQRS, migración o
  digitalización masiva del archivo histórico, integración con el sistema académico (hasta
  que se confirme), firma electrónica certificada, soporte posterior a la entrega.
