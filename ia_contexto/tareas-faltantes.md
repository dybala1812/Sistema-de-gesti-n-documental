# Tareas faltantes (backlog)

Organizado por sprint del F-02. Cada tarea cita su RF. Promover a `tareas-por-realizar.md`
solo con confirmación del usuario.

## Base (antes o al inicio del Sprint 1)

- [ ] GD-001: Obtener la firma del F-02 (numeral 9) y resolver las preguntas P-01…P-14
  Spec: ia_contexto/spec/decisiones.md
  Prioridad: alta
  Nota: sin firma no se avanza al siguiente hito.

- [ ] GD-002: Decidir BD, almacén de adjuntos, correo, CAPTCHA y hosting (D-04, D-09, D-10, D-11)
  Spec: ia_contexto/spec/decisiones.md
  Prioridad: alta

- [ ] GD-003: Estructura base del backend (src/, módulos, manejo de errores, scripts dev/start/test, .env.example)
  Spec: .agents/skills/desarrollo/SKILL.md
  Prioridad: alta
  Depende de: GD-002

- [ ] GD-004: Configurar framework de pruebas en backend y frontend (D-07)
  Spec: .agents/skills/testing/SKILL.md
  Prioridad: alta

- [ ] GD-005: Modelo de datos inicial y migraciones (usuarios, roles, dependencias, personas, radicados, contadores, eventos, auditoría)
  Spec: ia_contexto/spec/data-model.md (por crear)
  Prioridad: alta
  Depende de: GD-002

- [ ] GD-006: Layouts base del frontend: grupos (publico) y (panel), tokens de color en globals.css
  Spec: .agents/skills/frontend/
  Prioridad: media

## Sprint 1

- [ ] GD-010: Autenticación (RF-013, HU-001)
  Spec: ia_contexto/spec/requirements.md#rf-013
  Prioridad: alta

- [ ] GD-011: Administración de usuarios y roles (RF-012, HU-002)
  Spec: ia_contexto/spec/requirements.md#rf-012
  Prioridad: alta
  Depende de: GD-010

- [ ] GD-012: Servicio de consecutivos con prueba de concurrencia (RF-003, HU-003)
  Spec: ia_contexto/spec/requirements.md#rf-003
  Prioridad: alta

- [ ] GD-013: Registrar y radicar comunicación de entrada (RF-001, HU-004)
  Spec: ia_contexto/spec/requirements.md#rf-001
  Prioridad: alta
  Depende de: GD-012

## Sprint 2

- [ ] GD-020: Adjuntar documentos al radicado (RF-004, HU-005)
- [ ] GD-021: Enviar y reasignar radicado a dependencia (RF-005, HU-006)
- [ ] GD-022: Comunicación de salida relacionada y copias por correo (RF-002, HU-007)
- [ ] GD-023: Historial documental por cédula (RF-007, HU-008)
- [ ] GD-024: Registro y edición auditada de personas (RF-008, HU-009)
- [ ] GD-025: Correspondencia sin consecutivo (RF-014, HU-014)

## Sprint 3

- [ ] GD-030: Línea de tiempo del radicado (RF-006, HU-010)
- [ ] GD-031: Consultas con filtros combinados (RF-009, HU-011)
- [ ] GD-032: Anulación controlada (RF-011, HU-012)
- [ ] GD-033: Expedientes y clasificación en Archivo Central (RF-010, HU-013)
  Bloqueo: definición de expediente y TRD (P-07)
- [ ] GD-034: Alertas de vencimiento y configuración de plazos por trámite (RF-015, HU-015)
- [ ] GD-035: Flujo de aprobación por comité (RF-016, HU-016)
- [ ] GD-036: Portal público de autorradicación con CAPTCHA (RF-017, HU-017)
  Bloqueo: P-01 (prellenado por cédula)

## Verificación de RNF

- [ ] GD-040: Prueba de carga del listado con 500 radicados (RNF-001)
- [ ] GD-041: Matriz rol × endpoint e inspección de contraseñas (RNF-002)
- [ ] GD-042: Prueba de usabilidad con un usuario real de Recepción (RNF-003)
- [ ] GD-043: Pruebas en Chrome y Edge, escritorio y celular (RNF-005)
- [ ] GD-044: Carga de paquete de 100 MB con operaciones concurrentes (RNF-007)
