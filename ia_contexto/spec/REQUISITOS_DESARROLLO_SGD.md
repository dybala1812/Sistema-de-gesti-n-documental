# Requisitos de Desarrollo — Sistema de Gestión Documental (SGD)
### Universidad Autónoma — Práctica Profesional

> Documento de arranque de desarrollo. Consolida F-00 (acta de constitución), F-02 (especificación de requisitos), T-01/T-01-B (arquitectura y diagramas), F-03 (arquitectura y diseño) y F-04 (bitácora de desarrollo), en un solo lugar organizado para que el equipo empiece a programar sin tener que saltar entre documentos.
>
> Elaborado por: Juan David Burbano Manquillo · Juan Manuel Arteaga Flores
> Versión 1.0 — 23 de septiembre de 2026

---

## 0. Alcance del sistema

El SGD digitaliza la radicación, trazabilidad y respuesta de comunicaciones (trámites) dentro de la universidad. Tiene tres puertas de entrada:

1. **Portal público** — un estudiante o persona externa radica una solicitud o consulta su estado, sin iniciar sesión.
2. **Panel interno** — Recepción, cada dependencia, Archivo Central y el Administrador gestionan, responden, verifican y clasifican esas solicitudes, con inicio de sesión.
3. **n8n (automatización)** — clasifica automáticamente a qué dependencia debe ir cada solicitud y orquesta las notificaciones por correo en ambos sentidos del flujo.

No hay aplicación móvil nativa: todo es web responsiva.

---

## 1. Requisitos funcionales (RF)

| ID | Requisito | Prioridad | Sprint |
|---|---|---|---|
| RF-001 | Registrar y radicar una comunicación de entrada | Alta | 1 |
| RF-002 | Registrar una comunicación de salida relacionada con un radicado de entrada | Alta | 2 |
| RF-003 | Generar el consecutivo automático del radicado según su tipo | Alta | 1 |
| RF-004 | Adjuntar el documento digital al radicado | Alta | 2 |
| RF-005 | Asignar/enviar el radicado a la dependencia responsable | Alta | 2 |
| RF-006 | Consultar la trazabilidad y el estado de un radicado | Media | 3 |
| RF-007 | Consultar el historial documental de una persona por cédula | Alta | 2 |
| RF-008 | Registrar y editar los datos de una persona con auditoría de cambios | Media | 2 |
| RF-009 | Consultar y filtrar radicados por múltiples criterios | Alta | 3 |
| RF-010 | Gestionar expedientes y clasificación documental en Archivo Central | Media | 3 |
| RF-011 | Anular un documento de forma controlada | Media | 3 |
| RF-012 | Administrar usuarios y permisos por rol | Alta | 1 |
| RF-013 | Autenticarse en el sistema | Alta | 1 |
| RF-014 | Registrar correspondencia sin consecutivo (documentos externos: revistas, facturas, paquetes) | Baja | 2 |
| RF-015 | Generar alertas de vencimiento del plazo de respuesta (semáforo) | Alta | 3 |
| RF-016 | Gestionar el flujo de aprobación por comité | Media | 3 |
| RF-017 | Radicar una solicitud desde el portal público (autoservicio) | Alta | 3 |
| RF-018 | Consultar el estado de mis trámites desde el portal público (sin inicio de sesión) | Media | 3 |
| RF-019 | Configurar los tipos de trámite y sus plazos de respuesta | Media | 2 |

### 1.1 División por sprint (historias de usuario, puntos y responsable)

Las 19 historias de usuario de F-02 (una por cada RF), repartidas en 3 sprints de 2 semanas cada uno, con el puntaje dividido de forma casi equitativa entre los dos integrantes del equipo.

**Sprint 1 — semanas 8-9 · 21 puntos** (Juan David: 11 · Juan Manuel: 10)
Objetivo: dejar autenticación, gestión de usuarios y el consecutivo automático de radicados funcionando, como base para registrar comunicaciones.

