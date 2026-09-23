# Historias de usuario — Juan Manuel Arteaga Flores

Fuente: `REQUISITOS_DESARROLLO_SGD.md` v1.0 (23-sep-2026), §1.1, más F-02 v1.0.
Formato: RF FOR IA (`.agents/skills/project-manager/references/rf-for-ia.md`): reglas,
criterios Dado/Cuando/Entonces, contrato técnico y pruebas por historia.

| Sprint | Semanas | HU | Puntos |
|---|---|---|---|
| 1 | 8–9 | HU-002, HU-003 | 10 |
| 2 | 10–11 | HU-006, HU-007, HU-019 | 18 |
| 3 | 12–13 | HU-010, HU-015, HU-016, HU-018 | 26 |
| **Total** | | **9 historias** | **54** |

Convenciones del documento base: API con prefijo `/api/v1/`, error estándar
`{ error: { code, message, details, path, timestamp } }`, JWT solo en el panel interno.
Los contratos marcados **(propuesto)** no están en el catálogo de endpoints de
`REQUISITOS_DESARROLLO_SGD.md` §5.3 y deben agregarse allí al aprobarse.

---

# Sprint 1 — semanas 8–9 · 10 puntos

Objetivo del sprint: autenticación, usuarios y consecutivo automático como base de la
radicación.

## HU-002 · Crear y administrar usuarios con rol

- **RF:** RF-012 · **Prioridad:** Alta · **Puntos:** 5
- **Historia:** Como administrador, quiero crear y administrar usuarios asignándoles un rol,
  para controlar quién puede hacer qué dentro del sistema.
- **Depende de:** HU-001 (inicio de sesión, Juan David): el endpoint necesita un usuario
  autenticado con rol.

### Reglas

- RN-004: solo el rol Administrador crea, edita o deshabilita usuarios y asigna roles.
- Un usuario tiene exactamente un rol (`recepcion`, `dependencia`, `archivo_central`,
  `administrador`) y, si es de dependencia, exactamente una dependencia.
- Deshabilitar no elimina (ADR-006): se conserva la trazabilidad de sus acciones.
- Un usuario deshabilitado no puede iniciar sesión ni usar un token vigente.
- El correo es único (`USUARIOS.correo` UK).
- La contraseña se guarda solo como hash bcrypt; nunca se devuelve en ninguna respuesta.
- Cada creación o cambio queda en `AUDITORIA_CAMBIOS`.

### Criterios de aceptación

```
Escenario: Crear usuario de dependencia
Dado un administrador autenticado
Cuando crea un usuario con correo nuevo, rol "dependencia" y la dependencia "Ingeniería"
Entonces el usuario queda activo con ese rol y dependencia
Y la respuesta no incluye la contraseña ni su hash
Y queda un registro en AUDITORIA_CAMBIOS con el administrador como autor

Escenario: Correo duplicado
Dado que ya existe un usuario con el correo "recepcion@uni.edu.co"
Cuando el administrador intenta crear otro con el mismo correo
Entonces responde 409 CONFLICT y no se crea nada

Escenario: Rol sin permiso
Dado un usuario autenticado con rol "recepcion"
Cuando intenta crear, editar o listar usuarios
Entonces responde 403 FORBIDDEN

Escenario: Deshabilitar usuario
Dado un usuario activo con sesión abierta
Cuando el administrador lo deshabilita
Entonces su siguiente petición responde 401
Y sus radicados y eventos anteriores siguen mostrando su nombre

Escenario: Usuario de dependencia sin dependencia
Cuando el administrador crea un usuario con rol "dependencia" sin dependencia
Entonces responde 400 VALIDATION_ERROR indicando el campo "dependencia_id"
```

### Contrato técnico

```
POST /api/v1/usuarios                     Auth: administrador
Request:
{
  "nombre": "María Pérez",
  "correo": "maria.perez@uni.edu.co",
  "password": "********",
  "rol": "dependencia",
  "dependencia_id": 3
}
Response 201:
{
  "id_usuario": 12,
  "nombre": "María Pérez",
  "correo": "maria.perez@uni.edu.co",
  "rol": "dependencia",
  "dependencia": { "id_dependencia": 3, "nombre": "Ingeniería" },
  "activo": true
}
Errores: 400 VALIDATION_ERROR · 401 · 403 FORBIDDEN · 409 CONFLICT

GET   /api/v1/usuarios?page=1&limit=20&rol=&activo=   Auth: administrador → 200 paginado
PATCH /api/v1/usuarios/{id}                           Auth: administrador
      { "rol"?, "dependencia_id"?, "activo"? }        → 200 · 400 · 403 · 404
```

Nota de modelo: el catálogo de `USUARIOS` en §4.1 no incluye `nombre` ni `activo`; hacen
falta para esta historia y para "deshabilitar sin eliminar". Agregar en `schema.prisma`.

### Pruebas

| ID | Tipo | Verifica |
|---|---|---|
| T-HU002-01 | integración | Crear usuario válido → 201, sin `password`/`password_hash` en la respuesta |
| T-HU002-02 | integración | Correo duplicado → 409 y conteo de usuarios sin cambio |
| T-HU002-03 | integración | Matriz: `recepcion`, `dependencia`, `archivo_central` → 403 en los tres endpoints |
| T-HU002-04 | integración | Deshabilitar → token previo rechazado con 401 |
| T-HU002-05 | BD | `password_hash` empieza por `$2` (bcrypt), nunca texto plano (RNF-002) |
| T-HU002-06 | integración | Cada operación escribe en `AUDITORIA_CAMBIOS` |

