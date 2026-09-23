---
name: testing
description: Estrategia, comandos y criterio de verificación del Sistema de Gestión Documental. Úsala para saber cuándo una tarea está realmente lista y qué casos de prueba exige el F-02.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
---

# Testing — Sistema de Gestión Documental

## Estado actual

**Ningún paquete tiene framework de pruebas configurado.** El backend tiene el script
`test` por defecto de npm (`echo "Error: no test specified" && exit 1`). Elegir e instalar
las herramientas es una tarea del tablero y bloquea el cierre verificado de cualquier tarea
de backend: sin pruebas, "funciona" es una opinión.

Propuesta pendiente de aprobación (ver `ia_contexto/spec/decisiones.md`):

- Backend: Vitest o Jest + Supertest para endpoints, contra una BD de prueba real (no
  mocks del motor: la concurrencia del consecutivo solo se prueba con la BD de verdad).
- Frontend: Vitest + Testing Library para componentes con lógica; Playwright para los
  flujos de extremo a extremo críticos (radicar, portal público).

## Verificación mínima obligatoria, hoy

```bash
cd frontend_gestion_documental
npm run lint
npm run build
```

`npm run build` verifica tipos (`strict: true`): un error de tipos rompe el build, y así
debe seguir.

Backend: cuando existan los scripts, `npm test` (y lint si se configura). Hasta entonces,
como mínimo, el servidor debe arrancar sin errores y el endpoint tocado debe probarse con
una petición real (anotar la petición y la respuesta en el historial).

**No se cierra una tarea con pruebas que no se corrieron.** Si no se pudieron correr, la
tarea queda en `tareas-en-revision.md` con una línea `Bloqueo:` que diga por qué.

## Metas medibles del F-02 (RNF)

| RNF | Qué se prueba | Umbral |
|---|---|---|
| RNF-001 Rendimiento | Listado de radicados con 500 registros (algunos con adjuntos grandes) | < 3 s |
| RNF-002 Seguridad | Inspección de BD: contraseñas; matriz rol × endpoint | 0 en texto plano; 100 % de accesos sin permiso denegados |
| RNF-003 Usabilidad | Usuario real de Recepción, sin capacitación, radica un documento | < 5 min |
| RNF-004 Mantenibilidad | Cobertura unitaria en generador de consecutivos y control de permisos | ≥ 60 % |
| RNF-005 Compatibilidad | Chrome y Edge, 2 últimas versiones, escritorio y celular | sin errores visuales ni funcionales |
| RNF-006 Fiabilidad | Radicaciones simultáneas del mismo tipo; consulta de anulados | 0 duplicados; 100 % anulados consultables |
| RNF-007 Capacidad | Carga de un paquete de ≥ 100 MB con otras operaciones en curso | < 30 s sin degradar a los demás |

## Qué hay que probar, por orden de valor

### 1. Consecutivos (RF-003, RN-001, RNF-006) — lo más crítico

- N radicaciones **concurrentes** del mismo tipo → N números distintos y contiguos.
- Tipos distintos llevan contadores independientes.
- Cambio de año: el primer radicado del año nuevo es 1; los del año anterior no se
  reutilizan.
- Una transacción que falla después de pedir el número no deja un radicado a medias.
- Correspondencia sin consecutivo (RF-014) no consume número.

### 2. Permisos (RF-012, RF-013, RNF-002)

- Matriz completa rol × endpoint: cada combinación sin permiso responde 401/403.
- Dependencia A no puede ver ni responder radicados de la dependencia B (IDOR).
- Usuario deshabilitado no puede operar aunque tenga sesión abierta.
- Login con credenciales inválidas: mismo mensaje para usuario o contraseña erróneos.
- El portal público no puede llamar endpoints del panel.

### 3. Reglas de dominio (funciones puras)

- Cálculo de fecha límite por tipo de trámite y detección de "próximo a vencer" /
  "vencido" (RF-015), incluidos fines de semana y el caso de espera de comité (RF-016).
- Tabla de transiciones de estado: toda transición no permitida se rechaza.
- Anulación: documento no anulable se rechaza (RF-011); el anulado sigue consultable y no
  editable (RN-002).

### 4. Flujos completos (casos de la matriz de trazabilidad, numeral 8 del F-02)

| RF | Caso de prueba |
|---|---|
| RF-001 | Registrar comunicación de entrada → estado `recibido` y datos completos |
| RF-002 | Generar respuesta desde un radicado → ambos quedan relacionados; entrada pasa a `respondido` |
| RF-003 | Radicar dos documentos del mismo tipo a la vez → sin duplicados |
| RF-004 | Adjuntar un PDF → disponible para consulta; formato/tamaño inválido se rechaza con motivo |
| RF-005 | Enviar a dependencia → se registra quién, cuándo y a quién; reasignación conserva historial |
| RF-006 | Consultar un radicado → la línea de tiempo refleja todos los eventos |
| RF-007 | Buscar cédula existente → historial documental completo |
| RF-008 | Editar celular de una persona → queda registrado quién y cuándo |
| RF-009 | Filtros combinados → todos los resultados cumplen todos los criterios; sin resultados informa |
| RF-010 | Clasificar documento en expediente → consultable después |
| RF-011 | Anular → conserva estado `anulado` sin borrarse |
| RF-012 | Crear usuario con rol → solo accede a las funciones de ese rol |
| RF-013 | Login válido e inválido → comportamiento esperado en ambos |
| RF-014 | Registrar elemento sin consecutivo → no ocupa numeración |
| RF-015 | Solicitud próxima a vencer → la alerta se dispara en el momento configurado |
| RF-016 | Revisión de requisitos → comité → respuesta: la trazabilidad refleja cada estado |
| RF-017 | Radicar desde el portal con correo válido → mismo tipo de radicado que uno de Recepción |

### 5. Portal público

- Envío sin CAPTCHA válido se rechaza.
- Límite de peticiones por IP se aplica.
- La respuesta del portal nunca contiene datos de otra persona.

## Datos de prueba

Casos que suelen romper sistemas como este:

- dos usuarios radicando el mismo tipo en el mismo segundo;
- radicado creado el 31-dic a las 23:59 y otro el 1-ene a las 00:00;
- cédulas con ceros a la izquierda, con puntos o con guiones;
- persona sin correo o sin celular;
- archivo `.pdf` que en realidad no es PDF, archivo vacío, archivo de 100 MB;
- nombre de archivo con `../`, tildes, espacios y emojis;
- radicado reasignado varias veces;
- trámite de comité que espera semanas.

## Criterio para dar una tarea por lista

1. Lint y build del paquete tocado pasan.
2. Las pruebas del módulo tocado pasan (cuando existan).
3. El comportamiento coincide con el criterio Dado/Cuando/Entonces del requisito en
   `ia_contexto/spec/requirements.md` y con su caso de la tabla anterior.
4. La entrada de `historial.md` dice qué se ejecutó y el resultado **real**, no el esperado.
5. La matriz de trazabilidad se cierra en el documento de pruebas **F-05**: anota ahí (o
   en la tarea correspondiente) el caso ejecutado.

Si las pruebas fallan, se reporta que fallan, con la salida. Un resultado incómodo
informado a tiempo vale más que uno cómodo y falso.