| HU | RF | Historia | Puntos | Responsable |
|---|---|---|---|---|
| HU-001 | RF-013 | Iniciar sesión con usuario y contraseña | 3 | Juan David Burbano Manquillo |
| HU-002 | RF-012 | Crear y administrar usuarios con rol | 5 | Juan Manuel Arteaga Flores |
| HU-003 | RF-003 | Generar el consecutivo del radicado automáticamente | 5 | Juan Manuel Arteaga Flores |
| HU-004 | RF-001 | Registrar los datos de una comunicación recibida | 8 | Juan David Burbano Manquillo |

**Sprint 2 — semanas 10-11 · 36 puntos** (Juan David: 18 · Juan Manuel: 18)
Objetivo: completar el ciclo de radicación (adjuntos, envío a dependencia, respuesta), el historial de personas y la configuración de tipos de trámite.

| HU | RF | Historia | Puntos | Responsable |
|---|---|---|---|---|
| HU-005 | RF-004 | Adjuntar el documento escaneado/digital al radicado | 5 | Juan David Burbano Manquillo |
| HU-006 | RF-005 | Enviar el radicado a la dependencia responsable | 5 | Juan Manuel Arteaga Flores |
| HU-007 | RF-002 | Generar respuesta y notificar a Recepción y solicitante | 8 | Juan Manuel Arteaga Flores |
| HU-008 | RF-007 | Buscar una persona por cédula y ver su historial | 8 | Juan David Burbano Manquillo |
| HU-009 | RF-008 | Actualizar celular/correo de una persona | 3 | Juan David Burbano Manquillo |
| HU-014 | RF-014 | Registrar revista/factura/paquete sin radicar | 2 | Juan David Burbano Manquillo |
| HU-019 | RF-019 | Configurar tipos de trámite y sus plazos | 5 | Juan Manuel Arteaga Flores |

**Sprint 3 — semanas 12-13 · 53 puntos** (Juan David: 27 · Juan Manuel: 26)
Objetivo: cerrar trazabilidad, filtros, archivo/expedientes, alertas de vencimiento, comité y los dos flujos del portal público.

| HU | RF | Historia | Puntos | Responsable |
|---|---|---|---|---|
| HU-010 | RF-006 | Consultar en qué estado está un documento | 5 | Juan Manuel Arteaga Flores |
| HU-011 | RF-009 | Filtrar radicados por fecha, tipo, dependencia o remitente | 8 | Juan David Burbano Manquillo |
| HU-012 | RF-011 | Anular un documento con constancia del motivo | 3 | Juan David Burbano Manquillo |
| HU-013 | RF-010 | Clasificar documentos en expedientes por serie documental | 8 | Juan David Burbano Manquillo |
| HU-015 | RF-015 | Recibir alerta cuando un radicado esté por vencer | 8 | Juan Manuel Arteaga Flores |
| HU-016 | RF-016 | Llevar un trabajo de grado por estado de comité | 8 | Juan Manuel Arteaga Flores |
| HU-017 | RF-017 | Radicar mi propia solicitud desde el portal público | 8 | Juan David Burbano Manquillo |
| HU-018 | RF-018 | Consultar el estado de mis trámites sin iniciar sesión | 5 | Juan Manuel Arteaga Flores |

**Total: 110 puntos · 19 historias · 3 sprints.** El detalle completo (fechas, definición de terminado, retrospectiva) vive en F-04 (Bitácora de desarrollo).

## 2. Reglas de negocio (RN)