### Frontend (panel interno)

Pantalla "Usuarios" solo visible para administrador: tabla paginada con filtros por rol y
estado, formulario de alta/edición, acción "Deshabilitar" con confirmación.

---

## HU-003 · Generar el consecutivo del radicado automáticamente

- **RF:** RF-003 · **Prioridad:** Alta · **Puntos:** 5
- **Historia:** Como funcionario de Recepción, quiero que el sistema genere el consecutivo
  del radicado automáticamente, para no revisarlo manualmente en Excel ni arriesgarme a
  duplicarlo.
- **La usa:** HU-004 (Juan David), HU-007, HU-017.

### Reglas

- RN-001: un consecutivo nunca se repite, aunque dos usuarios radiquen a la vez.
- F-02 RF-003: un contador por tipo de documento (recibida, enviada, circular, resolución,
  convenio) y por año; el 1 de enero reinicia en 1; los de años anteriores no se reutilizan.
- RN-009: el portal público usa el mismo generador que Recepción.
- El consecutivo se asigna **dentro de la misma transacción** que crea el radicado: si la
  creación falla, no queda un radicado a medias.
- RNF-004: cobertura unitaria ≥ 60 % en este servicio.

### Criterios de aceptación

```
Escenario: Siguiente consecutivo
Dado que el último radicado de tipo "recibida" en 2026 es el 41
Cuando se radica una nueva comunicación recibida
Entonces recibe el número 42 del año 2026

Escenario: Concurrencia
Dado el contador de "recibida" 2026 en 41
Cuando se radican 20 comunicaciones recibidas al mismo tiempo
Entonces se asignan los números 42 a 61, sin repetidos ni huecos

Escenario: Contadores independientes por tipo
Dado "recibida" 2026 en 41 y "enviada" 2026 en 7
Cuando se radica una comunicación enviada
Entonces recibe el 8 y "recibida" sigue en 41

Escenario: Cambio de año
Dado que el último "recibida" de 2026 es el 3500
Cuando se radica el primero de 2027
Entonces recibe el número 1 de 2027
Y el 3500 de 2026 no se modifica

Escenario: Falla a mitad de la creación
Dado el contador en 41
Cuando la creación del radicado falla después de pedir el número
Entonces no existe ningún radicado nuevo
```

### Contrato técnico

Servicio interno de dominio (no expone endpoint propio). Lo invocan los casos de uso de
radicación.

```
siguienteConsecutivo(tx, tipo: TipoDocumento, anio: number) → { numero: number, visible: string }

Implementación (PostgreSQL / Prisma, dentro de $transaction):
  INSERT INTO contadores_radicado (tipo, anio, ultimo) VALUES ($1, $2, 1)
  ON CONFLICT (tipo, anio) DO UPDATE SET ultimo = contadores_radicado.ultimo + 1
  RETURNING ultimo;

Restricción: UNIQUE (tipo, anio, numero) en RADICADOS.
Prohibido: SELECT MAX(numero)+1.
```

Nota de modelo: el catálogo §4.1 no tiene tabla de contadores ni columna de tipo de
documento en `RADICADOS`. Hacen falta `CONTADORES_RADICADO (tipo, anio, ultimo)` y
`RADICADOS.tipo_documento`, `RADICADOS.anio`, `RADICADOS.numero`.

**Pendiente de decidir (ver "Inconsistencias"):** formato visible. El ejemplo de §5.4 usa
`SGD-2026-004821` (sin tipo), pero el F-02 pide un contador por tipo, lo que obliga a
distinguir el tipo en el número visible, por ejemplo `REC-2026-000042`.

### Pruebas

| ID | Tipo | Verifica |
|---|---|---|
| T-HU003-01 | unitaria | Formato visible del número según tipo y año |
| T-HU003-02 | integración (BD real) | 20 transacciones concurrentes → 20 números distintos y contiguos (RNF-006) |
| T-HU003-03 | integración | Tipos distintos no comparten contador |
| T-HU003-04 | integración | Año nuevo reinicia en 1 |
| T-HU003-05 | integración | Rollback: la falla posterior no deja radicado |
| T-HU003-06 | cobertura | ≥ 60 % en el módulo (RNF-004) |

La prueba de concurrencia se hace contra PostgreSQL real (Supabase de pruebas o local), no
con mocks.

---

# Sprint 2 — semanas 10–11 · 18 puntos

Objetivo del sprint: ciclo de radicación completo (envío a dependencia, respuesta) y
configuración de tipos de trámite.

Orden sugerido: **HU-019 → HU-006 → HU-007**, porque el envío y la respuesta necesitan
los tipos de trámite y sus plazos.

## HU-019 · Configurar tipos de trámite y sus plazos

- **RF:** RF-019 · **Prioridad:** Media · **Puntos:** 5
- **Historia:** Como administrador, quiero configurar los tipos de trámite, su plazo de
  respuesta y si requieren comité, para que las fechas límite y las alertas reflejen las
  reglas reales de cada trámite.
- **La usan:** HU-015 (alertas), HU-016 (comité), HU-017 y HU-018 (portal).

### Reglas

- RN-007: plazo y necesidad de comité se configuran por tipo de trámite.
- RN-010: ningún plazo supera 15 días hábiles (derecho de petición); puede ser menor (tutela).
- El nombre es único y estable (se usa como clave en el portal: `homologacion`,
  `reingreso`, `tutela`, …).
