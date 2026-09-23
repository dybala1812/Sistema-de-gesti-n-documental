- [ ] GD-002: Resolver inconsistencias I-01…I-11 (stack, formato del consecutivo, RF-018/RF-019, umbrales del semáforo…)
  Spec: ia_contexto/spec/historias-juan-manuel.md#inconsistencias-a-resolver-con-el-equipo
  Prioridad: alta

- [ ] GD-003: Estructura base del backend (módulos, manejo de errores estándar, scripts dev/start/test, .env.example)
  Spec: .agents/skills/desarrollo/SKILL.md · REQUISITOS_DESARROLLO_SGD.md §5
  Prioridad: alta
  Depende de: GD-002

- [ ] GD-004: Configurar framework de pruebas en backend y frontend (D-07)
  Spec: .agents/skills/testing/SKILL.md
  Prioridad: alta

- [ ] GD-005: Esquema Prisma inicial y migraciones, incluidos los campos faltantes de I-10
  Spec: REQUISITOS_DESARROLLO_SGD.md §4 · historias-juan-manuel.md (notas de modelo)
  Prioridad: alta
  Depende de: GD-002

- [ ] GD-010: Iniciar sesión con usuario y contraseña (HU-001, RF-013) · 3 pts
  Spec: ia_contexto/spec/requirements.md#rf-013

- [ ] GD-011: Crear y administrar usuarios con rol (HU-002, RF-012) · 5 pts
  Spec: ia_contexto/spec/historias-juan-manuel.md#hu-002--crear-y-administrar-usuarios-con-rol
  Prioridad: alta
  Depende de: GD-011a

- [ ] GD-012: Generar el consecutivo del radicado automáticamente (HU-003, RF-003) · 5 pts
  Spec: ia_contexto/spec/historias-juan-manuel.md#hu-003--generar-el-consecutivo-del-radicado-automáticamente
  Prioridad: alta
  Depende de: GD-012a

- [ ] GD-013: Registrar los datos de una comunicación recibida (HU-004, RF-001) · 8 pts
  Spec: ia_contexto/spec/requirements.md#rf-001
  Depende de: GD-012

- [ ] GD-020: Adjuntar el documento escaneado/digital al radicado (HU-005, RF-004) · 5 pts

- [ ] GD-026: Configurar tipos de trámite y sus plazos (HU-019, RF-019) · 5 pts
  Spec: ia_contexto/spec/historias-juan-manuel.md#hu-019--configurar-tipos-de-trámite-y-sus-plazos
  Depende de: GD-026a

- [ ] GD-021: Enviar el radicado a la dependencia responsable (HU-006, RF-005) · 5 pts
  Spec: ia_contexto/spec/historias-juan-manuel.md#hu-006--enviar-el-radicado-a-la-dependencia-responsable
  Depende de: GD-021a

- [ ] GD-022: Generar respuesta y notificar a Recepción y solicitante (HU-007, RF-002) · 8 pts
  Spec: ia_contexto/spec/historias-juan-manuel.md#hu-007--generar-respuesta-y-notificar-a-recepción-y-al-solicitante
  Depende de: GD-022a

- [ ] GD-023: Buscar una persona por cédula y ver su historial (HU-008, RF-007) · 8 pts

- [ ] GD-024: Actualizar celular/correo de una persona (HU-009, RF-008) · 3 pts

- [ ] GD-025: Registrar revista/factura/paquete sin radicar (HU-014, RF-014) · 2 pts

- [ ] GD-030: Consultar en qué estado está un documento (HU-010, RF-006) · 5 pts
  Spec: ia_contexto/spec/historias-juan-manuel.md#hu-010--consultar-en-qué-estado-está-un-documento
  Depende de: GD-030a

- [ ] GD-034: Recibir alerta cuando un radicado esté por vencer (HU-015, RF-015) · 8 pts
  Spec: ia_contexto/spec/historias-juan-manuel.md#hu-015--recibir-alerta-cuando-un-radicado-esté-por-vencer
  Depende de: GD-034a
  Bloqueo: umbrales del semáforo (I-05) y festivos / días hábiles (P-03)

- [ ] GD-035: Llevar un trabajo de grado por estado de comité (HU-016, RF-016) · 8 pts
  Spec: ia_contexto/spec/historias-juan-manuel.md#hu-016--llevar-un-trabajo-de-grado-por-estado-de-comité
  Depende de: GD-035a

- [ ] GD-037: Consultar el estado de mis trámites sin iniciar sesión (HU-018, RF-018) · 5 pts
  Spec: ia_contexto/spec/historias-juan-manuel.md#hu-018--consultar-el-estado-de-mis-trámites-sin-iniciar-sesión
  Depende de: GD-037a

- [ ] GD-031: Filtrar radicados por fecha, tipo, dependencia o remitente (HU-011, RF-009) · 8 pts

- [ ] GD-032: Anular un documento con constancia del motivo (HU-012, RF-011) · 3 pts

- [ ] GD-033: Clasificar documentos en expedientes por serie documental (HU-013, RF-010) · 8 pts
  Bloqueo: definición de expediente y TRD (P-07)

- [ ] GD-036: Radicar mi propia solicitud desde el portal público (HU-017, RF-017) · 8 pts
  Bloqueo: P-01 (prellenado por cédula)

- [ ] GD-040: Prueba de carga del listado con 500 radicados (RNF-001)

- [ ] GD-041: Matriz rol × endpoint e inspección de contraseñas (RNF-002)

- [ ] GD-042: Prueba de usabilidad con un usuario real de Recepción (RNF-003)

- [ ] GD-043: Pruebas en Chrome y Edge, escritorio y celular (RNF-005)

- [ ] GD-044: Carga de paquete de 100 MB con operaciones concurrentes (RNF-007)