| ID | Regla | RF relacionados |
|---|---|---|
| RN-001 | Un consecutivo de radicado nunca puede repetirse, incluso si dos usuarios radican al mismo tiempo. | RF-001, RF-002, RF-003 |
| RN-002 | Un documento eliminado no se borra físicamente: cambia su estado a "anulado" y conserva el registro de quién y cuándo lo anuló. | RF-011 |
| RN-003 | Toda modificación a los datos de una persona debe registrar quién y cuándo realizó el cambio. | RF-008 |
| RN-004 | Solo el rol Administrador puede crear, editar o deshabilitar usuarios y asignar roles. | RF-012, RF-013 |
| RN-005 | La responsabilidad de radicar oportunamente una solicitud recae en la dependencia, no en el solicitante, incluso si este entregó su documento a tiempo. | RF-001, RF-015 |
| RN-006 | La correspondencia que no está regida por la Tabla de Retención Documental (revistas, facturas, paquetes, documentos sin firma) no lleva consecutivo ni código TDR; se registra en la línea de documentos externos, dejando solo constancia de su recepción. | RF-014 |
| RN-007 | El plazo de respuesta y la necesidad de pasar por comité dependen del tipo de trámite; el sistema debe permitir configurar ambos por tipo de solicitud. | RF-015, RF-016 |
| RN-008 | La respuesta a una solicitud radicada por el portal público se entrega únicamente por correo electrónico; el portal no requiere ni ofrece inicio de sesión. Recepción debe **verificar** esa respuesta antes de que se notifique al solicitante. | RF-002, RF-017 |
| RN-009 | Una solicitud radicada por el portal público recibe el mismo consecutivo, plazo y flujo de aprobación que si la hubiera registrado Recepción; el canal de entrada no cambia su tratamiento. | RF-003, RF-005, RF-017 |
| RN-010 | Todo documento debe recibir respuesta dentro de un máximo de 15 días hábiles (derecho de petición constitucional), salvo que su tipo de trámite tenga un plazo específico más corto (ej. tutela); el sistema refleja este límite con un semáforo de 4 colores (verde/amarillo/naranja/rojo). | RF-015 |

## 3. Roles del sistema

| Rol | Qué hace | Dónde |
|---|---|---|
| Estudiante / persona externa | Radica solicitudes y consulta su estado | Portal público (sin login) |
| Recepción | Registra correspondencia, notifica dependencias, **verifica** respuestas antes de notificar al solicitante | Panel interno |
| Dependencia | Recibe los radicados asignados, registra su respuesta | Panel interno |
| Archivo Central | Clasifica documentos en expedientes con código TDR | Panel interno |
| Administrador | Gestiona usuarios, roles, tipos de trámite | Panel interno |

---

## 4. Base de datos

**Motor:** Supabase (PostgreSQL 16 administrado en la nube) — no se containeriza junto al resto del backend; la API se conecta mediante la cadena `DATABASE_URL` que Supabase entrega, como variable de entorno.
**ORM:** Prisma — el esquema (`schema.prisma`) es la fuente de verdad de la estructura de tablas y migraciones.
**Nivel de normalización:** Tercera Forma Normal (3FN). Todas las relaciones del modelo son 1—N; ninguna es N:N, así que no se necesitan tablas intermedias.

### 4.1 Catálogo de entidades y atributos

**RADICADOS** (tabla central)
- `id_radicado` int, PK
- `numero_radicado` string, UK — consecutivo público
- `estado` string — recibido, en_revision_requisitos, en_comite, respondido, etc.
- `semaforo` string — verde/amarillo/naranja/rojo
- `fecha_limite` date — calculada según el plazo del tipo de trámite
- FK `tramite_id` → TIPOS_TRAMITE, FK `dependencia_id` → DEPENDENCIAS, FK `persona_id` → PERSONAS

**PERSONAS**
- `id_persona` int, PK
- `cedula` string, UK
- `nombre` string
- `correo` string

**USUARIOS** (cuentas del panel interno)
- `id_usuario` int, PK
- `correo` string, UK
- `password_hash` string — bcrypt
- FK `rol_id` → ROLES, FK `dependencia_id` → DEPENDENCIAS

**RESPUESTAS**
- `id_respuesta` int, PK
- `verificada` boolean
- `fecha_respuesta` date
- FK `radicado_id` → RADICADOS

**DOCUMENTOS_ADJUNTOS**
- `id_documento` int, PK
- `codigo_trd` string (nulo hasta que Archivo Central clasifica)
- FK `radicado_id` → RADICADOS, FK `respuesta_id` → RESPUESTAS (opcional), FK `clasificacion_id` → CLASIFICACIONES_DOCUMENTALES (opcional)

**DEPENDENCIAS**
- `id_dependencia` int, PK
- `nombre` string, `correo` string, `tipo` string (académica/administrativa)

**TIPOS_TRAMITE**
- `id_tipo_tramite` int, PK
- `nombre` string
- `plazo_dias_habiles` int (RF-019)
- `requiere_comite` boolean

**ROLES**
- `id_rol` int, PK
- `nombre` string (recepción, dependencia, archivo central, administrador)
- `descripcion` string (opcional)