- Un tipo usado por radicados no se elimina: se desactiva y deja de aparecer en el portal.
- Cambiar un plazo **no recalcula** la fecha límite de radicados ya creados; aplica a los
  nuevos. (Propuesta: confirmar con el cliente.)

### Criterios de aceptación

```
Escenario: Crear tipo de trámite
Dado un administrador autenticado
Cuando crea "reingreso" con plazo 8 días hábiles y sin comité
Entonces el tipo aparece en GET /api/v1/tramites para el portal y el panel

Escenario: Plazo fuera del límite legal
Cuando intenta guardar un plazo de 20 días hábiles
Entonces responde 400 VALIDATION_ERROR indicando que el máximo es 15 (RN-010)

Escenario: Plazo inválido
Cuando intenta guardar un plazo de 0 o negativo
Entonces responde 400 VALIDATION_ERROR

Escenario: Nombre duplicado
Dado que existe "tutela"
Cuando crea otro con el nombre "tutela"
Entonces responde 409 CONFLICT

Escenario: Cambio de plazo no afecta radicados existentes
Dado un radicado de "homologacion" con fecha límite ya calculada
Cuando el administrador cambia el plazo de "homologacion"
Entonces la fecha límite de ese radicado no cambia
Y los radicados nuevos usan el plazo nuevo

Escenario: Rol sin permiso
Dado un usuario "recepcion"
Cuando intenta crear o editar un tipo de trámite
Entonces responde 403
```

### Contrato técnico

```
GET /api/v1/tramites                      Auth: pública y panel
Response 200:
[
  { "id_tipo_tramite": 1, "nombre": "homologacion", "plazo_dias_habiles": 15, "requiere_comite": false, "activo": true }
]
(El portal solo recibe los activos.)

POST /api/v1/tramites                     Auth: administrador
{ "nombre": "reingreso", "plazo_dias_habiles": 8, "requiere_comite": false }
→ 201 · 400 · 401 · 403 · 409

PATCH /api/v1/tramites/{id}               Auth: administrador
{ "plazo_dias_habiles"?, "requiere_comite"?, "activo"? }
→ 200 · 400 · 401 · 403 · 404
```

Nota de modelo: `TIPOS_TRAMITE` necesita `activo` (boolean) y `nombre` único.

### Pruebas

| ID | Tipo | Verifica |
|---|---|---|
| T-HU019-01 | unitaria | Validación del plazo: 1–15 válido; 0, negativo, 16+ inválido |
| T-HU019-02 | integración | Crear, listar, editar; duplicado → 409 |
| T-HU019-03 | integración | Radicado existente conserva su fecha límite tras cambiar el plazo |
| T-HU019-04 | integración | Tipo inactivo no aparece para el portal |
| T-HU019-05 | integración | Roles no administradores → 403 en POST/PATCH |

### Frontend (panel interno)

"Configuración → Tipos de trámite": tabla con nombre, plazo, comité y estado; edición en
línea o en modal; aviso de que el cambio de plazo aplica a radicados nuevos.

---

## HU-006 · Enviar el radicado a la dependencia responsable

- **RF:** RF-005 · **Prioridad:** Alta · **Puntos:** 5
- **Historia:** Como funcionario de Recepción, quiero enviar el radicado a la dependencia
  responsable, para que el trámite continúe sin entregarlo físicamente.
- **Depende de:** HU-004 (radicado registrado), HU-019.

### Reglas

- La asignación puede venir de **n8n** (clasificador de IA, §7.1) o de **Recepción**
  manualmente. En ambos casos pasa por la API (ADR-005).
- Se registra quién asignó (usuario o `n8n`), a qué dependencia, fecha y hora, en
  `EVENTOS_TRAZABILIDAD`.
- Reasignar a otra dependencia conserva el historial de asignaciones anteriores.
- Al asignar se notifica a la dependencia por correo (n8n) indicando que debe entrar al panel.
- Estado resultante: `enviado`.
- Solo se puede asignar un radicado en estado `recibido` o reasignar uno `enviado` que aún
  no tiene respuesta; un radicado `respondido` o `anulado` no se reasigna.
- Las categorías "Spam / no aplica" y "Falta información" de n8n **no** asignan: el
  radicado queda en `recibido` para revisión manual de Recepción.

### Criterios de aceptación

```
Escenario: Envío manual por Recepción
Dado un radicado en estado "recibido" sin dependencia
Cuando Recepción lo asigna a "Talento Humano"
Entonces el radicado queda en "enviado" con dependencia "Talento Humano"
Y se registra un evento con el usuario de Recepción, la dependencia, fecha y hora
Y se dispara la notificación a la dependencia

Escenario: Asignación automática por n8n
Dado un radicado del portal con dependencia null
Cuando n8n envía la clasificación "Ingeniería" con su credencial de servicio
Entonces el radicado queda en "enviado" a "Ingeniería"
Y el evento registra "n8n" como autor

Escenario: Reasignación
Dado un radicado "enviado" a "Ingeniería" sin respuesta
Cuando Recepción lo reasigna a "Derecho"
Entonces queda asignado a "Derecho"
Y la trazabilidad muestra ambas asignaciones en orden

Escenario: Radicado ya respondido
Dado un radicado en estado "respondido"
Cuando se intenta reasignar
Entonces responde 409 CONFLICT

Escenario: Visibilidad
Dado un radicado enviado a "Derecho"
Cuando un usuario de "Ingeniería" consulta GET /api/v1/radicados/{id}
Entonces responde 404 (no se revela que existe)
```

### Contrato técnico

```
PATCH /api/v1/radicados/{id}/asignacion   (propuesto)
Auth: recepcion, administrador, o credencial de servicio de n8n
Request:  { "dependencia_id": 4, "motivo"?: "Reasignación: correspondía a Derecho" }
Response 200:
{
  "id_radicado": 4821,
  "numero_radicado": "…",
  "estado": "enviado",
  "dependencia_asignada": { "id_dependencia": 4, "nombre": "Derecho" }
}
Errores: 400 · 401 · 403 · 404 · 409 CONFLICT (estado no permite asignar)

Efectos: evento de trazabilidad + webhook a n8n "radicado_asignado".
```

La credencial de servicio de n8n es un token propio (no un JWT de usuario), guardado como
variable de entorno, con permiso solo para este endpoint y los que n8n necesite.

### Pruebas

| ID | Tipo | Verifica |
|---|---|---|
| T-HU006-01 | integración | Asignación manual → estado `enviado`, evento con autor, dependencia y fecha |
| T-HU006-02 | integración | Asignación por n8n con token de servicio → evento con autor `n8n` |
| T-HU006-03 | integración | Reasignación conserva ambos eventos en orden |
| T-HU006-04 | integración | Radicado `respondido`/`anulado` → 409 |
| T-HU006-05 | integración | Dependencia ajena → 404 en detalle y ausente en listado |
| T-HU006-06 | integración | Rol `dependencia` o `archivo_central` no puede asignar → 403 |
| T-HU006-07 | integración | Se emite el webhook a n8n (mock del receptor HTTP) |

### Frontend (panel interno)

En el detalle del radicado: selector de dependencia con búsqueda, botón "Enviar" /
"Reasignar" con motivo obligatorio al reasignar. Bandeja de Recepción con filtro
"Sin asignar" para lo que n8n dejó en revisión manual.

---

## HU-007 · Generar respuesta y notificar a Recepción y al solicitante

- **RF:** RF-002 · **Prioridad:** Alta · **Puntos:** 8
- **Historia:** Como funcionario de una dependencia, quiero generar la respuesta a una
  solicitud, relacionarla con su radicado de entrada y enviar copia a Recepción, Registro
  Académico y al solicitante, para que la trazabilidad y la historia académica queden
  completas.
- **Depende de:** HU-006, HU-003 (consecutivo de salida), HU-005 (adjuntos, Juan David).

### Reglas

- La respuesta queda relacionada con el radicado de entrada (`RESPUESTAS.radicado_id`) y
  recibe su propio consecutivo de tipo `enviada` (RF-003).
- RN-008: Recepción **verifica** la respuesta antes de notificar al solicitante.
  - Verificada → estado `respondido`, n8n (Flujo 2) notifica a Recepción y al solicitante
    por correo; copia a Registro Académico cuando aplique.
  - No verificada → estado `requiere_correccion`, vuelve a la dependencia.
- Solo la dependencia asignada responde; solo Recepción verifica.
- La respuesta del portal se entrega **solo por correo**.
- Cada paso (respuesta registrada, verificada, devuelta) es un evento de trazabilidad.
- También existe la salida independiente (sin radicado de entrada) del F-02; queda fuera de
  esta HU salvo que el equipo decida incluirla (ver "Inconsistencias").

### Estados involucrados (propuesta)

```
enviado ──(dependencia responde)──▶ pendiente_verificacion
pendiente_verificacion ──(Recepción verifica)──▶ respondido
pendiente_verificacion ──(Recepción devuelve)──▶ requiere_correccion
requiere_correccion ──(dependencia corrige)──▶ pendiente_verificacion
```

### Criterios de aceptación

```
Escenario: Registrar respuesta
Dado un radicado "enviado" a "Ingeniería"
Cuando un usuario de "Ingeniería" registra la respuesta con texto y un PDF adjunto
Entonces se crea la respuesta con consecutivo de tipo "enviada"
Y queda relacionada con el radicado de entrada
Y el radicado pasa a "pendiente_verificacion"
Y aparece en la bandeja de verificación de Recepción

Escenario: Recepción verifica
Dado un radicado en "pendiente_verificacion"
Cuando Recepción marca la respuesta como verificada
Entonces el radicado pasa a "respondido"
Y n8n recibe el webhook "respuesta_verificada" con el número de radicado
Y el solicitante recibe el correo con la respuesta

Escenario: Recepción devuelve
Dado un radicado en "pendiente_verificacion"
Cuando Recepción la marca como no verificada con una observación
Entonces el radicado pasa a "requiere_correccion"
Y la dependencia ve la observación
Y el solicitante no recibe ningún correo

Escenario: Dependencia ajena
Dado un radicado asignado a "Derecho"
Cuando un usuario de "Ingeniería" intenta responderlo
Entonces responde 404

Escenario: Estado inválido
Dado un radicado "respondido"
Cuando se intenta registrar otra respuesta
Entonces responde 409 CONFLICT
```

### Contrato técnico