**EXPEDIENTES**
- `id_expediente` int, PK
- `codigo` string, UK
- `nombre` string, `estado` string (abierto/cerrado)

**CLASIFICACIONES_DOCUMENTALES**
- `id_clasificacion` int, PK
- `serie` string, `subserie` string (opcional), `codigo_trd` string
- FK `expediente_id` → EXPEDIENTES

**EVENTOS_TRAZABILIDAD**
- `id_evento` int, PK
- `accion` string, `estado_anterior` string (opcional), `estado_nuevo` string, `fecha_evento` date
- FK `radicado_id` → RADICADOS

**ALERTAS_VENCIMIENTO**
- `id_alerta` int, PK
- `nivel` string, `mensaje` string, `atendida` boolean
- FK `radicado_id` → RADICADOS

**WORKFLOW_N8N_EJECUCIONES**
- `id_ejecucion` int, PK
- `workflow_nombre` string, `estado` string (iniciado/finalizado/fallido)
- `fecha_inicio` date, `fecha_fin` date (opcional)
- FK `radicado_id` → RADICADOS

**AUDITORIA_CAMBIOS** (propuesta estándar, pendiente de validar por el equipo — no viene de ningún diagrama entregado)
- `id_auditoria` int, PK
- FK `id_usuario` → USUARIOS
- `tabla_afectada` string, `id_registro_afectado` int, `accion` string (crear/actualizar/eliminar)
- `valores_anteriores` string (JSON, opcional), `valores_nuevos` string (JSON, opcional), `fecha_cambio` date

### 4.2 Relaciones clave

`TIPOS_TRAMITE` clasifica → `RADICADOS` · `DEPENDENCIAS` atiende → `RADICADOS` y agrupa → `USUARIOS` · `PERSONAS` solicita → `RADICADOS` · `ROLES` asigna → `USUARIOS` · `RADICADOS` automatiza → `WORKFLOW_N8N_EJECUCIONES`, genera → `ALERTAS_VENCIMIENTO`, registra → `EVENTOS_TRAZABILIDAD`, recibe → `RESPUESTAS`, contiene → `DOCUMENTOS_ADJUNTOS` · `USUARIOS` ejecuta → `AUDITORIA_CAMBIOS` · `RESPUESTAS` soporta → `DOCUMENTOS_ADJUNTOS` · `DOCUMENTOS_ADJUNTOS` clasifica → `CLASIFICACIONES_DOCUMENTALES` · `EXPEDIENTES` organiza → `CLASIFICACIONES_DOCUMENTALES`.

Todas 1—N. El diagrama entidad-relación completo y el diagrama de clases ya están en F-03 (secs. 2.1 y 5.2).

---

## 5. Backend (API)

**Stack:** Node.js 20 LTS + TypeScript + NestJS.
**Arquitectura en capas:** Presentación (Controllers, solo validan DTOs) → Aplicación (Services/casos de uso) → Dominio (reglas de negocio puras, ej. cálculo del semáforo) → Infraestructura (Repositorios/Prisma, servicios externos).
**Organización:** por dominio, no por tipo técnico — cada módulo agrupa su controlador, servicio y DTOs; nada de carpetas `controllers/`, `services/` sueltas.

### 5.1 Estructura de carpetas

```
apps/api/                  # Backend NestJS
  src/
    modules/
      auth/
      radicados/
      dependencias/
      tramites/
      archivo/
      usuarios/
      notificaciones/
    common/                # filtros de error, decoradores, pipes
    config/
    main.ts
  prisma/
    schema.prisma
    migrations/
  test/

apps/portal-publico/       # React + Vite — sin login
apps/panel-interno/        # React + Vite — con login y roles
packages/shared-types/     # tipos TS compartidos (generados desde OpenAPI)

infra/                     # docker-compose.yml, flujos de n8n (fuera de apps/)
docs/                       # F-00, F-01, F-02, actas, este documento
```

Lógica compartida entre módulos va en `common/`; nunca se importa directo de otro módulo de dominio. `portal-publico` y `panel-interno` son aplicaciones separadas (ADR-003), no rutas de una sola app.