```
PATCH /api/v1/radicados/{id}/respuesta    Auth: dependencia (la asignada)
Request (multipart/form-data):
  descripcion: "Se aprueba la homologación de MAT-101…"
  destinatario: "laura.rojas@correo.com"
  archivos[]: respuesta.pdf
Response 200:
{
  "id_radicado": 4821,
  "estado": "pendiente_verificacion",
  "respuesta": {
    "id_respuesta": 310,
    "numero_radicado_salida": "…",
    "verificada": false,
    "fecha_respuesta": "2026-09-25"
  }
}
Errores: 400 · 401 · 403 · 404 · 409 CONFLICT · 422

PATCH /api/v1/radicados/{id}/verificacion Auth: recepcion
Request:  { "verificada": true }  |  { "verificada": false, "observacion": "Falta firma" }
Response 200: { "id_radicado": 4821, "estado": "respondido" | "requiere_correccion" }
Errores: 400 (observación obligatoria si false) · 401 · 403 · 404 · 409

Efectos: evento de trazabilidad; webhook a n8n Flujo 2 solo cuando verificada = true.
```

Adjuntos por `multipart/form-data` en streaming (RNF-007), no en base64 dentro del JSON.

### Pruebas

| ID | Tipo | Verifica |
|---|---|---|
| T-HU007-01 | integración | Respuesta crea consecutivo `enviada` y la relaciona con la entrada |
| T-HU007-02 | integración | Estados: enviado → pendiente_verificacion → respondido |
| T-HU007-03 | integración | Devolución → requiere_correccion; sin webhook al solicitante |
| T-HU007-04 | integración | `verificada: false` sin observación → 400 |
| T-HU007-05 | integración | Dependencia ajena → 404; rol dependencia no puede verificar → 403 |
| T-HU007-06 | integración | Webhook a n8n solo al verificar (mock del receptor) |
| T-HU007-07 | integración | Cada transición deja un evento en `EVENTOS_TRAZABILIDAD` |

### Frontend (panel interno)

- Dependencia: en el detalle, formulario "Responder" (texto, destinatario prellenado,
  adjuntos con progreso). Si hay devolución, se muestra la observación de Recepción.
- Recepción: bandeja "Por verificar" con vista previa de la respuesta y botones
  "Verificar" / "Devolver con observación".

---

# Sprint 3 — semanas 12–13 · 26 puntos

Objetivo del sprint: trazabilidad, alertas de vencimiento, comité y consulta pública de
estado.

Orden sugerido: **HU-010 → HU-015 → HU-016 → HU-018**. La línea de tiempo (HU-010) es
la base de la vista de comité y de la consulta pública.

## HU-010 · Consultar en qué estado está un documento

- **RF:** RF-006 · **Prioridad:** Media · **Puntos:** 5
- **Historia:** Como funcionario de la dependencia, quiero consultar en qué estado está un
  documento, para responder qué pasó con esa comunicación sin buscarla físicamente.

### Reglas

- La línea de tiempo se construye con `EVENTOS_TRAZABILIDAD`, ordenada por fecha.
- Cada evento muestra fecha, hora, usuario (o `n8n` / `portal`), acción, estado anterior y
  estado nuevo.
- Los eventos no se editan ni se borran desde la aplicación.
- Visibilidad: Recepción, Archivo Central y Administrador ven cualquier radicado; una
  dependencia solo los que tiene o tuvo asignados.
- Todos los casos de uso que cambian estado (HU-006, HU-007, HU-016, anulación, etc.)
  escriben su evento en la misma transacción que el cambio.

### Criterios de aceptación

```
Escenario: Línea de tiempo completa
Dado un radicado recibido, enviado a "Ingeniería", respondido y verificado
Cuando un usuario autorizado consulta su trazabilidad
Entonces ve cuatro eventos en orden cronológico con fecha, hora, autor y estados

Escenario: Reasignaciones visibles
Dado un radicado reasignado de "Ingeniería" a "Derecho"
Cuando se consulta su trazabilidad
Entonces aparecen ambas asignaciones

Escenario: Dependencia sin relación
Dado un radicado que nunca estuvo asignado a "Salud"
Cuando un usuario de "Salud" consulta su trazabilidad
Entonces responde 404

Escenario: Inmutabilidad
Cuando cualquier usuario intenta modificar o borrar un evento
Entonces no existe endpoint para hacerlo
```

### Contrato técnico

```
GET /api/v1/radicados/{id}/eventos        (propuesto)
Auth: recepcion, dependencia (con relación), archivo_central, administrador
Response 200:
{
  "id_radicado": 4821,
  "numero_radicado": "…",
  "estado_actual": "respondido",
  "eventos": [
    { "fecha_evento": "2026-09-18T14:32:07Z", "accion": "radicado",   "estado_anterior": null,        "estado_nuevo": "recibido",  "autor": "portal" },
    { "fecha_evento": "2026-09-18T14:33:10Z", "accion": "asignado",   "estado_anterior": "recibido",  "estado_nuevo": "enviado",   "autor": "n8n", "detalle": "Ingeniería" }
  ]
}
Errores: 401 · 403 · 404
```

Nota de modelo: `EVENTOS_TRAZABILIDAD` en §4.1 no tiene autor. Agregar
`usuario_id` (FK opcional → USUARIOS) y `origen` (`usuario` | `n8n` | `portal` |
`sistema`), y guardar `fecha_evento` como marca de tiempo, no solo fecha.

### Pruebas

| ID | Tipo | Verifica |
|---|---|---|
| T-HU010-01 | integración | Flujo completo genera todos los eventos en orden |
| T-HU010-02 | integración | Autor correcto por origen (usuario, n8n, portal) |
| T-HU010-03 | integración | Dependencia sin relación → 404 |
| T-HU010-04 | integración | Un cambio de estado que falla no deja evento huérfano |

### Frontend (panel interno)

Pestaña "Trazabilidad" en el detalle del radicado: lista ordenada (`<ol>`) tipo línea de
tiempo, con icono y texto por acción, fecha en hora de Colombia y autor.

---

## HU-015 · Recibir alerta cuando un radicado esté por vencer

- **RF:** RF-015 · **Prioridad:** Alta · **Puntos:** 8
- **Historia:** Como funcionario de una dependencia, quiero recibir una alerta cuando un
  radicado esté por vencer su plazo de respuesta, para no dejarlo pasar y evitar que la
  responsabilidad recaiga en la universidad.
- **Depende de:** HU-019 (plazos).

### Reglas

- `fecha_limite` = fecha de radicación + `plazo_dias_habiles` del tipo de trámite, contando
  solo días hábiles (sin sábados, domingos ni festivos de Colombia).
- RN-010: máximo 15 días hábiles salvo plazo específico menor.
- Semáforo de 4 colores (verde / amarillo / naranja / rojo) según la proporción del plazo
  consumida. **Umbrales pendientes de definir** (ver "Inconsistencias"); propuesta:

  | Color | Condición (propuesta) |
  |---|---|
  | Verde | < 50 % del plazo consumido |
  | Amarillo | 50 %–79 % |
  | Naranja | ≥ 80 % y aún no vence |
  | Rojo | vencido |

- RN-005: la responsabilidad del plazo es de la dependencia, no del solicitante.
- Si el trámite espera comité (HU-016), la alerta lo indica: el retraso no es de la dependencia.
- Radicados `respondido` o `anulado` no generan alertas.
- Una tarea periódica recalcula el semáforo y crea `ALERTAS_VENCIMIENTO` al cambiar de
  color hacia naranja o rojo; notifica al responsable y, si corresponde, a Recepción.
- No se repite la misma alerta (mismo radicado y nivel) en cada ejecución.

### Criterios de aceptación

```
Escenario: Cálculo de fecha límite en días hábiles
Dado un tipo de trámite con plazo 10 días hábiles
Cuando se radica un viernes
Entonces la fecha límite salta sábados, domingos y festivos

Escenario: Paso a naranja
Dado un radicado "enviado" con el 80 % del plazo consumido
Cuando corre la tarea de alertas
Entonces el semáforo pasa a "naranja"
Y se crea una alerta de nivel "naranja"
Y se notifica a la dependencia asignada

Escenario: Vencido
Dado un radicado sin respuesta cuya fecha límite ya pasó
Cuando corre la tarea de alertas
Entonces el semáforo es "rojo" y se notifica a la dependencia y a Recepción

Escenario: Sin duplicados
Dado un radicado que ya tiene alerta "naranja"
Cuando la tarea corre otra vez sin cambio de nivel
Entonces no se crea otra alerta ni otro correo

Escenario: Espera de comité
Dado un radicado en estado "en_comite" próximo a vencer
Cuando se genera la alerta
Entonces el mensaje indica que el retraso corresponde a la espera del comité

Escenario: Radicado respondido
Dado un radicado "respondido"
Cuando corre la tarea de alertas
Entonces no se genera alerta
```

### Contrato técnico

```
Dominio (función pura, sin BD):
  calcularFechaLimite(fechaRadicacion: Date, plazoDiasHabiles: number, festivos: Date[]) → Date
  calcularSemaforo(fechaRadicacion, fechaLimite, ahora) → "verde" | "amarillo" | "naranja" | "rojo"

Tarea periódica (cron del backend o n8n llamando a la API):
  POST /api/v1/alertas/evaluar            (propuesto) Auth: credencial de servicio
  Response 200: { "evaluados": 312, "alertas_nuevas": 4 }

GET   /api/v1/alertas?atendida=false      (propuesto) Auth: panel (filtrado por dependencia)
PATCH /api/v1/alertas/{id}                (propuesto) { "atendida": true }
```

El semáforo se guarda en `RADICADOS.semaforo` para filtrar rápido (así lo define §4.1),
pero **la fuente de verdad es el cálculo**: la tarea lo recalcula y el detalle del
radicado lo calcula al vuelo para no mostrar un color desactualizado.

### Pruebas

| ID | Tipo | Verifica |
|---|---|---|
| T-HU015-01 | unitaria | `calcularFechaLimite` con fines de semana y festivos |
| T-HU015-02 | unitaria | `calcularSemaforo` en cada límite de umbral (49 %, 50 %, 79 %, 80 %, vencido) |
| T-HU015-03 | integración | La tarea crea alerta al subir de nivel y no la duplica |
| T-HU015-04 | integración | Respondidos y anulados excluidos |
| T-HU015-05 | integración | Mensaje de comité cuando el estado es `en_comite` |
| T-HU015-06 | integración | Una dependencia solo ve sus alertas |

### Frontend (panel interno)

Indicador de semáforo (color + texto) en la bandeja y el detalle; bandeja ordenada por
fecha límite; campana o sección "Alertas" con las no atendidas y acción "Marcar como
atendida".

---

## HU-016 · Llevar un trabajo de grado por estado de comité