### 5.2 Convenciones de la API

- **Versionado:** prefijo `/api/v1/`
- **Nomenclatura:** sustantivos en plural, minúsculas (`/radicados`, `/tramites`, `/dependencias`, `/usuarios`)
- **Formato:** JSON
- **Paginación** (a implementar — no venía definida): `GET /radicados?page=2&limit=20` → respuesta `{ "data": [...], "pagination": { "page", "limit", "total_registros", "total_paginas" } }`. `limit` por defecto 20, máximo 100.
- **Filtrado:** `GET /radicados` se filtra automáticamente por dependencia según el rol del usuario autenticado
- **Autenticación:** JWT (access + refresh token), solo para el panel interno; rutas del portal público abiertas, con rate limiting
- **Formato de error estándar:**
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "El campo \"correo\" es obligatorio.",
    "details": [{ "field": "correo", "issue": "required" }],
    "path": "/api/v1/radicados",
    "timestamp": "2026-09-17T15:04:00Z"
  }
}
```
`code` es un identificador estable en mayúsculas (`VALIDATION_ERROR`, `NOT_FOUND`, `FORBIDDEN`, `CONFLICT`, `RATE_LIMITED`, `INTERNAL_ERROR`...) que el frontend usa para decidir qué mostrar; `message` es el texto para la persona.

### 5.3 Catálogo de endpoints

| Método | Ruta | Descripción | Auth | Códigos |
|---|---|---|---|---|
| POST | `/api/v1/radicados` | Radicar una nueva solicitud (RF-017) | Público | 201, 400, 422, 429 |
| GET | `/api/v1/radicados/estado` | Consultar estado por cédula o número de radicado (RF-018) | Público | 200, 404, 429 |
| GET | `/api/v1/radicados` | Listar radicados (filtrados por dependencia según rol) | Recepción, dependencia, admin | 200, 401, 403 |
| GET | `/api/v1/radicados/{id}` | Ver detalle de un radicado | Recepción, dependencia, admin | 200, 401, 403, 404 |
| PATCH | `/api/v1/radicados/{id}/respuesta` | Registrar la respuesta a un radicado asignado (RF-013) | Dependencia | 200, 401, 403, 404, 409, 422 |
| PATCH | `/api/v1/radicados/{id}/verificacion` | Verificar una respuesta antes de notificar al solicitante (RN-008) | Recepción | 200, 401, 403, 404, 409 |
| POST | `/api/v1/radicados/{id}/expediente` | Clasificar el radicado con serie/subserie y código TDR (RF-010) | Archivo Central | 201, 401, 403, 404 |
| GET | `/api/v1/tramites` | Catálogo de tipos de trámite disponibles | Público y panel | 200 |
| POST / PATCH | `/api/v1/tramites` · `/api/v1/tramites/{id}` | Crear o ajustar un tipo de trámite y su plazo (RF-019) | Administrador | 201/200, 400, 401, 403 |
| GET | `/api/v1/dependencias` | Catálogo de dependencias y su contacto | Panel interno | 200, 401, 403 |
| GET / POST / PATCH | `/api/v1/usuarios` | Gestión de cuentas internas y sus roles | Administrador | 200/201, 400, 401, 403 |
| POST | `/api/v1/auth/login` · `/refresh` · `/logout` | Inicio y mantenimiento de sesión (nunca aplica al portal público) | Panel interno | 200, 400, 401 |

### 5.4 Ejemplo completo: `POST /api/v1/radicados`

**Request:**
```json
{
  "persona": {
    "cedula": "1075632481",
    "nombre": "Laura Ximena Rojas Peña",
    "correo": "laura.rojas@correo.com"
  },
  "tipo_tramite": "homologacion",
  "descripcion": "Solicito homologación de la asignatura Cálculo Diferencial cursada en la Universidad del Cauca durante el primer semestre de 2025, código MAT-101.",
  "documentos_adjuntos": [
    { "nombre_archivo": "certificado_notas_calculo.pdf", "tipo_mime": "application/pdf", "contenido_base64": "JVBERi0xLjQK..." }
  ]
}
```

**Respuesta exitosa (201 Created):**
```json
{
  "id_radicado": 4821,
  "numero_radicado": "SGD-2026-004821",
  "estado": "recibido",
  "semaforo": "verde",
  "fecha_creacion": "2026-09-18T14:32:07Z",
  "fecha_limite": "2026-10-02T23:59:59Z",
  "tipo_tramite": { "nombre": "homologacion", "plazo_dias_habiles": 10 },
  "dependencia_asignada": null,
  "documentos_adjuntos": [{ "id_documento": 9034, "nombre_archivo": "certificado_notas_calculo.pdf", "estado": "recibido" }],
  "mensaje": "Su solicitud fue radicada correctamente. Use el número de radicado SGD-2026-004821 para consultar el estado."
}
```
`dependencia_asignada` llega en `null` porque la clasificación por dependencia la hace n8n después, mediante un PATCH sobre este mismo recurso (ver sec. 7).

**Error (422 Unprocessable Entity):**
```json
{
  "error": {
    "code": "TIPO_TRAMITE_INVALIDO",
    "message": "El tipo de trámite 'reingresoo' no existe.",
    "details": { "campo": "tipo_tramite", "valores_permitidos": ["reingreso", "homologacion", "certificados", "tutela", "reintegro_dinero", "trabajo_grado"] },
    "path": "/api/v1/radicados",
    "timestamp": "2026-09-18T14:32:07Z"
  }
}
```

### 5.5 Documentación interactiva

Swagger/OpenAPI generado automáticamente desde el código (NestJS). La URL pública se define al desplegar; debe entregarse junto con el sistema, no como anexo opcional.

### 5.6 Seguridad

- **Autenticación:** JWT (access + refresh), solo panel interno.
- **Autorización:** por rol (recepción, dependencia, archivo central, administrador); `GET /radicados` filtra por rol.
- **Contraseñas:** bcrypt.
- **Transporte:** HTTPS/TLS obligatorio en producción — reverse proxy (Nginx o Caddy) con certificado Let's Encrypt delante de la API; la conexión a Supabase ya exige TLS (`sslmode=require`); las llamadas de n8n a la API también deben ir por HTTPS, no HTTP plano.
- **Validación de entradas:** DTOs en la capa de Presentación.
- **Datos personales (Ley 1581 de 2012 — Habeas Data, Colombia):**
  - La universidad es responsable del tratamiento; el SGD es el encargado técnico.
  - Solo se recolecta cédula, nombre y correo del solicitante — nada más sin justificación explícita.
  - Aviso de privacidad con casilla de aceptación **obligatoria** antes de radicar (agregar como campo requerido en `POST /radicados`).
  - Acceso a PERSONAS restringido por rol/dependencia.
  - Los radicados no se eliminan nunca (retención documental, TDR) — el titular puede pedir corrección de sus datos, no borrado.
  - n8n, el servidor SMTP, Supabase y el clasificador de IA son "encargados del tratamiento" y deben mencionarse en el aviso de privacidad.
  - Procedimiento simple de notificación de incidentes de seguridad ante el responsable del proyecto.

---

## 6. Frontend

Dos aplicaciones React 18 + TypeScript + Vite + Tailwind CSS, **completamente separadas** (ADR-003): el portal público nunca maneja credenciales.

### 6.1 Portal Público (sin autenticación)

**Flujo 1 — Radicación (RF-017):**
`Inicio del portal` → `Formulario de radicación` (nombre, cédula, correo, tipo de trámite, descripción) → `Aviso de privacidad` (checkbox obligatorio) → `Adjuntar soportes` (opcional) → `Confirmación` (muestra `numero_radicado`) — dispara `POST /api/v1/radicados`.

**Flujo 2 — Consulta de estado (RF-018):**
`Inicio del portal` → `Formulario de consulta` (número de radicado + cédula) → `Resultado` (estado, semáforo, fecha límite) — dispara `GET /api/v1/radicados/estado`.

### 6.2 Panel Interno (JWT + roles)

**Flujo 3 — Respuesta y verificación (RF-013, RN-008):**
`Login` → `Bandeja de radicados` (filtrada por dependencia/rol) → `Detalle del radicado` → Dependencia registra su respuesta (`PATCH /radicados/{id}/respuesta`) → pasa a la bandeja de verificación de Recepción → **Recepción verifica**:
- Si es verificada → se notifica al solicitante por correo (estado = respondido, vía n8n Flujo 2).
- Si no es verificada → vuelve a la dependencia con estado `requiere_correccion` para ajustar la respuesta.

Además: `Gestión de expedientes` (Archivo Central, RF-010), `Administración de usuarios y roles` (RF-012), `Configuración de tipos de trámite` (RF-019), `Consulta de trazabilidad` (RF-006), `Alertas de vencimiento` (RF-015).

---

## 7. Automatización (n8n)

n8n **nunca** accede a PostgreSQL/Supabase directamente: siempre llama a la API por HTTP (webhook que la API dispara, y PATCH que n8n devuelve con el resultado). Son **dos flujos separados**.

### 7.1 Flujo 1 — Selección, filtrado y envío

`Webhook (nueva solicitud)` → `Filter` (verifica que los datos estén completos) → `Normalizar datos` → `Notificar a Recepción` (correo) → `AI Text Classifier` (categorías = **las dependencias**, no los tipos de trámite — cada dependencia agrupa varios tipos: ej. Ingeniería ve reingreso/homologación/certificados, Rectoría ve tutelas/paquetes) + modelo Anthropic → ramifica a 6 nodos "Dependencia X" (cada uno con nombre, correo y los campos del radicado) → `Guardar en base de datos` (vía la API, no directo a la BD) → `Enviar a Dependencia` (correo, indicando que debe entrar al panel interno a responder). Rama paralela: "Estado de la solicitud" → `Buscar radicado` → `Responder consulta de estado`. Categorías "Spam / no aplica" y "Falta información" quedan sin conectar (revisión manual).

### 7.2 Flujo 2 — Respuesta de la dependencia al solicitante

`Webhook (respuesta registrada)` → `Normalizar respuesta` → `Buscar radicado en base de datos` (por número de radicado, vía API) → `Verificar respuesta` (If, campo `verificado`):
- **Verdadero:** `Notificar a Recepción (verificada)` → `Notificar al estudiante` (correo final).
- **Falso:** `Notificar a Recepción (sin verificar)` — pide revisión manual.

---

## 8. Despliegue

Docker + Docker Compose: un único `docker-compose.yml` (en `infra/`) levanta API Backend (NestJS), n8n y almacenamiento de objetos (MinIO). **La base de datos NO se containeriza** — es Supabase, administrada en la nube; la API se conecta con `DATABASE_URL` como variable de entorno por ambiente (desarrollo, pruebas, producción). Los frontends se construyen como artefactos estáticos, servidos aparte del backend.

---

## 9. Decisiones de arquitectura (ADR) — resumen

| ADR | Decisión |
|---|---|
| ADR-001 | Backend en Node.js + TypeScript + NestJS |
| ADR-002 | Supabase (PostgreSQL administrado) + Prisma como ORM |
| ADR-003 | Portal público y panel interno como aplicaciones frontend separadas |
| ADR-004 | JWT solo para el panel interno; portal público sin autenticación |
| ADR-005 | n8n integra con el backend por HTTP (webhook + PATCH), nunca accede a la base de datos directamente |
| ADR-006 | Los radicados nunca se eliminan (soft state vía campo `estado`, por retención documental TDR) |
| ADR-007 (propuesta) | Nginx/Caddy + Let's Encrypt para forzar HTTPS/TLS en producción |

---

## 10. Pendientes para el equipo antes de programar

- Validar y ajustar los campos propuestos de `AUDITORIA_CAMBIOS` (no vienen de ningún diagrama entregado).
- Confirmar nombres definitivos de columnas FK en `schema.prisma` (aquí se proponen con la convención `<entidad>_id`).
- Wireframes/mockups de las pantallas descritas en la sec. 6 (aún no existen).
- Publicar la URL real de Swagger una vez desplegado.
- Revisar límites del plan gratuito de Supabase (almacenamiento y conexiones simultáneas) antes de producción.
- Los flujos de n8n de prueba actuales escriben directo en la base de datos; deben migrarse a llamar la API (ADR-005) antes de integrarse al backend real.