- **RF:** RF-016 · **Prioridad:** Media · **Puntos:** 8
- **Historia:** Como funcionario de un programa académico, quiero llevar un trabajo de
  grado por el estado de revisión de requisitos y comité, para reflejar fielmente por qué su
  respuesta se demora más que otras solicitudes.
- **Depende de:** HU-019 (`requiere_comite`), HU-010, HU-007.

### Reglas

- Aplica solo a tipos de trámite con `requiere_comite = true` (RN-007).
- Flujo de estados:

```
enviado ──▶ en_revision_requisitos
en_revision_requisitos ──(cumple)──▶ en_comite
en_revision_requisitos ──(no cumple)──▶ rechazado_requisitos
en_comite ──(decisión registrada)──▶ respuesta (HU-007) ──▶ pendiente_verificacion
```

- Cualquier otra transición se rechaza con 409.
- La decisión del comité (aprobado / no aprobado, fecha de sesión, observación) se registra
  antes de generar la respuesta.
- `rechazado_requisitos` también requiere una respuesta al solicitante explicando qué falta.
- Cada cambio queda en la trazabilidad (HU-010) con autor.
- Solo la dependencia asignada mueve estos estados.

### Criterios de aceptación

```
Escenario: Paso a revisión de requisitos
Dado un radicado de "trabajo_grado" en estado "enviado"
Cuando la dependencia lo marca "en revisión de requisitos"
Entonces el estado cambia y queda el evento con autor y fecha

Escenario: Cumple requisitos
Dado un radicado en "en_revision_requisitos"
Cuando la dependencia indica que cumple
Entonces pasa a "en_comite"

Escenario: No cumple requisitos
Dado un radicado en "en_revision_requisitos"
Cuando la dependencia indica que no cumple con una observación
Entonces pasa a "rechazado_requisitos" sin pasar por comité

Escenario: Decisión del comité
Dado un radicado "en_comite"
Cuando la dependencia registra la decisión "aprobado" con fecha de sesión
Entonces se habilita "Responder" (HU-007) con la decisión precargada

Escenario: Tipo sin comité
Dado un radicado de "reingreso" (requiere_comite = false)
Cuando se intenta pasar a "en_revision_requisitos"
Entonces responde 409 CONFLICT

Escenario: Transición inválida
Dado un radicado "enviado" de "trabajo_grado"
Cuando se intenta pasar directo a "en_comite"
Entonces responde 409 CONFLICT
```

### Contrato técnico

```
PATCH /api/v1/radicados/{id}/estado       (propuesto)
Auth: dependencia (la asignada)
Request:
  { "estado": "en_revision_requisitos" }
  { "estado": "en_comite" }
  { "estado": "rechazado_requisitos", "observacion": "Falta paz y salvo financiero" }
Response 200: { "id_radicado": 4821, "estado": "en_comite" }
Errores: 400 · 401 · 403 · 404 · 409 CONFLICT (transición no permitida)

POST /api/v1/radicados/{id}/decision-comite   (propuesto)
Auth: dependencia (la asignada)
Request:  { "decision": "aprobado" | "no_aprobado", "fecha_sesion": "2026-11-05", "observacion"?: "…" }
Response 201
Errores: 409 si el radicado no está "en_comite"
```

Dominio: tabla de transiciones permitidas como constante, probada unitariamente; el
servicio la consulta antes de cualquier cambio de estado (la usan también HU-006 y HU-007).

Nota de modelo: hace falta dónde guardar la decisión del comité (tabla
`DECISIONES_COMITE` o campos en `RESPUESTAS`). No está en §4.1.

### Pruebas

| ID | Tipo | Verifica |
|---|---|---|
| T-HU016-01 | unitaria | Tabla de transiciones: todas las permitidas pasan, el resto falla |
| T-HU016-02 | integración | Flujo completo hasta respuesta; trazabilidad con cada estado |
| T-HU016-03 | integración | Rechazo por requisitos exige observación |
| T-HU016-04 | integración | Tipo sin comité → 409 |
| T-HU016-05 | integración | Decisión fuera de `en_comite` → 409 |
| T-HU016-06 | integración | Dependencia ajena → 404 |

### Frontend (panel interno)

En el detalle de radicados con comité: indicador de etapa (revisión → comité → respuesta),
botones según el estado actual, formulario de decisión del comité. El semáforo muestra
"En espera de comité" cuando aplica.

---

## HU-018 · Consultar el estado de mis trámites sin iniciar sesión

- **RF:** RF-018 · **Prioridad:** Media · **Puntos:** 5
- **Historia:** Como estudiante o solicitante externo, quiero consultar el estado de mi
  trámite desde el portal público sin iniciar sesión, para saber en qué va sin llamar ni ir
  a Recepción.
- **Depende de:** HU-017 (radicación desde el portal, Juan David), HU-010, HU-015.

### Reglas

- Sin inicio de sesión (ADR-004).
- La consulta exige **número de radicado y cédula juntos** (flujo 2 de §6.1). Con solo uno
  de los dos, cualquiera podría consultar trámites ajenos (Ley 1581).
- Si no coinciden, la respuesta es la misma que si no existiera: 404 genérico, sin revelar
  cuál de los dos datos falló.
- Solo se muestra: número, tipo de trámite, estado (en lenguaje para el ciudadano),
  semáforo y fecha límite. **No** se muestran la dependencia interna, nombres de
  funcionarios, observaciones internas ni el contenido de la respuesta (que llega solo por
  correo, RN-008).
- Límite de peticiones por IP (429) y CAPTCHA tras varios intentos fallidos.

### Criterios de aceptación

```
Escenario: Consulta válida
Dado un radicado "SGD-…" de la cédula 1075632481 en estado "en_comite"
Cuando el solicitante consulta con ese número y esa cédula
Entonces ve el estado "En revisión por comité", el semáforo y la fecha límite
Y no ve la dependencia ni observaciones internas

Escenario: Datos que no coinciden
Cuando consulta con un número existente y una cédula distinta
Entonces recibe 404 con el mismo mensaje que para un número inexistente

Escenario: Falta un dato
Cuando consulta solo con la cédula
Entonces recibe 400 VALIDATION_ERROR

Escenario: Abuso
Dado más de N consultas por minuto desde la misma IP
Cuando hace otra consulta
Entonces recibe 429 RATE_LIMITED

Escenario: Trámite respondido
Dado un radicado "respondido"
Cuando se consulta
Entonces el estado dice que la respuesta fue enviada al correo registrado
Y no se muestra el contenido de la respuesta
```

### Contrato técnico

```
GET /api/v1/radicados/estado?numero_radicado=SGD-2026-004821&cedula=1075632481
Auth: pública, con rate limiting

Response 200:
{
  "numero_radicado": "SGD-2026-004821",
  "tipo_tramite": "homologacion",
  "estado": "en_revision",
  "estado_texto": "Su solicitud está siendo revisada por la dependencia.",
  "semaforo": "verde",
  "fecha_limite": "2026-10-02"
}
Errores: 400 VALIDATION_ERROR · 404 NOT_FOUND (genérico) · 429 RATE_LIMITED
```

Recomendación de seguridad: pasar la consulta a `POST /api/v1/radicados/estado` con los
datos en el cuerpo, para que la cédula no quede en la URL (logs del servidor, del proxy y
del historial del navegador). El catálogo §5.3 la define como `GET`; cambiarlo requiere
actualizar ese catálogo.

Traducción de estados internos a texto ciudadano: tabla fija en el backend (por ejemplo
`pendiente_verificacion` y `requiere_correccion` se muestran ambos como "En revisión").

### Pruebas

| ID | Tipo | Verifica |
|---|---|---|
| T-HU018-01 | integración | Número + cédula correctos → 200 con solo los campos permitidos |
| T-HU018-02 | integración | Cédula incorrecta y número inexistente → misma respuesta 404 |
| T-HU018-03 | integración | Falta un parámetro → 400 |
| T-HU018-04 | integración | Rate limiting → 429 |
| T-HU018-05 | contrato | La respuesta nunca incluye `dependencia`, `observacion`, usuarios ni texto de la respuesta |
| T-HU018-06 | integración | Estados internos se traducen al texto ciudadano |

### Frontend (portal público)

Formulario "Consultar mi trámite" (número de radicado + cédula, CAPTCHA si aplica) y
tarjeta de resultado con estado, semáforo (color + texto) y fecha límite. Mensaje de error
genérico si no se encuentra.

---

# Inconsistencias a resolver con el equipo

Detectadas al documentar estas historias; no se resolvieron por cuenta propia.

| # | Tema | Detalle | Afecta |
|---|---|---|---|
| I-01 | Stack | El documento base define NestJS + Prisma + Supabase y dos apps React + Vite. El repo tiene instalados **Express 5** y **Next.js 16** en una sola app, y las skills `desarrollo`/`seguridad`/`testing` se escribieron sobre eso. Hay que decidir cuál manda y actualizar lo otro. | Todas |
| I-02 | Formato del consecutivo | §5.4 usa `SGD-2026-004821` (sin tipo); F-02 RF-003 pide contador por tipo. | HU-003 |
| I-03 | RF-018 vs F-02 | El F-02 firmado no tiene RF-018 ni RF-019, y RN-008 dice que el portal solo radica. Es un cambio de alcance: debe pasar por el control de cambios (numeral 10 del F-02). | HU-018, HU-019 |
| I-04 | Consulta por cédula **o** número | §5.3 dice "por cédula o número"; §6.1 dice "número + cédula". Se documentó con ambos obligatorios por seguridad. | HU-018 |
| I-05 | Umbrales del semáforo | RN-010 define 4 colores pero no los umbrales. | HU-015 |
| I-06 | Referencia errónea | §5.3 marca `PATCH /radicados/{id}/respuesta` como RF-013; corresponde a RF-002. | HU-007 |
| I-07 | Adjuntos en base64 | §5.4 envía archivos en base64 dentro del JSON; con paquetes de 100 MB (RNF-007) conviene `multipart/form-data` en streaming. | HU-007 |
| I-08 | Plazo de homologación | §5.4 muestra 10 días hábiles; el F-02 dice "hasta 15". | HU-019 |
| I-09 | Endpoints faltantes | No están en §5.3: asignación, eventos, estado/comité, decisión de comité, alertas. Se proponen aquí. | HU-006, 010, 015, 016 |
| I-10 | Campos faltantes en el modelo | `USUARIOS.nombre/activo`, contadores y tipo de documento, `TIPOS_TRAMITE.activo`, autor en `EVENTOS_TRAZABILIDAD`, decisión de comité. | HU-002, 003, 010, 016, 019 |
| I-11 | Salida independiente | El F-02 (RF-002) permite comunicaciones de salida sin radicado de entrada; el documento base no la menciona. | HU-007 |
